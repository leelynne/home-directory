;;; leef-code.el --- Settings for various languages  -*- lexical-binding: t; -*-
;;
;; Author: leef

;;; Code:

;; generic
(use-package flycheck
  :bind* (("C-." . flycheck-next-error)
		 ("C-," . flycheck-previous-error))
  :custom
  ;; eglot reports diagnostics through flymake; flycheck 38+ consumes them
  ;; directly via the `eglot-check' checker, which keeps the bindings above and
  ;; consult-flycheck working in LSP buffers. nil so eglot's diagnostics chain
  ;; to the command checkers rather than replacing them.
  (flycheck-eglot-exclusive nil)
  :config
  (global-flycheck-eglot-mode 1))
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

;; bash -- eglot maps sh-mode/bash-ts-mode to bash-language-server by default
(add-hook 'sh-mode-hook #'eglot-ensure)
(add-hook 'bash-ts-mode-hook #'eglot-ensure)

;; terraform
(use-package terraform-mode)
(use-package hcl-mode)

;; containers
(use-package dockerfile-mode)

;; graphql
(use-package graphql-mode)

;; markdown
(use-package markdown-mode)

;; pandoc
(use-package pandoc-mode)
(use-package ox-pandoc)

;; string case conversion
(use-package string-inflection)

;; templ
(use-package templ-ts-mode)

;; grep editing
(use-package wgrep)

;; scala
(use-package scala-mode
  :config
  (add-hook 'scala-mode-hook (lambda ()
							   (subword-mode +1))))
;; Metals is a scala LSP. It claims to support range formatting but only does so
;; for multiline strings, so turn it off and let scala-mode handle indentation.
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((scala-mode scala-ts-mode)
                 . ("metals" "-J-Dmetals.allow-multiline-string-formatting=off"))))
(add-hook 'scala-mode-hook #'eglot-ensure)

;; java -- eglot maps java-mode to jdtls by default. Two things lsp-java used to
;; handle now have to be split by where jdtls actually wants them:
;;
;;   * JVM args (heap) are launch-time, so they go on the command line as
;;     --jvm-arg=... The jdtls wrapper script forwards these to the JVM.
;;   * Formatter settings are workspace configuration, sent as a nested :java
;;     section. eglot matches the *top-level* section name against what the
;;     server asks for, so flat "java.format.settings.url" keys never match.
;;     The url must also be an absolute file:// URI -- a bare path makes jdtls
;;     throw "URI is not absolute".
;;
;; No Lombok javaagent: a -javaagent pointing at a missing jar stops the JVM
;; from booting at all ("agent library failed Agent_OnLoad"), so add it back
;; only alongside a jar that exists.
(defconst leef/java-format-style
  (expand-file-name "~/home-directory/spotless.eclipse-java-google-style.xml")
  "Eclipse formatter profile XML used for Java buffers.")

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((java-mode java-ts-mode)
                 . ("jdtls"
                    "--jvm-arg=-Xmx2G"
                    "--jvm-arg=-XX:+UseG1GC"
                    "--jvm-arg=-XX:+UseStringDeduplication"))))

;; Set as a global default rather than buffer-locally: eglot reads this in a
;; temp buffer (via hack-dir-local-variables-non-file-buffer), so a setq-local
;; in the Java buffer would never be seen. Override per project with a
;; .dir-locals.el entry if a repo needs a different profile.
(setq-default eglot-workspace-configuration
              `(:java
                (:format
                 (:enabled t
                  :settings (:url ,(concat "file://" leef/java-format-style)
                             :profile "GoogleStyle")))))

(defun leef/java-eglot-setup ()
  "Editing conveniences for Java buffers.

The indent settings matter beyond local editing: eglot derives the LSP
FormattingOptions it sends from `indent-tabs-mode' and `tab-width', and jdtls
prefers those over the profile named in `java.format.settings.url' (see
eclipse.jdt.ls issue #2053). They have to agree with the XML -- GoogleStyle is
2 spaces -- or formatting silently comes back with tabs."
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 2)
  (setq-local java-ts-mode-indent-offset 2)
  (setq-local c-basic-offset 2)
  ;; CamelCase aware editing operations
  (subword-mode +1)
  (local-set-key (kbd "<C-tab>") 'company-capf))

(dolist (hook '(java-mode-hook java-ts-mode-hook))
  (add-hook hook #'eglot-ensure)
  (add-hook hook #'leef/java-eglot-setup))

;; kotlin
(use-package kotlin-mode)

(use-package aidermacs
  :bind (("C-c a" . aidermacs-transient-menu))
  :config
  :custom
  ; See the Configuration section below
  (aidermacs-use-architect-mode t)
  (aidermacs-default-model "sonnet"))

;; Claude
(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind ("C-c C-'" . claude-code-ide-menu) ; Set your favorite keybinding
  :config
  (setq claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools

;; json
;; Prefer Tree-sitter JSON if available
(when (fboundp 'json-ts-mode)
  (add-to-list 'major-mode-remap-alist '(json-mode . json-ts-mode)))

;; 4-space indentation for JSON
(add-hook 'json-ts-mode-hook
          (lambda ()
            (setq-local json-ts-mode-indent-offset 4)
            (setq-local js-indent-level 4)))
(add-hook 'json-mode-hook
          (lambda ()
            (setq-local js-indent-level 4)))

;; Formatter via jq (install jq on your system)
(use-package reformatter
  :config
  (reformatter-define jq-format
    :program "jq"
	:args (list "--indent" (number-to-string tab-width) "."))
  (add-hook 'json-ts-mode-hook #'jq-format-on-save-mode))

(provide 'leef-code)
;;; leef-code.el ends here
