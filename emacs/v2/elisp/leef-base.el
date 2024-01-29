;;; leef-base.el --- Base Config
;;; Commentary:
;; Bootstrap-y type things
;;; Code:

;; UI
(use-package zenburn-theme
  :config
  (load-theme 'zenburn t))
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq ring-bell-function 'ignore)
(setq inhibit-startup-screen t)
;;  y/n instead of yes/no
(fset 'yes-or-no-p 'y-or-n-p)

(require 'whitespace)
(setq whitespace-style '(face tabs empty trailing))

;; Default to visual line mode
(global-visual-line-mode)

;; Generic stuff
;; Show available key bindings in a pop up
(use-package which-key)
(use-package magit)
(use-package diminish)
(use-package s) ;; string manipulation

;; Helm
(use-package helm)
(use-package helm-projectile)
(use-package helm-descbinds)
(use-package helm-ag)
;;(require 'helm-config)
(require 'helm-projectile)
(require 'helm-eshell)


(setq helm-split-window-in-side-p           t
      helm-buffers-fuzzy-matching           t
      helm-move-to-line-cycle-in-source     t
      helm-ff-search-library-in-sexp        t
      helm-ff-file-name-history-use-recentf t)

(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-m") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-h f") 'helm-apropos)
(global-set-key (kbd "C-h r") 'helm-info-emacs)
(global-set-key (kbd "C-h C-l") 'helm-locate-library)

(define-key minibuffer-local-map (kbd "C-c C-l") 'helm-minibuffer-history)

(define-key isearch-mode-map (kbd "C-o") 'helm-occur-from-isearch)

;; shell history.
(define-key shell-mode-map (kbd "C-c C-l") 'helm-comint-input-ring)

;; use helm to list eshell history
(add-hook 'eshell-mode-hook
          #'(lambda ()
              (substitute-key-definition 'eshell-list-history 'helm-eshell-history eshell-mode-map)))

(substitute-key-definition 'find-tag 'helm-etags-select global-map)

(helm-descbinds-mode)
(helm-mode 1)

;; enable Helm version of Projectile with replacment commands
(helm-projectile-on)

;; Completion
(use-package company
  :bind (:map company-active-map
			  ("C-n" . company-select-next)
			  ("C-p" . company-select-previous))
  :config
  (setq company-tooltip-limit 20)                      ; bigger popup window
  (setq company-idle-delay .2)                         ; decrease delay before autocompletion popup shows
  (setq company-echo-delay 0)
  (setq company-minimum-prefix-length 1)
  (global-company-mode t))


;; misc
;; Always load newest byte code
;;(setq load-prefer-newer t)

;; warn when opening files bigger than 100MB
;;(setq large-file-warning-threshold 100000000)

(provide 'leef-base)
;;; leef-base.el ends here
