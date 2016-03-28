;:* $Id: packages,v 1.1 1999/06/26 20:12:18 robin Exp robin $
;:*=======================
;:* automatic horizontal scrolling
;(require 'auto-show)
;:*=======================

;:* a minor mode, which highlights whitespaces (blanks and tabs) with
;:* different faces, so that it is easier to distinguish between them.
(autoload 'whitespace-mode "whitespace-mode" 
  "Toggle whitespace mode.
   With arg, turn whitespace mode on iff arg is positive.  In
   whitespace mode the different whitespaces (tab, blank return) are
   highlighted with different faces. The faces are:
   `whitespace-blank-face', `whitespace-tab-face' and
   `whitespace-return-face'."
  t)
(autoload 'whitespace-incremental-mode "whitespace-mode" 
  "Toggle whitespace incremental mode.
   With arg, turn whitespace incremental mode on iff arg is positive.
   In whitespace incremental mode the different whitespaces (tab and
   blank) are highlighted with different faces. The faces are:
   `whitespace-blank-face' and `whitespace-tab-face'.  Use the command
   `whitespace-show-faces' to show their values.  In this mode only
   these tabs and blanks are highlighted, which are in the region from
   (point) - (window-heigh) to (point) + (window-heigh)."
  t)
;:*=======================
;:* font-lock
(remove-hook 'font-lock-mode-hook 'turn-on-fast-lock)
(require 'font-lock)
