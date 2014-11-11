;; -*- Mode: Emacs-Lisp ; Coding: utf-8 -*-
(require 'smartchr)
(global-set-key (kbd "=") (smartchr '("=" " = " " == ")))
(global-set-key (kbd "'") (smartchr '("'`!!''" "'''`!!''''" "'")))
(global-set-key (kbd "\"") (smartchr '("\"`!!'\"" "\"")))
(global-set-key (kbd "(") (smartchr '("(`!!')" "(")))
(global-set-key (kbd "{") (smartchr '("{`!!'}" "{{ `!!' }}" "{% `!!' %}" "{# `!!' #}" "{")))
(global-set-key (kbd "[") (smartchr '("[`!!']" "[")))
(global-set-key (kbd "C") (smartchr '("C" "class `!!'():")))
(global-set-key (kbd "D") (smartchr '("D" "Debug.Log(`!!');")))
(global-set-key (kbd "A") (smartchr '("A" "<a href=\"`!!'\"></a>")))
(global-set-key (kbd "H") (smartchr '("H" "<h1>`!!'</h1>" "<h2>`!!'</h2>" "<h3>`!!'</h3>" "<h4>`!!'</h4>" "<h5>`!!'</h5>")))
(global-set-key (kbd "B") (smartchr '("B" "<br />" "BB" "back_button" "button_480" "button_320" "button_240")))
(global-set-key (kbd "<") (smartchr '("<`!!'>" "<" "&lt;")))
(global-set-key (kbd ">") (smartchr '(">" "&gt;")))
(global-set-key (kbd "&") (smartchr '("&" "&amp;" "&&")))
