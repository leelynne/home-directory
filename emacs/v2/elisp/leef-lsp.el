;;; leef-lsp.el --- Settings for lsp
;;
;; Author: leef

;;; Code:

;; Additions to prelude-lsp module
(use-package lsp-mode
  :config
  (setq lsp-enable-snippet nil))

(use-package lsp-ui
  :config
  (setq lsp-ui-imenu-auto-refresh t
		lsp-ui-sideline-enable t
		lsp-ui-doc-enable t
		lsp-ui-peek-enable t
		lsp-ui-peek-always-show t
		lsp-ui-imenu-auto-refresh t
		lsp-ui-sideline-actions-icon nil))

;; TODO: lsp-treemacs doesn't pick these up from the treemacs configuration correctly for some unknown reason
(setq treemacs-width 50)
(setq treemacs-position 'right)

(use-package lsp-treemacs
  :after (treemacs)
  :config
  (setq	lsp-treemacs-sync-mode 1))

(use-package dap-mode)

(use-package consult-lsp)

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
(define-key lsp-ui-mode-map (kbd "C-c C-f") 'consult-lsp-file-symbols)
(define-key lsp-ui-mode-map (kbd "C-c C-g") 'consult-lsp-symbols)

;; templ
(add-to-list 'lsp-language-id-configuration '(".*\\.templ$" . "templ"))
(lsp-register-client (make-lsp-client
                      :new-connection (lsp-stdio-connection '("templ" "lsp" "-goplsRPCTrace"))
                      :activation-fn (lsp-activate-on "templ")
                      :server-id 'templ))
(provide 'leef-lsp)
;;; leef-lsp.el ends here
