;;; leef-eglot.el --- Settings for eglot  -*- lexical-binding: t; -*-
;;
;; Author: leef

;;; Code:

;; eglot is built into Emacs 29+, so no :ensure.
(use-package eglot
  :ensure nil
  :config
  ;; Don't keep servers around once their last buffer is gone.
  (setq eglot-autoshutdown t)
  ;; Let xref jump into files outside the project (stdlib, deps).
  (setq eglot-extend-to-xref t)
  ;; Block briefly on connect so the first command doesn't race the server.
  (setq eglot-sync-connect 1)
  ;; Logging every JSON event is a noticeable drag with gopls.
  (setq eglot-events-buffer-config '(:size 0 :format full))

  ;; Navigation (M-. M-, M-?) is already bound globally by xref, so only bind
  ;; the eglot commands that have no default binding of their own.
  (define-key eglot-mode-map (kbd "C-c C-l r") 'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c C-l e") 'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c C-l i") 'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c C-l =") 'eglot-format-buffer)
  (define-key eglot-mode-map (kbd "C-c C-l x") 'eglot-reconnect)
  (define-key eglot-mode-map (kbd "C-c C-d") 'eldoc-doc-buffer))

;; Diagnostics: eglot speaks flymake, but flycheck 38+ bridges them via
;; `global-flycheck-eglot-mode'. Configured alongside flycheck in leef-code.el.

(use-package consult-eglot
  :after eglot
  :bind (:map eglot-mode-map
              ("C-c C-g" . consult-eglot-symbols)
              ("C-c C-f" . consult-imenu)))

;; cedar
(define-derived-mode cedar-mode prog-mode "Cedar"
  "Major mode for Cedar policy files."
  (setq-local comment-start "//")
  (setq-local comment-end "")
  (setq-local font-lock-defaults
              '((("\\<\\(permit\\|forbid\\|when\\|unless\\|in\\|is\\|has\\|like\\|if\\|then\\|else\\|true\\|false\\)\\>" . font-lock-keyword-face)
                 ("\\<\\([A-Z][A-Za-z0-9_]*\\)::[A-Za-z0-9_:\"]*" . font-lock-type-face)
                 ("\"[^\"]*\"" . font-lock-string-face)
                 ("\\(principal\\|action\\|resource\\|context\\)\\>" . font-lock-variable-name-face)
                 ("//.*$" . font-lock-comment-face)))))
(add-to-list 'auto-mode-alist '("\\.cedar\\'" . cedar-mode))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(cedar-mode . ("cedar-language-server"))))
(add-hook 'cedar-mode-hook #'eglot-ensure)

;; templ needs no setup here: templ-ts-mode registers ("templ" "lsp") with
;; eglot-server-programs itself.

(provide 'leef-eglot)
;;; leef-eglot.el ends here
