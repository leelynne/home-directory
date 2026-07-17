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

;; retry package refresh once after failure
(defun my/use-package-ensure-with-retry (orig &rest args)
  (condition-case _
      (apply orig args)
    ((error file-error)
     (package-refresh-contents)
     (apply orig args))))
(advice-add 'use-package-ensure-elpa :around #'my/use-package-ensure-with-retry)

(eval-when-compile
  (require 'use-package))
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Collect all use-package names as they're declared, then merge into
;; package-selected-packages after init (after custom-set-variables has run).
(defvar my/use-package-selected nil)
(defun my/use-package-handler/:ensure (orig name keyword args rest state)
  (add-to-list 'my/use-package-selected name)
  (funcall orig name keyword args rest state))
(advice-add 'use-package-handler/:ensure :around #'my/use-package-handler/:ensure)

(add-hook 'after-init-hook
          (lambda ()
            (dolist (pkg my/use-package-selected)
              (add-to-list 'package-selected-packages pkg))))

(add-to-list 'load-path "~/.emacs.d/elisp/")

(require 'leef-base)
(require 'leef-editor)
(require 'leef-org)
(require 'leef-lsp)
(require 'leef-code)
(require 'leef-go)
(require 'leef-caddy)

;; warn when opening files bigger than 100MB
;;(setq large-file-warning-threshold 100000000)


;;; myinit.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(tblui no-littering zenburn-theme which-key magit diminish s rg eat ghostel consult vertico emacs orderless marginalia consult-dir company avy ace-window flyspell consult-flyspell projectile consult-projectile anzu savehist recentf undo-tree super-save editorconfig openai chatgpt org-roam zotxt deft org-roam-bibtex org-roam-ui org-roam-timestamps org-ref org-chef ox-jira ox-gfm langtool ob-async ob-deno ob-tmux ob-dart ob-go ob-kotlin ob-rust ob-http ob-mermaid ob-php ob-sql-mode ob-typescript consult-org-roam vulpea lsp-mode lsp-ui lsp-treemacs dap-mode consult-lsp lsp-docker flycheck consult-flycheck treesit-auto hl-todo treemacs treemacs-projectile yaml-mode terraform-mode hcl-mode dockerfile-mode graphql-mode markdown-mode pandoc-mode ox-pandoc string-inflection templ-ts-mode wgrep scala-mode lsp-metals lsp-java kotlin-mode aidermacs claude-code-ide reformatter go-mode go-dlv go-rename go-projectile go-eldoc go-guru))
)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
