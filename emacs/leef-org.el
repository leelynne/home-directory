;;; leef-org.el --- Settings for org-mode
;;
;; Author: leef

;;; Code:

;; ox-gfm for github flavored markdown exports for org-mode
;; zotxt to integrate org-mode and zotero bib
(prelude-require-packages '(org-roam ox-gfm zotxt deft))

(require 'prelude-org)
(require 'org-roam)
(require 'company-org-roam)

(push 'company-org-roam company-backends)

(custom-set-variables
 '(org-directory "~/org")
 '(org-roam-directory "~/org/notes")
 '(org-roam-completion-system 'helm)
 '(org-agenda-files (list org-directory))
 '(deft-recursive t)
 '(deft-directory "~/org")
 )

(eval-after-load "org"
  '(require 'ox-gfm nil t)

  )

(add-hook 'org-mode-hook #'org-zotxt-mode)
(add-hook 'org-mode-hook (lambda()

                           ))

(add-hook 'org-roam-mode-hook (lambda()
          (company-org-roam-init)
          (local-set-key (kbd "<C-tab>") 'company-complete)
          ))
;;; leef-org.el ends here
