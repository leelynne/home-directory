;;; myinit.el --- my crap
;;; Commentary:
;;
;;; Code:

(prelude-require-packages '(company ecb flymake-ruby flymake-cursor puppet-mode mustache-mode enh-ruby-mode robe rjsx-mode terraform-mode company-terraform protobuf-mode restclient jq-mode plantuml-mode))

;; Generic company mode improvements
(require 'company)
(setq company-tooltip-limit 20)                      ; bigger popup window
(setq company-idle-delay .3)                         ; decrease delay before autocompletion popup shows
(setq company-echo-delay 0)

;; Java
(require 'lsp-java)
(add-hook 'java-mode-hook #'lsp)
(add-hook 'java-mode-hook (lambda ()
                            ;; Spaces for tabs
                            (setq-default indent-tabs-mode nil)
                            ))

;; JCS
(require 'rjsx-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))

;; PHP
;;(require 'php-mode)
;;(setq flycheck-phpcs-standard "~/styles/phprules.xml")
;;(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))
;;(add-hook 'php-mode-hook (lambda ()
;; stop whitespace being highlighted
;;                           (setq indent-tabs-mode t)
;;                           (whitespace-toggle-options '(tabs))
;;                           (local-set-key [f5] 'my-php-debug)
;;                           (php-eldoc-enable)
;;                           ))

;; python
(add-hook 'python-mode-hook 'anaconda-mode)
(add-hook 'python-mode-hook (lambda ()
                              (local-set-key (kbd "<C-tab>") 'company-complete)
                              ))

;; restclient
(require 'restclient)
(require 'jq-mode)
(require 'restclient-jq)
(require 'restclient-helm)


;; Steal flyspell bindings for flycheck
(require 'flycheck)
(global-flycheck-mode)
(require 'lsp-ui-flycheck)
(setq lsp-prefer-flymake nil)
(define-key flycheck-mode-map (kbd "C-,") #'flycheck-previous-error)
(define-key flycheck-mode-map (kbd "C-.") #'flycheck-next-error)

;; Helm good
(require 'prelude-helm-everywhere)
(require 'helm-lsp)

;; plantuml
(require 'plantuml-mode)
(setq org-plantuml-jar-path (expand-file-name "~/apps/plantuml/plantuml.jar"))
(add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
(org-babel-do-load-languages 'org-babel-load-languages '((plantuml . t)))

(setq-default tab-width 4)
(setq default-tab-width 4)
(global-company-mode t)
(global-visual-line-mode t)

(setq whitespace-line-column 200)
;; Don't stop on first "error"
(setq compilation-scroll-output 1)

(defun my-gfm-mode-hook ()
  "Use the 'marked' tool to display github flavored markdown."
  (setq markdown-command "cmark-gfm"))
(add-hook 'gfm-mode-hook 'my-gfm-mode-hook)

;;; myinit.el ends here
