;; init.el --- skeleton config  -*- lexical-binding: t; coding:utf-8; fill-column: 119 -*-

;;; Commentary:
;; A bare-boned config template. Use "outshine-cycle-buffer" (<Tab> and <S-Tab>
;; in org style) to navigate through sections, and "imenu" to locate individual
;; use-package definition.

;;; Bootstrap
;; Speed up startup
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)
(add-hook 'after-init-hook
	  `(lambda ()
	     (setq gc-cons-threshold 800000
		   gc-cons-percentage 0.1)
	     (garbage-collect)) t)

;; Turn off mouse interface early in startup to avoid momentary display
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Initialize package.el
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Bootstrap `straight.el'
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Bootstrap `use-package'
(setq-default use-package-always-ensure t ; Auto-download package if not exists
	      use-package-always-defer t ; Always defer load package to speed up startup
	      use-package-verbose nil ; Don't report loading details
	      use-package-expand-minimally t  ; make the expanded code as minimal as possible
	      use-package-enable-imenu-support t) ; Let imenu finds use-package definitions
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

;; Add system-wide defaults here, for example:
;;
;; (setq-default inhibit-startup-message t
;;               initial-scratch-message nil)

;; Add all use-package definitions from here


;; Testing

;; (global-unset-key [?\e ?\e ?\e])
;; (define-key esc-map (kbd "<ESC><ESC>") nil)
;; (define-key esc-map (kbd "<ESC><ESC><ESC>") nil)

;; General settings
(setq-default
 make-backup-files nil
 column-number-mode t
 )

(setq make-backup-files nil)
(unbind-key "C-z")

(defun previous-window ()
    (interactive nil)
    (other-window -1))

;; Kinesis keyboards

;; (global-set-key (kbd "<prior>") 'save-buffer)
;; (global-set-key (kbd "<prior>") 'ctl-x-map)
(global-set-key (kbd "<prior>") (lookup-key global-map (kbd "C-x")))
(global-set-key (kbd "<next>") 'other-window)
(global-set-key (kbd "C-<next>") 'previous-window)
(global-set-key (kbd "<home>") 'crux-move-beginning-of-line)
(global-set-key (kbd "ESC <select>") 'end-of-buffer)
(global-set-key (kbd "ESC <home>") 'beginning-of-buffer)

(global-set-key (kbd "<select>") 'move-end-of-line)
(global-set-key (kbd "<f9>") 'undo-tree-undo)
(global-set-key (kbd "M-[ 3 3 ~") 'undo-tree-redo)  ;; shift f9
(global-set-key (kbd "C-x f") 'projectile-find-file)
(global-set-key (kbd "C-x s") 'save-buffer)
(global-set-key (kbd "C-x u") 'undo-tree-visualize)

(global-unset-key (kbd "C-M-q"))
(global-unset-key (kbd "C-M-b"))

;; (global-set-key (kbd "C-M-i") 'previous-line)
;; (global-set-key (kbd "C-M-k") 'next-line)
;; (global-set-key (kbd "C-M-l") 'right-char)
;; (global-set-key (kbd "C-M-j") 'left-char)
(global-set-key (kbd "C-M-j") 'jump-char-forward)
(global-set-key (kbd "C-M-r") 'repeat)
(global-set-key (kbd "C-M-z") 'zap-up-to-char)
(global-set-key (kbd "C-M-u") 'forward-word)
(global-set-key (kbd "C-M-y") 'backward-word)
(global-set-key (kbd "C-M-n") 'forward-sexp)
(global-set-key (kbd "C-M-p") 'backward-sexp)
(global-set-key (kbd "C-M-b") 'switch-to-last-buffer)
(global-set-key (kbd "C-M-k") 'kill-current-buffer)
(global-set-key (kbd "C-x u") 'undo-tree-visualize)
(global-set-key (kbd "C-M-q") 'previous-buffer)
(global-set-key (kbd "C-M-w") 'next-buffer)
(global-set-key (kbd "C-e") 'end-of-line)
(global-set-key (kbd "C-E") 'end-of-visual-line)
;; (global-set-key (kbd "C-M-o") (lambda ()
;;                   (interactive)
;;                   (insert-char #x7B)))
;; (global-set-key (kbd "C-M-p") (lambda ()
;;                   (interactive)
;;                   (insert-char #x7D)))

;; always mixed up with kill-buffer
(global-set-key (kbd "C-x C-k RET") 'kill-current-buffer)

;; Try buffer switch
(global-set-key (kbd "C-x B") 'persp-counsel-switch-buffer)


;; General settings
(setq-default
 ;; Don't create ~ files
 make-backup-files nil
 ;; Show column number
 column-number-mode t
 )

;;; Load path
(let ((default-directory  "~/.emacs.d/lisp/"))
  (normal-top-level-add-to-load-path '("."))
  (normal-top-level-add-subdirs-to-load-path))

;;; Blogging
(set-face-attribute 'default nil :height 1000)
(set-face-attribute 'default nil :font "Monaco-16" )

(use-package ox-hugo
  :ensure t            ;Auto-install the package from Melpa (optional)
  :after ox)

;; isearch
(define-key isearch-mode-map "n" 'isearch-repeat-forward)
(define-key isearch-mode-map "p" 'isearch-repeat-backward)


;; Misc register
(global-set-key (kbd "C-c i") 'point-to-register)
(global-set-key (kbd "C-c j") 'jump-to-register)
(global-set-key (kbd "M-j") 'avy-goto-char-in-line)
(set-register ?r (cons 'file "/Git/GoExample/src/gitlab.com/billyla/"))
(set-register ?R (cons 'file "/Git/GoExample/Playground/random/main.go"))
(set-register ?c (cons 'file "/Git/orgfiles/cheatsheet.org"))
(set-register ?i (cons 'file "~/.emacs.d/init.el"))
(set-register ?b (cons 'file "/Git/orgfiles/blog.org"))
(set-register ?j (cons 'file "/Git/orgfiles/journal.org"))
(set-register ?m (cons 'file "/Git/orgfiles/commands.org"))
(set-register ?w (cons 'file "/Git/orgfiles/work.org"))
(set-register ?d (cons 'file "/Git/orgfiles/daily.org"))
(set-register ?h (cons 'file "/Git/orgfiles/hossted.org"))
(set-register ?n (cons 'file "/Git/orgfiles/notes.org"))
(set-register ?g (cons 'file "/Git/boo/main.go"))
(set-register ?p (cons 'file "/Git/boo_py/main.py"))


;; Misc - self defined function
(defun fn-occur-at-point ()
  "Run occur using the `word-at-point'."
  (interactive)
  (let ((term (thing-at-point 'word t)))
    (occur term))
    (other-frame 1) ;; <<<-- how to jump to the new window
)


(defun fn-copy-region-to-other-window (start end)
  "Move selected text to other window"
  (interactive "r")
  (if (use-region-p)
      (let ((count (count-words-region start end)))
        (save-excursion
          ;; (kill-region start end)
          (copy-region-as-kill start end)
          (other-window 1)
          (yank)
          (newline))
        (other-window -1)
        (message "Moved %s words" count))
    (message "No region selected")))




;; (defun copy-line (arg)
;;       "Copy lines (as many as prefix argument) in the kill ring.
;;       Ease of use features:
;;       - Move to start of next line.
;;       - Appends the copy on sequential calls.
;;       - Use newline as last char even on the last line of the buffer.
;;       - If region is active, copy its lines."
;;       (interactive "p")
;;       (let ((beg (line-beginning-position))
;; 	    (end (line-end-position arg)))
;; 	(when mark-active
;; 	  (if (> (point) (mark))
;; 	      (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
;; 	    (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
;; 	(if (eq last-command 'copy-line)
;; 	    (kill-append (buffer-substring beg end) (< end beg))
;; 	  (kill-ring-save beg end)))
;;       (kill-append "\n" nil)
;;       (beginning-of-line (or (and arg (1+ arg)) 2))
;;           (if (and arg (not (= 1 arg))) (message "%d lines copied" arg)))


;; Misc kbd
(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-l") 'isearch-forward-symbol-at-point)
(global-set-key (kbd "M-l") 'fn-occur-at-point)
;; (global-set-key (kbd "M-c") 'copy-line)
(global-set-key (kbd "M-u") 'undo-tree-undo)
(global-set-key (kbd "C-c m") 'fn-copy-region-to-other-window)
;; (global-set-key (kbd "M-.") 'xref-find-definitions-other-window)
(global-set-key (kbd "C-c h") 'cheat-sh-search)
(global-set-key (kbd "C-c u u") 'lsp-ui-imenu)





;; Misc
(setq initial-major-mode 'org-mode)
(setq initial-scratch-message "Welcome to emacs! \n\n")
(setq default-directory "/Git/GoExample/")

;; Misc buffer
(defun switch-to-last-buffer ()
  (interactive)
  (switch-to-buffer nil))

(global-set-key (kbd "C-c n") 'switch-to-last-buffer)

;; sql
;; (eval-after-load "sql"
;;   '(load-library "sql-indent"))

;; indentation
;; (setq-default indent-tabs-mode nil)
;; (setq-default tab-width 4)
;; (setq indent-line-function 'insert-tab)

;; crux
(use-package crux
:defer 1
:bind
(("C-k" . crux-smart-kill-line)
 ("C-c d" . crux-duplicate-current-line-or-region)
 ("C-x t" . 'crux-swap-windows)
 ("C-c b" . 'crux-create-scratch-buffer)
 ;; ("C-x f"   . 'crux-recentf-find-file)
 )
:init
(global-set-key [remap move-beginning-of-line] #'crux-move-beginning-of-line)
(global-set-key [(shift return)] #'crux-smart-open-line)
(global-set-key [remap kill-whole-line] #'crux-kill-whole-line)
:config
;; Retain indentation in these modes.
(add-to-list 'crux-indent-sensitive-modes 'markdown-mode)
)


;; deft
(use-package deft
  :bind ("<f8>" . deft)
  :bind ("M-\\" . deft)
  :bind ("C-c q" . quit-window)
  :bind ("C-x C-g" . deft-find-file)
  :commands (deft)
  :config (setq deft-directory "/Git/orgfiles"
                deft-extensions '("md" "org" "txt")
                deft-use-filename-as-title t
          )
)

(setq deft-auto-save-interval nil)

;; highlight
(use-package hl-todo
  ;; Highlight all TODO keywords
  :defer 3
  :config
  (global-hl-todo-mode))(use-package hl-todo
  ;; Highlight all TODO keywords
  :defer 3
  :config
  (global-hl-todo-mode))

;; Misc scrolling
(define-key input-decode-map "\e\eOB" [(meta up)])
(define-key input-decode-map "\e\eOA" [(meta down)])
;; (global-set-key (kbd "ESC <up>") 'move-text-up)
;; (global-set-key (kbd "ESC <down>") 'move-text-down)

(global-set-key [(meta down)] 'scroll-down-line)
(global-set-key [(meta up)] 'scroll-up-line)
(global-set-key (kbd "ESC <down>") 'scroll-up-line)
(global-set-key (kbd "ESC <up>") 'scroll-down-line)


;; multi cursor
(use-package multiple-cursors)

;; dictionary
;; (use-package define-word
;; :bind (("C-c t" . 'define-word-at-point))
;;   )

;; (use-package mw-thesaurus
;;   :bind (("C-c T" . mw-thesaurus-lookup-at-point))
;;   )

;; protobuf
(use-package protobuf-mode)

(defun fn-bind-eshell ()
  "bind stupid eshell kbd"
  (interactive)
  (bind-keys :map eshell-hist-mode-map
           ((kbd "M-s") . swiper)
           ((kbd "<up>") . nil)
           ((kbd "<down>") . nil)
           ((kbd "<home>") . eshell-bol)
           )
)

(defun fish ()
  "Just stupid eshell with the kbd initiated"
  (interactive)
  (eshell "new")
  (fn-bind-eshell)
)


(defun eshell-there ()
      "Opens up a new shell in the directory associated with the
    current buffer's file. The eshell is renamed to match that
    directory to make multiple eshell windows easier."
      (interactive)
      (let* ((parent (if (buffer-file-name)
                         (file-name-directory (buffer-file-name))
                       default-directory))
             (height (/ (window-total-height) 4))
             (name   (car (last (split-string parent "/" t)))))
        (split-window-vertically (- height))
        (other-window 1)
        (eshell "new")
	(fn-bind-eshell)
        (rename-buffer (concat "*eshell: " name "*"))

        (insert (concat "ls"))
        (eshell-send-input)))

(defun eshell-here-half ()
      "Opens up a new shell in the directory associated with the
    current buffer's file. The eshell is renamed to match that
    directory to make multiple eshell windows easier."
      (interactive)
      (let* ((parent (if (buffer-file-name)
                         (file-name-directory (buffer-file-name))
                       default-directory))
             (width (/ (window-total-width) 2))
             (name   (car (last (split-string parent "/" t)))))
        (split-window-horizontally (- width))
        (other-window 1)
        (eshell "new")
	(fn-bind-eshell)
        (rename-buffer (concat "*eshell: " name "*"))

        (insert (concat "ls"))
        (eshell-send-input)))

(defun eshell-here-third ()
      "Opens up a new shell in the directory associated with the
    current buffer's file. The eshell is renamed to match that
    directory to make multiple eshell windows easier."
      (interactive)
      (let* ((parent (if (buffer-file-name)
                         (file-name-directory (buffer-file-name))
                       default-directory))
             (width (/ (window-total-width) 2))
             (name   (car (last (split-string parent "/" t)))))
        (split-window-horizontally (- width))
        (other-window 1)
        (eshell "new")
	(fn-bind-eshell)
        (rename-buffer (concat "*eshell: " name "*"))

        (insert (concat "ls"))
        (eshell-send-input)))


(global-set-key (kbd "C-c 1") 'eshell-here-half)
(global-set-key (kbd "C-c 2") 'eshell-there)
(global-set-key (kbd "C-c 3") 'eshell-here-half) ;; duplicate for easy reference


;; set truncate mode
(set-default 'truncate-lines 1)

; Highlights the current cursor line
(global-hl-line-mode t)
;; (set-face-foreground 'hl-line "#3e4446")

;; Autosave file
(setq auto-save-file-name-transforms
  `((".*" "~/.emacs-saves/" t)))


(use-package hungry-delete
:ensure t)

(global-hungry-delete-mode)














;; clipboard
(setq x-select-enable-clipboard t)

;; enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)

;; Disable stupid stop
(global-unset-key [(control z)])
(global-unset-key [(control x)(control z)])

;; Global keybinding
(global-set-key (kbd "<home>") 'beginning-of-line)
(global-set-key (kbd "<select>") 'end-of-line)

;; Eshell keybinding
(add-hook 'eshell-mode-hook
          (lambda ()
            (define-key eshell-mode-map (kbd "<home>") #'eshell-bol)))


;; Revert
(global-auto-revert-mode 1) ;; you might not want this
(setq auto-revert-verbose nil) ;; or this
(global-set-key (kbd "<f5>") 'revert-buffer)
(global-set-key (kbd "<f6>") 'revert-buffer)

;; expand the marked region in semantic increments (negative prefix to reduce region)
(use-package expand-region)
(global-set-key (kbd "C-\\") 'er/expand-region)


;; (use-package smartparens
;;   :defer 5
;;   :bind (:map smartparens-mode-map
;; 	      ;; ("M-("           . sp-wrap-round)
;; 	      ;; ("M-["           . sp-wrap-square)
;; 	      ;; ("M-{"           . sp-wrap-curly)
;; 	      ;; ("M-<backspace>" . sp-backward-unwrap-sexp)
;; 	      ;; ("M-<del>"       . sp-unwrap-sexp)
;; 	      ;; ("C-<right>"     . sp-forward-slurp-sexp)
;; 	      ;; ("C-<left>"      . sp-backward-slurp-sexp)
;; 	      ;; ("C-M-<right>"   . sp-forward-barf-sexp)
;; 	      ;; ("C-M-<left>"    . sp-backward-barf-sexp)
;; 	      ;; ("C-M-a"         . sp-beginning-of-sexp)
;; 	      ;; ("C-M-e"         . sp-end-of-sexp)
;; 	      )
;;   :config
;;   (require 'smartparens-config)
;;   ;; Non strict modes
;;   (--each '(emacs-lisp-mode-hook
;; 	    ess-mode-hook
;; 	    python-mode-hook
;; 	    ;;inferior-ess-r-mode-hook
;; 	    )
;;     (add-hook it 'smartparens-mode))
;;   )



(use-package window
  :ensure nil
  :bind (("M-o" . other-window))
  )

(use-package ace-window
:ensure t
:init
(progn
(setq aw-scope 'global) ;; was frame
(global-set-key (kbd "C-x O") 'other-window)
;; (global-set-key [remap other-window] 'ace-window)
  (global-set-key [remap other-window] 'other-window)
  (custom-set-faces
   '(aw-leading-char-face
     ((t (:inherit ace-jump-face-foreground :height 3.0)))))
  ))

;; Completion framework
(use-package counsel
  :demand
  :ensure t
  :ensure ivy-rich
  :ensure smex
  :ensure wgrep
  :ensure counsel-tramp
  :config

  (ivy-mode 1)
  (ivy-rich-mode 1)
  (counsel-mode 1)
  :bind (("M-s" . swiper))
  )

;; Ivy
(defvar ivy-minibuffer-map
  (let ((map (make-sparse-keymap)))
    (ivy-define-key map (kbd "C-m") 'ivy-done)
    (define-key map [down-mouse-1] 'ignore)
    (ivy-define-key map [mouse-1] 'ivy-mouse-done)
    (ivy-define-key map [mouse-3] 'ivy-mouse-dispatching-done)
    (ivy-define-key map (kbd "C-M-m") 'ivy-call)
    (ivy-define-key map (kbd "C-j") 'ivy-alt-done)
    (ivy-define-key map (kbd "C-M-j") 'ivy-immediate-done)
    (ivy-define-key map (kbd "TAB") 'ivy-partial-or-done)
    (ivy-define-key map [remap next-line] 'ivy-next-line)
    (ivy-define-key map [remap previous-line] 'ivy-previous-line)
    (ivy-define-key map (kbd "C-r") 'ivy-reverse-i-search)
    (define-key map (kbd "SPC") 'self-insert-command)
    (ivy-define-key map [remap delete-backward-char] 'ivy-backward-delete-char)
    (ivy-define-key map [remap backward-delete-char-untabify] 'ivy-backward-delete-char)
    (ivy-define-key map [remap backward-kill-word] 'ivy-backward-kill-word)
    (ivy-define-key map [remap delete-char] 'ivy-delete-char)
    (ivy-define-key map [remap forward-char] 'ivy-forward-char)
    (ivy-define-key map (kbd "<right>") 'ivy-forward-char)
    (ivy-define-key map [remap kill-word] 'ivy-kill-word)
    (ivy-define-key map [remap beginning-of-buffer] 'ivy-beginning-of-buffer)
    (ivy-define-key map [remap end-of-buffer] 'ivy-end-of-buffer)
    (ivy-define-key map (kbd "M-n") 'ivy-next-history-element)
    (ivy-define-key map (kbd "M-p") 'ivy-previous-history-element)
    (define-key map (kbd "C-g") 'minibuffer-keyboard-quit)
    (ivy-define-key map [remap scroll-up-command] 'ivy-scroll-up-command)
    (ivy-define-key map [remap scroll-down-command] 'ivy-scroll-down-command)
    (ivy-define-key map (kbd "<next>") 'ivy-scroll-up-command)
    (ivy-define-key map (kbd "<prior>") 'ivy-scroll-down-command)
    (ivy-define-key map (kbd "C-v") 'ivy-scroll-up-command)
    (ivy-define-key map (kbd "M-v") 'ivy-scroll-down-command)
    (ivy-define-key map (kbd "C-M-n") 'ivy-next-line-and-call)
    (ivy-define-key map (kbd "C-M-p") 'ivy-previous-line-and-call)
    (ivy-define-key map (kbd "M-a") 'ivy-toggle-marks)
    (ivy-define-key map (kbd "M-r") 'ivy-toggle-regexp-quote)
    (ivy-define-key map (kbd "M-j") 'ivy-yank-word)
    (ivy-define-key map (kbd "M-i") 'ivy-insert-current)
    (ivy-define-key map (kbd "C-M-y") 'ivy-insert-current-full)
    (ivy-define-key map (kbd "C-o") 'hydra-ivy/body)
    (ivy-define-key map (kbd "M-o") 'ivy-dispatching-done)
    (ivy-define-key map (kbd "C-M-o") 'ivy-dispatching-call)
    (ivy-define-key map [remap kill-line] 'ivy-kill-line)
    (ivy-define-key map [remap kill-whole-line] 'ivy-kill-whole-line)
    (ivy-define-key map (kbd "S-SPC") 'ivy-restrict-to-matches)
    (ivy-define-key map [remap kill-ring-save] 'ivy-kill-ring-save)
    (ivy-define-key map (kbd "C-M-a") 'ivy-read-action)
    (ivy-define-key map (kbd "C-c C-o") 'ivy-occur)
    (ivy-define-key map (kbd "C-c C-a") 'ivy-toggle-ignore)
    (ivy-define-key map (kbd "C-c C-s") 'ivy-rotate-sort)
    (ivy-define-key map [remap describe-mode] 'ivy-help)
    (ivy-define-key map "$" 'ivy-magic-read-file-env)
    map)
  "Keymap used in the minibuffer.")


(use-package tramp
  :config
    (setq tramp-default-method "ssh"))

;; Indentation
(use-package aggressive-indent
  :config
  (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
  (add-hook 'org-mode-hook #'aggressive-indent-mode)
  )

;; Search
(use-package avy
:ensure t
:bind (("C-s" . avy-goto-char-2)
       ;; ("C-c s"   . avy-goto-char-2)
       ("C-c l"   . avy-goto-line)
       ("M-g f"   . avy-goto-line)
       )
)


;; Yasnippet
(use-package yasnippet
 :ensure t
 :init
 (yas-global-mode 1))

;; Manage window layout
(use-package eyebrowse
  :defer 2
  :init
  (setq eyebrowse-keymap-prefix (kbd "C-c w")) ;; w for workspace
  :bind
  (
   ;; ("<f9>"      . 'eyebrowse-create-window-config)
   ;; ("<f10>"     . 'eyebrowse-rename-window-config)
   ;; ("<f11>"     . 'eyebrowse-next-window-config)
   ("C-c w s"   . 'eyebrowse-switch-to-window-config)
   ("C-c w k"   . 'eyebrowse-close-window-config)
   ("C-c w w"   . 'eyebrowse-last-window-config)
   ("C-c w n"   . 'eyebrowse-next-window-config)
   ("C-c w p"   . 'eyebrowse-prev-window-config)
   ("C-c '"     . 'eyebrowse-switch-to-window-config))
  :config
  (setq eyebrowse-wrap-around t
        eyebrowse-close-window-config-prompt t
        eyebrowse-mode-line-style 'smart
        eyebrowse-tagged-slot-format "%t"
        eyebrowse-new-workspace nil)
  (eyebrowse-mode)
  )



;; Bookmark
(use-package bookmark-plus
  ;; Bookmark utilities
  :straight (bookmark-plus :type git :host github :repo "emacsmirror/bookmark-plus")
  :defer 3
  :init
  (require 'bookmark+)
  ;; Save bookmarks on every change
  (setq bookmark-save-flag 1)
  (setq bookmark-default-file (expand-file-name "bookmarks" user-emacs-directory))
  )

;; Magit
(use-package magit)

;; Try
(use-package try
  :ensure t)

;; Show keys
(use-package which-key
  :demand
  :config
  (which-key-mode)
  )

(use-package whole-line-or-region
  ;; If no region is active, C-w M-w will act on current line
  :defer 5
  ;; Right click to paste: I don't use the popup menu a lot.
  :bind ("<mouse-3>" . whole-line-or-region-yank)
  :bind (:map whole-line-or-region-local-mode-map
	      ("C-w" . kill-region-or-backward-word)) ;; Reserve for backward-kill-word
  :init
  (defun kill-region-or-backward-word ()
    "Kill selected region if region is active. Otherwise kill a backward word."
    (interactive)
    (if (region-active-p)
        (kill-region (region-beginning) (region-end))
      (backward-kill-word 1)))
  :config
  (whole-line-or-region-global-mode)
  )

;;; Auto save
(use-package super-save
  :defer 3
  :config
  (setq auto-save-default nil))

;;; Org mode stuff
(use-package org
  :straight org-bullets
  :straight ox-hugo
  :hook (org-mode . org-bullets-mode))

;;; Hugo
(with-eval-after-load 'ox
  (require 'ox-hugo))


;;; Python
(setq python-shell-interpreter "python3"
      python-shell-interpreter-args "-i")

(use-package elpy
  :ensure t
  :bind (:map elpy-mode-map
              ;; ("C-M-f" . elpy-nav-forward-block)
              ;; ("C-M-b" . elpy-nav-backward-block)
              ("M-<up>"          . nil)
              ("M-<down>"        . nil)
              ;; ("ESC <up>" . elpy-nav-move-line-or-region-up)
              ;; ("ESC <down>" . elpy-nav-move-line-or-region-down)
        )
  :init
  (advice-add 'python-mode :before 'elpy-enable)
  (add-hook 'elpy-mode-hook (lambda () (highlight-indentation-mode -1)))
  (add-hook 'python-mode-hook 'jedi:setup)
  (add-hook 'python-mode-hook
  '(lambda () (set (make-local-variable 'yas-indent-line) 'fixed)))
  (setq jedi:complete-on-dot t)
  (setq elpy-rpc-backend "jedi")
  )
(setenv "WORKON_HOME" "/root/.virtualenvs")
(setq elpy-rpc-python-command "python3")

;; (use-package blacken
;;   ;; Reformat python buffers using the "black" formatter
;;   :hook (python-mode . blacken-mode))

(setq elpy-rpc-python-command "python3")

(add-hook 'python-mode-hook 'yapf-mode)

;;; HTML
(add-to-list 'auto-mode-alist '("\\.ts\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
)
(add-hook 'web-mode-hook  'my-web-mode-hook)

(require 'emmet-mode)

(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.
(add-hook 'web-mode-hook  'emmet-mode)

;;; Typescript
(use-package typescript-mode
  :ensure t
  :config
  (setq typescript-indent-level 2)
  (add-hook 'typescript-mode #'subword-mode))

(use-package tide
  :init
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))


(defun setup-tide-mode ()
    (interactive)
    (tide-setup)
    (flycheck-mode +1)
    (setq flycheck-check-syntax-automatically '(save mode-enabled))
    (eldoc-mode +1)
    (tide-hl-identifier-mode +1)
    ;; company is an optional dependency. You have to
    ;; install it separately via package-install
    ;; `M-x package-install [ret] company`
    (company-mode +1))

  ;; aligns annotation to the right hand side
  (setq company-tooltip-align-annotations t)

  ;; formats the buffer before saving
  (add-hook 'before-save-hook 'tide-format-before-save)

  (add-hook 'typescript-mode-hook #'setup-tide-mode)

(require 'typescript-mode)

(require 'web-mode)

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-hook 'web-mode-hook
	  (lambda ()
	    (when (string-equal "tsx" (file-name-extension buffer-file-name))
	      (setup-tide-mode))))




;;; Golang

(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (replace-regexp-in-string
                          "[ \t\n]*$"
                          ""
                          (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq eshell-path-env path-from-shell) ; for eshell users
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))
(setenv "GOPATH" "/Git/GoExample")
;; (add-to-list 'exec-path "/root/go/bin")
(setq exec-path (append exec-path '("/root/go/bin")))

(use-package go-guru)

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))


;;; Some hooks
(add-hook 'before-save-hook 'delete-trailing-whitespace)


(defun my-go-mode-hook ()
      (setq tab-width 4 indent-tabs-mode nil)
      ; eldoc shows the signature of the function at point in the status bar.
      (go-eldoc-setup)
      (setq gofmt-command "goimports")
      (local-set-key (kbd "M-.") #'godef-jump)
      (local-set-key (kbd "C-x 4 M-.") #'godef-jump-other-window)
      (add-hook 'before-save-hook 'gofmt-before-save)

      ; extra keybindings from https://github.com/bbatsov/prelude/blob/master/modules/prelude-go.el
      (let ((map go-mode-map))
        (define-key map (kbd "C-c a") 'go-test-current-project) ;; current package, really
        (define-key map (kbd "C-c m") 'go-test-current-file)
        (define-key map (kbd "C-c .") 'go-test-current-test)
	(define-key map (kbd "C-M-w") 'next-buffer)
	(define-key map (kbd "C-M-q") 'previous-buffer)
        ; (define-key map (kbd "C-c b") 'go-run)
	))
(add-hook 'go-mode-hook 'my-go-mode-hook)
(add-hook 'completion-at-point-functions 'go-complete-at-point)

(set-face-attribute 'eldoc-highlight-function-argument nil
                    :underline t :foreground "green"
                    :weight 'bold)

(defun auto-complete-for-go ()
(auto-complete-mode 1))
(add-hook 'go-mode-hook 'auto-complete-for-go)

(with-eval-after-load 'go-mode
   (require 'go-autocomplete))


(require 'gud)
(require 'go-mode)

;; Sample marker lines:
;; > main.main() ./test.go:10 (hits goroutine(5):1 total:1)
;; > [unrecovered-panic] runtime.fatalpanic() /usr/lib/golang/src/runtime/panic.go:681 (hits goroutine(16):1 total:1) (PC: 0x435140)
;; Frame 2: /usr/lib/golang/src/testing/testing.go:792 (PC: 50fc82)
(defvar go-dlv-marker-regexp
  "^\\(?:\\(?:> .+?(.*?) \\)\\|\\(?:Frame [0-9]+: \\)\\)\\(.+?\\)\\:\\([0-9]+\\)")

(defvar go-dlv-marker-regexp-file-group 1)
(defvar go-dlv-marker-regexp-line-group 2)

(defvar go-dlv-marker-regexp-start "^> ")

(defvar go-dlv-marker-acc "")
(make-variable-buffer-local 'go-dlv-marker-acc)

;; There's no guarantee that Emacs will hand the filter the entire
;; marker at once; it could be broken up across several strings.  We
;; might even receive a big chunk with several markers in it.  If we
;; receive a chunk of text which looks like it might contain the
;; beginning of a marker, we save it here between calls to the
;; filter.
(defun go-dlv-marker-filter (string)
  (setq go-dlv-marker-acc (concat go-dlv-marker-acc string))
  (let ((output ""))
    ;; Process all the complete markers in this chunk.
    (while (string-match go-dlv-marker-regexp go-dlv-marker-acc)
      (setq

       ;; Extract the frame position from the marker.
       gud-last-frame
       (let ((file (match-string go-dlv-marker-regexp-file-group
                                 go-dlv-marker-acc))
             (line (string-to-number
                    (match-string go-dlv-marker-regexp-line-group
                                  go-dlv-marker-acc))))
         (cons file line))

       ;; Output everything instead of the below
       output (concat output (substring go-dlv-marker-acc 0 (match-end 0)))
       ;;	  ;; Append any text before the marker to the output we're going
       ;;	  ;; to return - we don't include the marker in this text.
       ;;	  output (concat output
       ;;		      (substring go-dlv-marker-acc 0 (match-beginning 0)))

       ;; Set the accumulator to the remaining text.
       go-dlv-marker-acc (substring go-dlv-marker-acc (match-end 0))))

    ;; Does the remaining text look like it might end with the
    ;; beginning of another marker?  If it does, then keep it in
    ;; go-dlv-marker-acc until we receive the rest of it.  Since we
    ;; know the full marker regexp above failed, it's pretty simple to
    ;; test for marker starts.
    (if (string-match go-dlv-marker-regexp-start go-dlv-marker-acc)
        (progn
          ;; Everything before the potential marker start can be output.
          (setq output (concat output (substring go-dlv-marker-acc
                                                 0 (match-beginning 0))))

          ;; Everything after, we save, to combine with later input.
          (setq go-dlv-marker-acc
                (substring go-dlv-marker-acc (match-beginning 0))))

      (setq output (concat output go-dlv-marker-acc)
            go-dlv-marker-acc ""))

    output))

(defcustom go-dlv-command-name "dlv"
  "File name for executing the Go Delve debugger.
This should be an executable on your path, or an absolute file name."
  :type 'string
  :group 'gud)

;;;###autoload
(defun dlv (command-line)
  "Run dlv on program FILE in buffer `*gud-FILE*'.
The directory containing FILE becomes the initial working directory
and source-file directory for your debugger."
  (interactive
   (list (gud-query-cmdline 'dlv "debug")))

  (gud-common-init command-line nil 'go-dlv-marker-filter)
  (set (make-local-variable 'gud-minor-mode) 'dlv)

  (gud-def gud-break  "break %d%f:%l"    "\C-b" "Set breakpoint at current line.")
  (gud-def gud-trace  "trace %d%f:%l"    "\C-t" "Set trace at current line.")
  (gud-def gud-remove "clearall %d%f:%l" "\C-d" "Remove breakpoint at current line")
  (gud-def gud-step   "step"             "\C-s" "Step one source line with display.")
  (gud-def gud-finish "stepout"          "\C-f" "Finish executing current function.")
  (gud-def gud-next   "next"             "\C-n" "Step one line (skip functions).")
  (gud-def gud-cont   "continue"         "\C-r" "Continue running program.")
  (gud-def gud-print  "print %e"         "\C-p" "Evaluate Go expression at point.")
  (gud-def gud-up     "up %p"            "<"    "Up N stack frames (numeric arg).")
  (gud-def gud-down   "down %p"          ">"    "Down N stack frames (numeric arg).")

  (setq comint-prompt-regexp "^(Dlv) *")
  (setq paragraph-start comint-prompt-regexp)
  (run-hooks 'go-dlv-mode-hook))

;;;###autoload
(defun dlv-current-func ()
  "Debug the current program or test stopping at the beginning of the current function."
  (interactive)
  (let (current-test-name current-bench-name current-func-loc)
    ;; find the location of the current function and (if it is a test function) its name
    (save-excursion
      (when (go-beginning-of-defun)
        (setq current-func-loc (format "%s:%d" buffer-file-name (line-number-at-pos)))
        ;; Check for Test or Benchmark function, set current-test-name/current-bench-name
        (when (looking-at go-func-regexp)
          (let ((func-name (match-string 1)))
            (when (string-match-p "_test\.go$" buffer-file-name)
              (cond
               ((string-match-p "^Test\\|^Example" func-name)
                (setq current-test-name func-name))
               ((string-match-p "^Benchmark" func-name)
                (setq current-bench-name func-name))))))))

    (if current-func-loc
        (let (gud-buffer-name dlv-command)
          (cond
           (current-test-name
            (setq gud-buffer-name "*gud-test*")
            (setq dlv-command (concat go-dlv-command-name " test -- -test.run " current-test-name)))
           (current-bench-name
            (setq gud-buffer-name "*gud-test*")
            (setq dlv-command (concat go-dlv-command-name " test -- -test.run='^$' -test.bench=" current-bench-name)))
           (t
            (setq gud-buffer-name "*gud-debug*")
            (setq dlv-command (concat go-dlv-command-name " debug"))))

          ;; stop the current active dlv session if any
          (let ((gud-buffer (get-buffer gud-buffer-name)))
            (when gud-buffer (kill-buffer gud-buffer)))

          ;; run dlv and stop at the beginning of the current function
          (dlv dlv-command)
          (gud-call (format "break %s" current-func-loc))
          (gud-call "continue"))
      (error "Not in function"))))

(provide 'go-dlv)

;;; go-dlv.el ends here


;; (use-package company-go
;; :defer 2
;; :config
;; (seq company-go-show-annotation t)
;; (add-hook 'go-mode-hook
;; 	(lambda()
;; 	(set (make-local-variable 'company-backends) '(company-go))
;; 	(company-mode))))

;;; R
(use-package ess
  :ensure t
  :init (require 'ess-site))

;;; Miscellaneous scrolling
(use-package golden-ratio-scroll-screen)
(global-set-key (kbd "C-v") 'golden-ratio-scroll-screen-down)
(global-set-key (kbd "M-v") 'golden-ratio-scroll-screen-up)


;;; dump-jump
(use-package dumb-jump
:bind (("M-g o" . dumb-jump-go-other-window)
("M-g b" . dumb-jump-back)
("M-g j" . dumb-jump-go)
("M-g x" . dumb-jump-go-prefer-external)
("M-g z" . dumb-jump-go-prefer-external-other-window))
:config (setq dumb-jump-selector 'ivy) ;; (setq dumb-jump-selector 'helm)
:ensure)

;;; projectile
(use-package projectile
:ensure t
:config
(projectile-global-mode)
(setq projectile-completion-system 'ivy))

(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

(setq projectile-project-search-path '("/Git" "~/.emacs.d"))
(setq projectile-globally-ignored-file-suffixes '(".png" ".jpg" ".gif" ".woff" ".woff2" ".ttf" ".cache" "__init__.py"))
(use-package counsel-projectile
:ensure t
:config
(counsel-projectile-on))

;;; undo-tree
(use-package undo-tree
  :defer 3
  :config
  (global-undo-tree-mode))

;;; Themes and Fonts
;; (load-theme 'leuven t)
;; (load-theme 'sanityinc-tomorrow-bright' t)
;; (load-theme 'sanityinc-tomorrow-day' t)
;; (load-theme 'sanityinc-tomorrow-bright' t)
(load-theme 'sanityinc-tomorrow-eighties' t)

;; smart-mode-line
(use-package smart-mode-line
  :ensure t
  :defer 0.2
  :init
  ;;(add-hook 'after-load-theme-hook 'smart-mode-line-enable)
  (setq sml/no-confirm-load-theme t
        sml/theme 'dark
        sml/mode-width 'full
        sml/name-width 30
        sml/shorten-modes t
        sml/show-frame-identification nil
        sml/shorten-directory t
        sml/shortener-func (lambda (_dir _max-length) "")
        )
  (sml/setup)
  (sml/apply-theme 'dark)
  )


;;; ibuffer
(global-set-key (kbd "C-x C-b") 'ibuffer)
(setq ibuffer-saved-filter-groups
(quote (("default"
("dired" (mode . dired-mode))
("org" (name . "^.*org$"))
("shell" (or (mode . eshell-mode) (mode . shell-mode)))
("programming" (or
(mode . python-mode)
(mode . c++-mode)
(mode . go-mode)
(mode . ess-mode)
))
("emacs" (or
(name . "^\\*scratch\\*$")
(name . "^\\*Messages\\*$")))
))))
(add-hook 'ibuffer-mode-hook
(lambda ()
(ibuffer-auto-mode 1)
(ibuffer-switch-to-saved-filter-groups "default")))


(use-package hippie-exp
  :ensure nil
  :defer 3
  :bind (("M-/"   . hippie-expand-no-case-fold)
	 ("M-t"   . hippie-expand-no-case-fold)
	 ("M-c"   . hippie-expand-no-case-fold)
         ("C-M-/" . dabbrev-completion))
  :config
  ;; Don't case-fold when expanding with hippe
  (defun hippie-expand-no-case-fold ()
    (interactive)
    (let ((case-fold-search nil))
      (hippie-expand nil)))

  ;; hippie expand is dabbrev expand on steroids
  (setq hippie-expand-try-functions-list '(try-expand-dabbrev
                                           try-expand-dabbrev-all-buffers
                                           try-expand-dabbrev-from-kill
                                           try-complete-file-name-partially
                                           try-complete-file-name
                                           try-expand-all-abbrevs
                                           try-expand-list
                                           try-expand-line
                                           try-complete-lisp-symbol-partially
                                           try-complete-lisp-symbol))

  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org mode start                                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Org-mode
(setq my-sync-directory "/Git/orgfiles")
(setq org-confirm-elisp-link-function nil)
(setq org-clock-into-drawer nil)

(use-package org
  ;; Combining demand and org-plus-contrib to ensure the latest version of org is used
  :demand t
  ;; :straight org-bullets
  :hook (org-mode . turn-off-auto-fill)
  :hook (org-mode . org-bullets-mode)
  :hook (org-mode . visual-line-mode)
  :init
  ;; customized export formats
  :bind (
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture)
	 )

  :bind (:map org-mode-map
              ("ESC <right>"    . org-shiftright)
              ("ESC <left>"    . org-shiftleft)

              ;; Unbinding org-cycle-agenda-files
              ("C-'"          . nil)
              ("C-,"          . nil)
              ;; Unbinding org-force-cycle-archived
              ("<C-tab>"      . nil)
	      ("M-<down>"      . nil)
              ("M-<up>"      . nil)
	      ("ESC <down>"      . nil)
	      ("ESC-<up>"      . nil)
	      ("ESC-<left>"      . nil)
	      ("ESC-<right>"      . nil)
	      ("C-M-i"      . org-clock-in)
	      ("C-M-o"      . org-clock-out)
	      ("C-M-l"      . org-id-store-link)
	      )
  :config
  ;; All org directory under Dropbox
  (setq org-directory (expand-file-name "journals" my-sync-directory))
  ;; Personal files
  (setq org-blog-file (expand-file-name "blog.org" my-sync-directory))
  (setq org-commands-file (expand-file-name "commands.org" my-sync-directory))
  (setq org-cheatsheet-file (expand-file-name "cheatsheet.org" my-sync-directory))
  (setq org-notes-file (expand-file-name "notes.org" my-sync-directory))
  (setq org-links-file (expand-file-name "links.org" my-sync-directory))
  (setq org-todo-file (expand-file-name "todo.org" my-sync-directory))
  (setq org-daily-file (expand-file-name "daily.org" my-sync-directory))
  (setq org-hossted-file (expand-file-name "hossted.org" my-sync-directory))
  (setq org-work-file (expand-file-name "work.org" my-sync-directory))
  (setq org-journal-file (expand-file-name "journal.org" my-sync-directory))
  (setq org-todo-keyword-faces


 '(("TODO" . (:foreground "dark salmon" :weight bold :underline t))
          ("NEXT" . (:foreground "dark salmon" :weight bold :underline t))
          ("IN-PROGRESS" . (:foreground "rosy brown" :weight bold :underline t))
          ("CONTINUE" . (:foreground "rosy brown" :weight bold :underline t))
          ("CANCELLED" . (:foreground "dark grey" :weight bold :underline t))
          ("DONE" .  (:foreground "dark goldenrod" :weight bold :underline t))))

  ;; Default org-mode startup
  (setq org-startup-folded t
        org-startup-indented t
        org-startup-with-inline-images nil
        org-startup-with-latex-preview nil
  )
)

(setf org-blank-before-new-entry '((heading . t) (plain-list-item . t)))
(setq org-todo-keywords
      '((sequence "TODO" "NEXT" "IN-PROGRESS" "CONTINUE" "DONE" "CANCELLED")))

(setq org-agenda-files (list "/Git/orgfiles/agenda.org"))

(setq org-capture-templates
'(("a" "Appointment" entry (file  "/Git/orgfiles/gcal.org" "Appointments")
   "* TODO %?\n:PROPERTIES:\n\n:END:\nDEADLINE: %^T \n %i\n")
("c" "Commands" entry (file+headline org-commands-file "Commands")
 "* %i \n%?")

("n" "Note" entry (file+headline org-notes-file "Notes")
 "* %i \n%?" :empty-lines 1 :jump-to-captured t)

("l" "Link" entry (file+headline org-links-file "Links")
 "* %? %^L %^g \n%t")

("b" "Blog idea" entry (file+headline org-blog-file "Blog Topics:")
 "* %i %^t %^g \n%?" :prepend t :empty-lines 1 :jump-to-captured t)

("t" "To Do Item" entry (file+headline org-todo-file "To Do Items")
 "* %i %t \n%?" :prepend t :empty-lines 1 :jump-to-captured t)

("j" "Journal" entry (file+datetree org-journal-file)
 "* %? %^g\n%i\n  %a" :empty-lines 1 :jump-to-captured t)

("d" "Daily" entry (file+datetree org-daily-file)
 "* %? %^g\n%i\n  %a" :empty-lines 1 :jump-to-captured t)

("w" "Work" entry (file+datetree org-work-file)
 "* %? %^g\n%i\n  %a" :empty-lines 1 :jump-to-captured t)

("h" "Hossted" entry (file+datetree  org-hossted-file)
 "* %? %^g\n%i\n  %a" :empty-lines 1 :jump-to-captured t)

;; Cheatsheet related
("P" "Cheatsheet - Python" entry (file+headline org-cheatsheet-file "Python")
 "* %? \n%i " :empty-lines 1 :jump-to-captured t)

("G" "Cheatsheet - Golang" entry (file+headline org-cheatsheet-file "Go")
 "* %? \n%i" :empty-lines 1 :jump-to-captured t)

("E" "Cheatsheet - Emacs" entry (file+headline org-cheatsheet-file "emacs")
 "* %? \n%i " :empty-lines 1 :jump-to-captured t)

))

;;; some org color
;; (add-to-list 'org-emphasis-alist
;;              '("*" (:foreground "gold")
;;                ))

(setq org-emphasis-alist
      '(("*" (bold :foreground "Orange" ))
	("/" italic)
	("_" underline)
	("=" (:background "maroon" :foreground "white"))
	("~" (:background "deep sky blue" :foreground "MidnightBlue"))
	("+" (:strike-through t))))

;;; Some global bind key
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-c;" 'comment-line)
(global-set-key (kbd "<f5>") 'revert-buffer)
(setq inhibit-startup-message t)


(require 'org-element)
(require 'ox)
(require 'ox-html)
(require 'ox-reveal)

(defcustom org-html-quote-keep-newlines nil
    "Keep newlines in org quote blocks.
This is the default value.
You can set it buffer-specific with
,#+HTML_QUOTE_KEEP_NEWLINES: t"
    :group 'org-html
    :type 'boolean)

(setf (org-export-backend-options (org-export-get-backend 'html))
      (cons
       '(:html-quote-keep-newlines "HTML_QUOTE_KEEP_NEWLINES" nil org-html-quote-keep-newlines)
       (org-export-backend-options (org-export-get-backend 'html))))

(defun my-html-real-text-on-line-p ()
  "Return non-nil if there is more than whitespace and html tags on current line."
  (catch :found
    (while (null (eq (char-after) ?\n))
      (skip-syntax-forward " ") ;; skip whitespace
      (cond
       ((eq (char-after) ?<) ;; 1st case: beginning of tag
	;; go behind the tag:
	(skip-chars-forward "^>") ;;< We even skip newlines here. It is actually an error if we fall off the edge of the world at this point.
	(forward-char)) ;;< Go behind the tag.
       ((eq (char-after) ?\n)) ;; 2nd case: Do nothing if we end up at an end of line.
       (t (throw :found t)))))) ;; 3rd case: No tag, no end of line, that is actually some real text.

(defun my-org-quote-preserve-linebreaks (quote_block_contents back_end info)
  "Keep linebreaks in QUOTE_BLOCK_CONTENTS when BACK_END is 'html."
  (when (and (eq back_end 'html)
	     (plist-get info :html-quote-keep-newlines))
    (with-temp-buffer
      (insert quote_block_contents)
      (goto-char (point-min))
      (while (null (eobp))
	(when (my-html-real-text-on-line-p)
	  (end-of-line)
	  (insert "<br/>"))
	(forward-line))
      (buffer-string))))

(add-hook 'org-export-filter-quote-block-functions #'my-org-quote-preserve-linebreaks)

(org-add-link-type
 "color"
 (lambda (path)
   (message (concat "color "
		    (progn (add-text-properties
			    0 (length path)
			    (list 'face `((t (:foreground ,path))))
			    path) path))))
 (lambda (path desc format)
   (cond
    ((eq format 'html)
          (format "<span style=\"color:%s;\">%s</span>\" path desc))
    ((eq format 'latex)
     (format \"{\\color{%s}%s}\" path desc)))))
\"")))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org mode finish                                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Closing
(defun ask-before-closing ()
  "Close only if y was pressed."
  (interactive)
  (if (y-or-n-p (format "Are you sure you want to close this frame? "))
      (save-buffers-kill-terminal)
    (message "Canceled frame close")))

(global-set-key (kbd "C-x C-c") 'ask-before-closing)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A random separator                                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Long Misc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; mark and edit all copies of the marked region simultaniously.
(use-package iedit
:ensure t)

; if you're windened, narrow to the region, if you're narrowed, widen
; bound to C-x n
(defun narrow-or-widen-dwim (p)
"If the buffer is narrowed, it widens. Otherwise, it narrows intelligently.
Intelligently means: region, org-src-block, org-subtree, or defun,
whichever applies first.
Narrowing to org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer is already
narrowed."
(interactive "P")
(declare (interactive-only))
(cond ((and (buffer-narrowed-p) (not p)) (widen))
((region-active-p)
(narrow-to-region (region-beginning) (region-end)))
((derived-mode-p 'org-mode)
;; `org-edit-src-code' is not a real narrowing command.
;; Remove this first conditional if you don't want it.
(cond ((ignore-errors (org-edit-src-code))
(delete-other-windows))
((org-at-block-p)
(org-narrow-to-block))
(t (org-narrow-to-subtree))))
(t (narrow-to-defun))))

;; (define-key endless/toggle-map "n" #'narrow-or-widen-dwim)
;; This line actually replaces Emacs' entire narrowing keymap, that's
;; how much I like this command. Only copy it if that's what you want.
(define-key ctl-x-map "n" #'narrow-or-widen-dwim)



;; When config gets stable, using emacs server may be more convenient
;; (require 'server)
;; (unless (server-running-p)
;;   (server-start))

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(bmkp-last-as-first-bookmark-file "/root/.emacs.d/bookmarks")
 '(custom-safe-themes
   (quote
    ("f3ab34b145c3b2a0f3a570ddff8fabb92dafc7679ac19444c31058ac305275e1" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "43cadc6254cf27ff544e044b4139a7d50cf44e107cffef255aa8c5943581f606" "62a40a0c171466abb0b321d1682f64ed2e2e8a12ae781837034822061c39f7eb" default)))
 '(org-agenda-files (quote ("~/chun/agender.org")))
 '(package-selected-packages
   (quote
    (ag counsel-projectile projectile dumb-jump better-shell term-keys expand-region hungry-delete beacon ace-window org-bullets try unittest undo-tree golden-ratio-scroll-screen golden-ration-scroll-screen jedi counsel-tramp magit eyebrowse ess elpy super-save whole-line-or-region which-key aggressive-indent wgrep smex ivy-rich counsel go-mode smartparens use-package)))
 '(python-shell-interpreter "python3" t)
 '(send-mail-function (quote mailclient-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0)))))
