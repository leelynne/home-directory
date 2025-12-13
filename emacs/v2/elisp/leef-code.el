;;; leef-code.el --- Settings for various languages
;;
;; Author: leef

;;; Code:

;; generic
(use-package flycheck
  :bind* (("C-." . flycheck-next-error)
		 ("C-," . flycheck-previous-error)))
(use-package consult-flycheck)

(use-package treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install nil)    ;; ask to install missing grammars
  (global-treesit-auto-mode))

;; Add both common locations; only the one that exists will be used.
(dolist (dir '("~/.emacs.d/tree-sitter" "~/.emacs.d/treesit"
               "~/Library/Application Support/Emacs/tree-sitter"))
  (when (file-directory-p (expand-file-name dir))
    (add-to-list 'treesit-extra-load-path (expand-file-name dir))))
;; Spell check comments
(add-hook 'prog-mode-hook (lambda ()
							(flyspell-prog-mode)
							))
(use-package hl-todo
  :config
  (global-hl-todo-mode 1))

;; treemacs
(use-package treemacs
  :ensure t
  :defer t
  :config
  (setq treemacs-width 50
        treemacs-position 'right
		treemacs-tag-follow-mode t
        treemacs-follow-after-init t))

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

;; yaml
(use-package yaml-mode
  :hook ((yaml-mode . whitespace-mode)
         (yaml-mode . subword-mode)))

;; bash
(add-hook 'sh-mode-hook (lambda ()
						  (lsp)))
(require 'lsp-bash)

;; terraform
(use-package terraform-mode)

;; scala
(use-package scala-mode
  :config
  (add-hook 'scala-mode-hook (lambda ()
							   (subword-mode +1))))
;; Metals is a scala LSP
(use-package lsp-metals
  :custom
  ;; Metals claims to support range formatting by default but it supports range
  ;; formatting of multiline strings only. You might want to disable it so that
  ;; emacs can use indentation provided by scala-mode.
  (lsp-metals-server-args '("-J-Dmetals.allow-multiline-string-formatting=off"))
  :hook (scala-mode . lsp))

;; java
(use-package lsp-java)
(add-hook 'java-mode-hook #'lsp)
(add-hook 'java-mode-hook (lambda ()
                            ;;(add-hook 'before-save-hook #'lsp-format-buffer t t)
                            ;;(add-hook 'before-save-hook #'lsp-organize-imports t t)
                            (setq lsp-headerline-breadcrumb-enable t)
                            (setq lsp-ui-doc-delay 2) ;; slow down
                            ;; icons are freaking huge
                            (setq lsp-java-vmargs
                                  `("-Xmx2G"
                                    "-XX:+UseG1GC"
                                    "-XX:+UseStringDeduplication"
                                    "-javaagent:/Users/lee/.m2/repository/org/projectlombok/lombok/1.18.10/lombok-1.18.10.jar"))
                            (setq lsp-java-format-settings-url "~/home-directory/spotless.eclipse-java-google-style.xml")
                            (setq lsp-java-format-settings-profile "GoogleStyle")
                            ;; CamelCase aware editing operations
                            (subword-mode +1)
                            (local-set-key (kbd "M-.") 'lsp-ui-peek-find-definitions)
                            (local-set-key (kbd "M-/") 'lsp-ui-peek-find-references)
                            (local-set-key (kbd "<C-tab>") 'company-capf)
                            (local-set-key (kbd "C-c C-d") 'lsp-ui-doc-show)
                          ))

;; kotlin
(use-package kotlin-mode)

(use-package aidermacs
  :bind (("C-c a" . aidermacs-transient-menu))
  :config
  :custom
  ; See the Configuration section below
  (aidermacs-use-architect-mode t)
  (aidermacs-default-model "sonnet"))

(use-package claude-code-ide
  :vc (:fetcher github :repo "manzaltu/claude-code-ide.el")
  :bind ("C-c C-'" . claude-code-ide-menu) ; Set your favorite keybinding
  :config
  (setq claude-code-ide-terminal-backend 'eat)
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools

;; json
;; Prefer Tree-sitter JSON if available
(when (fboundp 'json-ts-mode)
  (add-to-list 'major-mode-remap-alist '(json-mode . json-ts-mode)))

;; Formatter via jq (install jq on your system)
(use-package reformatter
  :config
  (reformatter-define jq-format
    :program "jq" :args '("."))
  (add-hook 'json-ts-mode-hook #'jq-format-on-save-mode))

(provide 'leef-code)
;;; leef-code.el ends here
