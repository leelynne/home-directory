;;; leef-code.el --- Settings for various languages
;;
;; Author: leef

;;; Code:

;; generic
(use-package flycheck
  :bind* (("C-." . flycheck-next-error)
		 ("C-," . flycheck-previous-error)))

;; Spell check comments
(add-hook 'prog-mode-hook (lambda ()
							(flyspell-prog-mode)
							))
(use-package hl-todo
  :config
  (global-hl-todo-mode 1))

;; yaml
(use-package yaml-mode
  :hook ((yaml-mode . whitespace-mode)
         (yaml-mode . subword-mode)))

;; bash
(add-hook 'sh-mode-hook (lambda ()
						  (lsp)))
(require 'lsp-bash)


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
(require 'lsp-java)
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

(provide 'leef-code)
;;; leef-code.el ends here
