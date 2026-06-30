;; -*- lexical-binding: t; -*-
;;
;; =============================================================================
;;  gleam.el — Gleam / Lustre powerhouse
;;
;;  Turns firemacs into a full Gleam + Lustre development environment.
;;
;;  Features:
;;    - Tree-sitter grammar auto-install (gleam-ts-mode built-in)
;;    - Format on save via `gleam-ts-format-on-save`
;;    - One-key build, test, run, check, docs
;;    - Compilation-mode integration (error regex)
;;    - Lustre dev server (start / stop / restart / build)
;;    - Org-babel support via ob-gleam
;;    - Project-aware commands (detects gleam.toml root)
;;    - Toggle between src/ and test/ files
;;    - Create new projects, add dependencies
;; =============================================================================

;; ---------------------------------------------------------------------------
;;  Package setup — gleam-ts-mode + ob-gleam
;; ---------------------------------------------------------------------------

(use-package gleam-ts-mode
  :ensure t
  :defer t
  :mode "\\.gleam\\'"
  :hook (gleam-ts-mode . eglot-ensure)
  :config
  ;; ── Tree-sitter grammar ──────────────────────────────────
  (unless (treesit-language-available-p 'gleam)
    (with-eval-after-load 'treesit
      (add-to-list 'treesit-language-source-alist
                   '(gleam . ("https://github.com/gleam-lang/tree-sitter-gleam" "v1.0.0")))
      (gleam-ts-install-grammar)))

  ;; ── Format on save (built-in) ────────────────────────────
  (setq gleam-ts-format-on-save t)

  ;; ── Indentation ──────────────────────────────────────────
  (setq gleam-ts-indent-offset 2))

;; Register the Gleam LSP server for Eglot
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(gleam-ts-mode . ("gleam" "lsp"))))

;; Org-babel support for Gleam code blocks
(use-package ob-gleam
  :ensure t
  :after org
  :config
  (add-to-list 'org-babel-load-languages '(gleam . t)))

;; ---------------------------------------------------------------------------
;;  Project root detection
;; ---------------------------------------------------------------------------

(defun my/gleam-project-root (&optional file)
  "Return the root directory of a Gleam project containing FILE.
Defaults to the current buffer's file name.  Returns nil if no
`gleam.toml' is found in any parent directory."
  (let ((dir (locate-dominating-file
              (or file buffer-file-name default-directory)
              "gleam.toml")))
    (if dir (expand-file-name dir) nil)))

(defun my/gleam-project-root-or-error ()
  "Return the Gleam project root or signal a user-error."
  (or (my/gleam-project-root)
      (user-error "Not inside a Gleam project (no gleam.toml found)")))

;; ---------------------------------------------------------------------------
;;  Build commands — compile-mode integration
;; ---------------------------------------------------------------------------

(defvar my/gleam-compile-buffer-name "*gleam-compile*"
  "Buffer name for Gleam compilation output.")

(defun my/gleam-compile (command &optional args)
  "Run a gleam COMMAND with ARGS in the project root via compilation-mode."
  (let* ((root (my/gleam-project-root-or-error))
         (default-directory root)
         (full-cmd (mapconcat #'shell-quote-argument
                              (cons command args) " ")))
    (with-current-buffer (get-buffer-create my/gleam-compile-buffer-name)
      (read-only-mode -1)
      (erase-buffer))
    (compile full-cmd t)
    (when-let ((buf (get-buffer my/gleam-compile-buffer-name)))
      (with-current-buffer buf
        (when (> (buffer-size) 0)
          (display-buffer buf))))))

(defun my/gleam-build ()
  "Run `gleam build`."
  (interactive)
  (my/gleam-compile "gleam" '("build")))

(defun my/gleam-test (&optional test-name)
  "Run `gleam test`.  With prefix argument, prompt for a specific test."
  (interactive "P")
  (if test-name
      (let ((target (read-string "Test name: ")))
        (my/gleam-compile "gleam" (list "test" "--" target)))
    (my/gleam-compile "gleam" '("test"))))

(defun my/gleam-check ()
  "Run `gleam check` (type-check without emitting code)."
  (interactive)
  (my/gleam-compile "gleam" '("check")))

(defun my/gleam-run (&rest args)
  "Run `gleam run` with optional ARGS."
  (interactive)
  (my/gleam-compile "gleam" (cons "run" args)))

(defun my/gleam-run-with-args ()
  "Run `gleam run` prompting for extra arguments."
  (interactive)
  (let* ((root (my/gleam-project-root-or-error))
         (gleam-toml (with-temp-buffer
                       (insert-file-contents (expand-file-name "gleam.toml" root))
                       (goto-char (point-min))
                       (if (re-search-forward "^name\\s-*=\\s-*\"\\([^\"]+\\)\"" nil t)
                           (match-string-no-properties 1)
                         "")))
         (default-target (if (string-suffix-p "-" gleam-toml)
                             (substring gleam-toml 0 -1)
                           gleam-toml))
         (target (read-string (format "Run target [%s]: " default-target)
                              nil nil default-target)))
    (my/gleam-compile "gleam" (list "run" target))))

(defun my/gleam-format-project ()
  "Run `gleam format` on the whole project."
  (interactive)
  (let ((root (my/gleam-project-root-or-error)))
    (async-shell-command
     (format "cd %s && gleam format"
             (shell-quote-argument root))
     "*gleam-format*")
    (message "Formatting Gleam project…")))

(defun my/gleam-docs ()
  "Run `gleam docs` to generate HTML documentation."
  (interactive)
  (my/gleam-compile "gleam" '("docs")))

(defun my/gleam-docs-build ()
  "Run `gleam docs build` to generate and build documentation."
  (interactive)
  (my/gleam-compile "gleam" '("docs" "build")))

;; ---------------------------------------------------------------------------
;;  Lustre dev server
;; ---------------------------------------------------------------------------

(defvar my/gleam-lustre-dev-process nil
  "The Lustre dev server process, if running.")

(defun my/gleam-lustre-dev ()
  "Start the Lustre dev server (via `lustre_dev_tools`)."
  (interactive)
  (let ((root (my/gleam-project-root-or-error)))
    (when (and my/gleam-lustre-dev-process
               (process-live-p my/gleam-lustre-dev-process))
      (delete-process my/gleam-lustre-dev-process))
    (setq my/gleam-lustre-dev-process
          (start-process "lustre-dev" "*gleam-lustre-dev*"
                         "gleam" "run" "lustre_dev_tools" "dev"))
    (set-process-sentinel
     my/gleam-lustre-dev-process
     (lambda (proc event)
       (when (string-match-p "finished\\|exited" event)
         (my/gleam--on-lustre-dev-stop)
         (message "Lustre dev server stopped"))))
    (message "Lustre dev server starting…")
    (display-buffer (get-buffer-create "*gleam-lustre-dev*"))))

(defun my/gleam--on-lustre-dev-stop ()
  "Cleanup when Lustre dev server stops."
  (setq my/gleam-lustre-dev-process nil))

(defun my/gleam-lustre-dev-stop ()
  "Stop the Lustre dev server."
  (interactive)
  (when (and my/gleam-lustre-dev-process
             (process-live-p my/gleam-lustre-dev-process))
    (kill-process my/gleam-lustre-dev-process)
    (my/gleam--on-lustre-dev-stop)
    (message "Lustre dev server stopped.")))

(defun my/gleam-lustre-dev-restart ()
  "Restart the Lustre dev server."
  (interactive)
  (my/gleam-lustre-dev-stop)
  (my/gleam-lustre-dev))

(defun my/gleam-lustre-build ()
  "Run Lustre build (static site / SPA build)."
  (interactive)
  (my/gleam-compile "gleam" '("run" "lustre_dev_tools" "build")))

;; ---------------------------------------------------------------------------
;;  Goto test / toggle between module and test file
;; ---------------------------------------------------------------------------

(defun my/gleam-toggle-test-file ()
  "Switch between a Gleam module and its test file.
E.g., src/foo.gleam → test/foo_test.gleam and back."
  (interactive)
  (let* ((file (or (buffer-file-name) (user-error "Buffer not visiting a file")))
         (dir (file-name-directory file))
         (name (file-name-base file)))
    (cond
     ;; In test/ dir → jump to src/
     ((string-match-p "\\btest/" dir)
      (let* ((src-path (replace-regexp-in-string "\\btest/" "src/" file))
             (src-file (if (string-suffix-p "_test" name)
                           (replace-regexp-in-string "_test\\.gleam$" ".gleam" src-path)
                         src-path)))
        (if (file-exists-p src-file)
            (find-file src-file)
          (user-error "Source file not found: %s" src-file))))
     ;; In src/ dir → jump to test/
     ((string-match-p "\\bsrc/" dir)
      (let* ((test-path (replace-regexp-in-string "\\bsrc/" "test/" file))
             (test-file (replace-regexp-in-string "\\.gleam$" "_test.gleam" test-path)))
        (if (file-exists-p test-file)
            (find-file test-file)
          (user-error "Test file not found: %s" test-file))))
     (t
      (user-error "Not in a src/ or test/ directory")))))

;; ---------------------------------------------------------------------------
;;  Gleam project — create / deps
;; ---------------------------------------------------------------------------

(defun my/gleam-new-project (name)
  "Create a new Gleam project named NAME in ~/projects/gleam/."
  (interactive "sProject name: ")
  (let* ((dir (expand-file-name name "~/projects/gleam"))
         (default-directory "~"))
    (if (file-exists-p dir)
        (user-error "Project %s already exists at %s" name dir)
      (async-shell-command
       (format "cd ~/projects && gleam new %s" (shell-quote-argument name))
       "*gleam-new*")
      (message "Creating new Gleam project %s…" name))))

(defun my/gleam-add-dependency (package)
  "Add a Gleam dependency by running `gleam add PACKAGE`."
  (interactive "sPackage: ")
  (let ((root (my/gleam-project-root-or-error)))
    (async-shell-command
     (format "cd %s && gleam add %s"
             (shell-quote-argument root)
             (shell-quote-argument package))
     "*gleam-add*")
    (message "Adding %s…" package)))

;; ---------------------------------------------------------------------------
;;  Compilation error regexp for Gleam compiler output
;; ---------------------------------------------------------------------------

(with-eval-after-load 'compile
  ;; Match Gleam compiler errors and warnings:
  ;;
  ;;   error: Description text
  ;;    ┌─ /path/to/file.gleam:12:5
  ;;
  ;; Also handle the "warning:" variant:
  ;;
  ;;   warning: Description text
  ;;    ┌─ /path/to/file.gleam:42:3
  (add-to-list 'compilation-error-regexp-alist-alist
               '(gleam
                 "^[[:space:]]*┌─ \\([^:]+?\\):\\([0-9]+\\):\\([0-9]+\\)"
                 1 2 3))
  (add-to-list 'compilation-error-regexp-alist 'gleam))

;; ---------------------------------------------------------------------------
;;  Local keybindings in gleam-ts-mode buffers
;; ---------------------------------------------------------------------------

(defvar my/gleam-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-b") 'my/gleam-build)
    (define-key map (kbd "C-c C-t") 'my/gleam-test)
    (define-key map (kbd "C-c C-c") 'my/gleam-check)
    (define-key map (kbd "C-c C-r") 'my/gleam-run-with-args)
    (define-key map (kbd "C-c C-f") 'gleam-ts-format)
    (define-key map (kbd "C-c C-d") 'my/gleam-docs)
    map)
  "Keymap for Gleam buffers.")

(add-hook 'gleam-ts-mode-hook
          (lambda ()
            (use-local-map (make-composed-keymap
                            my/gleam-mode-map
                            (current-local-map)))))

(provide 'gleam)
;; gleam.el ends here
