;;; leef-caddy.el --- Settings for Caddyfiles
;;
;; Author: leef

;;; Code:

(add-to-list 'treesit-language-source-alist
             '(caddyfile "https://github.com/caddyserver/tree-sitter-caddyfile"))

(defvar caddyfile-ts--font-lock-rules
  (treesit-font-lock-rules
   :language 'caddyfile
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'caddyfile
   :feature 'string
   '([(interpreted_string_literal)
      (raw_string_literal)
      (heredoc)
      (cel_expression)] @font-lock-string-face)

   :language 'caddyfile
   :feature 'constant
   '([(environment_variable)
      (placeholder)] @font-lock-constant-face)

   :language 'caddyfile
   :feature 'number
   '([(duration_literal)
      (int_literal)
      (status_code_fallback)] @font-lock-number-face)

   :language 'caddyfile
   :feature 'keyword
   '([(snippet_name)
      (named_route_identifier)
      (site_address)] @font-lock-keyword-face)

   :language 'caddyfile
   :feature 'type
   '([(network_address)
      (ip_address_or_cidr)
      (path)] @font-lock-type-face)

   :language 'caddyfile
   :feature 'property
   '((directive (directive_name) @font-lock-property-name-face))

   :language 'caddyfile
   :feature 'function
   '((named_matcher (matcher_identifier (matcher_name)) @font-lock-function-name-face)
     (matcher (matcher_identifier (matcher_name)) @font-lock-function-name-face)
     (matcher) @font-lock-function-name-face
     (matcher_directive (matcher_directive_name) @font-lock-function-name-face))

   :language 'caddyfile
   :feature 'escape-sequence
   :override t
   '((escape_sequence) @font-lock-escape-face)

   :language 'caddyfile
   :feature 'bracket
   '(["{" "}"] @font-lock-bracket-face))
  "Tree-sitter font-lock rules for `caddyfile-ts-mode'.")

;;;###autoload
(define-derived-mode caddyfile-ts-mode prog-mode "Caddyfile"
  "Major mode for editing Caddyfiles, powered by tree-sitter."
  :group 'caddyfile
  (when (treesit-ready-p 'caddyfile)
    (treesit-parser-create 'caddyfile)
    (setq-local comment-start "# "
                comment-end ""
                comment-start-skip (rx "#" (* (syntax whitespace))))
    (setq-local treesit-font-lock-settings caddyfile-ts--font-lock-rules)
    (setq-local treesit-font-lock-feature-list
                '((comment string)
                  (keyword type property)
                  (constant number function)
                  (escape-sequence bracket)))
    (treesit-major-mode-setup)))

(when (treesit-ready-p 'caddyfile)
  (add-to-list 'auto-mode-alist '("\\(?:^\\|/\\)Caddyfile\\'" . caddyfile-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.caddy\\'" . caddyfile-ts-mode)))

(provide 'leef-caddy)
;;; leef-caddy.el ends here
