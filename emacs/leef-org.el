;;; leef-org.el --- Settings for org-mode
;;
;; Author: leef

;;; Code:

(prelude-require-packages '(org-roam))

(require 'org-roam)

(custom-set-variables
 '(org-directory "~/org")
 '(org-roam-directory "~/org/notes")
 '(org-roam-completion-system 'helm)
 '(org-agenda-files (list org-directory)))

(eval-after-load "org"
  '(require 'ox-gfm nil t))

;;; leef-org.el ends here
