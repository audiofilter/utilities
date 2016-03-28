(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)
(setq ns-function-modifier 'hyper)

;; keybinding to toggle full screen mode
(global-set-key (quote [M-f10]) (quote ns-toggle-fullscreen))

;; Move to trash when deleting stuff
(setq delete-by-moving-to-trash t trash-directory "~/tmp/emacs")

;; to copy and paste from clipboard
(setq x-select-enable-clipboard t)

(set-frame-size (selected-frame) 130 70)

(add-hook 'after-init-hook #'global-flycheck-mode)

;(setq load-path (cons "\/home\/tkirke\/lisp" load-path))
(fset 'yes-or-no-p 'y-or-n-p)
(setq load-path (cons "\/Users\/tgkirk\/emacs_lisp" load-path))
;; -*- Mode: Emacs-Lisp -*-
(defun byte-compile-if-newer-and-load (file)
  "Byte compile file.el if newer than file.elc"
  (if (file-newer-than-file-p (concat file ".el") (concat file ".elc"))
  (byte-compile-file (concat file ".el")))
  (load file))
;(byte-compile-if-newer-and-load "xemacs-startup")
(byte-compile-if-newer-and-load "packages")

(load "template")

(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line


(exec-path-from-shell-initialize)

(setq clang-format-executable "/usr/local/bin/clang-format")
(load "clang-format")
(template-initialize)
(fset 'yes-or-no-p 'y-or-n-p)

(setq where "")
;;(setq abbrev-mode t)


;;;; shell on win95 to bash
;;; end of changes required for bash
;(setq explicit-sh-args '("-i"))
;(setq shell-command-switch "-c")

(column-number-mode 1)
(defvar cvlog-c-mode-keyword-completion-char 'multi_key)
(setq show-paren-mode t)
(setq minibuffer-max-depth nil)
(setq url-gateway-broken-resolution t)
(setq query-replace-highlight t)	;highlight during query
(setq search-highlight t)		;incremental search highlights

(setq uniquify-buffer-name-style 'reverse)   
(setq uniquify-separator "/")   
(setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified   
    
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special   

;;(load-library "rtags")
(require 'cpputils-cmake)
(require 'cmake-ide)
(cmake-ide-setup)
(require 'cc-mode)
(require 'expand)
(require 'cmake-mode)
;;;;;(require 'confluence)
(load-library "whitespace")
(load-library "matlab")

;;(setq matlab-indent-function t)
(setq fill-column 200)


(setq ediff-window-setup-function 'ediff-setup-windows-plain)
; To make ediff to be horizontally split use:
(setq ediff-split-window-function 'split-window-horizontally)
;Note that you can also split the window depending on the frame width:
(setq ediff-split-window-function (if (> (frame-width) 150)
                                      'split-window-horizontally
                                    'split-window-vertically))


(put 'narrow-to-region 'disabled nil)

;; This adds additional extensions which indicate files normally
;; handled by cc-mode.
(setq auto-mode-alist
      (append '(("\\.cc$"  . c++-mode)
		("\\.hh$" . c++-mode)
		("\\.bit$"  . hexl-mode)
		("\\.php$"  . php-mode)
		("\\.pm$"  . perl-mode)
		("\\.bin$"  . hexl-mode)
		("\\.pde$"  . processing-mode)
		("\\.m$"  . matlab-mode)
		("\\.py$"  . python-mode)
		("\\.pyx$"  . python-mode)
		("CMakeLists.txt"  . cmake-mode)
		("\\.c$"  . c-mode)
		("\\.h$"  . c-mode))
	      auto-mode-alist))

;; Change the indentation amount to 4 spaces instead of 2.
;; You have to do it in this complicated way because of the
;; strange way the cc-mode initializes the value of `c-basic-offset'.

(setq line-number-mode t)
(setq font-lock-keywords t)
(setq kill-whole-line t)
;;;; Add dired highlighting for various file types
(setq dired-font-lock-keywords t)
(setq dired-font-lock-keywords (purecopy
    (list
     (cons (concat "^D.*$") 'font-lock-doc-string-face)
     (cons (concat "^  .*\\(\\.c\\|\\.h\\|\\.cpp\\).*$") 'font-lock-string-face)
     (cons (concat "^  .*\\(\\.v\\|\\.vhd\\|\\.vhdl\\).*$") 'font-lock-preprocessor-face)
     (cons (concat "^  .*\\(\\.htm\\|\\.html\\).*$") 'font-lock-comment-face)
     (cons (concat "^  .*\\(\\.txt\\|\\.doc\\).*$") 'font-lock-reference-face)
     (cons (concat "^  d.*$") 'font-lock-warning-face)
    )))


;; -------------------Tony's Macros
;; Avoid tabs?
(setq-default indent-tabs-mode nil)

(defvar cmake-tab-width 4)
(setq-default tab-width 4)
(setq tab-width 4)
;(setq indent-line-function 'insert-tab)
(setq c-basic-offset 4)   

(defun my-indent-setup ()
  (c-set-offset 'arglist-intro '5)
  (c-set-offset 'arglist-cont '-1)
  (c-set-offset 'arglist-cont-nonempty '0)
  (c-set-offset 'arglist-close '0)
  )

;; Customizations for all modes in CC Mode.
(defun my-c-mode-common-hook ()
  ;; set my personal style for the current buffer
  (c-set-style "tony")
)

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)


(defalias 'ehead
  (read-kbd-macro "C-u de 4*<backspace> HEAD RET"))

(fset 'comout   "\C-a--\C-n")
(fset 'rekill	  "\C-n\C-k")
(fset 'remcom   "\C-a\C-d\C-d\C-n")

(byte-compile-if-newer-and-load "emacs-keys")
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
