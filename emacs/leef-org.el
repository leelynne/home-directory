;;; leef-org.el --- Settings for org-mode
;;
;; Author: leef

;;; Code:

;; ox-gfm for github flavored markdown exports for org-mode
;; zotxt to integrate org-mode and zotero bib
(prelude-require-packages '(org-roam ox-gfm zotxt deft))

(require 'prelude-org)
(require 'org-roam)

(custom-set-variables
 '(org-directory "~/org")
 '(org-roam-directory "~/org/notes")
 '(org-roam-completion-system 'helm)
 '(org-agenda-files (list org-directory org-roam-directory))
 '(deft-recursive t)
 '(deft-directory "~/org")
 )

;;
(eval-after-load "org"
  '(require 'ox-gfm nil t))

;;; leef-org.el ends here
