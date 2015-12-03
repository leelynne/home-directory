;;; myinit.el --- my crap
;;; Commentary:
;;
;;; Code:

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
(require 'go-mode)
(require 'company-go)
;; Map code jumping to tags
(add-hook 'go-mode-hook (lambda ()
                          (local-set-key (kbd "M-.") 'godef-jump)
                          (local-set-key (kbd "<C-tab>") 'company-complete)
                          (local-set-key (kbd "C-c C-r") 'go-rename)
                          ;; Company mode rulz
                          (auto-complete-mode 0)))
;; Use goimports with is gofmt + automatic include adding/removing
(setq gofmt-command "goimports")

;; Java
;; Eclim
(custom-set-variables
 '(eclim-eclipse-dirs '("~/apps/eclipse"))
 '(eclim-executable "~/apps/eclipse/eclim")
 '(eclimd-default-workspace "~/eclipsews")
)

(require 'eclim)
(global-eclim-mode)
(require 'eclimd)

(require 'company-emacs-eclim)
(company-emacs-eclim-setup)
(global-company-mode t)

(add-hook 'java-mode-hook (lambda ()
                          (local-set-key (kbd "M-.") 'eclim-java-find-declaration)
                          (local-set-key (kbd "<C-tab>") 'company-complete)
                          (local-set-key (kbd "C-S-o") 'eclim-java-import-organize)
                          ;; eclim mode always on for java
                          (eclim-mode t)
                          ;; Company mode rulz
                          (auto-complete-mode 0)
                          ;; Show error message is echo buffer
                          (setq help-at-pt-display-when-idle t)
                          (setq help-at-pt-timer-delay 0.1)
                          (help-at-pt-set-timer)
                          ;; Start the daemon
                          (start-eclimd "~/eclipsews")
))

;; PHP
(require 'php-mode)
(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))
(add-hook 'php-mode-hook (lambda ()
                           ;; stop whitespace being highlighted
                           (setq indent-tabs-mode t)
                           (whitespace-toggle-options '(tabs))
                           (local-set-key [f5] 'my-php-debug)
                           ))
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
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

;; Steal flyspell bindings for flycheck
(require 'flycheck)
(define-key flycheck-mode-map (kbd "C-,") #'flycheck-previous-error)
(define-key flycheck-mode-map (kbd "C-.") #'flycheck-next-error)

(setq default-tab-width 4)

(when window-system (set-frame-size (selected-frame) 160 48))

(setq whitespace-line-column 200)
;; Don't stop on first "error"
(setq compilation-scroll-output 1)
;;; myinit.el ends here
