;; -*- lexical-binding: t; -*-

;; ---------------------------------------------------------------------------
;;  Vue 3 — SFC editing + Volar LSP
;; ---------------------------------------------------------------------------
(use-package vue-mode
  :defer t
  :mode "\\.vue\\'"
  :hook (vue-mode . eglot-ensure)
  :config
  (setq vue-mode-use-typescript-ts-mode t))

;; ---------------------------------------------------------------------------
;;  Clojure & ClojureScript — LSP + Cider
;; ---------------------------------------------------------------------------
(use-package clojure-mode
  :defer t
  :mode ("\\.clj\\'" "\\.cljs\\'" "\\.cljc\\'" "\\.edn\\'")
  :config
  (add-hook 'clojure-mode-hook 'eglot-ensure))

(use-package cider
  :defer t
  :config
  (setq cider-repl-display-in-current-window t)
  (setq cider-show-error-buffer t)
  (setq cider-auto-select-error-buffer t))

;; ---------------------------------------------------------------------------
;;  Typst — tinymist LSP
;; ---------------------------------------------------------------------------
(use-package typst-ts-mode
  :defer t
  :mode "\\.typ\\'"
  :hook (typst-ts-mode . eglot-ensure))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(typst-ts-mode . ("tinymist"))))

;; ---------------------------------------------------------------------------
;;  Markdown — GFM support + LSP
;; ---------------------------------------------------------------------------
(use-package markdown-mode
  :defer t
  :mode ("\\.md\\'" "\\.markdown\\'")
  :config
  (setq markdown-fontify-code-blocks-natively t))

;; ---------------------------------------------------------------------------
;;  Gleam — handled by the dedicated gleam.el module (below)
;; ---------------------------------------------------------------------------
;; Full Gleam / Lustre setup is in gleam.el — format-on-save, build/test/run
;; commands, compilation integration, Lustre dev server, org-babel support.
;; See: gleam.el

;; ---------------------------------------------------------------------------
;;  Supabase-adjacent — SQL, JSON, YAML, TOML
;; ---------------------------------------------------------------------------
(use-package sql
  :defer t
  :mode ("\\.sql\\'" . sql-mode))

(use-package json-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.json\\'" "\\.jsonc\\'"))

(use-package yaml-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.yaml\\'" "\\.yml\\'"))

(use-package toml-mode
  :defer t
  :mode "\\.toml\\'")
