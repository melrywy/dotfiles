_ = require 'underscore-plus'
EditorState = require './editor-state'
Mark = require './../lib/mark'
{keydown, getEditorElement} = require './spec-helper'

describe "Mark", ->
  [editor, editorElement, cursor] = []

  beforeEach ->
    spyOn(_._, 'now').andCallFake -> window.now
    getEditorElement (element) ->
      editorElement = element
      editor = editorElement.getModel()
      cursor = editor.getLastCursor()

  describe ".for", ->
    it "returns the mark for the given cursor", ->
      EditorState.set(editor, "a[0]b[1]c")
      [cursor0, cursor1] = editor.getCursors()
      mark0 = Mark.for(cursor0)
      mark1 = Mark.for(cursor1)
      expect(mark0.cursor).toBe(cursor0)
      expect(mark1.cursor).toBe(cursor1)

    it "returns the same Mark each time for a cursor", ->
      mark = Mark.for(cursor)
      expect(Mark.for(cursor)).toBe(mark)

  describe "constructor", ->
    it "sets the mark to where the cursor is", ->
      EditorState.set(editor, ".[0]")
      mark = Mark.for(cursor)
      {row, column} = mark.getBufferPosition()
      expect([row, column]).toEqual([0, 1])

    it "deactivates and destroys the marker when the cursor is destroyed", ->
      EditorState.set(editor, "[0].")
      [cursor0, cursor1] = editor.getCursors()
      numMarkers = editor.getMarkerCount()

      cursor1 = editor.addCursorAtBufferPosition([0, 1])
      mark1 = Mark.for(cursor1)
      expect(editor.getMarkerCount()).toBeGreaterThan(numMarkers)

      cursor1.destroy()
      expect(mark1.isActive()).toBe(false)
      expect(editor.getMarkerCount()).toEqual(numMarkers)

  describe "set", ->
    # it "sets the mark position to where the cursor is", ->
    #   EditorState.set(editor, "[0].")
    #   mark = Mark.for(cursor)
    #
    #   cursor.setBufferPosition([0, 1])
    #   expect(mark.getBufferPosition().column).toEqual(0)
    #
    #   mark.set()
    #   expect(mark.getBufferPosition().column).toEqual(1)

    it "clears the active selection", ->
      EditorState.set(editor, "a(0)b[0]c")
      mark = Mark.for(cursor)
      expect(cursor.selection.getText()).toEqual('b')

      mark.set()
      expect(cursor.selection.getText()).toEqual('')

    it "returns the mark so we can conveniently chain an activate() call", ->
      mark = Mark.for(cursor)
      expect(mark.set()).toBe(mark)

  describe "activate", ->
    it "activates the mark", ->
      mark = Mark.for(cursor)
      mark.activate()
      expect(mark.isActive()).toBe(true)

    it "causes cursor movements to extend the selection", ->
      EditorState.set(editor, ".[0]..")
      Mark.for(cursor).activate()
      cursor.setBufferPosition([0, 2])
      expect(EditorState.get(editor)).toEqual(".(0).[0].")

    it "causes buffer edits to deactivate the mark", ->
      EditorState.set(editor, ".[0]..")
      mark = Mark.for(cursor)

      mark.set().activate()
      cursor.setBufferPosition([0, 2])
      expect(EditorState.get(editor)).toEqual(".(0).[0].")

      editor.setTextInBufferRange([[0, 1], [0, 2]], 'x')
      expect(mark.isActive()).toBe(false)
      expect(EditorState.get(editor)).toEqual(".x[0].")
      expect(cursor.selection.isEmpty()).toBe(true)

    it "doesn't deactive the mark if changes are indents", ->
      EditorState.set(editor, ".[0]..")
      mark = Mark.for(cursor)

      mark.set().activate()
      cursor.setBufferPosition([0, 2])
      expect(EditorState.get(editor)).toEqual(".(0).[0].")

      editor.indentSelectedRows()
      expect(mark.isActive()).toBe(true)
      expect(EditorState.get(editor)).toEqual("  .(0).[0].")
      expect(cursor.selection.isEmpty()).toBe(false)

    it "puts the editor into mark mode", ->
      EditorState.set(editor, ".[0]..")
      mark = Mark.for(cursor)

      mark.set().activate()
      editorElement = atom.views.getView(editor)
      expect(editorElement.classList.contains('mark-mode')).toBeTruthy()

    it 'even if a cursor moves, keep selection.',  ->
      mark = Mark.for(cursor)
      EditorState.set(editor, "aaa\n(0)bbb\nccc[0]")
      advanceClock(100)
      expect(mark.isActive()).toBe(true)
      keydown('n', ctrl: true)
      expect(EditorState.get(editor)).toEqual("aaa\n(0)bbb\nccc[0]")
      expect(cursor.selection.isEmpty()).toBe(false)

    it 'support merge selections', ->
      EditorState.set(editor, "[0]aaa 123\n[1]bbb 123\n[2]ccc 123")
      atom.commands.dispatch(editorElement, 'emacs-plus:set-mark')
      editor.selectRight(3)
      expect(EditorState.get(editor)).toEqual("(0)aaa[0] 123\n(1)bbb[1] 123\n(2)ccc[2] 123")
      expect(editor.getCursors().length).toBe(3)
      editor.selectDown()
      expect(EditorState.get(editor)).toEqual("(0)aaa 123\nbbb 123\nccc 123[0]")
      expect(editor.getCursors().length).toBe(1)

    it 'support multiple cursors', ->
      EditorState.set(editor, "[0]aaa\n[1]aaa\n[2]aaa")
      atom.commands.dispatch(editorElement, 'emacs-plus:set-mark')
      editor.selectRight(3)
      expect(EditorState.get(editor)).toEqual("(0)aaa[0]\n(1)aaa[1]\n(2)aaa[2]")

      editor.upperCase()
      expect(EditorState.get(editor)).toEqual("(0)AAA[0]\n(1)AAA[1]\n(2)AAA[2]")
      editor.lowerCase()
      expect(EditorState.get(editor)).toEqual("(0)aaa[0]\n(1)aaa[1]\n(2)aaa[2]")

  describe "deactivate", ->
    it "deactivates the mark", ->
      mark = Mark.for(cursor)
      mark.activate()
      expect(mark.isActive()).toBe(true)
      mark.deactivate()
      expect(mark.isActive()).toBe(false)

    it "clears the selection", ->
      EditorState.set(editor, "[0].")
      mark = Mark.for(cursor)
      mark.activate()
      cursor.setBufferPosition([0, 1])
      expect(cursor.selection.isEmpty()).toBe(false)

      mark.deactivate()
      expect(cursor.selection.isEmpty()).toBe(true)

  it "removes the mark mode from the editor", ->
    EditorState.set(editor, ".[0]..")
    mark = Mark.for(cursor)

    mark.set().activate()
    editorElement = atom.views.getView(editor)
    expect(editorElement.classList.contains('mark-mode')).toBeTruthy()
    mark.deactivate()
    expect(editorElement.classList.contains('mark-mode')).toBeFalsy()

  describe "exchange", ->
    # it "exchanges the cursor and mark", ->
    #   EditorState.set(editor, "[0].")
    #   mark = Mark.for(cursor)
    #   cursor.setBufferPosition([0, 1])
    #
    #   mark.exchange()
    #
    #   point = mark.getBufferPosition()
    #   expect([point.row, point.column]).toEqual([0, 1])
    #   point = cursor.getBufferPosition()
    #   expect([point.row,  point.column]).toEqual([0, 0])
    #
    # it "activates the mark & selection if it wasn't active", ->
    #   EditorState.set(editor, "[0].")
    #   mark = Mark.for(cursor)
    #   cursor.setBufferPosition([0, 1])
    #
    #   expect(EditorState.get(editor)).toEqual(".[0]")
    #   expect(mark.isActive()).toBe(false)
    #
    #   mark.exchange()
    #
    #   expect(EditorState.get(editor)).toEqual("[0].(0)")
    #   expect(mark.isActive()).toBe(true)

    it "leaves the mark & selection active if it already was", ->
      EditorState.set(editor, "[0].")
      mark = Mark.for(cursor)
      mark.activate()
      cursor.setBufferPosition([0, 1])

      expect(EditorState.get(editor)).toEqual("(0).[0]")
      expect(mark.isActive()).toBe(true)

      mark.exchange()

      expect(EditorState.get(editor)).toEqual("[0].(0)")
      expect(mark.isActive()).toBe(true)

  describe 'setBufferRange', ->
    mark = []
    beforeEach ->
      mark = Mark.for(cursor)

    it 'keep selection range', ->
      EditorState.set(editor, 'aaa b[0]bb ccc')
      atom.commands.dispatch(editorElement, 'editor:select-word')
      expect(EditorState.get(editor)).toEqual('aaa (0)bbb[0] ccc')

      advanceClock(100)
      expect(mark.isActive()).toBe(true)

      keydown('f', ctrl: true)
      expect(EditorState.get(editor)).toEqual('aaa (0)bbb [0]ccc')

      EditorState.set(editor, 'aaa b(0)b[0]b ccc')
      advanceClock(100)
      expect(mark.isActive()).toBe(true)
      atom.commands.dispatch(editorElement, 'editor:select-word')
      expect(EditorState.get(editor)).toEqual('aaa (0)bbb[0] ccc')

      advanceClock(100)
      expect(mark.isActive()).toBe(true)

      keydown('f', ctrl: true)
      expect(EditorState.get(editor)).toEqual('aaa (0)bbb [0]ccc')

    it 'reversed', ->
      EditorState.set(editor, 'aaa bbb[0] ccc')
      atom.commands.dispatch(editorElement, 'core:select-left')
      expect(EditorState.get(editor)).toEqual('aaa bb[0]b(0) ccc')

      advanceClock(100)
      expect(mark.isActive()).toBe(true)

      atom.commands.dispatch(editorElement, 'core:select-left')
      atom.commands.dispatch(editorElement, 'core:select-left')
      expect(EditorState.get(editor)).toEqual('aaa [0]bbb(0) ccc')
