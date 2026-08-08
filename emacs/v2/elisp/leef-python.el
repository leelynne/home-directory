;;; leef-python.el --- Settings for python  -*- lexical-binding: t; -*-
;;
;; Author: leef

;;; Code:

;; No eglot-server-programs entry here on purpose: eglot's built-in
;; (python-mode python-ts-mode) entry already searches pylsp, pyls,
;; basedpyright-langserver, pyright-langserver, pyrefly, jedi-language-server,
;; `ruff server' and ruff-lsp, taking the first one found on PATH.
;; basedpyright is the only one installed (`uv tool install basedpyright'), so
;; it wins without any configuration.
;;
;; That "first found" rule is also the one hazard worth knowing about: when
;; several are present eglot prompts "More than one server executable
;; available" on every connect. So don't leave a stray pylsp or pyrefly
;; around unless you want to pick one each time. Bare `ruff' is safe -- eglot
;; looks for the `("ruff" "server")' and ruff-lsp entries, both of which sort
;; after basedpyright.
;;
;; basedpyright rather than upstream pyright because it ships as a
;; self-contained pypi wheel with node bundled, so `uv tool install' is the
;; entire install; pyright is npm-first and its pypi wrapper downloads node on
;; first run. The type-checking engine is the same.
;;
;; Astral's `ty' is the obvious future contender -- same Rust lineage as ruff
;; and dramatically faster -- but as of Aug 2026 it is still 0.0.x beta and
;; documents breaking diagnostic changes between patch releases, so it is not
;; the default. Switching is a config no-op: `uv tool install ty', uninstall
;; basedpyright (or eglot will prompt), restart. Nothing in this file changes.
;;
;; No major-mode-remap-alist entry either: treesit-auto ships a python recipe
;; remapping python-mode to python-ts-mode, and global-treesit-auto-mode in
;; leef-code.el applies it given tree-sitter/libtree-sitter-python.dylib.

;; pet ("Python Executable Tracker") solves the one problem that is genuinely
;; Python-specific and unavoidable: basedpyright resolves imports against an
;; interpreter, so if it can't find the project's virtualenv then every
;; third-party import becomes a reportMissingImports error and the session is
;; nothing but noise. This is the usual cause of "the Python LSP is broken".
;;
;; basedpyright does default to .venv/bin/python at the project root, so a
;; plain `uv venv' layout happens to work unaided -- but only that layout. pet
;; walks VIRTUAL_ENV, pixi, conda/mamba, poetry, hatch, pipenv, a
;; .venv/venv/env directory, then pyenv, and hands the result to whichever
;; server eglot picked.
;;
;; Two properties made it preferable to hand-rolling a :pythonPath into
;; eglot-workspace-configuration:
;;
;;   * It sends `python.pythonPath', pointing at the venv's interpreter,
;;     rather than the venvPath+venv pair. basedpyright's own docs call
;;     venvPath "not recommended ... less robust" since it uses pyright's
;;     internal path logic instead of asking the interpreter for its sys.path.
;;     Most "I set venvPath and still get reportMissingImports" reports are
;;     that trap: venvPath wants the directory *containing* venvs, so a uv
;;     layout needs venvPath="." plus venv=".venv", not venvPath=".venv".
;;   * It deep-merges via map-merge-with rather than overwriting, so it
;;     composes with the :java and :kotlin sections that leef-code.el merges
;;     into leef/eglot-workspace-configuration instead of clobbering them.
;;
;; It also sets flycheck-python-ruff-executable buffer-locally to the venv's
;; own ruff when the project ships one, so a repo pinning a specific ruff gets
;; linted by that version rather than the global uv-installed one.
;;
;; Caveat for the next eglot upgrade: pet works by advising eglot internals
;; (eglot--guess-contact, eglot--workspace-configuration-plist). If Python
;; buffers ever stop connecting right after an eglot bump, that advice is the
;; first place to look -- `M-x pet-eglot-teardown' then reconnect to confirm.
;;
;; pet can also read poetry/pipenv/conda metadata, which needs a TOML/YAML
;; parser it doesn't bundle -- it shells out to `dasel', which is not
;; installed here. That is deliberately not a prerequisite: plain .venv
;; discovery is locate-dominating-file with no parsing at all, and the parse
;; is wrapped in condition-case reporting through pet-report-error, silent
;; unless pet-debug is non-nil. `brew install dasel' only if a poetry or
;; pipenv project turns up.
(use-package pet
  :config
  ;; Depth -10 so pet runs early in the hook: it sets python-shell-interpreter
  ;; and the executable variables that everything after it reads.
  (add-hook 'python-base-mode-hook #'pet-mode -10))

;; Prefer a project-local .venv over an inherited VIRTUAL_ENV.
;;
;; pet checks VIRTUAL_ENV first, which is the right default -- an explicitly
;; activated venv should win. It goes wrong here because launching Emacs from
;; a shell that has some unrelated venv active exports VIRTUAL_ENV into the
;; Emacs environment (exec-path-from-shell imports it), and from then on every
;; Python buffer in every project gets that one interpreter. The symptom is
;; subtle rather than loud: imports appear to resolve, because the stray venv
;; happens to have some of the same packages, while anything it lacks reports
;; reportMissingImports and any version skew produces phantom type errors.
;;
;; This was observed live: with VIRTUAL_ENV pointing at an unrelated project,
;; pet returned that interpreter for a test project that had its own .venv one
;; directory up; unsetting VIRTUAL_ENV made pet find the right one immediately.
;;
;; So: if the project root has its own .venv, that wins. Otherwise fall
;; through to pet's normal search, which still honours VIRTUAL_ENV -- so
;; deliberately activating a venv and opening a file outside any project
;; behaves as before.
(with-eval-after-load 'pet
  (defun leef/pet-prefer-project-venv (orig &rest args)
    "Return the project's own .venv if it has one, else defer to ORIG.
Advice around `pet-virtualenv-root', called with ARGS."
    (let* ((root (and buffer-file-name
                      (locate-dominating-file buffer-file-name ".venv")))
           (venv (and root (expand-file-name ".venv/" root))))
      (if (and venv (file-directory-p venv))
          venv
        (apply orig args))))
  (advice-add 'pet-virtualenv-root :around #'leef/pet-prefer-project-venv))

;; Relax basedpyright from its default strictness to pyright's.
;;
;; basedpyright defaults typeCheckingMode to "recommended", which is stricter
;; than upstream pyright's "standard" and turns on the reportAny and
;; reportUnknown* families. Those fire on any function that isn't fully
;; annotated and on any library without complete stubs, which on ordinary code
;; buries the real diagnostics. Measured on one 13-line file with a genuine
;; type error in it: "recommended" produced 10 diagnostics, "standard"
;; produced 1 -- and the 1 was the real bug. Nothing of value is lost.
;;
;; "standard" also matches what Remitly repos actually do. Of the seven local
;; repos that configure pyright or ty, not one runs a strict mode without
;; walking it back: bifrost sets typeCheckingMode "standard" explicitly,
;; pen-queue-api sets "basic", oraql and va-agent-svc configure only venv
;; paths (so inherit pyright's "standard"), fides-sync sets
;; reportUnknownParameterType false, squall (ty) ignores unresolved-attribute
;; and invalid-argument-type, and the two neon repos -- the only ones on
;; "strict" -- downgrade reportUnknownArgumentType, reportUnknownParameterType
;; and reportUnknownMemberType to warnings with reportMissingTypeStubs off.
;; Ruff is the near-universal standard there (83 of 91 pyproject.toml files);
;; type checking is used by well under a quarter of repos, and no repo uses
;; basedpyright at all.
;;
;; Keyed :basedpyright rather than :python -- basedpyright reads its own
;; section for settings pyright doesn't have, and typeCheckingMode is
;; accepted there. A project's own pyproject.toml or pyrightconfig.json still
;; wins over this, so the repos listed above keep their chosen settings and
;; this only supplies the default for everything else.
;;
;; Merged into leef/eglot-workspace-configuration rather than set directly:
;; eglot-workspace-configuration is a single global variable, so each language
;; has to plist-put into the shared one or it clobbers the :java and :kotlin
;; sections from leef-code.el. Same reason that defvar exists.
(with-eval-after-load 'leef-code
  (setq leef/eglot-workspace-configuration
        (plist-put leef/eglot-workspace-configuration
                   :basedpyright
                   '(:analysis (:typeCheckingMode "standard"))))
  (setq-default eglot-workspace-configuration
                leef/eglot-workspace-configuration))

;; ruff for both linting and formatting, deliberately kept outside eglot.
;;
;; Linting needs no configuration at all here, which looks like an omission
;; and isn't. flycheck ships a `python-ruff' checker, and leef-code.el sets
;; flycheck-eglot-exclusive to nil -- which makes `eglot-check' chain onward
;; to the first command checker supporting the buffer's major mode.
;; python-ruff is first among the Python checkers in flycheck-checkers, so
;; basedpyright's type diagnostics and ruff's lint diagnostics both land in
;; the same flycheck buffer with no wiring. Same arrangement as the kotlin
;; eglot+ktlint pairing.
;;
;; So: no flycheck-define-checker, no flymake-ruff, and no eglot-stay-out-of.
;; (The eglot-stay-out-of advice found in most write-ups is for vanilla
;; flymake setups; the flycheck bridge here makes it unnecessary.) python-ruff
;; also finds pyproject.toml / ruff.toml / .ruff.toml on its own via
;; flycheck-python-ruff-config.
;;
;; python-ruff chains onward to python-mypy in turn, which is harmless: mypy
;; isn't installed and flycheck skips a checker whose executable is missing.
;;
;; Formatting has to be a reformatter rather than eglot-format-buffer, which
;; is the opposite of the go setup and worth spelling out: basedpyright is a
;; type checker and advertises no documentFormattingProvider at all, so
;; eglot-format-buffer would silently do nothing in a Python buffer.
;;
;; Two formatters, because ruff splits the work the same way gofmt and
;; goimports do: `ruff format' explicitly does not sort imports -- that is
;; lint rule I001, applied by `ruff check'. Hence the same
;; imports-then-format ordering used for go.
;;
;; On the flags: --fix-only suppresses the diagnostic report so only code
;; reaches stdout (leftover violations are flycheck's job, not the
;; formatter's), and --select I restricts that pass to import sorting so it
;; cannot quietly rewrite anything else on save. --stdin-filename lets ruff
;; resolve per-file config, excludes and first-party module detection for a
;; buffer arriving over a pipe; without it, first-party imports get grouped as
;; third-party. Guarded with `when buffer-file-name' so an unsaved scratch
;; buffer doesn't pass a nil argument.
(use-package reformatter
  :config
  (reformatter-define ruff-isort
    :program "ruff"
    :args `("check" "--fix-only" "--select" "I" "--quiet"
            ,@(when buffer-file-name
                (list "--stdin-filename" buffer-file-name))
            "-"))

  (reformatter-define ruff-format
    :program "ruff"
    :args `("format" "--quiet"
            ,@(when buffer-file-name
                (list "--stdin-filename" buffer-file-name))
            "-")))

(defun leef/python-eglot-setup ()
  "Editing conveniences for Python buffers.

`python-indent-offset' is the variable to set, for both python-mode and
python-ts-mode: unlike java-ts-mode or json-ts-mode there is no
`python-ts-mode-indent-offset'.  python-ts-mode keeps
`python-indent-line-function' rather than switching to tree-sitter's indent
engine, so both modes read the same variable.  It matters beyond local
editing too, since eglot derives the LSP FormattingOptions it sends from
`indent-tabs-mode' and `tab-width'.

4 spaces is PEP 8, which is also what ruff format emits and what
`python-indent-offset' already defaults to.  Set explicitly anyway, because
python-mode otherwise guesses the offset from the first indented block in the
file and will happily adopt a 2-space file's convention -- that guess is
`python-indent-guess-indent-offset', and the source of the \"Can't guess
python-indent-offset, using defaults: 4\" message."
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (setq-local python-indent-offset 4)
  (setq-local python-indent-guess-indent-offset nil)
  ;; snake_case is the norm, but decorators, CamelCase class names and dunder
  ;; methods all benefit from subword motion.
  (subword-mode +1)
  (local-set-key (kbd "<C-tab>") 'company-capf))

;; Both hooks even though treesit-auto remaps python-mode to python-ts-mode:
;; the remap only applies when the grammar loads, and python-mode is still
;; what gets used if it ever doesn't.
(dolist (hook '(python-mode-hook python-ts-mode-hook))
  (add-hook hook #'eglot-ensure)
  (add-hook hook #'leef/python-eglot-setup)
  ;; Ordering: imports must be sorted before `ruff format' runs -- that is the
  ;; direction ruff documents, since sorting afterwards can leave the buffer
  ;; wanting another pass.
  ;;
  ;; The registration order below looks backwards for that, and isn't, because
  ;; add-hook prepends twice. These two calls leave the mode hook as
  ;; (format-on-save isort-on-save ...), so format-on-save is *enabled* first;
  ;; but enabling each mode prepends its own function to before-save-hook, so
  ;; that second reversal restores the intended order. Verified: the resulting
  ;; before-save-hook is (ruff-isort-buffer ruff-format-buffer t).
  ;;
  ;; Enabled as minor modes rather than adding the buffer functions to
  ;; before-save-hook directly so either can be switched off in a single
  ;; buffer (M-x ruff-format-on-save-mode) when a file needs leaving alone --
  ;; same as jq-format-on-save-mode in leef-code.el.
  (add-hook hook #'ruff-isort-on-save-mode)
  (add-hook hook #'ruff-format-on-save-mode))

(provide 'leef-python)
;;; leef-python.el ends here
