;;; leef-go.el --- Settings for go  -*- lexical-binding: t; -*-
;;
;; Author: leef

;;; Code:

(use-package go-mode)
(use-package go-dlv)
(use-package go-rename)
(use-package go-guru)

;; Debug adapter client; replaces dap-mode, which depends on lsp-mode.
(use-package dape)

;; eglot has no non-interactive organize-imports, so drive the code action
;; directly. Guarded because a save can land before gopls has attached.
(defun leef/eglot-organize-imports ()
  "Apply the LSP organize-imports code action to the whole buffer."
  (when (and (bound-and-true-p eglot--managed-mode)
             (eglot-server-capable :codeActionProvider))
    (ignore-errors
      (eglot-code-action-organize-imports (point-min) (point-max)))))

(dolist (hook '(go-mode-hook go-ts-mode-hook))
  (add-hook hook #'eglot-ensure)
  (add-hook hook (lambda ()
                   ;; imports first, then format, matching gofmt/goimports order
                   (add-hook 'before-save-hook #'leef/eglot-organize-imports t t)
                   (add-hook 'before-save-hook #'eglot-format-buffer t t)
                   ;; stop whitespace being highlighted
                   (whitespace-toggle-options '(tabs))
                   ;; CamelCase aware editing operations
                   (subword-mode +1)
                   (local-set-key (kbd "<C-tab>") 'company-capf))))

(provide 'leef-go)
;;; leef-go.el ends here
