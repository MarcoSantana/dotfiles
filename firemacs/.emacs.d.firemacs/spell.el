;; -*- lexical-binding: t; -*-
;;
;; spell.el — Spelling (flyspell + aspell) and grammar (LanguageTool)
;; with Spanish/English support and one-key toggles.
;;
;; Toggles (SPC leader):
;;   SPC t s   toggle spelling on/off
;;   SPC t g   run / clear grammar check (LanguageTool)
;;   SPC t L   switch language es <-> en

;; ---------------------------------------------------------------------------
;;  Spelling — flyspell + aspell (es / en)
;; ---------------------------------------------------------------------------

(require 'ispell)

(setq ispell-program-name "aspell")
(setq ispell-dictionary "en")   ;; default language

;; aspell ships the dictionaries we need ("en" and "es" — see `aspell dicts`).

;; ---------------------------------------------------------------------------
;;  Grammar — LanguageTool (via the `langtool` package)
;; ---------------------------------------------------------------------------

(use-package langtool
  :ensure t
  :defer t
  :config
  (setq langtool-language-tool-jar
        "/extra/languagetool/LanguageTool-6.6/languagetool-commandline.jar")
  (setq langtool-java-bin "java")
  (setq langtool-mother-tongue "es")       ;; rule explanations in Spanish
  (setq langtool-default-language "en-US"))

;; ---------------------------------------------------------------------------
;;  Language state + switching (keeps aspell and langtool in sync)
;; ---------------------------------------------------------------------------

(defvar my/prose-lang 'en
  "Current prose language: `en' or `es'.")

(defun my/prose-set-language (lang)
  "Set spelling and grammar language to LANG (`en' or `es')."
  (interactive)
  (require 'langtool)
  (setq my/prose-lang lang)
  (cond
   ((eq lang 'en)
    (ispell-change-dictionary "en" t)
    (setq langtool-default-language "en-US"))
   ((eq lang 'es)
    (ispell-change-dictionary "es" t)
    (setq langtool-default-language "es")))
  ;; Re-check any open flyspell buffer in the new language.
  (when (and (boundp 'flyspell-mode) flyspell-mode)
    (flyspell-buffer))
  (message "Prose language: %s"
           (if (eq lang 'en) "English" "Spanish")))

(defun my/prose-toggle-language ()
  "Toggle prose language between English and Spanish."
  (interactive)
  (my/prose-set-language (if (eq my/prose-lang 'en) 'es 'en)))

;; ---------------------------------------------------------------------------
;;  Toggles
;; ---------------------------------------------------------------------------

(defun my/spell-toggle ()
  "Toggle on-the-fly spelling (flyspell) in the current buffer."
  (interactive)
  (if (and (boundp 'flyspell-mode) flyspell-mode)
      (progn
        (flyspell-mode -1)
        (message "Spelling: off"))
    (progn
      (flyspell-mode 1)
      (message "Spelling: on"))))

(defvar-local my/grammar-active nil
  "Non-nil when LanguageTool overlays are shown in this buffer.")

(defun my/grammar-toggle ()
  "Run a grammar check (LanguageTool) or clear its highlighting."
  (interactive)
  (require 'langtool)
  (if my/grammar-active
      (progn
        (langtool-check-done)
        (setq my/grammar-active nil)
        (message "Grammar: off"))
    (langtool-check)
    (setq my/grammar-active t)
    (message "Grammar: checking…")))

;; ---------------------------------------------------------------------------
;;  Enable spelling automatically in prose buffers
;; ---------------------------------------------------------------------------

(defvar my/prose-modes
  '(org-mode markdown-mode text-mode typst-ts-mode latex-mode LaTeX-mode)
  "Major modes where spelling is enabled automatically.")

(dolist (mode my/prose-modes)
  (let ((hook (intern (concat (symbol-name mode) "-hook"))))
    (add-hook hook (lambda () (flyspell-mode 1)))))

(provide 'spell)
;; spell.el ends here
