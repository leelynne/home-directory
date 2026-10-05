;;; leef-org.el --- Settings for org-mode  -*- lexical-binding: t; -*-
;;
;; Author: leef

;;; Code:

;; ox-gfm for github flavored markdown exports for org-mode
;; zotxt to integrate org-mode and zotero bib
(use-package org-roam
  :bind (("C-c n f" . org-roam-node-find))
  :init
  (setq org-roam-directory "~/roam"
        org-roam-db-location "~/.cache/org-roam/org-roam.db")
  :config (org-roam-db-autosync-mode))

;; (setq org-roam-node-display-template "${title:*}")
(setq org-roam-node-display-template
    (concat "${title:*} "
        (propertize "${tags:25}" 'face 'org-tag)))

;; Adds tags to the identity of the node. This is different than just adding tags to the display
;;(defun org-roam-node-read--annotation (node)
;;  (mapconcat #'identity
;;             (org-roam-node-tags node)
;;             "\s"))

(use-package zotxt)
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
(use-package ox-jira)
(use-package ox-gfm)

(use-package langtool
  :config
  (setq langtool-language-tool-server-jar "~/.emacs.d/languagetool-server.jar")
  (setq langtool-server-user-arguments `("--config" ,(expand-file-name "~/.emacs.d/languagetool.properties")))
  )


;; org
(require 'org)

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(setq org-startup-with-inline-images t)

(setq org-directory "~/org/"
      org-image-actual-width nil
      ;; default is empty; set org-agenda-files per-machine in
      ;; ~/.emacs.d/hosts/<hostname>.el instead
      org-agenda-files nil)
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

(setq ob-mermaid-cli-path "~/.config/node/bin/mmdc")

;; Update org files timestamps
(require 'time-stamp)
(add-hook 'write-file-functions 'time-stamp) ; update when saving
(setq time-stamp-pattern "%:y-%02m-%02d %02H:%02M:%02S")
(setq time-stamp-start "updated:[ 	]+\\\\?[\"<]+")

;; consult-org-roam
(use-package consult-org-roam
   :ensure t
   :after org-roam
   :init
   (require 'consult-org-roam)
   ;; Keep org-roam buffers mingled into the plain "Buffers" section of
   ;; consult-buffer instead of split into their own "Org-roam" group.
   ;; Must be set before `consult-org-roam-mode' runs, since that's what
   ;; decides (once, at enable time) whether to install the split.
   (setq consult-org-roam-buffer-enabled nil)
   ;; Activate the minor mode
   (consult-org-roam-mode 1)
   :custom
   ;; Use `ripgrep' for searching with `consult-org-roam-search'
   (consult-org-roam-grep-func #'consult-ripgrep)
   :config
   ;; Eventually suppress previewing for certain functions
   (consult-customize
    consult-org-roam-forward-links
    :preview-key "M-.")
   :bind
   ;; Define some convenient keybindings as an addition
   ("C-c n e" . consult-org-roam-file-find)
   ("C-c n b" . consult-org-roam-backlinks)
   ("C-c n B" . consult-org-roam-backlinks-recursive)
   ("C-c n l" . consult-org-roam-forward-links)
   ("C-c n r" . consult-org-roam-search))

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

(setq org-todo-keywords
      '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)" "WONTDO(c)")))

(setq org-agenoda-prefix-format
      '((agenda . " %i %-20.20c%?-15t% s")
        (todo . " %i %-20.20c ")
        (tags . " %i %-20.20c ")
        (search . " %i %-20.20c ")))

(add-hook 'org-mode-hook #'org-zotxt-mode)
(add-hook 'org-mode-hook #'flyspell-mode)
;; Org export to markdown with support for github flavored markdown
(eval-after-load "org"
  '(require 'ox-gfm nil t)
  )

;; Add option to latex to allow for bigger fonts in pdfs
(add-to-list 'org-latex-classes
  '("extarticle"
    "\\documentclass{extarticle}"
    ("\\section{%s}" . "\\section*{%s}")
    ("\\subsection{%s}" . "\\subsection*{%s}")))

;; org-roam
(require 'org-roam)


;; org-roam-dailies
(require 'org-roam-dailies)

(setq org-roam-dailies-directory "daily/")

(setq org-roam-dailies-capture-templates
      '(("d" "default" entry
         "* %?"
         :target (file+head "%<%Y-%m-%d>.org"
                             "#+title: %<%Y-%m-%d>\n")
         :empty-lines 1)
        ("j" "journal" entry
         "* %<%H:%M> %?\n"
         :target (file+head "%<%Y-%m-%d>.org"
                             "#+title: %<%Y-%m-%d>\n")
         :empty-lines 1)
        ("t" "task" entry
         "* TODO %?\nSCHEDULED: %t\n"
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>\n"
                                ("Tasks"))
         :empty-lines 1)
        ("m" "meeting" entry
         "* %? :meeting:\n%U\n** Attendees\n- \n** Notes\n- \n** Action Items\n- [ ] "
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>\n"
                                ("Meetings"))
         :empty-lines 1)
        ("l" "link" entry
         "* %? :link:\n%U\n%a\n"
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>\n"
                                ("Links"))
         :empty-lines 1)))

(global-set-key (kbd "C-c n d") 'org-roam-dailies-map)


(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer)))

(add-hook 'org-mode-hook (lambda()
						   (company-mode 1)
						   (local-set-key (kbd "<C-tab>") (lambda () (interactive) (company-begin-backend 'company-capf)))
                           ))


;; org-ref
(require 'org-ref)
(setq reftex-default-bibliography '("~/Dropbox/zotero/bib/zotero.bib"))
(setq org-ref-bibliography-notes "~/Dropbox/zotero/bib/zotero.bib"
      org-ref-default-bibliography '("~/Dropbox/zotero/bib/zotero.bib")
      org-ref-pdf-directory "~/Dropbox/pdfdocs")


(setq bibtex-completion-bibliography "~/Dropbox/zotero/bib/zotero.bib"
      bibtex-completion-pdf-field "file"
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
