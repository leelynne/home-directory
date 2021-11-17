;;; leef-org.el --- Settings for org-mode
;;
;; Author: leef

;;; Code:

;; ox-gfm for github flavored markdown exports for org-mode
;; zotxt to integrate org-mode and zotero bib
(prelude-require-packages '(org-roam ox-gfm zotxt deft org-roam-bibtex org-roam-server org-noter org-ref helm-bibtex ox-jira langtool org-chef))

(require 'prelude-org)

;; org
(setq org-directory "~/Dropbox/org/"
      org-agenda-files (list "~/Dropbox/org/tasks"
                             "~/Dropbox/org/mobile"
                             ))

;; Update org files timestamps
(require 'time-stamp)
(add-hook 'write-file-functions 'time-stamp) ; update when saving
(setq time-stamp-pattern "%:y-%02m-%02d %02H:%02M:%02S")
(setq time-stamp-start "updated:[ 	]+\\\\?[\"<]+")


;;                             )
;;      org-adapt-indentation nil)
;;(add-to-list 'org-structure-template-alist
             ;;(list "p" (concat ":PROPERTIES:\n"
               ;;                "?\n"
                 ;;              ":END:")))

;; agenda
(setq org-agenda-custom-commands
      '(("f" "Month agenda"
         ((agenda "" ((org-agenda-span 30)))
          (todo ""))
         )
        ("o" "OKRs"
         ((agenda "" ((org-agenda-span 30)
                      (org-agenda-tag-filter-preset '("+okr")))
                  )
          (tags "okr"))
         )
        ("r" "RFC"
         ((agenda "" ((org-agenda-span 30)
                      (org-agenda-tag-filter-preset '("+rfc")))
                  )
          (tags "rfc"))
         )
        ("w" "work"
         ((agenda "" ((org-agenda-span 30)
                      (org-agenda-tag-filter-preset '("+work")))
                  )
          (tags "work")
          )
         )
        ))

(setq org-agenda-span 17
      org-agenda-start-on-weekday nil
      org-agenda-start-day "-3d")

(add-hook 'org-mode-hook #'org-zotxt-mode)
;; Org export to markdown with support for github flavored markdown
(eval-after-load "org"
  '(require 'ox-gfm nil t)
  )

;; Deft
(setq deft-recursive t
      deft-directory "~/Dropbox/org"
      )
(setq deft-extensions '("org" "md" "txt"))

;; org-roam
(require 'org-roam)

(setq org-roam-directory "~/Dropbox/org/notes"
      org-roam-completion-system 'helm
      ;; Don't sync the cache across machines
      org-roam-db-location "~/.cache/org-roam/org-roam.db"
      )

;; (setq org-roam-capture-templates
;;       '(("d" "default" plain #'org-roam-capture--get-point
;;          "%?"
;;          :file-name "%<%Y%m%d%H%M%S>-${slug}"
;;          :head "#+title: ${title}\n"
;;          :unnarrowed t)
;;         ("i" "interview" plain #'org-roam-capture--get-point
;;          "%?"
;;          :file-name "interviews/${slug}"
;;          :head "
;; #+title: ${title}
;; #+roam_tags: interview\n"
;;          :unnarrowed t))
;;       )

(add-hook 'after-init-hook 'org-roam-setup)
(add-hook 'org-mode-hook (lambda()
                           (local-set-key (kbd "<C-tab>") 'completion-at-point)
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

(defun org-hide-properties ()
  "Hide all org-mode headline property drawers in buffer. Could be slow if it has a lot of overlays."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward
            "^ *:properties:\n\\( *:.+?:.*\n\\)+ *:end:\n" nil t)
      (let ((ov_this (make-overlay (match-beginning 0) (match-end 0))))
        (overlay-put ov_this 'display "")
        (overlay-put ov_this 'hidden-prop-drawer t))))
  (put 'org-toggle-properties-hide-state 'state 'hidden))

(defun org-show-properties ()
  "Show all org-mode property drawers hidden by org-hide-properties."
  (interactive)
  (remove-overlays (point-min) (point-max) 'hidden-prop-drawer t)
  (put 'org-toggle-properties-hide-state 'state 'shown))

(defun org-toggle-properties ()
  "Toggle visibility of property drawers."
  (interactive)
  (if (eq (get 'org-toggle-properties-hide-state 'state) 'hidden)
      (org-show-properties)
    (org-hide-properties)))

;; org-chef
(setq org-chef-prefer-json-ld t)
