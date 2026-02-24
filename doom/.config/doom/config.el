(setq user-full-name "MSantana"
      user-mail-address "msantana@example.com")

(setq doom-theme 'doom-one)

;; Add some subtle transparency if using a compositor (like Pop!_OS's default)
(set-frame-parameter (selected-frame) 'alpha '(95 . 95))
(add-to-list 'default-frame-alist '(alpha . (95 . 95)))

(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 14 :weight 'medium)
      doom-variable-pitch-font (font-spec :family "CaskaydiaCove Nerd Font Propo" :size 15)
      doom-big-font (font-spec :family "FiraCode Nerd Font" :size 20))

;; Enable ligatures
(setq +ligatures-in-modes '(org-mode markdown-mode emacs-lisp-mode web-mode javascript-mode ruby-mode))

(setq display-line-numbers-type 'relative) ; More efficient for Vim users

(after! org
  (setq org-directory "~/org/"
        org-ellipsis " ▾ "
        org-hide-emphasis-markers t
        org-log-done 'time
        org-hide-leading-stars t
        org-priority-faces
        '((?A . error)
          (?B . warning)
          (?C . success)))

  ;; Customizing header sizes
  (custom-set-faces
   '(org-level-1 ((t (:inherit outline-1 :height 1.4 :weight bold))))
   '(org-level-2 ((t (:inherit outline-2 :height 1.3 :weight bold))))
   '(org-level-3 ((t (:inherit outline-3 :height 1.2 :weight semi-bold))))
   '(org-level-4 ((t (:inherit outline-4 :height 1.1 :weight semi-bold)))))

  ;; Use variable pitch for prose in Org
  (add-hook 'org-mode-hook #'mixed-pitch-mode))

(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-star '("◉" "○" "◈" "◇" "✳")
        org-modern-list '((?+ . "•") (?- . "–"))))

(after! markdown-mode
  (setq markdown-header-scaling t
        markdown-header-scaling-values '(1.4 1.3 1.2 1.1 1.0 1.0))
  (add-hook 'markdown-mode-hook #'mixed-pitch-mode))

(use-package! obsidian
  :ensure t
  :demand t
  :config
  (setq obsidian-directory "~/Notes")

  ;; Note: You might want to define some keybindings
  (map! :map obsidian-mode-map
        :localleader
        :desc "Insert link" "l" #'obsidian-insert-link
        :desc "Insert wikilink" "w" #'obsidian-insert-wikilink
        :desc "Follow link" "f" #'obsidian-follow-link-at-point
        :desc "Backlinks" "b" #'obsidian-backlink-show
        :desc "Search vault" "s" #'obsidian-search
        :desc "Daily note" "d" #'obsidian-today)

  ;; Global keybindings for quick access
  (map! :leader
        (:prefix ("n" . "notes")
         (:prefix ("O" . "obsidian")
          :desc "Open vault" "o" (cmd! (find-file obsidian-directory))
          :desc "Search vault" "s" #'obsidian-search
          :desc "Daily note" "d" #'obsidian-today
          :desc "Capture note" "c" #'obsidian-capture))))

;; Ensure obsidian-mode is enabled for files in your vault
(add-hook 'markdown-mode-hook
          (lambda ()
            (when (and (buffer-file-name)
                       (string-prefix-p (expand-file-name obsidian-directory)
                                        (expand-file-name (buffer-file-name))))
              (obsidian-mode 1))))

(setq-default line-spacing 0.12)
(setq confirm-kill-emacs #'yes-or-no-p)

(after! typst-ts-mode
  (add-hook 'typst-ts-mode-hook #'mixed-pitch-mode)
  (add-hook 'typst-ts-mode-hook #'outline-minor-mode))

(add-to-list 'auto-mode-alist '("\\.typ\\'" . typst-ts-mode))

(after! typst-ts-mode
  (setq typst-ts-mode-watch-options "--open")
  
  (map! :map typst-ts-mode-map
        :localleader
        :desc "Preview" "p" #'typst-preview
        :desc "Compile" "c" #'typst-ts-mode-compile
        :desc "Watch"   "w" #'typst-ts-mode-watch))

(after! typst-preview
  (setq typst-preview-browser "firefox") ; or "google-chrome", "chromium", etc.
  (setq typst-preview-args '("--listen" "127.0.0.1:9876")))
