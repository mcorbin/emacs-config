;;; vagrant-tramp-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (or (file-name-directory #$) (car load-path)))

;;;### (autoloads nil "vagrant-tramp" "vagrant-tramp.el" (21862 371
;;;;;;  255251 818000))
;;; Generated autoloads from vagrant-tramp.el

(defconst vagrant-tramp-method "vagrant" "\
TRAMP method for vagrant boxes.")

(defvar vagrant-tramp-ssh (executable-find (concat (file-name-directory (or load-file-name buffer-file-name)) "bin/vagrant-tramp-ssh")) "\
The vagrant-tramp-ssh executable.")

(custom-autoload 'vagrant-tramp-ssh "vagrant-tramp" t)

(autoload 'vagrant-tramp-term "vagrant-tramp" "\
SSH to a Vagrant BOX in an `ansi-term'.

\(fn BOX)" t nil)

(autoload 'vagrant-tramp-enable "vagrant-tramp" "\
Add `vagrant-tramp-method' to `tramp-methods'.

\(fn)" nil nil)

;;;***

;;;### (autoloads nil nil ("vagrant-tramp-pkg.el") (21862 371 371595
;;;;;;  700000))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; vagrant-tramp-autoloads.el ends here
