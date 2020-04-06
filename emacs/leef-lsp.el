;;; leef-lsp.el --- Settings for lsp
;;
;; Author: leef

;;; Code:

;; Additions to prelude-lsp module
(prelude-require-packages '(lsp-java helm-lsp treemacs-lsp))

(require 'prelude-lsp)
(require 'lsp-mode)
(require 'company-lsp)
(push 'company-lsp company-backends)
(setq lsp-enable-snippet nil)

;;; leef-lsp.el ends here
