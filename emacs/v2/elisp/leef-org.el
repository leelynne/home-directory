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
(use-package org-roam-timestamps
  :after org-roam
  ;; set creation and modification timestamps
  :config (org-roam-timestamps-mode)
  (setq org-roam-timestamps-remember-timestamps nil)
  )

(use-package org-ref)
(use-package org-chef)
(use-package helm-bibtex)
(use-package ox-jira)
(use-package ox-gfm)
(use-package langtool)
;; project management helpers
(use-package vulpea
  :ensure t
  ;; hook into org-roam-db-autosync-mode you wish to enable
  ;; persistence of meta values (see respective section in README to
  ;; find out what meta means)
  :hook ((org-roam-db-autosync-mode . vulpea-db-autosync-enable)))

;; org
(require 'org)

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(setq org-directory "~/Dropbox/org/"
	  org-image-actual-width nil
      org-agenda-files (list "~/Dropbox/org/notes/mobile"
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

(setq org-agenda-prefix-format
      '((agenda . " %i %(mgmt-agenda-category 15)%?-15t% s")
        (todo . " %i %(mgmt-agenda-category 15) ")
        (tags . " %i %(mgmt-agenda-category 15) ")
        (search . " %i %(mgmt-agenda-category 15) ")))

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

;; project and task management

;; dynamically add any org-roam files with TODOs to org agenda
;;   1. Auto tag any org-roam note that has TODO as a 'project'
;;   2. Dynamically feed only these file to org agenda
(require 'vulpea)

;; Auto tag any org-roam note that has a TODO as a 'project'
(defun mgmt-project-p ()
  "Return non-nil if current buffer has any todo entry.

TODO entries marked as done are ignored, meaning the this
function returns nil if current buffer contains only completed
tasks."
  (org-element-map                          
       (org-element-parse-buffer 'headline) 
       'headline
     (lambda (h)
       (eq (org-element-property :todo-type h)
           'todo))
     nil 'first-match))                     

(add-hook 'find-file-hook #'mgmt-project-update-tag)
(add-hook 'before-save-hook #'mgmt-project-update-tag)

(defun mgmt-project-update-tag ()
      "Update PROJECT tag in the current buffer."
      (when (and (not (active-minibuffer-window))
                 (mgmt-buffer-p))
        (save-excursion
          (goto-char (point-min))
          (let* ((tags (vulpea-buffer-tags-get))
                 (original-tags tags))
            (if (mgmt-project-p)
                (setq tags (cons "project" tags))
              (setq tags (remove "project" tags)))

            ;; cleanup duplicates
            (setq tags (seq-uniq tags))

            ;; update tags if changed
            (when (or (seq-difference tags original-tags)
                      (seq-difference original-tags tags))
              (apply #'vulpea-buffer-tags-set tags))))))

(defun mgmt-buffer-p ()
  "Return non-nil if the currently visited buffer is a note."
  (and buffer-file-name
       (string-prefix-p
        (expand-file-name (file-name-as-directory org-roam-directory))
        (file-name-directory buffer-file-name))))

;; Dynamically feed only these file to org agenda
(defun mgmt-project-files ()
  "Return a list of note files containing 'project' tag." ;
  (seq-uniq
   (seq-map
    #'car
    (org-roam-db-query
     [:select [nodes:file]
      :from tags
      :left-join nodes
      :on (= tags:node-id nodes:id)
      :where (like tag (quote "%\"project\"%"))]))))

(defun mgmt-agenda-files-update (&rest _)
  "Update the value of `org-agenda-files'."
  (setq org-agenda-files (mgmt-project-files)))

(advice-add 'org-agenda :before #'mgmt-agenda-files-update)
(advice-add 'org-todo-list :before #'mgmt-agenda-files-update)

(defun mgmt-agenda-category (&optional len)
  "Get category of item at point for agenda.

Category is defined by one of the following items:

- CATEGORY property
- TITLE keyword
- TITLE property
- filename without directory and extension

When LEN is a number, resulting string is padded right with
spaces and then truncated with ... on the right if result is
longer than LEN.

Usage example:

  (setq org-agenda-prefix-format
        '((agenda . \" %(mgmt-agenda-category) %?-12t %12s\")))

Refer to `org-agenda-prefix-format' for more information."
  (let* ((file-name (when buffer-file-name
                      (file-name-sans-extension
                       (file-name-nondirectory buffer-file-name))))
         (title (vulpea-buffer-prop-get "title"))
         (category (org-get-category))
         (result
          (or (if (and
                   title
                   (string-equal category file-name))
                  title
                category)
              "")))
    (if (numberp len)
        (s-truncate len (s-pad-right len " " result))
      result)))

(provide 'leef-org)
;;; leef-org.el ends here
