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

(global-whitespace-mode 1)
(setq whitespace-style '(tab-mark trailing face))


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

(defun cider-load ()
 (setq cider-popup-stacktraces t)
 (setq cider-repl-popup-stacktraces t)
 (setq cider-popup-on-error nil)

 (setq nrepl-buffer-name-separator "-")
 (setq nrepl-buffer-name-show-port t)

 (setq cider-repl-print-length 10000)
 (setq cider-repl-history-size 500000)
 (setq cider-repl-history-file "~/.nrepl-history.eld")
 (add-hook 'cider-repl-mode-hook 'subword-mode))


(defun haskell-mode-load ()
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
  (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode))

(defun zencoding-mode-load ()
  (require 'zencoding-mode)
  (add-hook 'sgml-mode-hook 'zencoding-mode))


(defun powershell-mode-load ()
  (require 'powershell-mode)
  (add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode)))


(defun tabbar-load ()
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

  (setq tabbar-buffer-groups-function 'tabbar-buffer-groups))


(defun diminish-load ()
  (require 'diminish)
  (eval-after-load "undo-tree" '(diminish 'undo-tree-mode))
  (diminish 'global-whitespace-mode)
  (diminish 'visual-line-mode)
  (diminish 'projectile-mode))


(defun expand-region-load ()
  (require 'expand-region)
  (global-set-key (kbd "C-0") 'er/expand-region)
  (global-set-key (kbd "C-9") 'er/contract-region))

(defun paredit-load ()
  (dolist (mode '(scheme emacs-lisp ielm lisp clojure clojurescript cider-repl))
    (let ((hook (intern (concat (symbol-name mode) "-mode-hook"))))
      (add-hook hook 'paredit-mode)
      (add-hook hook #'rainbow-delimiters-mode))))

(defun ibuffer-vc-load ()
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
                filename-and-process))))


(defun fsharp-mode-load ()
  (setq inferior-fsharp-program "fsharpi --readline-")
  (setq fsharp-compiler "fsharpc"))

(require 'package)
(add-to-list 'package-archives 
    '("marmalade" .
      "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
    '("melpa" . 
      "http://melpa.milkbox.net/packages/"))
(package-initialize)

(defun try-install (package)
  (let ((result nil))
    (condition-case nil
        (progn (when (not (package-installed-p package))
(package-install package))
               (setq result 't))
      ('error (message (format "Unable to install %s" package))))
    result))

(try-install 'dash)
(try-install 'dash-functional)
(require 'dash-functional)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages `((clojure-mode ignore)
                      (clojure-test-mode ignore)
                      (cider cider-load)
                      (haskell-mode haskell-mode-load)
                      (zencoding-mode zencoding-mode-load)
                      (erlang (lambda () (add-to-list 'auto-mode-alist '("\\.\\(e\\|h\\)rl" . erlang-mode))))
                      (yaml-mode ignore)
                      (undo-tree (lambda () (add-hook 'after-init-hook 'global-undo-tree-mode)))
                      (powershell-mode powershell-mode-load)
                      (solarized-theme (lambda () (load-theme 'solarized-dark)))
                      (evil ignore)
                      (tabbar tabbar-load)
                      (expand-region expand-region-load)
                      (rainbow-delimiters ignore)
                      (paredit paredit-load)
                      (projectile projectile-global-mode)
                      (rainbow-mode (lambda () (add-hook 'css-mode-hook 'rainbow-mode)))
                      ; FIXME this removes the hook for er/css-mode-expansion
                      (ack-and-a-half ignore)
                      (ibuffer-vc ibuffer-vc-load)
                      (fsharp-mode fsharp-mode-load)
                      (tuareg ignore)
                      (scala-mode2 ignore)
                      (nix-mode ignore)
                      (exec-path-from-shell ,(if (memq window-system '(mac ns))
                                                 exec-path-from-shell-initialize 'ignore))
                      (ace-jump-mode (lambda () (define-key global-map (kbd "C-c SPC") 'ace-jump-mode)))
                      (diminish diminish-load)
                      ))


(-each my-packages
  (-lambda ((p loader))
    (when (try-install p)
      (funcall loader))))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq tab-stop-list (number-sequence tab-width 120 tab-width))

(setq-default sgml-basic-offset tab-width)


;; (fset 'indent-region-copy (symbol-function 'indent-region))
;; (defun indent-region (START END &optional COLUMN) 
;;   (interactive)
;;   (increase-left-margin START END)
;;   (indent-region-copy START END COLUMN))



(delete-selection-mode)
(setq save-place-file "~/.emacs.d/saved-places")


(global-set-key (kbd "C-x C-g") 'goto-line)

(add-hook 'isearch-mode-hook (lambda () (define-key isearch-mode-map (kbd "C-f") 'isearch-repeat-forward)))

(require 'iso-transl)

(setq ruby-insert-encoding-magic-comment nil)
(add-to-list 'auto-mode-alist '("Rakefile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.fish\\'" . shell-script-mode))

(cua-mode t)


(global-set-key [home] 'beginning-of-line) ; macosx
(global-set-key [end] 'end-of-line) ; macosx
(global-set-key [C-S-iso-lefttab] 'tabbar-backward) ; linux
(global-set-key [C-S-tab] 'tabbar-backward) ; macosx
(global-set-key [C-tab] 'tabbar-forward)

(global-set-key (kbd "C-f") 'isearch-forward)
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-o") 'find-file)


;(windmove-default-keybindings 'shift)

(setq default-directory (or (getenv "USERPROFILE") (getenv "HOME")))
(put 'upcase-region 'disabled nil)

(setq backup-dir (expand-file-name ".emacs.d/backup/"))
(setq autosave-dir (expand-file-name ".emacs.d/autosaves/"))
(setq backup-directory-alist
      `((".*" . ,backup-dir)))
(setq auto-save-file-name-transforms
      `((".*" ,autosave-dir t)))

