;;; manage-minor-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (or (file-name-directory #$) (car load-path)))

;;;### (autoloads nil "manage-minor-mode" "manage-minor-mode.el"
;;;;;;  (21860 15456 621448 721000))
;;; Generated autoloads from manage-minor-mode.el

(autoload 'manage-minor-mode-set "manage-minor-mode" "\


\(fn)" nil nil)

(autoload 'manage-minor-mode "manage-minor-mode" "\


\(fn &optional $LAST-TOGGLED-ITEM)" t nil)

(autoload 'manage-minor-mode-bals "manage-minor-mode" "\

Eradicate all minor-modes in the current buffer.
This command may cause unexpected effect even to other buffers.
However, don't worry, restore command exists:
 `manage-minor-mode-restore-from-bals'.

\(fn)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; manage-minor-mode-autoloads.el ends here
