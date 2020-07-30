;;; leef-org.el --- Settings for org-mode
;;
;; Author: leef

;;; Code:

;; ox-gfm for github flavored markdown exports for org-mode
;; zotxt to integrate org-mode and zotero bib
(prelude-require-packages '(org-roam ox-gfm zotxt deft company-org-roam org-roam-bibtex org-roam-server org-noter org-ref helm-bibtex org-journal ox-jira langtool))

(require 'prelude-org)

;; org
(setq org-directory "~/Dropbox/org/"
      org-agenda-files '("~/Dropbox/org/journal")
      )
(add-hook 'org-mode-hook #'org-zotxt-mode)
;; Org export to markdown with support for github flavored markdown
(eval-after-load "org"
  '(require 'ox-gfm nil t)
  )

;; Deft
(setq deft-recursive t
      deft-directory "~/Dropbox/org"
      )

;; org-roam
(require 'org-roam)
(require 'company-org-roam)
(setq org-roam-directory "~/Dropbox/org/notes"
      org-roam-completion-system 'helm
      ;; Don't sync the cache across machines
      org-roam-db-location "~/.cache/org-roam/org-roam.db"
      )
(push 'company-org-roam company-backends)
(add-hook 'after-init-hook 'org-roam-mode)

(add-hook 'org-roam-mode-hook (lambda()
                                (local-set-key (kbd "<C-tab>") 'company-complete)
                                ))

;; org-ref
(require 'org-ref)
(setq reftex-default-bibliography '("~/Dropbox/zotero/bib/zotero.bib"))
(setq org-ref-bibliography-notes "~/Dropbox/zotero/bib/zotero.bib"
      org-ref-default-bibliography '("~/Dropbox/zotero/bib/zotero.bib")
      org-ref-pdf-directory "~/Dropbox/pdfdocs")

;; helm-bibtex
(require 'helm-bibtex)
(setq bibtex-completion-bibliography "~/Dropbox/zotero/bib/zotero.bib"
      bibtex-completion-pdf-field "file"
      )

;; org-journal
(require 'org-journal)
(setq org-journal-date-prefix "#+title: "
      org-journal-file-format "%Y-%m-%d.org"
      org-journal-time-format "%H%M"
      org-journal-date-format "%Y-%m-%d"
      org-journal-dir "~/Dropbox/org/journal/"
      org-journal-carryover-items nil
      org-journal-file-type 'daily
      )
(defun org-journal-save-entry-and-exit()
  "Save buffer of the current day's entry and kill the window."
  (interactive)
  (save-buffer)
  (kill-buffer-and-window))
(define-key org-journal-mode-map (kbd "C-x C-s") 'org-journal-save-entry-and-exit)

;; org-roam-server
(setq org-roam-server-host "127.0.0.1"
      org-roam-server-port 8080
      org-roam-server-export-inline-images t
      org-roam-server-authenticate nil
      org-roam-server-network-poll t
      org-roam-server-network-arrows nil
      org-roam-server-network-label-truncate t
      org-roam-server-network-label-truncate-length 60
      org-roam-server-network-label-wrap-length 20
      )

;; Grammar
(setq langtool-language-tool-server-jar "~/apps/LanguageTool-5.0/languagetool-server.jar")
(require 'langtool)
;;; leef-org.el ends here
