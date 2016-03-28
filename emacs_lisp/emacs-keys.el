;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          Key Definitions                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Set up the function keys to do common tasks to reduce Emacs pinky
;;; and such.

;; You can set a key sequence either to a command or to another key
;; sequence. (Use `C-h k' to map a key sequence to its command.  Use
;; `C-h w' to go the other way.) In general, however, it works better
;; to specify the command name.  For example, it does not currently
;; work to say

;;   (global-set-key 'f5 "\C-x\C-f")

;; The reason is that macros (which is what the string on the right
;; really is) can't currently use the minibuffer.  This is an
;; extremely longstanding bug in Emacs.  Eventually, it will be
;; fixed. (Hopefully ..)

;; Note also that you may sometimes see the idiom

;;   (define-key global-map ...)

;; in place of (global-set-key ...).  These are exactly the same.

;; Make the sequence "C-x w" execute the `what-line' command, 
;; which prints the current line number in the echo area.
(global-set-key "\C-xw" 'what-line)
(global-set-key "\C-xt" 'template-new-file)
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(global-set-key "\C-o" 'rekill)
(global-set-key "\C-z" 'kill-line)
(global-set-key "\C-xz" 'compile)       


;; PC Function Keys
(global-set-key [(shift f2)] 'universal-argument) ;uncomment is Shift-F2 F2 
(global-set-key [(shift f4)] 'wrap-all-lines) 
(global-set-key [(shift f5)] 'list-colors-display)
(global-set-key [(shift f6)] 'bury-buffer)

;; move just to the right of the closing paren and type C-x C-e.
(define-key global-map (quote [end]) (quote end-of-line))
(define-key global-map (quote [home]) (quote beginning-of-line))

(global-set-key [delete] 'delete-char)
(global-set-key [(meta right)] 'forward-word)
(global-set-key [(meta left)] 'backward-word)
(global-set-key (kbd "<C-home>") 'beginning-of-buffer)
(global-set-key (kbd "<C-end>") 'end-of-buffer)
(global-set-key [(meta f12)] 'goto-line)
(global-set-key (kbd "<C-up>") 'kill-this-buffer)

(global-set-key (kbd "<f1>") 'search-forward-regexp)
(global-set-key (kbd "<f2>") 'goto-line)
(global-set-key (kbd "<f3>") 'clang-format-region)
(global-set-key (kbd "<f4>") 'query-replace-regexp);  // yank-clipboard-selection) ;; Paste
(global-set-key (kbd "<f5>") 'query-replace)
(global-set-key (kbd "<f6>") 'other-window)
(global-set-key (kbd "<f7>") 'abbrev-mode)
(global-set-key (kbd "<S-f7>") 'switch-to-next-buffer)
(global-set-key (kbd "<A-f7>") 'toggle-source-header)

(global-set-key (kbd "<f8>") 'whitespace-mode)
(global-set-key (kbd "<f9>") 'kill-line)
(global-set-key (kbd "<C-f12>") 'end-of-buffer)


(global-set-key [(shift f12)] "†" )
(global-set-key [(control f12)] "—" )

(global-set-key [C-S-f1] "⁕")

