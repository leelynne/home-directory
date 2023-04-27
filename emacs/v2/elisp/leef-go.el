;;; leef-go.el --- Settings for go
;;
;; Author: leef

;;; Code:

(use-package go-mode)
(use-package go-dlv)
(use-package go-rename)
(use-package go-projectile)

(require 'lsp-go)
(require 'dap-dlv-go)
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
                          (local-set-key (kbd "<C-tab>") 'company-capf)
;;                          (nlinum-mode t)
                          ))

(provide 'leef-go)
;;; leef-go.el ends here
