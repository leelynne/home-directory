;;; leef-editor.el --- Editor-ish based settings
;;
;; Author: leef

;;; Code:

;; Tabby tabs
(setq-default tab-width 4)
(setq default-tab-width 4)
(setq js-indent-level 4)

(visual-line-mode t)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;;(defvar savefile-dir (expand-file-name "savefile" user-emacs-directory)
;;  "For automatically generated save/history-files.")

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

(use-package flyspell
  :config
  (setq ispell-program-name "aspell" ; use aspell instead ofispell
		ispell-extra-args '("--sug-mode=ultra")))
(use-package consult-flyspell)

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/repos/"))
  :config
  (define-key projectile-mode-map (kbd "C-c C-p") 'projectile-command-map)
  (global-set-key (kbd "C-c p") 'projectile-command-map)
;;  (setq projectile-cache-file (expand-file-name  "projectile.cache" savefile-dir))
  (projectile-mode +1))


(use-package consult-projectile)

;; saveplace remembers your location in a file when saving files
;;(setq save-place-file (expand-file-name "saveplace" savefile-dir))
;; activate it for all buffers
;;(save-place-mode 1)

;; anzu-mode enhances isearch & query-replace by showing total matches and current match position
(use-package anzu
  :diminish anzu-mode
  :bind (("M-%" . anzu-query-replace)
		 ("C-M-%" . anzu-query-replace-regexp))
  :config 
  (global-anzu-mode))

(use-package savehist
  :init
  :config
  (setq savehist-autosave-interval 60)
  (add-to-list 'savehist-additional-variables 'search-ring)
  (savehist-mode))

;; recent files
(use-package recentf
  :init
  :config
  (setq recentf-max-saved-items 500)
  (setq recentf-max-menu-items 15)
  (setq recentf-auto-cleanup 'never)
  (recentf-mode))

;; undo
(use-package undo-tree
  :diminish undo-tree
  :config
  (setq undo-tree-history-directory-alist
	`((".*" . ,temporary-file-directory)))
    ;; autosave the undo-tree history
  (setq undo-tree-auto-save-history t)
  (global-undo-tree-mode)
  )

;; automatically save buffers associated with files on buffer switch
;; and on windows switch
(use-package super-save
  :diminish super-save-mode
  :config
  (super-save-mode +1))

;; Suppot .editorconfig file when present
(use-package editorconfig
  :diminish editorconfig-mode
  :config
  (editorconfig-mode 1))

;; chatgpt
(unless (package-installed-p 'vc-use-package)
  (package-vc-install "https://github.com/slotThe/vc-use-package"))
(require 'vc-use-package)
(use-package openai :vc (:fetcher github :repo emacs-openai/openai))

(use-package chatgpt :vc (:fetcher github :repo emacs-openai/chatgpt))
;; (setq openai-key)

(provide 'leef-editor)
;;; leef-editor.el ends here
