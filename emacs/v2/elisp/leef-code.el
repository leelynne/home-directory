;;; leef-code.el --- Settings for various languages
;;
;; Author: leef

;;; Code:

;; java
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
                            (local-set-key (kbd "C-c C-f") 'helm-lsp-workspace-symbol)
                            (local-set-key (kbd "C-c C-d") 'lsp-ui-doc-show)
                          ))

(provide 'leef-code)
;;; leef-code.el ends here
