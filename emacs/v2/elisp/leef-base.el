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
(which-key-mode +1)
(use-package magit)
(use-package diminish)
(use-package s) ;; string manipulation
(use-package rg) ;; ripgrep


(global-unset-key (kbd "C-x c"))

;; Completion
;; Enable Vertico.
(use-package vertico
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Emacs minibuffer configurations.
(use-package emacs
  :custom
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))
;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

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
