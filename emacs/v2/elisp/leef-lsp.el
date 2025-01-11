;;; leef-lsp.el --- Settings for lsp
;;
;; Author: leef

;;; Code:

;; Additions to prelude-lsp module
(use-package lsp-mode)
(use-package lsp-ui)
(use-package helm-lsp)
(use-package lsp-treemacs)
(use-package dap-mode)

;;(require 'lsp-ui)
(require 'lsp-ui-imenu)
(require 'lsp-mode)
(require 'dap-mode)

;; lsp-ui bindings and settings
(define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
(define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
(define-key lsp-ui-mode-map (kbd "C-c C-l .") 'lsp-ui-peek-find-definitions)
(define-key lsp-ui-mode-map (kbd "M-.") 'lsp-ui-peek-find-definitions)
(define-key lsp-ui-mode-map (kbd "C-c C-l ?") 'lsp-ui-peek-find-references)
(define-key lsp-ui-mode-map (kbd "M-/") 'lsp-ui-peek-find-references)
(define-key lsp-ui-mode-map (kbd "C-c C-l r") 'lsp-rename)
(define-key lsp-ui-mode-map (kbd "C-c C-l x") 'lsp-workspace-restart)
(define-key lsp-ui-mode-map (kbd "C-c C-l w") 'lsp-ui-peek-find-workspace-symbol)
(define-key lsp-ui-mode-map (kbd "C-c C-l i") 'lsp-ui-peek-find-implementation)
(define-key lsp-ui-mode-map (kbd "C-c C-l d") 'lsp-describe-thing-at-point)
(define-key lsp-ui-mode-map (kbd "C-c C-l e") 'lsp-execute-code-action)
(define-key lsp-ui-mode-map (kbd "C-c C-d") 'lsp-ui-doc-show)
(define-key lsp-ui-mode-map (kbd "C-c C-u") 'lsp-ui-doc-focus-frame)
(define-key lsp-ui-mode-map (kbd "C-c C-f") 'helm-lsp-workspace-symbol)


(setq lsp-ui-sideline-enable t)
(setq lsp-ui-doc-enable t)
(setq lsp-ui-peek-enable t)
(setq lsp-ui-peek-always-show t)

(setq lsp-enable-snippet nil)
(setq lsp-ui-sideline-actions-icon nil)

(setq lsp-treemacs-sync-mode 1)

;; templ
(add-to-list 'lsp-language-id-configuration '(".*\\.templ$" . "templ"))
(lsp-register-client (make-lsp-client
                      :new-connection (lsp-stdio-connection '("templ" "lsp" "-goplsRPCTrace"))
                      :activation-fn (lsp-activate-on "templ")
                      :server-id 'templ))
(provide 'leef-lsp)
;;; leef-lsp.el ends here
