(require 'package)

;; add org to package repos
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))

;; add melpa and melpa-stable to package repos
(add-to-list 'package-archives '("mela-stable" . "http://stable.melpa.org/packages/"))


;; Fire up package.el
(package-initialize)

;; Load package contents if not present
(when (not package-archive-contents)
  (package-refresh-contents))

;; Load use-package
(require 'use-package)

(provide 'setup-package)
