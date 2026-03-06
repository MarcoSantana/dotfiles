;;; private/emma-capture/autoload.el -*- lexical-binding: t; -*-

;;;; Core Helpers

(defun emma--current-line ()
  (buffer-substring-no-properties
   (line-beginning-position)
   (line-end-position)))

(defun emma--replace-current-line (new)
  (delete-region (line-beginning-position)
                 (line-end-position))
  (insert new))

(defun emma--goto-line-safe (n)
  (goto-char (point-min))
  (forward-line (min (1- n) (1- (count-lines (point-min) (point-max))))))

;;;; TSV Block

;;;###autoload
(defun emma-set-tsv-block ()
  (interactive)
  (let ((letters '("t" "s" "v")))
    (dotimes (i 3)
      (let* ((line (emma--current-line))
             (new (replace-regexp-in-string
                   "^\\*\\w?\\s-*"
                   (format "*%s " (nth i letters))
                   line)))
        (emma--replace-current-line new))
      (forward-line 1)))
  (forward-line 1))

;;;; Question Marking

;;;###autoload
(defun emma-mark-question (&optional distractors)
  (interactive
   (list (or (when current-prefix-arg
               (prefix-numeric-value current-prefix-arg))
             (read-number "Distractors (default 5): " 5))))
  (let* ((line (emma--current-line))
         (new (replace-regexp-in-string "^\\*\\w?\\s-*" "*q " line)))
    (emma--replace-current-line new)
    (forward-line (1+ distractors))))

;;;###autoload
(defun emma-mark-study-block (&optional count)
  (interactive
   (list (read-number "Questions to process (default 5): " 5)))
  (dotimes (_ count)
    (emma-mark-question 5)))

;;;; Cleanup Tools

;;;###autoload
(defun emma-remove-trailing-spaces ()
  (interactive)
  (delete-trailing-whitespace)
  (message "Trailing spaces removed"))

;;;###autoload
(defun emma-normalize-chars ()
  (interactive)
  (let ((maps '(("—" . "-")
                ("–" . "-")
                ("“" . "\"")
                ("”" . "\"")
                ("‘" . "'")
                ("’" . "'")
                ("…" . "...")
                ("\u00A0" . " "))))
    (save-excursion
      (goto-char (point-min))
      (dolist (pair maps)
        (while (search-forward (car pair) nil t)
          (replace-match (cdr pair) nil t)))))
  (message "Characters normalized"))

;;;###autoload
(defun emma-clean-extra-lines ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\n\\{3,\\}" nil t)
      (replace-match "\n\n")))
  (message "Extra lines cleaned"))

;;;; Locate Position

;;;###autoload
(defun emma-locate-position ()
  (interactive)
  (let ((row (line-number-at-pos))
        (tags '(("^\\*v" . "Case")
                ("^\\*s" . "Subtopic")
                ("^\\*t" . "Topic"))))
    (dolist (tag tags)
      (save-excursion
        (goto-char (point-min))
        (forward-line (1- row))
        (when (re-search-backward (car tag) nil t)
          (message "%s: %s (Line %d)"
                   (cdr tag)
                   (string-trim
                    (replace-regexp-in-string "^\\*\\w\\s-*" ""
                                              (emma--current-line)))
                   (line-number-at-pos)))))))
