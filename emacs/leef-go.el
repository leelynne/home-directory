;;; leef-go.el --- Settings for go
;;
;; Author: leef

;;; Code:

;; Additions to prelude-go module
(prelude-require-packages '(go-dlv go-guru go-rename))

(require 'prelude-go)
(require 'lsp-go)
(add-hook 'go-mode-hook #'lsp)
(add-hook 'go-mode-hook (lambda ()
                          (whitespace-toggle-options '(tabs))
                          (subword-mode +1)
                          (setq gofmt-command "goimports")
                          (add-hook 'before-save-hook 'gofmt-before-save)
                          ;;(add-hook 'before-save-hook #'lsp-format-buffer)
                          ;;(add-hook 'before-save-hook #'lsp-organize-imports)
                          (set (make-local-variable 'company-backends) '(company-go))
                          ;;(setq gofmt-command "goimports") ;; Use goimports with is gofmt + automatic include adding/removing
                          ;;(add-hook 'before-save-hook 'gofmt-before-save)
                          (local-set-key (kbd "M-.") 'lsp-ui-peek-find-definitions)
                          (local-set-key (kbd "<C-tab>") 'company-lsp)

;;; leef-go.el ends here
