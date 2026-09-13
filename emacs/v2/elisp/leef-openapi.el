;;; leef-openapi.el --- Settings for OpenAPI specs
;;
;; Author: leef

;;; Code:

(require 'treesit)
(require 'xref)
(require 'cl-lib)

;; Grammar repo ships two grammars in one tree:
;;   tree-sitter-openapi/      -> language `openapi' (YAML-flavored)
;;   tree-sitter-openapi-json/ -> language `openapi_json' (JSON-flavored)
(add-to-list 'treesit-language-source-alist
             '(openapi "https://github.com/sailpoint-oss/tree-sitter-openapi"
                       nil "tree-sitter-openapi/src"))
(add-to-list 'treesit-language-source-alist
             '(openapi_json "https://github.com/sailpoint-oss/tree-sitter-openapi"
                             nil "tree-sitter-openapi-json/src"))

;; Ported from tree-sitter-openapi/queries/highlights.scm (node types
;; copied verbatim; capture names mapped to font-lock faces since
;; these grammars don't ship an Emacs-specific query).
;;
;; Two workarounds versus the upstream .scm queries, both due to this
;; Emacs's treesit query engine (see `treesit-query-compile'):
;; 1. Emacs only supports `equal', `match', and `pred' query
;;    predicates -- no `any-of?'. Every `#any-of? @cap "a" "b" ...'
;;    from the upstream query becomes `#match @cap "^\\(a\\|b\\|...\\)$"'
;;    via `leef-openapi--any-of-regexp'.
;; 2. When more than one sibling top-level pattern in a query carries
;;    a predicate, `treesit-font-lock-rules' mis-serializes the Lisp
;;    sexp form into an invalid query. Passing the equivalent query as
;;    a raw string (native `#'-prefixed predicate syntax) avoids it.

(defun leef-openapi--query-string-escape (regexp)
  "Escape REGEXP (a plain Emacs regexp string, e.g. containing literal
\\( \\| \\) or \" characters) for embedding in a treesit query string
literal. The query string's own \"...\" parsing unescapes backslashes
and quotes once before the regexp engine ever sees the result, so
both must be backslash-escaped here first."
  (let ((escaped (replace-regexp-in-string "\\\\" "\\\\\\\\" regexp)))
    (replace-regexp-in-string "\"" "\\\\\"" escaped)))

(defun leef-openapi--any-of-regexp (strings)
  "Build a \"^\\(a\\|b\\|...\\)$\" alternation regexp matching any of
STRINGS, already escaped for splicing into a treesit query string."
  (leef-openapi--query-string-escape
   (concat "^\\(?:" (mapconcat #'regexp-quote strings "\\|") "\\)$")))

(defun leef-openapi--any-of-json-key-regexp (keys)
  "Like `leef-openapi--any-of-regexp' but for a JSON (string) node's
text, which includes the surrounding double quotes, e.g. \"foo\"."
  (leef-openapi--query-string-escape
   (concat "^\\(?:"
           (mapconcat (lambda (k) (concat "\"" (regexp-quote k) "\""))
                      keys "\\|")
           "\\)$")))

(defvar openapi-yaml-ts--font-lock-rules
  (treesit-font-lock-rules
   :language 'openapi
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'openapi
   :feature 'string
   '([(double_quote_scalar)
      (single_quote_scalar)
      (block_scalar)
      (string_scalar)] @font-lock-string-face)

   :language 'openapi
   :feature 'constant
   '((boolean_scalar) @font-lock-constant-face
     (null_scalar) @font-lock-constant-face)

   :language 'openapi
   :feature 'number
   '([(integer_scalar) (float_scalar)] @font-lock-number-face)

   :language 'openapi
   :feature 'label
   '([(anchor_name) (alias_name)] @font-lock-constant-face)

   :language 'openapi
   :feature 'type
   '((tag) @font-lock-type-face)

   :language 'openapi
   :feature 'attribute
   '([(yaml_directive) (tag_directive) (reserved_directive)] @font-lock-preprocessor-face)

   ;; Generic catch-all: every mapping key gets @font-lock-property-use-face
   ;; first; the more specific keyword/property-definition rules below run
   ;; later in this same settings list and, with :override t, repaint the
   ;; keys they match. Order here matters as much as :override does.
   :language 'openapi
   :feature 'property
   '((block_mapping_pair
      key: (flow_node [(double_quote_scalar) (single_quote_scalar)] @font-lock-property-use-face))
     (block_mapping_pair
      key: (flow_node (plain_scalar (string_scalar) @font-lock-property-use-face)))
     (flow_mapping
      (_ key: (flow_node [(double_quote_scalar) (single_quote_scalar)] @font-lock-property-use-face)))
     (flow_mapping
      (_ key: (flow_node (plain_scalar (string_scalar) @font-lock-property-use-face)))))

   ;; See the workaround note above the file's `leef-openapi--any-of-regexp'
   ;; definition: raw query string + #match regex instead of #any-of?.
   :language 'openapi
   :feature 'keyword
   :override t
   (format
     "(block_mapping_pair
        key: (flow_node (plain_scalar (string_scalar) @font-lock-keyword-face))
        (#match \"%s\" @font-lock-keyword-face))
      (block_mapping_pair
        key: (flow_node (plain_scalar (string_scalar) @font-lock-keyword-face))
        (#equal @font-lock-keyword-face \"$ref\"))"
     (leef-openapi--any-of-regexp
      '("openapi" "info" "servers" "paths" "webhooks" "components"
        "arazzo" "sourceDescriptions" "workflows"
        "security" "tags" "externalDocs" "jsonSchemaDialect"
        "swagger" "host" "basePath" "schemes" "consumes" "produces"
        "definitions" "parameters" "responses" "securityDefinitions"
        "get" "put" "post" "delete" "patch" "options" "head" "trace"
        "type" "properties" "required" "items" "schema"
        "allOf" "oneOf" "anyOf" "not"
        "additionalProperties" "discriminator"
        "operationId" "requestBody" "callbacks"
        "content" "headers" "links" "encoding"
        "workflowId" "stepId" "operationPath"
        "successCriteria" "onSuccess" "onFailure"
        "successActions" "failureActions"
        "criteria" "reference" "value"
        "name" "in")))

   :language 'openapi
   :feature 'property-definition
   :override t
   (format
     "(block_mapping_pair
        key: (flow_node (plain_scalar (string_scalar) @font-lock-property-name-face))
        (#match \"%s\" @font-lock-property-name-face))"
     (leef-openapi--any-of-regexp
      '("description" "summary" "title"
        "format" "default" "example" "examples" "enum"
        "nullable" "readOnly" "writeOnly" "deprecated"
        "pattern" "minimum" "maximum" "minLength" "maxLength"
        "minItems" "maxItems" "exclusiveMinimum" "exclusiveMaximum"
        "retryAfter" "retryLimit" "contentType" "payload"
        "target" "dependsOn" "inputs" "outputs")))

   :language 'openapi
   :feature 'delimiter
   '([("," ) ("-") (":") (">") ("?") ("|")] @font-lock-delimiter-face)

   :language 'openapi
   :feature 'bracket
   '(["[" "]" "{" "}"] @font-lock-bracket-face)

   :language 'openapi
   :feature 'punctuation-special
   '(["*" "&" "---" "..."] @font-lock-misc-punctuation-face))
  "Tree-sitter font-lock rules for `openapi-yaml-ts-mode'.")

;; Ported from tree-sitter-openapi-json/queries/highlights.scm.
(defvar openapi-json-ts--font-lock-rules
  (treesit-font-lock-rules
   ;; Generic catch-all first; more specific rules below override it.
   :language 'openapi_json
   :feature 'property
   '((pair key: (_) @font-lock-property-use-face))

   ;; See the workaround note above `leef-openapi--any-of-regexp'.
   :language 'openapi_json
   :feature 'keyword
   :override t
   (format
    "(pair key: (string) @font-lock-keyword-face
       (#match \"%s\" @font-lock-keyword-face))
     (pair key: (string) @font-lock-keyword-face
       (#equal @font-lock-keyword-face \"\\\"$ref\\\"\"))"
    (leef-openapi--any-of-json-key-regexp
     '("openapi" "info" "servers" "paths" "webhooks" "components"
       "arazzo" "sourceDescriptions" "workflows"
       "security" "tags" "externalDocs" "jsonSchemaDialect"
       "swagger" "host" "basePath" "schemes" "consumes" "produces"
       "definitions" "parameters" "responses" "securityDefinitions"
       "get" "put" "post" "delete" "patch" "options" "head" "trace"
       "type" "properties" "required" "items" "schema"
       "allOf" "oneOf" "anyOf" "not"
       "additionalProperties" "discriminator"
       "operationId" "requestBody" "callbacks"
       "content" "headers" "links" "encoding"
       "workflowId" "stepId" "operationPath"
       "successCriteria" "onSuccess" "onFailure"
       "successActions" "failureActions"
       "criteria" "reference" "value"
       "name" "in")))

   :language 'openapi_json
   :feature 'property-definition
   :override t
   (format
    "(pair key: (string) @font-lock-property-name-face
       (#match \"%s\" @font-lock-property-name-face))"
    (leef-openapi--any-of-json-key-regexp
     '("description" "summary" "title"
       "format" "default" "example" "examples" "enum"
       "nullable" "readOnly" "writeOnly" "deprecated"
       "pattern" "minimum" "maximum" "minLength" "maxLength"
       "minItems" "maxItems" "exclusiveMinimum" "exclusiveMaximum"
       "retryAfter" "retryLimit" "contentType" "payload"
       "target" "dependsOn" "inputs" "outputs")))

   :language 'openapi_json
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'openapi_json
   :feature 'string
   '((string) @font-lock-string-face)

   :language 'openapi_json
   :feature 'number
   '((number) @font-lock-number-face)

   :language 'openapi_json
   :feature 'constant
   '([(null) (true) (false)] @font-lock-constant-face)

   :language 'openapi_json
   :feature 'escape-sequence
   :override t
   '((escape_sequence) @font-lock-escape-face))
  "Tree-sitter font-lock rules for `openapi-json-ts-mode'.")

;;;###autoload
(define-derived-mode openapi-yaml-ts-mode prog-mode "OpenAPI[YAML]"
  "Major mode for editing OpenAPI specs in YAML, powered by tree-sitter."
  :group 'openapi
  (when (treesit-ready-p 'openapi)
    (treesit-parser-create 'openapi)
    (setq-local comment-start "# "
                comment-end ""
                comment-start-skip (rx "#" (* (syntax whitespace))))
    (setq-local treesit-font-lock-settings openapi-yaml-ts--font-lock-rules)
    ;; property/property-definition/keyword are ordered so later
    ;; :override t rules win over the earlier catch-all property rule.
    (setq-local treesit-font-lock-feature-list
                '((comment string)
                  (property)
                  (property-definition keyword type label attribute)
                  (constant number)
                  (bracket delimiter punctuation-special)))
    (treesit-major-mode-setup)
    (leef-openapi--setup-xref)))

;;;###autoload
(define-derived-mode openapi-json-ts-mode prog-mode "OpenAPI[JSON]"
  "Major mode for editing OpenAPI specs in JSON, powered by tree-sitter."
  :group 'openapi
  (when (treesit-ready-p 'openapi_json)
    (treesit-parser-create 'openapi_json)
    (setq-local treesit-font-lock-settings openapi-json-ts--font-lock-rules)
    (setq-local treesit-font-lock-feature-list
                '((comment string)
                  (property)
                  (property-definition keyword)
                  (constant number)
                  (escape-sequence)))
    (treesit-major-mode-setup)
    (leef-openapi--setup-xref)))

;; xref backend: jump to $ref targets (M-.) for same-file JSON-pointer
;; refs, e.g. $ref: "#/components/schemas/Foo". Cross-file refs
;; ($ref: "other.yaml#/...") are not resolved.

(defun leef-openapi--node-text (node)
  "Buffer text spanned by NODE, or nil if NODE is nil."
  (and node (treesit-node-text node t)))

(defun leef-openapi--scalar-text (node)
  "Text of a YAML scalar or JSON string NODE, quotes stripped."
  (let ((text (leef-openapi--node-text node)))
    (when text
      (if (and (> (length text) 1)
               (memq (aref text 0) '(?\" ?\'))
               (eq (aref text 0) (aref text (1- (length text)))))
          (substring text 1 -1)
        text))))

(defun leef-openapi--pair-key-text (pair-node)
  "Key text of a YAML block_mapping_pair or JSON pair PAIR-NODE."
  (leef-openapi--scalar-text
   (treesit-node-child-by-field-name pair-node "key")))

(defun leef-openapi--mapping-child (mapping-node pair-type key)
  "Find the child of type PAIR-TYPE in MAPPING-NODE whose key text is
KEY. Returns the pair node, or nil."
  (seq-find (lambda (child)
              (and (string= (treesit-node-type child) pair-type)
                   (equal (leef-openapi--pair-key-text child) key)))
            (treesit-node-children mapping-node)))

(defun leef-openapi--descend-value-mapping (pair-node mapping-type)
  "Return PAIR-NODE's value as a MAPPING-TYPE node. For the JSON
grammar the value node already is the object; for YAML it is wrapped
in an intervening block_node, so unwrap one level in that case."
  (let ((value (treesit-node-child-by-field-name pair-node "value")))
    (when value
      (if (string= (treesit-node-type value) mapping-type)
          value
        (treesit-node-child value 0 t)))))

(defun leef-openapi--resolve-json-pointer (root pointer pair-type mapping-type)
  "Resolve JSON POINTER (e.g. \"/components/schemas/Foo\") against
ROOT's outermost mapping, using PAIR-TYPE (\"block_mapping_pair\" or
\"pair\") and MAPPING-TYPE (\"block_mapping\" or \"object\") for this
grammar. Returns the matching pair node, or nil."
  (let* ((segments (split-string pointer "/" t))
         (mapping (treesit-node-child root 0 t))) ; descend past document/stream wrappers
    (catch 'not-found
      (while (and mapping (not (string= (treesit-node-type mapping) mapping-type)))
        (setq mapping (treesit-node-child mapping 0 t))
        (unless mapping (throw 'not-found nil)))
      (let (pair)
        (dolist (segment segments)
          (unless mapping (throw 'not-found nil))
          (setq pair (leef-openapi--mapping-child mapping pair-type segment))
          (unless pair (throw 'not-found nil))
          (setq mapping (leef-openapi--descend-value-mapping pair mapping-type)))
        pair))))

(defun leef-openapi--ref-pointer-at (node)
  "If NODE (or an ancestor pair) is a $ref value pointing within this
file (\"#/...\"), return the pointer path sans leading \"#/\". Else nil."
  (let* ((pair-type (if (eq major-mode 'openapi-yaml-ts-mode) "block_mapping_pair" "pair"))
         (pair (treesit-parent-until
                node (lambda (n) (string= (treesit-node-type n) pair-type)))))
    (when pair
      (let ((key (leef-openapi--pair-key-text pair))
            (value (leef-openapi--scalar-text
                    (treesit-node-child-by-field-name pair "value"))))
        (when (and (equal key "$ref") value (string-prefix-p "#/" value))
          (substring value 2))))))

(defun leef-openapi-xref-backend ()
  "`xref-backend-functions' entry for OpenAPI YAML/JSON modes."
  'leef-openapi)

(cl-defmethod xref-backend-identifier-at-point ((_backend (eql leef-openapi)))
  (leef-openapi--ref-pointer-at (treesit-node-at (point))))

(cl-defmethod xref-backend-definitions ((_backend (eql leef-openapi)) pointer)
  (let* ((yaml-p (eq major-mode 'openapi-yaml-ts-mode))
         (pair-type (if yaml-p "block_mapping_pair" "pair"))
         (mapping-type (if yaml-p "block_mapping" "object"))
         (pair (leef-openapi--resolve-json-pointer
                (treesit-buffer-root-node) pointer pair-type mapping-type)))
    (if pair
        (let ((line (line-number-at-pos (treesit-node-start pair))))
          (list (xref-make (format "$ref target: #/%s" pointer)
                            (xref-make-buffer-location (current-buffer)
                                                        (treesit-node-start pair)))))
      (user-error "Could not resolve $ref \"#/%s\" in this buffer" pointer))))

(defun leef-openapi--setup-xref ()
  "Enable the `$ref'-jumping xref backend in the current buffer."
  (add-hook 'xref-backend-functions #'leef-openapi-xref-backend nil t))

;; Only claim filenames that look like OpenAPI/Swagger specs rather than
;; hijacking every .yaml/.yml/.json file in existence.
(when (treesit-ready-p 'openapi)
  (add-to-list 'auto-mode-alist
               '("\\(?:openapi\\|swagger\\).*\\.ya?ml\\'" . openapi-yaml-ts-mode)))

(when (treesit-ready-p 'openapi_json)
  (add-to-list 'auto-mode-alist
               '("\\(?:openapi\\|swagger\\).*\\.json\\'" . openapi-json-ts-mode)))

(provide 'leef-openapi)
;;; leef-openapi.el ends here
