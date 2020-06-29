;;; leef-org.el --- Settings for org-mode
;;
;; Author: leef

;;; Code:

;; ox-gfm for github flavored markdown exports for org-mode
;; zotxt to integrate org-mode and zotero bib
(prelude-require-packages '(org-roam ox-gfm zotxt deft company-org-roam org-roam-server org-noter org-ref))

(require 'prelude-org)
(require 'org-roam)
(require 'company-org-roam)

(push 'company-org-roam company-backends)

(custom-set-variables
 '(org-directory "~/Dropbox/org")
 '(org-agenda-files (list org-directory))
 ;; roam
 '(org-roam-directory "~/Dropbox/org/notes")
 '(org-roam-completion-system 'helm)
 ;; Don't sync this across machines
 '(org-roam-db-location "~/.cache/org-roam/org-roam.db")
 ;; deft
 '(deft-recursive t)
 '(deft-directory "~/Dropbox/org")
 )

(setq reftex-default-bibliography '("~/.cache/zotero/My Library.bib"))
(add-hook 'after-init-hook 'org-roam-mode)
(add-hook 'org-mode-hook #'org-zotxt-mode)

(eval-after-load "org"
  '(require 'ox-gfm nil t)
  )

(add-hook 'org-roam-mode-hook (lambda()
                                (local-set-key (kbd "<C-tab>") 'company-complete)
          ))
;;; leef-org.el ends here
