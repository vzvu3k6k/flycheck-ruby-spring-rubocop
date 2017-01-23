;;; flycheck-ruby-spring-rubocop.el --- Run rubocop via spring binstub.  -*- lexical-binding: t; -*-

;; Copyright (C) 2016 vzvu3k6k

;; Author: vzvu3k6k <vzvu3k6k@gmail.com>
;; Keywords: flycheck, ruby, rubocop
;; Package-Requires: ((flycheck "31-cvs") (f "0.19.0") (dash "2.12.1"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is a flycheck extension to run rubocop via spring binstub.

;;; Code:

(require 'flycheck)
(require 'f)
(require 'dash)

;; Based on the definition of ruby-rubocop in flycheck.el
;; https://github.com/flycheck/flycheck/blob/13fba48/flycheck.el
(flycheck-define-checker ruby-spring-rubocop
  "A Ruby syntax and style checker using the RuboCop tool via spring binstub.

Based on ruby-rubocop.

See URL `http://batsov.com/rubocop/', `https://github.com/rails/spring' and `https://github.com/toptal/spring-commands-rubocop'."
  ;; For spring binstub to work, it is required to set `default-directory` properly.
  :working-directory flycheck-ruby-spring-rubocop--find-default-directory

  ;; Find a spring binstub and set it as executable.
  ;; If a binstub is not found, disable this checker.
  :enabled
  (lambda ()
    (--if-let (flycheck-ruby-spring-rubocop--find-executable default-directory)
        (setq-local flycheck-ruby-spring-rubocop-executable it)))

  ;; The following definitions are dead copy of ruby-rubocop.
  :command ("rubocop" "--display-cop-names" "--format" "emacs"
            ;; Explicitly disable caching to prevent Rubocop 0.35.1 and earlier
            ;; from caching standard input.  Later versions of Rubocop
            ;; automatically disable caching with --stdin, see
            ;; https://github.com/flycheck/flycheck/issues/844 and
            ;; https://github.com/bbatsov/rubocop/issues/2576
            "--cache" "false"
            (config-file "--config" flycheck-rubocoprc)
            (option-flag "--lint" flycheck-rubocop-lint-only)
            ;; Rubocop takes the original file name as argument when reading
            ;; from standard input
            "--stdin" source-original)
  :standard-input t
  :error-patterns
  ((info line-start (file-name) ":" line ":" column ": C: "
         (optional (id (one-or-more (not (any ":")))) ": ") (message) line-end)
   (warning line-start (file-name) ":" line ":" column ": W: "
            (optional (id (one-or-more (not (any ":")))) ": ") (message)
            line-end)
   (error line-start (file-name) ":" line ":" column ": " (or "E" "F") ": "
          (optional (id (one-or-more (not (any ":")))) ": ") (message)
          line-end))
  :modes (enh-ruby-mode ruby-mode)
  :next-checkers ((warning . ruby-rubylint)))

(add-to-list 'flycheck-checkers 'ruby-spring-rubocop)

;; Based on the definition of flycheck-elixir--find-default-directory in flycheck.el
(defun flycheck-ruby-spring-rubocop--find-default-directory (_checker)
  "Come up with a suitable default directory for spring binstub to run CHECKER in."
  (and
   buffer-file-name
   (locate-dominating-file buffer-file-name "Gemfile")))

(defun flycheck-ruby-spring-rubocop--find-executable (working-directory)
  "Come up with a spring binstub."
  (and working-directory
       (let* ((bin-dir (f-join working-directory "bin"))
              (local-rubocop (f-join bin-dir "rubocop")))
         (when (f-exists? local-rubocop)
           local-rubocop))))

(provide 'flycheck-ruby-spring-rubocop)
;;; flycheck-ruby-spring-rubocop.el ends here
