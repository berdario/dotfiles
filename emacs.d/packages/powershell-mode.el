;;; powershell-mode.el --- Mode for editing Powershell scripts

;; Copyright (C) 2009, 2010 Fr�d�ric Perrin
;; Copyright (C) 2012 Richard Bielawski rbielaws-at-i1-dot-net
;;               http://www.emacswiki.org/emacs/Rick_Bielawski

;; Author: Fr�d�ric Perrin <frederic (dot) perrin (arobas) resel (dot) fr>
;; Keywords: Powershell, Monad, MSH

;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation, either version 3 of the License,
;; or (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Fr�d�ric Perrin Comments:
;; This was written from scratch, without using Vivek Sharma's code:
;; it had issues I wanted to correct, but unfortunately there were no
;; licence indication, and Vivek didn't answered my mails.
;;
;;; Rick Bielawski Comments:
;; On March 31, 2012 Fr�d�ric gave me permission to take over support.
;; I've added support multi-line comments and here-strings as well
;; as many other enhancement/features such as:
;; Functions to quote, unquote and escape a selection and one to wrap
;; a selection in $().  Meanwhile I hope I didn't break anything.

;; Variables you may want to customize.
(defgroup powershell nil
  "Customization of PowerShell mode."
  :link '(custom-group-link :tag "Font Lock Faces group" font-lock-faces)
  :group 'languages   )

(defcustom powershell-indent 4
  "Amount of horizontal space to indent after, for instance, an
opening brace"
  :type 'integer
  :group 'powershell)

(defcustom powershell-continuation-indent 2
  "Amount of horizontal space to indent a continuation line"
  :type 'integer
  :group 'powershell)

(defcustom powershell-continued-regexp  ".*\\(|[\\t ]*\\|`\\)$"
  "Regexp matching a continued line (ending either with an
explicit backtick, or with a pipe)."
  :type 'integer
  :group 'powershell)

(defun powershell-continuation-line-p ()
  "Returns t is the current line is a continuation line (i.e. the
previous line is a continued line, ending with a backtick or a pipe"
  (interactive)
  (save-excursion
    (forward-line -1)
    (looking-at powershell-continued-regexp)))

(defun powershell-indent-line-amount ()
  "Returns the column to which the current line ought to be indented."
  (interactive)
  (beginning-of-line)
  (let ((closing-paren (looking-at "[\t ]*[])}]")))
    ;; a very simple indentation method: if on a continuation line (i.e. the
    ;; previous line ends with a trailing backtick or pipe), we indent relative
    ;; to the continued line; otherwise, we indent relative to the ([{ that
    ;; opened the current block.
    (if (powershell-continuation-line-p)
	(progn
	  (while (powershell-continuation-line-p)
	    (forward-line -1))
	  (+ (current-indentation) powershell-continuation-indent))
      (condition-case nil
	  (progn
	    (backward-up-list)
	    ;; indentation relative to the opening paren: if there is text (no
	    ;; comment) after the opening paren, vertically align the block
	    ;; with this text; if we were looking at the closing paren, reset
	    ;; the indentation; otherwise, indent the block by powershell-indent.
	    (cond ((not (looking-at ".[\t ]*\\(#.*\\)?$"))
		   (forward-char)
		   (skip-chars-forward " \t")
		   (current-column))
		  (closing-paren
		   (current-indentation))
		  (t
		   (+ (current-indentation) powershell-indent))))
	(scan-error ;; most likely, we are at the top-level
	 0)))))

(defun powershell-indent-line ()
  "Indent the current line of powershell mode, leaving the point
in place if it is inside the meat of the line"
  (interactive)
  (let ((savep (> (current-column) (current-indentation)))
	(amount (save-excursion (powershell-indent-line-amount))))
    (if savep
	(save-excursion (indent-line-to amount))
      (indent-line-to amount))))
 
(defun powershell-quote-selection (beg end)
  "Quotes the selection with single quotes and doubles embedded single quotes"
  (interactive `(,(region-beginning) ,(region-end)))
  (if (not mark-active)
      (error "Command requires a marked region"))
  (goto-char beg)
  (while (re-search-forward "'" end t)
    (replace-match "''")(setq end (1+ end)))
  (goto-char beg)
  (insert "'")
  (setq end (1+ end))
  (goto-char end)
  (insert "'")
)
(defun powershell-unquote-selection (beg end)
  "Unquotes the selected text removing doubles as we go"
  (interactive `(,(region-beginning) ,(region-end)))
  (if (not mark-active)
      (error "Command requires a marked region"))
  (goto-char beg)
  (cond ((looking-at "'")
         (goto-char end)
         (when (looking-back "'")
           (delete-char -1)
           (setq end (1- end))
           (goto-char beg)
           (delete-char 1)
           (setq end (1- end))
           (while (search-forward "'" end t)
             (delete-char -1)
             (forward-char)
             (setq end (1- end)))))
        ((looking-at "\"")
         (goto-char end)
         (when (looking-back "\"")
           (delete-char -1)
           (setq end (1- end))
           (goto-char beg)
           (delete-char 1)
           (setq end (1- end))
           (while (search-forward "\"" end t)
             (delete-char -1)
             (forward-char)
             (setq end (1- end)))
           (while (search-forward "`" end t)
             (delete-char -1)
             (forward-char)
             (setq end (1- end)))
         ))
        (t (error "Must select quoted text exactly."))
  )
)
(defun powershell-escape-selection (beg end)
  "Escapes variables in the selection and extends existing escapes."
  (interactive `(,(region-beginning) ,(region-end)))
  (if (not mark-active)
      (error "Command requires a marked region"))
  (goto-char beg)
  (while (re-search-forward "`" end t)
    (replace-match "```")(setq end (+ end 2)))
  (goto-char beg)
  (while (re-search-forward "[^`][$]" end t)
    (goto-char (car (match-data)))
    (forward-char)
    (insert "`")
    (setq end (1+ end)))
)
(defun powershell-doublequote-selection (beg end)
  "Quotes the selection with double quotes, doubles embedded quotes"
  (interactive `(,(region-beginning) ,(region-end)))
  (if (not mark-active)
      (error "Command requires a marked region"))
  (goto-char beg)
  (while (re-search-forward "\"" end t)
    (replace-match "\"\"")(setq end (1+ end)))
  (goto-char beg)
  (while (re-search-forward "`'" end t)
    (replace-match "```")(setq end (+ 2 end)))
  (goto-char beg)
  (insert "\"")
  (setq end (1+ end))
  (goto-char end)
  (insert "\"")
)
(defun powershell-DollarParen-selection (beg end)
  "Wraps the selected text with $() leaving point after closing paren."
  (interactive `(,(region-beginning) ,(region-end)))
  (if (not mark-active)
      (error "Command requires a marked region"))
  (save-excursion
    (goto-char end)
    (insert ")")
    (goto-char beg)
    (insert "$(")
  )
  (forward-char)
)
(defun powershell-regexp-to-regex (beg end)
  "Turns the selected string (assumed to be regexp-opt output) into a regex"
  (interactive `(,(region-beginning) ,(region-end)))
  (if (not mark-active)
      (error "Command requires a marked region"))
  (save-restriction
    (narrow-to-region beg end)
    (goto-char (point-min))
    (while (re-search-forward "\\\\(" nil t)
      (replace-match "("))
    (goto-char (point-min))
    (while (re-search-forward "\\\\)" nil t)
      (replace-match ")"))
    (goto-char (point-min))
    (while (re-search-forward "\\\\|" nil t)
      (replace-match "|"))
  )
)

 
;; Taken from About_Keywords
(defvar powershell-keywords
  (concat "\\_<"
          (regexp-opt
           '("begin" "break" "catch" "continue" "data" "do" "default"
             "dynamicparam" "else" "elseif" "end" "exit" "filter"
             "finally" "for" "foreach" "from" "function" "if" "in"
             "param" "process" "return" "switch" "throw" "trap" "try"
             "until" "where" "while") t)
          "\\_>")
  "Powershell keywords")

;; Taken from About_Comparison_Operators and some questionable sources :-)
(defvar powershell-operators
  (concat "\\_<"
          (regexp-opt
           '("-eq" "-ne" "-gt" "-ge" "-lt" "-le"
             "-ceq" "-cne" "-cgt" "-cge" "-clt" "-cle" ;; case sensitive versions
             "-ieq" "-ine" "-igt" "-ige" "-ilt" "-ile" ;; explicitly case insensitive
             "-band" "-bor" "-bxor"
             "-and" "-or" "-xor"
             "-like" "-notlike" "-clike" "-cnotlike" "-ilike" "-inotlike"
             "-match" "-notmatch" "-cmatch" "-cnotmatch" "-imatch" "-inotmatch"
             "-contains" "-notcontains" "-ccontains" "-cnotcontains" "-icontains" "-inotcontains"
             "-replace" "-creplace" "-ireplace"
             "-is" "-as" "-f"
             ;; Questionable --> specific to certain contexts
             "-casesensitive" "-wildcard" "-regex" "-exact" ;specific to case
             "-begin" "-process" "-end"                     ;specific to scriptblock
            ) t)
          "\\_>")
  "Powershell operators")

(defvar powershell-scope-names
  (regexp-opt
  '("env" "function" "global" "local" "private" "script" "variable") t)
  "Names of scopes in Powershell mode.")

(defconst powershell-variables
  ;; There are 2 syntaxes detected: ${[scope:]name} and $[scope:]name
  ;; Match 0 is the entire variable name.
  ;; Match 1 is scope when the former syntax is found.
  ;; Match 2 is scope when the latter syntax is found.
  (concat
   "\\_<$\\(?:{\\(?:" powershell-scope-names ":\\)?[^}]+}\\|"
   "\\(?:" powershell-scope-names ":\\)?[a-zA-Z0-9_]+\\_>\\)")
  "Identifies legal powershell variable names")

(defconst powershell-function-names
  ;; Syntax detected is [scope:]verb-noun
  ;; Match 0 is the entire name.
  ;; Match 1 is the scope if any.
  ;; Match 2 is the function name (which must exist)
  (concat
   "\\_<\\(?:\\(global\\|local\\|script\\|private\\):\\)?"
   "\\([a-zA-Z][a-zA-Z0-9]*-[a-zA-Z0-9]+\\)\\_>")
  "Identifies legal function names")

(defconst powershell-object-types
  ;; Syntax is \[name[.name]\] (where the escaped []s are literal)
  ;; Only Match 0 is returned.
  "\\_<\\[\\(?:[a-zA-Z_][a-zA-Z0-9]*\\)\\(?:\\.[a-zA-Z_][a-zA-Z0-9]*\\)*]\\>"
  "Identifies object type references.  I.E. [object.data.type] syntax")

(defconst powershell-function-switch-names
  ;; Only Match 0 is returned.
  "\\_<-[a-zA-Z][a-zA-Z0-9]*\\_>"
  "Identifies function parameter names of the form -xxxx")

;; Taken from Get-Variable on a fresh shell, merged with man
;; about_automatic_variables
(defvar powershell-builtin-variables
  (regexp-opt
   '("$" "?"  "^" "_" "args" "ConsoleFileName" "Error" "Event"
    "EventSubscriber" "ExecutionContext" "false" "Foreach" "HOME" "Host"
    "input" "LASTEXITCODE" "Matches" "MyInvocation" "NestedPromptLevel"
    "null" "PID" "PROFILE" "PSBoundParameters" "PSCmdlet" "PSCulture"
    "PSDebugContext" "PSHOME" "PSScriptRoot" "PSUICulture" "PSVersionTable"
    "PWD" "ReportErrorShowExceptionClass" "ReportErrorShowInnerException"
    "ReportErrorShowSource" "ReportErrorShowStackTrace" "Sender" "ShellId"
    "SourceArgs" "SourceEventArgs" "StackTrace" "this" "true") t)
  "Names of the built-in Powershell variables. They are hilighted
differently from the other variables.")
(defvar powershell-config-variables
  (regexp-opt
   '("ConfirmPreference" "DebugPreference" "ErrorActionPreference"
    "ErrorView" "FormatEnumerationLimit" "LogCommandHealthEvent"
    "LogCommandLifecycleEvent" "LogEngineHealthEvent"
    "LogEngineLifecycleEvent" "LogProviderHealthEvent"
    "LogProviderLifecycleEvent" "MaximumAliasCount" "MaximumDriveCount"
    "MaximumErrorCount" "MaximumFunctionCount" "MaximumHistoryCount"
    "MaximumVariableCount" "OFS" "OutputEncoding" "ProgressPreference"
    "PSEmailServer" "PSSessionApplicationName" "PSSessionConfigurationName"
    "PSSessionOption" "VerbosePreference" "WarningPreference"
    "WhatIfPreference") t)
  "Names of variables that configure powershell features.")

 
(defun powershell-find-syntactic-comments (limit)
  "Finds PowerShell comment begin and comment end characters.
Returns match 1 and match 2 for <# #> comment sequences respectively.
Returns match 3 and optionally match 4 for #/eol comments.
Match 4 is returned only if eol is found before LIMIT"
  (when (search-forward "#" limit t)
    (cond
     ((looking-back "<#")
      (set-match-data (list (match-beginning 0) (1+ (match-beginning 0))
                            (match-beginning 0) (1+ (match-beginning 0)))))
     ((looking-at ">")
      (set-match-data (list (match-beginning 0) (match-end 0)
                            nil nil
                            (match-beginning 0) (match-end 0)))
      (forward-char))
     (t
      (let ((start (point)))
        (if (search-forward "\n" limit t)
            (set-match-data (list (1- start) (match-end 0)
                                  nil nil nil nil
                                  (1- start) start
                                  (match-beginning 0) (match-end 0)))
          (set-match-data (list start (match-end 0)
                                nil nil nil nil
                                (1- start) start))))))
    t))

(defun powershell-find-syntactic-quotes (limit)
  "Finds PowerShell hear string begin and end sequences.
Returns match 1 and match 2 for @' '@ sequences respectively.
Returns match 3 and match 4 for @\" \"@ sequences respectively."
  (when (search-forward "@" limit t)
    (cond
     ((looking-at "'$")
      (set-match-data (list (match-beginning 0) (1+ (match-beginning 0))
                            (match-beginning 0) (1+ (match-beginning 0))))
      (forward-char))
     ((looking-back "^'@")
      (set-match-data (list (1- (match-end 0)) (match-end 0)
                            nil nil
                            (1- (match-end 0)) (match-end 0))))
     ((looking-at "\"$")
      (set-match-data (list (match-beginning 0) (1+ (match-beginning 0))
                            nil nil
                            nil nil
                            (match-beginning 0) (1+ (match-beginning 0))))
      (forward-char))
     ((looking-back "^\"@")
      (set-match-data (list (1- (match-end 0)) (match-end 0)
                            nil nil
                            nil nil
                            nil nil
                            (1- (match-end 0)) (match-end 0)))))
    t))
(defvar powershell-font-lock-syntactic-keywords
  `((powershell-find-syntactic-comments (1 "!" t t) (2 "!" t t)
                                        (3 "<" t t) (4 ">" t t))
    (powershell-find-syntactic-quotes (1 "|" t t) (2 "|" t t)
                                      (3 "|" t t) (4 "|" t t)))
 "A list of regexp's or functions.  Used to add syntax-table properties to
characters that can't be set by the syntax-table alone.")

 
(defvar powershell-font-lock-keywords-1
  `(;; Type annotations
    (,powershell-object-types . font-lock-type-face)
    ;; syntaxic keywords
    (,powershell-keywords . font-lock-keyword-face)
    ;; operators
    (,powershell-operators . font-lock-builtin-face)
    ;; the REQUIRES mark
    ("^#\\(REQUIRES\\)" 1 font-lock-warning-face t))
  "Keywords for the first level of font-locking in Powershell mode.")

(defvar powershell-font-lock-keywords-2
  (append
   powershell-font-lock-keywords-1
   `(;; Built-in variables
     (,(concat "\\$\\(" powershell-builtin-variables "\\)\\>")
      0 font-lock-builtin-face t)
     (,(concat "\\$\\(" powershell-config-variables "\\)\\>")
      0 font-lock-builtin-face t)))
  "Keywords for the second level of font-locking in Powershell mode.")

(defvar powershell-font-lock-keywords-3
  (append
   powershell-font-lock-keywords-2
   `(;; user variables
     (,powershell-variables
      (0 font-lock-variable-name-face)
      (1 (cons font-lock-type-face '(underline)) t t)
      (2 (cons font-lock-type-face '(underline)) t t))
     ;; function argument names
     (,powershell-function-switch-names
      (0 font-lock-reference-face)
      (1 (cons font-lock-type-face '(underline)) t t)
      (2 (cons font-lock-type-face '(underline)) t t))
     ;; function names
     (,powershell-function-names
      (0 font-lock-function-name-face)
      (1 (cons font-lock-type-face '(underline)) t t))))
  "Keywords for the maximum level of font-locking in Powershell mode.")

 
(defun powershell-setup-font-lock ()
  "Sets up the buffer local value for font-lock-defaults"
  ;; I use font-lock-syntactic-keywords to set some properties and I
  ;; don't want them ignored.
  (set (make-local-variable 'parse-sexp-lookup-properties) t)
  ;; This is where all the font-lock stuff actually gets set up.  Once
  ;; font-lock-defaults has its value, setting font-lock-mode true should
  ;; cause all your syntax highlighting dreams to come true.
  (setq font-lock-defaults
         ;; The first value is all the keyword expressions.
        '((powershell-font-lock-keywords-1
           powershell-font-lock-keywords-2
           powershell-font-lock-keywords-3)
         ;; keywords-only means no strings or comments get fontified
         nil
         ;; case-fold (t ignores case)
         t
         ;; syntax-alist nothing special here
         nil
         ;; syntax-begin - no function defined to move outside syntactic block
         nil
         ;; font-lock-syntactic-keywords
         ;; takes (matcher (match syntax override lexmatch) ...)...
         (font-lock-syntactic-keywords . powershell-font-lock-syntactic-keywords))))

(defvar powershell-mode-syntax-table
  (let ((powershell-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?$  "_" powershell-mode-syntax-table)
    (modify-syntax-entry ?-  "_" powershell-mode-syntax-table)
    (modify-syntax-entry ?=  "_" powershell-mode-syntax-table)
    (modify-syntax-entry ?:  "_" powershell-mode-syntax-table)
    (modify-syntax-entry ?^  "_" powershell-mode-syntax-table)
    (modify-syntax-entry ?\\ "_" powershell-mode-syntax-table)
    (modify-syntax-entry ?{ "(}" powershell-mode-syntax-table)
    (modify-syntax-entry ?} "){" powershell-mode-syntax-table)
    (modify-syntax-entry ?[ "(]" powershell-mode-syntax-table)
    (modify-syntax-entry ?] ")[" powershell-mode-syntax-table)
    (modify-syntax-entry ?( "()" powershell-mode-syntax-table)
    (modify-syntax-entry ?) ")(" powershell-mode-syntax-table)
    (modify-syntax-entry ?` "\\" powershell-mode-syntax-table)
    (modify-syntax-entry ?_  "w" powershell-mode-syntax-table)
    (modify-syntax-entry ?' "\"" powershell-mode-syntax-table)
    (modify-syntax-entry ?#  "<" powershell-mode-syntax-table)
    powershell-mode-syntax-table)
  "Syntax for PowerShell major mode")

(defvar powershell-mode-map
  (let ((powershell-mode-map (make-keymap)))
;;    (define-key powershell-mode-map "\r" 'powershell-indent-line)
    (define-key powershell-mode-map "\t" 'powershell-indent-line)
    (define-key powershell-mode-map (kbd "M-\"") 'powershell-doublequote-selection)
    (define-key powershell-mode-map (kbd "M-'") 'powershell-quote-selection)
    (define-key powershell-mode-map (kbd "C-'") 'powershell-unquote-selection)
    (define-key powershell-mode-map (kbd "C-\"") 'powershell-unquote-selection)
    (define-key powershell-mode-map (kbd "M-`") 'powershell-escape-selection)
    (define-key powershell-mode-map (kbd "C-$") 'powershell-DollarParen-selection)
    powershell-mode-map)
  "Keymap for PS major mode")


 
(defvar powershell-imenu-expression
  `(("Functions" "function \\(\\w+\\)" 1)
    ("Top variables" ,(concat "^\\$\\(" powershell-scope-names "\\)?:?"
			      "\\([[:alnum:]_]+\\)")
     2))
  "List of regexps matching important expressions, for speebar & imenu.")

(defun powershell-setup-imenu ()
  "Installs powershell-imenu-expression."
  (when (require 'imenu nil t)
      ;; imenu doc says these are buffer-local by default
      (setq imenu-generic-expression powershell-imenu-expression)
      (setq imenu-case-fold-search nil)
      (imenu-add-menubar-index)
      (when (require 'which-func nil t)
        (which-function-mode t))))

(if (require 'speedbar nil t)
    (speedbar-add-supported-extension ".ps1?"))

(require 'compile nil t)
;; A better command would be something like "powershell.exe -NoLogo
;; -NonInteractive -Command & (buffer-file-name)". But it will just
;; sit there waiting...  The following will only work when .ps1 files
;; are associated with powershell.exe. And if they don't contain spaces.
(defvar powershell-compile-command
  '(buffer-file-name)
  "Default command used to invoke a powershell script")

;; The column number will be off whenever tabs are used. Since this is
;; the default in this mode, we will not capture the column number.
(setq compilation-error-regexp-alist
      (cons '("At \\(.*\\):\\([0-9]+\\) char:\\([0-9]+\\)" 1 2)
	    compilation-error-regexp-alist))

 
;; the hook is automatically run by derived-mode
(defvar powershell-mode-hook '(imenu-add-menubar-index)
  "Hook run after the initialization of Powershell mode.")

(defun powershell-mode ()
  "Major mode for editing PowerShell scripts"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'powershell-mode)
  (setq mode-name "PS")
  (set-syntax-table powershell-mode-syntax-table)
  (use-local-map powershell-mode-map)
  (powershell-setup-font-lock)
  (set (make-local-variable 'indent-line-function) 'powershell-indent-line)
  (set (make-local-variable 'compile-command) powershell-compile-command)
  (set (make-local-variable 'comment-start) "#")
  (set (make-local-variable 'comment-start-skip) "#+\\s*")
  (set (make-local-variable 'parse-sexp-ignore-comments) t)
  (powershell-setup-imenu)
  (run-hooks 'powershell-mode-hook))

(provide 'powershell-mode)

;;; end of powershell-mode.el