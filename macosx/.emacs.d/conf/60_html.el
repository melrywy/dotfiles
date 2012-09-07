;; -*- Mode: Emacs-Lisp ; Coding: utf-8 -*-

(require 'zencoding-mode)
(add-hook 'html-helper-mode-hook 'zencoding-mode) ;; Auto-start on any markup modes
(define-key zencoding-mode-keymap [s-return] 'zencoding-expand-line)
(define-key zencoding-mode-keymap [C-return] 'find-file)

;; html-helper-mode
;; http://www.santafe.edu/~nelson/tools/
;; http://www.santafe.edu/~nelson/tools/html-helper-mode.el
;; http://www.santafe.edu/~nelson/tools/tempo.el
(add-hook 'html-helper-load-hook '(lambda () (require 'html-font)))
(autoload 'html-helper-mode "html-helper-mode" "Yay HTML" t)
(setq auto-mode-alist 
      (append '(("\\.html?$" . html-helper-mode)
                ("\\.thtml?$" . html-helper-mode)
                ("\\.xhtml?$" . html-helper-mode)
                ("\\.tpl?$" . html-helper-mode)
                ("\\.tmpl?$" . html-helper-mode)
                ("\\.ctp?$" . html-helper-mode)
                ("\\.mt?$" . html-helper-mode)
                ("\\.tt?$" . html-helper-mode)
                ) auto-mode-alist))

;; change sequence face
(make-face 'my-sequence-face)
(set-face-foreground 'my-sequence-face "blue")
(set-face-background 'my-sequence-face "bisque")
(setq html-tt-sequence-face 'my-sequence-face)

(defvar html-helper-new-buffer-template
  '(html-helper-htmldtd-version
    "<html> <head>\n"
    "<title>" p "</title>\n</head>\n\n"
    "<body>\n"
    "<h1>" p "</h1>\n\n"
    p
    "\n\n<hr>\n"
    "<address>" html-helper-address-string "</address>\n"
    html-helper-timestamp-start
    html-helper-timestamp-end
    "\n</body> </html>\n")
  "*Template for new buffers.
Inserted by `html-helper-insert-new-buffer-strings' if
`html-helper-build-new-buffer' is set to t")