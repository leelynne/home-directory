;;; leef-go.el --- Settings for go
;;
;; Author: leef

;;; Code:

;; Additions to prelude-go module
(prelude-require-packages '(go-dlv go-rename))

(require 'prelude-go)
(require 'lsp-go)
(add-hook 'go-mode-hook #'lsp)
(add-hook 'go-mode-hook (lambda ()
                          ;;(add-hook 'before-save-hook #'lsp-format-buffer)
                          (setq lsp-ui-doc-delay 2) ;; slow down
                          (local-set-key (kbd "M-.") 'lsp-ui-peek-find-definitions)
                          (local-set-key (kbd "M-/") 'lsp-ui-peek-find-references)
                          (local-set-key (kbd "<C-tab>") 'company-lsp)
                          (local-set-key (kbd "C-h f") 'lsp-ui-doc-show)
                          ))

;;; leef-go.el ends here
