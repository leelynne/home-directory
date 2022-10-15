;;; myinit.el --- my crap
;;; Commentary:
;;
;;; Code:



(prelude-require-packages '(company ecb flymake-ruby flymake-cursor puppet-mode mustache-mode enh-ruby-mode robe rjsx-mode terraform-mode company-terraform protobuf-mode restclient jq-mode plantuml-mode pdf-tools nov avy))

;; Fix connecting to elpa
(when (and (equal emacs-version "27.2")
           (eql system-type 'darwin))
  (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

(require 'magit)

;; Disable prelude UI stuff
(menu-bar-mode -1)
(global-nlinum-mode -1)

;; Generic company mode improvements
(require 'company)
(setq company-tooltip-limit 20)                      ; bigger popup window
(setq company-idle-delay .2)                         ; decrease delay before autocompletion popup shows
(setq company-echo-delay 0)
(setq company-minimum-prefix-length 1)
(add-to-list 'company-backends 'company-capf)
(global-company-mode t)

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

;; avy
;; Steal goto-line binding. avy-goto-line takes in a number as well
(global-set-key (kbd "M-g g") 'avy-goto-line)
;; terraform
(add-hook 'terraform-mode-hook (lambda ()
                                 (add-hook 'before-save-hook #'terraform-format-buffer)
                                 ))
;; restclient
(require 'restclient)
(require 'jq-mode)
;;(require 'restclient-jq)

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
(setq plantuml-default-exec-mode 'executable)
;; plantuml org
;; org invokes the jar directly
(setq org-plantuml-jar-path (expand-file-name "~/.emacs.d/plantuml.jar"))
(add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
(org-babel-do-load-languages 'org-babel-load-languages '((plantuml . t)))

(setq-default tab-width 4)
(setq default-tab-width 4)

(global-visual-line-mode t)

(setq whitespace-line-column 200)
;; Don't stop on first "error"
(setq compilation-scroll-output 1)

(defun my-gfm-mode-hook ()
  "Use the 'marked' tool to display github flavored markdown."
  (setq markdown-command "cmark-gfm"))
(add-hook 'gfm-mode-hook 'my-gfm-mode-hook)



;; documents
;;(require 'pdf-tools)
;;(pdf-loader-install)
;;(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
;;; myinit.el ends here
