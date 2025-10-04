;;; myinit.el --- my crap
;;; Commentary:
;;
;;; Code:

(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; load newest byte code
(setq load-prefer-newer t)

(when (not package-archive-contents)
  (package-refresh-contents))

;; bootstrap use-package	     
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(require 'use-package-ensure)
(setq use-package-always-ensure t)

(add-to-list 'load-path "~/.emacs.d/elisp/")

(require 'leef-base)
(require 'leef-editor)
(require 'leef-org)
(require 'leef-lsp)
(require 'leef-code)
(require 'leef-go)


;; warn when opening files bigger than 100MB
;;(setq large-file-warning-threshold 100000000)


;;; myinit.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(terraform-mode eat claude-code-ide consult-projectile consult-flyspell consult-flycheck consult-dir consult-lsp marginalia consult-org-roam rg hcl-mode pandoc-mode aidermacs templ-ts-mode graphql-mode openai vc-use-package chatgpt use-package))
 '(package-vc-selected-packages
   '((zotxt :vc-backend Git :url "https://github.com/egh/zotxt-emacs")
	 (claude-code-ide :vc-backend Git :url "https://github.com/manzaltu/claude-code-ide.el")
	 (chatgpt :vc-backend Git :url "https://github.com/emacs-openai/chatgpt")
	 (openai :vc-backend Git :url "https://github.com/emacs-openai/openai")
	 (vc-use-package :vc-backend Git :url "https://github.com/slotThe/vc-use-package"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
