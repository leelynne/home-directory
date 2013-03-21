(global-set-key "\C-x\C-m" 'execute-extended-command) ; alias M-x
(global-set-key "\C-c\C-m" 'execute-extended-command) ; alias M-x

(global-set-key "\C-w" 'backward-kill-word) ; C-w kill word
(global-set-key "\C-x\C-k" 'kill-region) ; realias kill-region
(global-set-key "\C-c\C-k" 'kill-region) ; realias kill-region

(if (fboundp 'tool-bar-mode) (tool-bar-mode -1)) ; no tool bar
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1)) ; no menu bar

(setq c-basic-offset 4) ; indents 4 chars
(setq tab-width 4)          ; and 4 char wide for TAB

(setq-default indent-tabs-mode nil) ; And force use of spaces
(setq inhibit-startup-message t) ; disable start message

(add-to-list 'auto-mode-alist '("\\.el\\'" . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("\\.java$" . java-mode))
(add-to-list 'auto-mode-alist '("\\.cxx$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hxx$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cpp$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.c$" . c-mode))
(add-to-list 'auto-mode-alist '("\\.h$" . c-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . javascript-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . javascript-mode))

;; cedet
(load-file "~/emacs/cedet-1.1/common/cedet.el")
(global-ede-mode 1)                      ; Enable the Project management system
(semantic-load-enable-code-helpers)      ; Enable prototype help and smart completion 
(global-srecode-minor-mode 1)            ; Enable template insertion menu
(semantic-load-enable-minimum-features)

(add-to-list 'load-path "~/emacs/ecb-2.40")

;; enable ansi color
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; shell stuff
(setq ansi-color-names-vector ; better contrast colors
      ["black" "red4" "green4" "yellow4"
       "blue3" "magenta4" "cyan4" "white"])
;; Read only prompt
(add-hook 'shell-mode-hook 
     '(lambda () (toggle-truncate-lines 1)))
(setq comint-prompt-read-only t)
;; ruby
(autoload 'ruby-mode "ruby-mode" "Major mode for editing ruby scripts." t)
(setq auto-mode-alist  (cons '(".rb$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist  (cons '("Rakefile" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist  (cons '("^recs\-[.]*" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist  (cons '(".rhtml$" . html-mode) auto-mode-alist))

;; enable visual feedback on selections
(setq transient-mark-mode t)

;; Add F12 to toggle line wrap
(global-set-key [f12] 'toggle-truncate-lines)

;; enable password hiding
(add-hook 'comint-output-filter-functions 'comint-watch-for-password-prompt)

;; dired reuse
(setq display-time-day-and-date t display-time-24hr-format t)
(display-time)

(global-font-lock-mode t)

;; put backup files in their own directory
(setq backup-directory-alist `(("." . ,(expand-file-name "~/.emacs-backups"))))

(require 'ecb)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-options-version "2.40")
 '(ecb-source-path (quote ("/home/leef/engine/mysql-5.1.57"))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
