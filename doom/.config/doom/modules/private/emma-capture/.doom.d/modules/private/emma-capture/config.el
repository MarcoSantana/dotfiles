;;; private/emma-capture/config.el -*- lexical-binding: t; -*-

(map! :leader
      (:prefix ("m" . "emma")
       :desc "Set TSV block"       "s" #'emma-set-tsv-block
       :desc "Mark question"       "q" #'emma-mark-question
       :desc "Mark study block"    "b" #'emma-mark-study-block
       :desc "Locate position"     "l" #'emma-locate-position))

(map! :leader
      (:prefix ("T" . "tools")
       :desc "Clean extra lines"      "d" #'emma-clean-extra-lines
       :desc "Normalize characters"   "n" #'emma-normalize-chars
       :desc "Remove trailing spaces" "s" #'emma-remove-trailing-spaces))
