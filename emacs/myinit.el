;;; myinit.el --- my crap
;;; Commentary:
;;
;;; Code:

(prelude-require-packages '(ac-helm ac-inf-ruby company company-go auto-complete ecb go-autocomplete go-mode go-dlv go-guru go-projectile go-rename flymake-ruby flymake-cursor puppet-mode mustache-mode enh-ruby-mode robe  rjsx-mode terraform-mode company-terraform helm-lsp lsp-java dap-mode treemacs treemacs-lsp treemacs-magit treemacs-projectile treemacs-icons-dired))

;; Auto-complete stuff
(require 'auto-complete-config)
(require 'ac-helm)
(require 'ac-inf-ruby)

(eval-after-load 'auto-complete
  '(add-to-list 'ac-modes 'inf-ruby-mode))
(add-hook 'inf-ruby-mode-hook 'ac-inf-ruby-enable)
(ac-config-default)
(ac-set-trigger-key "TAB")

;; Generic company mode improvements
(require 'company)
(setq company-tooltip-limit 20)                      ; bigger popup window
(setq company-idle-delay .3)                         ; decrease delay before autocompletion popup shows
(setq company-echo-delay 0)

;; Go
;; Mostly relying on prelude's go module now
;;(require 'go-mode)
;;(require 'company-go)
(require 'lsp-mode)
(require 'company-lsp)
(push 'company-lsp company-backends)
(setq lsp-enable-snippet nil)

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
                          ))

;; Java
(require 'lsp-java)
(add-hook 'java-mode-hook #'lsp)
(add-hook 'java-mode-hook (lambda ()
                            ;; Spaces for tabs
                            (setq-default indent-tabs-mode nil)
                            ))

;; JCS
(require 'rjsx-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))

;; PHP
;;(require 'php-mode)
;;(setq flycheck-phpcs-standard "~/styles/phprules.xml")
;;(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))
;;(add-hook 'php-mode-hook (lambda ()
;; stop whitespace being highlighted
;;                           (setq indent-tabs-mode t)
;;                           (whitespace-toggle-options '(tabs))
;;                           (local-set-key [f5] 'my-php-debug)
;;                           (php-eldoc-enable)
;;                           ))
;; Debug a simple PHP script.
;; Change the session key my-php-54 to any session key text you like
(defun my-php-debug ()
  "Run current PHP script for debugging with geben."
  (interactive)
  (call-interactively 'geben)
  (shell-command
   (concat "XDEBUG_CONFIG='idekey=my-php-55' /usr/bin/php "
           (buffer-file-name) " &"))
  )

;; scala
;; (require 'ensime)
;; (add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

;; python
(add-hook 'python-mode-hook 'anaconda-mode)
(add-hook 'python-mode-hook (lambda ()
                              (local-set-key (kbd "<C-tab>") 'company-complete)
                              ))

;; Steal flyspell bindings for flycheck
(require 'flycheck)
(global-flycheck-mode)
(require 'lsp-ui-flycheck)
(setq lsp-prefer-flymake nil)
(define-key flycheck-mode-map (kbd "C-,") #'flycheck-previous-error)
(define-key flycheck-mode-map (kbd "C-.") #'flycheck-next-error)

;; Helm good
(require 'prelude-helm-everywhere)
(require 'helm-lsp)

(setq-default tab-width 4)
(setq default-tab-width 4)
(global-company-mode t)

(setq whitespace-line-column 200)
;; Don't stop on first "error"
(setq compilation-scroll-output 1)

;; Use visual-line-mode in gfm-mode
(defun my-gfm-mode-hook ()
  "Use the 'marked' tool to display github flavored markdown."
  (setq markdown-command "marked --gfm"))
(add-hook 'gfm-mode-hook 'my-gfm-mode-hook)

;;; myinit.el ends here
