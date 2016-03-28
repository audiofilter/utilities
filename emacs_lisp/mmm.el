;;; mmm.el --- Multiple Major Modes for XEmacs

;; Copyright (C) 1998 Petrotechical Open Software Corp. (POSC)

;; Author:     Gongquan Chen <chen@posc.org>
;; Maintainer: chen@posc.org
;; Created:    Dec-22-1998
;; Version:    0.11
;; Keywords:   extensions, major-mode, font-lock

;; This file may be part of XEmacs.

;; XEmacs is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; XEmacs is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with XEmacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This file implements a XEmacs lisp extension that allows multiple major modes
;; to co-exist in a single buffer. It's a workable, yet imperfect, solution that
;; basically supports key bindings and font-lock in those regions with a secondary
;; major mode. To activate one secondary major mode, simply add a hook to the
;; primary major mode's hook.  For details, see defun `mmm-activator'.

;;; Features:
;; For regions in secondary major modes, 
;; 1. font-lock support
;; 2. keymap support 
;; 3. `popup-mode-menu'

;;; Example:
;; Here is an example of enabling CSS mode as a secondary mode in the HTML 
;; primary major mode:

;(defun mmm-detect-css-region ()
;  (let ((case-fold-search t)
;	b e)
;    (and (re-search-forward "<style\\([^<>]*\\)>" nil t)
;	 (setq b (match-end 0))
;	 (search-forward "</style>" nil t)
;	 (setq e (match-beginning 0))
;	 (cons 'css-mode (cons b e))))
;)

;(defun mmm-css-activator () 
;  (mmm-activator 'mmm-detect-css-region)
;)

;(require 'css-mode)
;(add-hook 'html-mode-hook 'mmm-css-activator)

;;; Change Log:
;; 0.10 01/11/1999
;;      initial release on comp.emacs.xemacs
;; 0.11 01/12/1999
;;      fix doc-strings and style, thanks to comments from Jari Aalto <jaalto@tre.tele.nokia.fi>
;;


;;; Limitations:

;; 1. mode-related local variables can not be set in the regions with a secondary
;;    major mode. Its mode-hook will not be called either.
;; 2. "keymap leakage" due to use of extents for the regions -- if a key is not
;;    in the keymap of a secondary major mode, its binding will be sought in that
;;    of the primary major mode.

;;; Caveats:

;; This extension was developed and used in XEmacs v21.0b60 and its bundled font-lock.
;; It has not been tested/used in any previous version of XEmacs and font-lock.

;;; Code:
(require 'font-lock)

(defconst mmm-version "0.11"
  "Current version of the mmm extension.")

(defvar mmm-regions-count 0
  "Number of regions in some secondary major mode.")
(make-variable-buffer-local 'mmm-regions-count)


(defvar mmm-face (make-face 'mmm-face)
  "Face used to indicate text regions in a secondary mode.
Preferrably, in order not to mess with font-lock for the
secondary mode, only the background color may be set for
this face.  See `set-face-background'")
(set-face-background 'mmm-face "gray95")


(defun mmm-check-mode-variable (m s)
  "Check mode M's variable S's value by the name M-S."
  (let* ((x (format "%s-%s" m s))
	 (y (intern-soft x)))
    (and y
	 (symbol-value y)))
)

;;; our API entry point:
;;
(defun mmm-activator (detector)
  "Activate secondary major modes in regions identified by DETECTOR.

DECTECTOR is a symbol for a function that is called with no arguments.
It should return a region as a CONS cell of (MODE . (BEGIN-POS . END-POS))
where the secondary major MODE will be applied.  DETECTOR will be called
repeatedly until it returns nil - so it should never start from `point-min'
when it's called.

For each region that DETECTOR identifies, a special extent is created,
whose keymap is assigned with that of the secondary major MODE.  A indicator
face, `mmm-face', is also attached to the extent.

If font-lock is enabled for the primary major mode, regions in the seconday
major modes will also be highlighted with their respective keywords.

To activate any secondary major mode, simply `add-hook' to the primary
major mode's mode-hook with a callback which will call this function."

  (let (region)
    ;;sanity check...
    (or (fboundp detector)
	(error "region DETECTOR isn't fboundp"))

    (save-excursion
      (goto-char (point-min))
      (while (setq region (funcall detector))
	(let (p1 p2 ext mode map)
	  (setq mode (car region)
		p1 (car (cdr region))
		p2 (cdr (cdr region))
		map (mmm-check-mode-variable mode 'map)
		ext (make-extent p1 p2)
		mmm-regions-count (1+ mmm-regions-count)
		)
	  (set-extent-properties ext (list 'keymap map
					   ':mmm mode
					   'face 'mmm-face))
	  ))))
)

;;; a callback defun for the post-command-hook:
;; 1. update modeline
;; 2. adjust syntax table
(defun mmm-post-cmd-cb ()
  "Callback hooked on `post-command-hook' that updates the modeline on the mode
string to show if the point is inside a secondary major mode. If yes and the 
secondary major mode has its own syntax table, then it is set as the current
syntax table."

  (if (> mmm-regions-count 0)
      (let ((x (extent-at (point) nil ':mmm))
	    mode
	    syntab)

	(if x 
	    (setq mode (extent-property x ':mmm)
		  mode-name (format "%s:%s" major-mode mode))
	  (setq mode-name (format "%s" major-mode)))
	
	(setq mode-name (replace-in-string mode-name "-mode" "" t))
	(redraw-modeline)
    
	(setq syntab (mmm-check-mode-variable (if x mode major-mode) 'syntax-table))
	(if (syntax-table-p syntab)
	    (set-syntax-table syntab))
	))
)
(add-hook 'post-command-hook 'mmm-post-cmd-cb)


;;; mode context menu support by overloading popup-mode-menu
;;
(defadvice popup-mode-menu (around popup-mode-menu-by-mmm activate)
  "Adjust `mode-popup-menu' for `popup-mode-menu' in regions with secondary
major modes.  Several patterns are tried to find the mode menu."
  (let ((mode-popup-menu mode-popup-menu)
	(x (extent-at (point) nil ':mmm)))
    (if x
	(let* ((mode (extent-property x ':mmm))
	       (name (replace-in-string (format "%s" mode) "-mode$" "" t))
	       s
	       (menu (or (mmm-check-mode-variable mode 'popup-menu)            ;?-mode-popup-menu
			 (mmm-check-mode-variable mode 'popup-menu-1)          ;?-mode-popup-menu-1
			 (mmm-check-mode-variable mode 'menu)                  ;?-mode-menu
			 (and (setq s (intern-soft (concat name "-menu")))     ;?-menu
			      (symbol-value s))
			 ;;hack for cc-mode mode-menu:
			 (and (setq s (intern-soft (concat "c-" name "-menu")));c-?-menu
			      (symbol-value s))
			 )))
	  (if menu (setq mode-popup-menu menu))
	  ))
    ad-do-it)
)

;;; font-lock support by redirecting `font-lock-fontify-region-function'
;;
(defun mmm-fontify-region-1 (x &optional beg end)
  "Fontify a region covered by extent X assigned with a secondary major mode.
Optional arguments BEG and END default to the start and end positions of the
extent, respectively."
  (let* (;;localize...
	 font-lock-keywords
	 font-lock-defaults
	 font-lock-keywords-only
	 font-lock-keywords-case-fold-search
	 font-lock-syntax-table
	 font-lock-beginning-of-syntax-function
	 font-lock-defaults-computed
	 major-mode

	 ;;
	 (mode (extent-property x ':mmm))
	 (syntab (mmm-check-mode-variable mode 'syntax-table))
	 (old-syntab (syntax-table))
	 )
    
    (if syntab (set-syntax-table syntab))
    (setq major-mode mode)
    (font-lock-set-defaults-1)
    (font-lock-default-fontify-region (or beg (extent-start-position x))
				      (or end (extent-end-position x)))
    (if syntab (set-syntax-table old-syntab))
    )
)

(defun mmm-fontify-region (beg end &optional loudly)
  "A replacement for `font-lock-default-fontify-region' to support syntax
lighlighting in secondary major modes. It's assigned to variable:
`font-lock-fontify-region-function'"

  (let ((x (extent-at beg nil ':mmm)))
    (if (and x
	     (<= (extent-start-position x) beg)
	     (>= (extent-end-position x) end))
	(mmm-fontify-region-1 x beg end)
      ;;else
      (font-lock-default-fontify-region beg end loudly)
      (mapcar 'mmm-fontify-region-1
	      (mapcar-extents '(lambda(x) x)
			      '(lambda(x) (extent-property x ':mmm))
			      nil
			      beg
			      end))))
)
(setq font-lock-fontify-region-function 'mmm-fontify-region)


(defun mmm-cleanup (&optional buf)
  "Clears all secondary major modes in BUFFER,
which defaults to current buffer"
  (interactive)
  (if buf (set-buffer buf))
  (mapcar-extents '(lambda(x) (delete-extent x))
		  '(lambda(x) (extent-property x ':mmm)))
  (setq mmm-regions-count 0)
)
(add-hook 'change-major-mode-hook 'mmm-cleanup)


(provide 'mmm)

;;; mmm.el ends here
