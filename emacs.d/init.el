;; Custom Settings from customize
(setq custom-file "~/.emacs.d/customizations")
(load "~/.emacs.d/customizations" t t)

(set-scroll-bar-mode 'right)
(setq mouse-wheel-scroll-amount '(3 ((shift) .3) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)
(global-linum-mode 1)
(global-hl-line-mode 1)
(setq read-file-name-completion-ignore-case 1)
(global-visual-line-mode)
(column-number-mode)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(global-whitespace-mode 1)
(setq whitespace-style '(tab-mark trailing face))


(add-hook 'after-init-hook 'global-undo-tree-mode)

(global-set-key (kbd "C-x <tab>") 'increase-left-margin)

(if (boundp 'tramp-default-proxies-alist) nil (setq tramp-default-proxies-alist nil))
(add-to-list 'tramp-default-proxies-alist
                  '(nil "\\`root\\'" "/ssh:%h:"))
(add-to-list 'tramp-default-proxies-alist
                  '((regexp-quote (system-name)) nil nil))

(defun my-c-mode-common-hook ()
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
(add-to-list 'package-archives
	'("melpa" . 
	  "http://melpa.milkbox.net/packages/"))
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))
(defvar my-packages '(clojure-mode
					  haskell-mode
					  zencoding-mode
					  erlang
					  nrepl
					  nrepl-ritz
					  undo-tree
					  powershell-mode
					  solarized-theme
					  evil
					  tabbar
					  diminish
					  expand-region
					  paredit
					  projectile
					  rainbow-mode
					  ack-and-a-half
					  rainbow-delimiters
					  ibuffer-vc
					  fsharp-mode
					  tuareg
					  ))
(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(load-theme 'solarized-dark)

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

(setq inferior-fsharp-program "fsharpi --readline-")
(setq fsharp-compiler "fsharpc")

(add-to-list 'auto-mode-alist '("\\.\\(e\\|h\\)rl" . erlang-mode))

(delete-selection-mode)
(setq save-place-file "~/.emacs.d/saved-places")

(require 'expand-region)
(global-set-key (kbd "C-0") 'er/expand-region)
(global-set-key (kbd "C-9") 'er/contract-region)

(dolist (mode '(scheme emacs-lisp lisp clojure clojurescript))
  (add-hook (intern (concat (symbol-name mode) "-mode-hook"))
              'paredit-mode))

(projectile-global-mode)
(add-hook 'css-mode-hook 'rainbow-mode)
; FIXME this removes the hook for er/css-mode-expansion

(global-rainbow-delimiters-mode)

(add-hook 'ibuffer-hook
    (lambda ()
      (ibuffer-vc-set-filter-groups-by-vc-root)
      (unless (eq ibuffer-sorting-mode 'alphabetic)
        (ibuffer-do-sort-by-alphabetic))
	  (setq truncate-lines t)))

(setq ibuffer-formats
      '((mark modified read-only vc-status-mini " "
              (name 18 18 :left :elide)
              " "
              (size 9 -1 :right)
              " "
              (mode 16 16 :left :elide)
              " "
              (vc-status 16 16 :left)
              " "
              filename-and-process)))

(global-set-key (kbd "C-x C-g") 'goto-line)

(add-hook 'isearch-mode-hook (lambda () (define-key isearch-mode-map (kbd "C-f") 'isearch-repeat-forward)))

(require 'iso-transl)

(setq ruby-insert-encoding-magic-comment nil)
(add-to-list 'auto-mode-alist '("Rakefile\\'" . ruby-mode))

(cua-mode t)

(require 'tabbar)
(tabbar-mode t)

(setq tabbar-background-color "gray20")
(custom-set-faces
 '(tabbar-default ((t (:background "gray20" :foreground "black" :weight bold :box (:line-width 1 :color "gray20")))))
 '(tabbar-button ((t (:inherit tabbar-default :box (:line-width 1 :color "gray20" :style nil)))))
 '(tabbar-highlight ((t :background "white" :foreground "black" :underline nil :box (:line-width 5 :color "white" :style nil))))
 '(tabbar-selected ((t (:inherit tabbar-default :background "gray75" :foreground "black" :box (:line-width 5 :color "gray75" :style nil)))))
 '(tabbar-separator ((t (:inherit tabbar-default :background "gray20" :height 0.6))))
 '(tabbar-unselected ((t (:inherit tabbar-default :background "gray30" :foreground "white" :box (:line-width 5 :color "gray30" :style nil))))))

; define all tabs to be one of 3 possible groups: “Emacs Buffer”, “Dired”, “User Buffer”.

(defun tabbar-buffer-groups ()
  "Return the list of group names the current buffer belongs to.
This function is a custom function for tabbar-mode's tabbar-buffer-groups.
This function group all buffers into 3 groups:
Those Dired, those user buffer, and those emacs buffer.
Emacs buffer are those starting with “*”."
  (list
   (cond
    ((string-equal "*" (substring (buffer-name) 0 1))
     "Emacs Buffer"
     )
    ((eq major-mode 'dired-mode)
     "Dired"
     )
    (t
     "User Buffer"
     )
    ))) 

(setq tabbar-buffer-groups-function 'tabbar-buffer-groups)

(global-set-key [C-S-iso-lefttab] 'tabbar-backward)
(global-set-key [C-tab] 'tabbar-forward)

(global-set-key (kbd "C-f") 'isearch-forward)
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-o") 'find-file)

(require 'diminish)
(eval-after-load "undo-tree" '(diminish 'undo-tree-mode))
(diminish 'global-whitespace-mode)
(diminish 'global-visual-line-mode)
(diminish 'visual-line-mode)
(diminish 'projectile-mode)

;(windmove-default-keybindings 'shift)

(setq default-directory (or (getenv "USERPROFILE") (getenv "HOME")))
(put 'upcase-region 'disabled nil)

(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
