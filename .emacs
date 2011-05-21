(global-set-key "\C-x\C-m" 'execute-extended-command) ; alias M-x
(global-set-key "\C-c\C-m" 'execute-extended-command) ; alias M-x

(global-set-key "\C-w" 'backward-kill-word) ; C-w kill word
(global-set-key "\C-x\C-k" 'kill-region) ; realias kill-region
(global-set-key "\C-c\C-k" 'kill-region) ; realias kill-region

(if (fboundp 'tool-bar-mode) (tool-bar-mode -1)) ; no tool bar
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1)) ; no menu bar

(setq c-basic-offset 4) ; indents 4 chars
(setq tab-width 4)          ; and 4 char wide for TAB
(setq indent-tabs-mode nil) ; And force use of spaces
(setq inhibit-startup-message t) ; disable start message

(add-to-list 'auto-mode-alist '("\\.el\\'" . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("\\.java$" . java-mode))
(add-to-list 'auto-mode-alist '("\\.cxx$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hxx$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cpp$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.c$" . c-mode))
(add-to-list 'auto-mode-alist '("\\.h$" . c-mode))

;; cedet
(load-file "~/emacs/cedet-1.0/common/cedet.el")
(global-ede-mode 1)                      ; Enable the Project management system
(semantic-load-enable-code-helpers)      ; Enable prototype help and smart completion 
(global-srecode-minor-mode 1)            ; Enable template insertion menu
(semantic-load-enable-minimum-features)

(add-to-list 'load-path "/home/leef/emacs/ecb-2.40")

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