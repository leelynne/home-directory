;;; leef-org.el --- Settings for org-mode
;;
;; Author: leef

;;; Code:

;; ox-gfm for github flavored markdown exports for org-mode
;; zotxt to integrate org-mode and zotero bib
(use-package org-roam)
(use-package zotxt)
(use-package deft)
(use-package org-roam-bibtex)
(use-package org-roam-ui)
;;(use-package org-noter)
(use-package org-ref)
(use-package org-chef)
(use-package helm-bibtex)
(use-package ox-jira)
(use-package ox-gfm)
(use-package langtool)

;; org
(require 'org)

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(setq org-directory "~/Dropbox/org/"
      org-agenda-files (list "~/Dropbox/org/tasks"
                             "~/Dropbox/org/mobile"
                             ))
;; org-babel
(use-package ob-async) ;; async code block execution
(use-package ob-deno) ;; javascript
(use-package ob-tmux) ;; shell
(use-package ob-dart) ;;
(use-package ob-go)
(use-package ob-kotlin)
(use-package ob-rust)
(use-package ob-http)
(use-package ob-mermaid)
(use-package ob-php)
(use-package ob-sql-mode)
(use-package ob-typescript) 

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
p         )
        ))

(setq org-agenda-span 17
      org-agenda-start-on-weekday nil
      org-agenda-start-day "-3d")

(add-hook 'org-mode-hook #'org-zotxt-mode)
(add-hook 'org-mode-hook #'flyspell-mode)
;; Org export to markdown with support for github flavored markdown
(eval-after-load "org"
  '(require 'ox-gfm nil t)
  )

;; Deft
(defun cm/deft-parse-title (file contents)
  "Parse the given FILE and CONTENTS and determine the title.
  If `deft-use-filename-as-title' is nil, the title is taken to
  be the first non-empty line of the FILE.  Else the base name of the FILE is
  used as title."
  (let ((begin (string-match "^#\\+[tT][iI][tT][lL][eE]: .*$" contents)))
	(if begin
	    (string-trim (substring contents begin (match-end 0)) "#\\+[tT][iI][tT][lL][eE]: *" "[\n\t ]+")
	  (deft-base-filename file))))

(advice-add 'deft-parse-title :override #'cm/deft-parse-title)
(setq deft-recursive t
      deft-directory "~/Dropbox/org"
      deft-strip-summary-regexp	  (concat "\\("
		                                  "[\n\t]" ;; blank
		                                  "\\|^#\\+[[:alpha:]_]+:.*$" ;; org-mode metadata
		                                  "\\|^:PROPERTIES:\n\\(.+\n\\)+:END:\n"
		                                  "\\)"))
(setq deft-extensions '("org" "md" "txt"))

;; org-roam
(require 'org-roam)

(setq org-roam-directory "~/Dropbox/org/notes"
      ;;org-roam-completion-system 'helm
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

(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer)))

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

(provide 'leef-org)
;;; leef-org.el ends here
