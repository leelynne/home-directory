;;; leef-eglot.el --- Settings for eglot  -*- lexical-binding: t; -*-
;;
;; Author: leef

;;; Code:

;; eglot is built into Emacs 29+, so no :ensure.
(use-package eglot
  :ensure nil
  :config
  ;; Don't keep servers around once their last buffer is gone.
  (setq eglot-autoshutdown t)
  ;; Let xref jump into files outside the project (stdlib, deps).
  (setq eglot-extend-to-xref t)
  ;; Block briefly on connect so the first command doesn't race the server.
  (setq eglot-sync-connect 1)
  ;; Logging every JSON event is a noticeable drag with gopls.
  (setq eglot-events-buffer-config '(:size 0 :format full))

  ;; Navigation (M-. M-, M-?) is already bound globally by xref, so only bind
  ;; the eglot commands that have no default binding of their own.
  (define-key eglot-mode-map (kbd "C-c C-l r") 'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c C-l e") 'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c C-l i") 'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c C-l =") 'eglot-format-buffer)
  (define-key eglot-mode-map (kbd "C-c C-l x") 'eglot-reconnect)
  (define-key eglot-mode-map (kbd "C-c C-d") 'eldoc-box-help-at-point))

;; Diagnostics: eglot speaks flymake, but flycheck 38+ bridges them via
;; `global-flycheck-eglot-mode'. Configured alongside flycheck in leef-code.el.

;; eldoc-box: a lsp-ui-doc-style childframe shown on demand at point, instead
;; of eldoc's default of expanding the echo area/minibuffer for long LSP doc
;; strings (which reads as "popping a buffer" for anything past one line).
;; Not enabled globally/automatically -- only on C-c C-d above -- so it stays
;; out of the way otherwise, same as lsp-ui-doc-show used to.
(use-package eldoc-box
  :after eglot)

;; flycheck-mode always adds flycheck-eldoc-function to
;; eldoc-documentation-functions (eglot's own hover/signature functions are
;; there too), so simply having point on a flagged line -- no keypress
;; involved -- feeds that diagnostic into eldoc same as a doc string would.
;; Multi-line/long messages (ktlint's error text with "relations" appended,
;; jdtls' full type names, etc.) then hit the same echo-area-resize behavior
;; that C-c C-d used to: nil forces a single truncated line instead of
;; growing the minibuffer into what reads as a popped-up buffer.
(setq eldoc-echo-area-use-multiline-p nil)

;; flycheck-previous-error/-next-error call flycheck-display-errors-via-eldoc,
;; which asks Eldoc to document "interactively" so the echo area refreshes
;; even after error-navigation commands Eldoc doesn't otherwise recognize.
;; Flycheck tries to confine that "interactive" flag to the echo area (see
;; `flycheck--eldoc-echo-area-only'), but eglot's hover/signature sources
;; answer asynchronously: eldoc's dispatcher reads `eldoc-display-functions'
;; from the *callback*, which runs after flycheck's let-binding has already
;; unwound, so the flag reaches `eldoc-display-in-buffer' unguarded and it
;; pops a *eldoc* window on every error jump -- confirmed by tracing the
;; actual `interactive' argument it receives.
;;
;; `eldoc-display-in-buffer' can't just be dropped from the pipeline though:
;; it's the only thing that populates `eldoc--doc-buffer', which
;; `eldoc-box-help-at-point' (our C-c C-d) reads directly -- removing it
;; entirely left that buffer permanently empty/nil and broke C-c C-d with
;; "Wrong type argument: stringp, nil". So keep it, but force its own
;; `interactive' argument to nil unconditionally: it still refreshes the
;; buffer every time (so eldoc-box has content to show), it just never
;; decides on its own to pop a window for it.
(setq eldoc-display-functions
      (mapcar (lambda (fn)
                (if (eq fn 'eldoc-display-in-buffer)
                    (lambda (docs _interactive) (eldoc-display-in-buffer docs nil))
                  fn))
              eldoc-display-functions))

(use-package consult-eglot
  :after eglot
  :bind (:map eglot-mode-map
              ("C-c C-g" . consult-eglot-symbols)
              ("C-c C-f" . consult-imenu))
  :config
  ;; kotlin-language-server's workspace/symbol response omits `range' from
  ;; SymbolInformation.location entirely (confirmed: gopls always includes
  ;; it, kotlin-language-server never does). consult-eglot's transformer and
  ;; grep-params functions both assume it's there and index straight into
  ;; nil, which is the "wrong-type-argument number-or-marker-p nil" error --
  ;; it comes from consult--marker-from-line-column being handed a nil line.
  ;; Neither function guards against a missing range, and there's no config
  ;; knob for it, so patch the location plist before it reaches them: default
  ;; to line 0/character 0 (jumps to the top of the symbol's file, same as
  ;; picking an ambiguous xref result) rather than crashing the candidate
  ;; list entirely.
  (defun leef/consult-eglot--ensure-range (symbol-info)
    "Return SYMBOL-INFO with a placeholder :range if its :location lacks one."
    (let* ((location (plist-get symbol-info :location))
           (range (plist-get location :range)))
      (if range
          symbol-info
        (plist-put (copy-sequence symbol-info)
                   :location
                   (plist-put (copy-sequence location)
                              :range
                              (list :start (list :line 0 :character 0)
                                    :end (list :line 0 :character 0)))))))

  (advice-add 'consult-eglot--transformer :around
              (lambda (orig symbol-info)
                (funcall orig (leef/consult-eglot--ensure-range symbol-info))))
  (advice-add 'consult-eglot--symbol-information-to-grep-params :around
              (lambda (orig symbol-info)
                (funcall orig (leef/consult-eglot--ensure-range symbol-info)))))

;; cedar
(define-derived-mode cedar-mode prog-mode "Cedar"
  "Major mode for Cedar policy files."
  (setq-local comment-start "//")
  (setq-local comment-end "")
  (setq-local font-lock-defaults
              '((("\\<\\(permit\\|forbid\\|when\\|unless\\|in\\|is\\|has\\|like\\|if\\|then\\|else\\|true\\|false\\)\\>" . font-lock-keyword-face)
                 ("\\<\\([A-Z][A-Za-z0-9_]*\\)::[A-Za-z0-9_:\"]*" . font-lock-type-face)
                 ("\"[^\"]*\"" . font-lock-string-face)
                 ("\\(principal\\|action\\|resource\\|context\\)\\>" . font-lock-variable-name-face)
                 ("//.*$" . font-lock-comment-face)))))
(add-to-list 'auto-mode-alist '("\\.cedar\\'" . cedar-mode))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(cedar-mode . ("cedar-language-server"))))
(add-hook 'cedar-mode-hook #'eglot-ensure)

;; templ needs no setup here: templ-ts-mode registers ("templ" "lsp") with
;; eglot-server-programs itself.

(provide 'leef-eglot)
;;; leef-eglot.el ends here
