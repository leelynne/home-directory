;;; leef-editor.el --- Editor-ish based settings
;;
;; Author: leef

;;; Code:

(setq-default tab-width 4)
(setq default-tab-width 4)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)


(which-key-mode +1)
;; recent files
(require 'recentf)
;;(setq recentf-save-file (expand-file-name "recentf" prelude-savefile-dir)
;;      recentf-max-saved-items 500
;;      recentf-max-menu-items 15
      ;; disable recentf-cleanup on Emacs start, because it can cause
      ;; problems with remote files
;;      recentf-auto-cleanup 'never)

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

;; Suppot .editorconfig file when present
(use-package editorconfig
  :diminish editorconfig-mode
  :config
  (editorconfig-mode 1))
  
(provide 'leef-editor)
;;; leef-editor.el ends here
