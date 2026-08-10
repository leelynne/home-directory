;;; myinit.el --- my crap
;;; Commentary:
;;
;;; Code:

(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))

(package-initialize)

;; Custom writes go to a dedicated, tracked file instead of this one.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

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

;; package-selected-packages persistence is redundant: my/use-package-selected
;; + the after-init-hook below already derive it from source every startup,
;; which is what package-autoremove/list-packages actually consult live.
(advice-add 'package--save-selected-packages :override #'ignore)

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
(require 'leef-eglot)
(require 'leef-code)
(require 'leef-go)
(require 'leef-python)
(require 'leef-caddy)

;; warn when opening files bigger than 100MB
;;(setq large-file-warning-threshold 100000000)


;;; myinit.el ends here
