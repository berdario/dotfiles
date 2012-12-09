;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File name: ` ~/.emacs '
;;; ---------------------
;;;
;;; If you need your own personal ~/.emacs
;;; please make a copy of this file
;;; an placein your changes and/or extension.
;;;
;;; Copyright (c) 1997-2002 SuSE Gmbh Nuernberg, Germany.
;;;
;;; Author: Werner Fink, <feedback@suse.de> 1997,98,99,2002
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Test of Emacs derivates
;;; -----------------------
(if (string-match "XEmacs\\|Lucid" emacs-version)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; XEmacs
  ;;; ------
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (progn
     (if (file-readable-p "~/.xemacs/init.el")
        (load "~/.xemacs/init.el" nil t))
  )
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; GNU-Emacs
  ;;; ---------
  ;;; load ~/.gnu-emacs or, if not exists /etc/skel/.gnu-emacs
  ;;; For a description and the settings see /etc/skel/.gnu-emacs
  ;;;   ... for your private ~/.gnu-emacs your are on your one.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (if (file-readable-p "~/.gnu-emacs")
      (load "~/.gnu-emacs" nil t)
    (if (file-readable-p "/etc/skel/.gnu-emacs")
	(load "/etc/skel/.gnu-emacs" nil t)))

  ;; Custom Settings
  ;; ===============
  ;; To avoid any trouble with the customization system of GNU emacs
  ;; we set the default file ~/.gnu-emacs-custom
  (setq custom-file "~/.gnu-emacs-custom")
  (load "~/.gnu-emacs-custom" t t)
;;;
)
;;;
;;(setenv "ERGOEMACS_KEYBOARD_LAYOUT" "it")
;;(load-file "~/.emacs.d/ergoemacs_1.9.3.1/site-lisp/site-start.el")
(add-to-list 'load-path "~/.emacs.d/packages/")

(set-scroll-bar-mode 'right)
(setq mouse-wheel-scroll-amount '(3 ((shift) .3) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)
(global-linum-mode 1)
(global-hl-line-mode 1)
(setq read-file-name-completion-ignore-case 1)
(global-visual-line-mode)
(column-number-mode)
;(setq-default indent-tabs-mode t)
(setq-default tab-width 4)
(global-whitespace-mode 1)
(setq whitespace-style '(tab-mark))
(add-hook 'python-mode-hook
              (lambda ()
                (setq tab-width (default-value 'tab-width)
                      python-indent 4)))
(require 'undo-tree)
(global-undo-tree-mode)

(global-set-key (kbd "C-x <tab>") 'increase-left-margin)

(if (boundp 'tramp-default-proxies-alist) nil (setq tramp-default-proxies-alist nil))
(add-to-list 'tramp-default-proxies-alist
                  '(nil "\\`root\\'" "/ssh:%h:"))
(add-to-list 'tramp-default-proxies-alist
                  '((regexp-quote (system-name)) nil nil))

(defun my-c-mode-common-hook ()
  (setq indent-tabs-mode t)
  (setq c-default-style "bsd" c-basic-offset 4)
)
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

(defun toggle-fullscreen (&optional f)
  (interactive)
  (let ((current-value (frame-parameter nil 'fullscreen)))
	(set-frame-parameter nil 'fullscreen
						 (if (equal 'fullboth current-value)
							 (if (boundp 'old-fullscreen) old-fullscreen nil)
						   (progn (setq old-fullscreen current-value)
								  'fullboth)))))
(global-set-key [f11] 'toggle-fullscreen)

(tool-bar-mode -1)

(require 'package)
(add-to-list 'package-archives 
    '("marmalade" .
      "http://marmalade-repo.org/packages/"))
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))
(defvar my-packages '(clojure-mode
                      nrepl
                      nrepl-ritz))
(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(require 'powershell-mode)
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode))

(require 'zencoding-mode)
(add-hook 'sgml-mode-hook 'zencoding-mode)

(setq-default sgml-basic-offset tab-width)


;; (fset 'indent-region-copy (symbol-function 'indent-region))
;; (defun indent-region (START END &optional COLUMN) 
;;   (interactive)
;;   (increase-left-margin START END)
;;   (indent-region-copy START END COLUMN))

(setq load-path (cons "~/.emacs.d/packages/fsharp" load-path))
(setq auto-mode-alist (cons '("\\.fs[iylx]?$" . fsharp-mode) auto-mode-alist))
(autoload 'fsharp-mode "fsharp" "Major mode for editing F# code." t)
(autoload 'run-fsharp "inf-fsharp" "Run an inferior F# process." t)
(setq inferior-fsharp-program "fsharpi")
(setq fsharp-compiler "fsharpc")
