;;; leef-go.el --- Settings for go
;;
;; Author: leef

;;; Code:

;; Additions to prelude-go module
(prelude-require-packages '(go-dlv go-rename))

;;(require 'prelude-go)
(require 'lsp-go)
(add-hook 'go-mode-hook #'lsp)
(add-hook 'go-mode-hook (lambda ()
                          (add-hook 'before-save-hook #'lsp-format-buffer t t)
                          (add-hook 'before-save-hook #'lsp-organize-imports t t)
                          ;; stop whitespace being highlighted
                          (whitespace-toggle-options '(tabs))
                          ;; CamelCase aware editing operations
                          (subword-mode +1)
                          ;; lsp-ui
                          (setq lsp-ui-doc-delay 2) ;; slow down
                          (setq lsp-headerline-breadcrumb-enable t)
                          (setq lsp-headerline-breadcrumb-segments '(path-up-to-project symbols))
                          ;; keys
                          (local-set-key (kbd "M-.") 'lsp-ui-peek-find-definitions)
                          (local-set-key (kbd "M-/") 'lsp-ui-peek-find-references)
                          (local-set-key (kbd "<C-tab>") 'company-capf)
                          (local-set-key (kbd "C-c C-f") 'helm-lsp-workspace-symbol)
                          (local-set-key (kbd "C-c C-d") 'lsp-ui-doc-show)
                          ))

;;; leef-go.el ends here
