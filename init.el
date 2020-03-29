;; Bootstrap 'use-package
(require 'package)
(setq package-enable-at-startup nil)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(package-initialize nil)
;; Add custom lisp files to the load-path
(add-to-list 'load-path "~/.emacs.d/lisp")
(package-initialize nil)

;(require 'vde-functions)
;; initialize all ELPA packages
(require 'setup-package)

;; Make sure we have a decent and recent org-mode version
(require 'org)

;; keep customize settings in their own file
(setq custom-file
      (expand-file-name "custom.el"
			user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; load the literate configuration
(require 'ob-tangle)

(org-babel-load-file "~/.emacs.d/emacs.org")


