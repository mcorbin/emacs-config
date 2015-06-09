
(setq user-full-name "Vincent Demeester"
      user-mail-address "vincent@demeester.fr")

(setq
 ;; General
 ;; TODO use xdg to get these
 desktop-folder (substitute-env-in-file-name "$HOME/desktop")
 videos-folder (expand-file-name "videos" desktop-folder)
 downloads-folder (expand-file-name "downloads" desktop-folder)
 music-folder (expand-file-name "music" desktop-folder)
 pictures-folder (expand-file-name "pictures" desktop-folder)
 ;; Orgmode related
 org-root-directory (substitute-env-in-file-name "$HOME/.emacs.d/org")
 org-todos-directory-name "todos"
 org-notes-directory-name "notes"
 org-sites-directory-name "sites"
 org-archive-directory-name "archive"
 org-archive-file-pattern "%s_archive::"
 org-inbox-file "inbox.org"
 org-main-file "personal.org"
 org-journal-file "journal.org"
 org-stackoverflow-file "stack.org"
 org-web-article-file "ent.org"
 org-publish-folder (substitute-env-in-file-name "$HOME/var/public_html")
 sites-folder (substitute-env-in-file-name "$HOME/src/sites/")
 ;; Github related
 github-general-folder (substitute-env-in-file-name "$HOME/src/github")
 github-username "vdemeester")

(when (file-readable-p "~/.emacs.d/user.el")
  (load "~/.emacs.d/user.el"))

(setq FULLHOSTNAME (format "%s" system-name))
(setq HOSTNAME (substring (system-name) 0 (string-match "\\." (system-name))))

(setq HOSTNAME-FILE
      (expand-file-name
       (format "hosts/%s.el" HOSTNAME)
       "~/.emacs.d"))

(when (file-readable-p HOSTNAME-FILE)
  (load HOSTNAME-FILE))

(setq
 ;; Orgmode related
 org-todos-directory (expand-file-name org-todos-directory-name org-root-directory)
 org-notes-directory (expand-file-name org-notes-directory-name org-root-directory)
 org-sites-directory (expand-file-name org-sites-directory-name org-root-directory)
 org-archive-directory (expand-file-name org-archive-directory-name org-root-directory)
 ;; Github related
 github-personal-folder (expand-file-name github-username github-general-folder))

(add-to-list 'load-path "~/.emacs.d/neotree")
(require 'neotree)
(require 'nyan-mode)
(nyan-mode)
(nyan-start-animation)

(global-set-key [f8] 'neotree-toggle)

     (menu-bar-mode -1)
     (tool-bar-mode -1)
     (scroll-bar-mode -1)
     (blink-cursor-mode -1)
     (setq inhibit-splash-screen t)

(line-number-mode 1)
(column-number-mode 1)
(global-hl-line-mode 1)

(setq font-lock-maximum-decoration 2)

(setq-default indicate-buffer-boundaries 'left)
(setq-default indicate-empty-lines +1)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
 (load-theme 'spolsky t)

(defun my/edit-emacs-configuration ()
  (interactive)
  (find-file "~/.emacs.d/emacs.org"))

(global-set-key "\C-ce" 'my/edit-emacs-configuration)

(setq require-final-newline t)

(fset 'yes-or-no-p 'y-or-n-p)

(defmacro require-maybe (feature &optional file)
  "*Try to require FEATURE, but don't signal an error if `require' fails."
  `(require ,feature ,file 'noerror))

(defmacro when-available (func foo)
  "*Do something if FUNCTION is available."
  `(when (fboundp ,func) ,foo))

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "HISTFILE"))

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

(mouse-avoidance-mode 'jump)

(defconst emacs-tmp-dir (format "%s/%s%s/" temporary-file-directory "emacs" (user-uid)))
(setq backup-directory-alist
      `((".*" . ,emacs-tmp-dir))
      auto-save-file-name-transforms
      `((".*" ,emacs-tmp-dir t))
      auto-save-list-file-prefix emacs-tmp-dir)

(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

(use-package uniquify)
(setq uniquify-buffer-name-style 'forward)

(defun kill-default-buffer ()
  "Kill the currently active buffer"
  (interactive)
  (let (kill-buffer-query-functions) (kill-buffer)))

(global-set-key (kbd "C-x k") 'kill-default-buffer)

(defun my/toggle-comments ()
    "A modified way to toggle comments, 'à-la' ide (intelliJ, Eclipse).
If no region is selected, comment/uncomment the line. If a region is selected, comment/uncomment this region *but* starting from the begining of the first line of the region to the end of the last line of the region"
  (interactive)
  (save-excursion
    (if (region-active-p)
        (progn
          (setq start (save-excursion
                        (goto-char (region-beginning))
                        (beginning-of-line)
                        (point))
                end (save-excursion
                      (goto-char (region-end))
                      (end-of-line)
                      (point)))
          (comment-or-uncomment-region start end))
      (progn
        (comment-or-uncomment-region (line-beginning-position) (line-end-position)))
      )))
(global-set-key (kbd "C-M-/") 'my/toggle-comments)

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(setq-default indent-tabs-mode nil)
(defcustom indent-sensitive-modes
  '(coffee-mode python-mode haml-mode yaml-mode)
  "Modes for which auto-indenting is suppressed."
  :type 'list)

(defun my/untabify-buffer ()
  "Untabify the currently visited buffer."
  (interactive)
  (untabify (point-min) (point-max)))

(defun my/untabify-region-or-buffer ()
  "Untabify a region if selected, otherwise the whole buffer."
  (interactive)
  (unless (member major-mode indent-sensitive-modes)
    (save-excursion
      (if (region-active-p)
          (progn
            (untabify (region-beginning) (region-end))
            (message "Untabify selected region."))
        (progn
          (my/untabify-buffer)
          (message "Untabify buffer.")))
      )))

(defun my/indent-buffer ()
  "Indent the currently visited buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defun my/indent-region-or-buffer ()
  "Indent a region if selected, otherwise the whole buffer."
  (interactive)
  (unless (member major-mode indent-sensitive-modes)
    (save-excursion
      (if (region-active-p)
          (progn
            (indent-region (region-beginning) (region-end))
            (message "Indented selected region."))
        (progn
          (my/indent-buffer)
          (message "Indented buffer.")))
      (whitespace-cleanup))))

(defun my/cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (my/indent-buffer)
  (my/untabify-buffer)
  (delete-trailing-whitespace))

(defun my/cleanup-region (beg end)
  "Remove tmux artifacts from region."
  (interactive "r")
  (dolist (re '("\\\\│\·*\n" "\W*│\·*"))
    (replace-regexp re "" nil beg end)))

(global-set-key (kbd "C-x M-t") 'my/cleanup-region)
(global-set-key (kbd "C-c n") 'my/cleanup-buffer)
(global-set-key (kbd "C-C i") 'my/indent-region-or-buffer)

(add-hook 'text-mode-hook
          (lambda()
            (turn-on-auto-fill)
            (setq show-trailing-whitespace 't))
          )

(defun smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; remap C-a to `smarter-move-beginning-of-line'
(global-set-key [remap move-beginning-of-line]
                'smarter-move-beginning-of-line)

(use-package pretty-mode
             :ensure t
             :init
             (add-hook 'prog-mode-hook
                       'turn-on-pretty-mode))



(use-package async
  :ensure t)
(use-package dired-async
  :init
  (dired-async-mode 1))

(use-package dired-x)
(setq dired-guess-shell-alist-user
         '(("\\.pdf\\'" "evince" "okular")
           ("\\.\\(?:djvu\\|eps\\)\\'" "evince")
           ("\\.\\(?:jpg\\|jpeg\\|png\\|gif\\|xpm\\)\\'" "geeqie")
           ("\\.\\(?:xcf\\)\\'" "gimp")
           ("\\.csv\\'" "libreoffice")
           ("\\.tex\\'" "pdflatex" "latex")
           ("\\.\\(?:mp4\\|mkv\\|avi\\|flv\\|ogv\\)\\(?:\\.part\\)?\\'"
            "mpv")
           ("\\.\\(?:mp3\\|flac\\)\\'" "mpv")
           ("\\.html?\\'" "firefox")
           ("\\.cue?\\'" "audacious")))
(put 'dired-find-alternate-file 'disabled nil)

(setq diredp-hide-details-initially-flag nil)
(use-package dired+
             :ensure t
             :init)

(use-package dired-aux)

(defvar dired-filelist-cmd
  '(("vlc" "-L")))

(defun dired-start-process (cmd &optional file-list)
  (interactive
   (let ((files (dired-get-marked-files
                 t current-prefix-arg)))
     (list
      (dired-read-shell-command "& on %s: "
                                current-prefix-arg files)
      files)))
  (let (list-switch)
    (start-process
     cmd nil shell-file-name
     shell-command-switch
     (format
      "nohup 1>/dev/null 2>/dev/null %s \"%s\""
      (if (and (> (length file-list) 1)
             (setq list-switch
                   (cadr (assoc cmd dired-filelist-cmd))))
          (format "%s %s" cmd list-switch)
        cmd)
      (mapconcat #'expand-file-name file-list "\" \"")))))

(define-key dired-mode-map "c" 'dired-start-process)

(defun dired-get-size ()
  (interactive)
  (let ((files (dired-get-marked-files)))
    (with-temp-buffer
      (apply 'call-process "/usr/bin/du" nil t nil "-schL" files) ;; -L to dereference (git-annex folder)
      (message
       "Size of all marked files: %s"
       (progn
         (re-search-backward "\\(^[ 0-9.,]+[A-Za-z]+\\).*total$")
         (match-string 1))))))
(define-key dired-mode-map (kbd "z") 'dired-get-size)

(define-key dired-mode-map "F" 'find-name-dired)

(define-key dired-mode-map "e" 'wdired-change-to-wdired-mode)

(define-key dired-mode-map (kbd "`") 'dired-open-term)
;; FIXME it seems not to work propertly..
(defun dired-open-term ()
  "Open an `ansi-term' that corresponds to current directory."
  (interactive)
  (let ((current-dir (dired-current-directory)))
    (term-send-string
     (terminal)
     (if (file-remote-p current-dir)
         (let ((v (tramp-dissect-file-name current-dir t)))
           (format "ssh %s@%s\n"
                   (aref v 1) (aref v 2)))
       (format "cd '%s'\n" current-dir)))))

(setq dired-listing-switches "-laGh1v --group-directories-first")

(defun my-isearch-goto-match-beginning ()
  (when (and isearch-forward (not isearch-mode-end-hook-quit)) (goto-char isearch-other-end)))
(add-hook 'isearch-mode-end-hook 'my-isearch-goto-match-beginning)

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package notifications)

(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

(define-prefix-command 'vde/toggle-map)
;; The manual recommends C-c for user keys, but C-x t is
;; always free, whereas C-c t is used by some modes.
(define-key ctl-x-map "t" 'vde/toggle-map)
(define-key vde/toggle-map "d" #'toggle-debug-on-error)
(define-key vde/toggle-map "f" #'auto-fill-mode)
(define-key vde/toggle-map "v" #'visual-line-mode)
(define-key vde/toggle-map "l" #'toggle-truncate-lines)
(define-key vde/toggle-map "q" #'toggle-debug-on-quit)
(define-key vde/toggle-map "r" #'dired-toggle-read-only)
(define-key vde/toggle-map' "w" #'whitespace-mode)

(define-prefix-command 'vde/launcher-map)
(define-key ctl-x-map "l" 'vde/launcher-map)
(global-set-key (kbd "s-l") 'vde/launcher-map)
(define-key vde/launcher-map "c" #'calc)
(define-key vde/launcher-map "d" #'ediff-buffers)
(define-key vde/launcher-map "f" #'find-dired)
(define-key vde/launcher-map "g" #'lgrep)
(define-key vde/launcher-map "G" #'rgrep)
(define-key vde/launcher-map "h" #'man)    ; Help
(define-key vde/launcher-map "s" #'shell)
(define-key vde/launcher-map "r" #'multi-term)
(define-key vde/launcher-map "t" #'proced) ; top
(define-key vde/launcher-map "m" #'mu4e)   ; mails
(define-key vde/launcher-map "u" #'mu4e-update-mail-and-index)

(setq scroll-preserve-screen-position 'always)

(defun joe-scroll-other-window()
  (interactive)
  (scroll-other-window 1))
(defun joe-scroll-other-window-down ()
  (interactive)
  (scroll-other-window-down 1))
;; From https://github.com/abo-abo/ace-window/wiki but adapted to bepo
(use-package ace-window
  :ensure t
  :bind (("C-x C-o" . ace-window)
         ("C-x M-s" . avi-goto-word-1))
  :config
  (set-face-attribute 'aw-leading-char-face nil :foreground "deep sky blue" :weight 'bold :height 3.0)
  (set-face-attribute 'aw-mode-line-face nil :inherit 'mode-line-buffer-id :foreground "lawn green")
  (setq aw-keys   '(?a ?u ?i ?e ?t ?s ?r)
        aw-dispatch-always t
        aw-dispatch-alist
        '((?y aw-delete-window     "Ace - Delete Window")
          (?x aw-swap-window       "Ace - Swap Window")
          (?\' aw-flip-window)
          (?\. aw-split-window-vert "Ace - Split Vert Window")
          (?c aw-split-window-horz "Ace - Split Horz Window")
          (?n delete-other-windows "Ace - Maximize Window")
          (?\, delete-other-windows)
          (?k balance-windows)
          (?v winner-undo)
          (?o winner-redo)))

  (when (package-installed-p 'hydra)
    (defhydra hydra-window-size (:color red)
      "Windows size"
      ("c" shrink-window-horizontally "shrink horizontal")
      ("t" shrink-window "shrink vertical")
      ("s" enlarge-window "enlarge vertical")
      ("r" enlarge-window-horizontally "enlarge horizontal"))
    (defhydra hydra-window-frame (:color red)
      "Frame"
      ("e" make-frame "new frame")
      ("y" delete-frame "delete frame"))
    (defhydra hydra-window-scroll (:color red)
      "Scroll other window"
      ("'" joe-scroll-other-window "scroll")
      ("j" joe-scroll-other-window-down "scroll down"))
    (add-to-list 'aw-dispatch-alist '(?w hydra-window-size/body) t)
    (add-to-list 'aw-dispatch-alist '(?l hydra-window-scroll/body) t)
    (add-to-list 'aw-dispatch-alist '(?g hydra-window-frame/body) t))
  (ace-window-display-mode t)
  (winner-mode 1))

(global-set-key (kbd "S-C-<right>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<left>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'enlarge-window)
(global-set-key (kbd "S-C-<up>") 'shrink-window)

;; install fullframe for list-packages
(use-package fullframe
  :init
  (progn
    (fullframe list-packages quit-window))
  :ensure t)

(use-package popwin
  :ensure t
  :config
  (progn
    (add-to-list 'popwin:special-display-config `("*Swoop*" :height 0.5 :position bottom))
    (add-to-list 'popwin:special-display-config `("*Warnings*" :height 0.5 :noselect t))
    (add-to-list 'popwin:special-display-config `("*Procces List*" :height 0.5))
    (add-to-list 'popwin:special-display-config `("*Messages*" :height 0.5 :noselect t))
    (add-to-list 'popwin:special-display-config `("*Backtrace*" :height 0.5))
    (add-to-list 'popwin:special-display-config `("*Compile-Log*" :height 0.5 :noselect t))
    (add-to-list 'popwin:special-display-config `("*Remember*" :height 0.5))
    (add-to-list 'popwin:special-display-config `("*All*" :height 0.5))
    (add-to-list 'popwin:special-display-config `(flycheck-error-list-mode :height 0.5 :regexp t :position bottom))
    (popwin-mode 1)
    (global-set-key (kbd "C-z") popwin:keymap)))

(use-package ace-jump-mode
  :ensure t
  :commands ace-jump-mode
  :bind ("<f7>" . ace-jump-mode))

(use-package highlight-indentation
  :ensure t
  :commands (highlight-indentation-mode highlight-indentation-current-column-mode)
  :init
  (progn
    ;; Add a key to toggle-map
    (define-key vde/toggle-map "C" #'highlight-indentation-mode)
    (define-key vde/toggle-map "c" #'highlight-indentation-current-column-mode))
  :config
  (progn
    (set-face-background 'highlight-indentation-face "#e3e3d3")
    (set-face-background 'highlight-indentation-current-column-face "#c3b3b3")))

;;; Load undo-tree before evil for the :bind
(use-package undo-tree
  :ensure t
  :bind (("C-*" . undo-tree-undo)))
(use-package evil
  :ensure t
  :init
  (progn
    (define-key vde/toggle-map "e" #'evil-mode)))

(setq evil-emacs-state-cursor '("red" box))
(setq evil-normal-state-cursor '("green" box))
(setq evil-visual-state-cursor '("orange" box))
(setq evil-insert-state-cursor '("red" bar))
(setq evil-replace-state-cursor '("red" bar))
(setq evil-operator-state-cursor '("red" hollow))

(setq evil-search-module 'evil-search)

(use-package evil-leader
  :ensure t
  :requires evil
  :init
  (global-evil-leader-mode t))

(evil-leader/set-leader ",")
(evil-leader/set-key
  "e" 'find-file
  "b" 'switch-to-buffer
  "k" 'kill-buffer)

(use-package evil-args
  :ensure t
  :requires evil
  :config
  (progn
    ;; bind evil-args text objects
    (define-key evil-inner-text-objects-map "a" 'evil-inner-arg)
    (define-key evil-outer-text-objects-map "a" 'evil-outer-arg)
    ;; bind evil-forward/backward-args
    (define-key evil-normal-state-map "L" 'evil-forward-arg)
    (define-key evil-normal-state-map "H" 'evil-backward-arg)
    (define-key evil-motion-state-map "L" 'evil-forward-arg)
    (define-key evil-motion-state-map "H" 'evil-backward-arg)
    ;; bind evil-jump-out-args
    (define-key evil-normal-state-map "K" 'evil-jump-out-args)
    ))

(defadvice server-ensure-safe-dir (around
                                   my-around-server-ensure-safe-dir
                                   activate)
  "Ignores any errors raised from server-ensure-safe-dir"
  (ignore-errors ad-do-it))
(unless (string= (user-login-name) "root")
  (require 'server)
  (when (or (not server-process)
           (not (eq (process-status server-process)
                  'listen)))
    (unless (server-running-p server-name)
      (server-start))))

(use-package discover-my-major
  :ensure t
  :bind ("C-h C-m" . discover-my-major))

(use-package manage-minor-mode
  :ensure t
  :bind ("C-c x n" . manage-minor-mode))

(use-package helm
  :ensure t
  :config
  (progn
    (require 'helm-config)
    (setq helm-idle-delay 0.01
          helm-input-idle-delay 0.01
          helm-buffer-max-length 40
          helm-M-x-always-save-history t
          helm-move-to-line-cycle-in-source t
          helm-ff-file-name-history-use-recentf t
          ;; Enable fuzzy matching
          helm-M-x-fuzzy-match t
          helm-buffers-fuzzy-matching t
          helm-recentf-fuzzy-match t)
    (add-to-list 'helm-sources-using-default-as-input 'helm-source-man-pages)
    ;; Rebind actions
    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
    (define-key helm-map (kbd "C-z") 'helm-select-action)
    (helm-autoresize-mode t)
    (helm-mode 1))
  :bind (("C-c h" . helm-command-prefix)
         ("C-x C-f" . helm-find-files)
         ("M-x" . helm-M-x)
         ("C-c b" . helm-mini)
         ("C-x C-b" . helm-buffers-list)
         ("M-y" . helm-show-kill-ring)
         ("C-x c o" . helm-occur)))
;; (add-to-list 'helm-completing-read-handlers-alist '(org-refile)) ; helm-mode does not do org-refile well
;; (add-to-list 'helm-completing-read-handlers-alist '(org-agenda-refile)) ; same goes for org-agenda-refile

(use-package helm-descbinds
  :ensure t
  :defer t
  :bind ("C-h b" . helm-descbinds))

(use-package helm-gtags
  :ensure t)
;; (helm-gtags-mode 1)

(use-package helm-make
  :ensure t)

(use-package helm-swoop
  :ensure t
  :defer t
  :bind (("C-S-s" . helm-swoop)
         ("M-I" . helm-swoop-back-to-last-point))
  :config
  (progn
    (define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
    (define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)))

(use-package helm-google
  :ensure t)

(use-package hydra
  :ensure t
  :config
  (hydra-add-font-lock)
  ;; Zooming
  (defhydra hydra-zoom (global-map "<f2>")
    "zoom"
    ("g" text-scale-increase "in")
    ("l" text-scale-decrease "out"))
  ;; Toggling modes
  (global-set-key
   (kbd "C-c C-v")
   (defhydra hydra-toggle-simple (:color blue)
     "toggle"
     ("a" abbrev-mode "abbrev")
     ("d" toggle-debug-on-error "debug")
     ("f" auto-fill-mode "fill")
     ("t" toggle-truncate-lines "truncate")
     ("w" whitespace-mode "whitespace")
     ("q" nil "cancel")))
  ;; Buffer menu
  (defhydra hydra-buffer-menu (:color pink
                                      :hint nil)
    "
^Mark^ ^Unmark^ ^Actions^ ^Search
^^^^^^^^----------------------------------------------------------------- (__)
_m_: mark _u_: unmark _x_: execute _R_: re-isearch (oo)
_s_: save _U_: unmark up _b_: bury _I_: isearch /------\\/
_d_: delete ^ ^ _g_: refresh _O_: multi-occur / | ||
_D_: delete up ^ ^ _T_: files only: % -28`Buffer-menu-files-only^^ * /\\---/\\
_~_: modified ^ ^ ^ ^ ^^ ~~ ~~
"
    ("m" Buffer-menu-mark)
    ("u" Buffer-menu-unmark)
    ("U" Buffer-menu-backup-unmark)
    ("d" Buffer-menu-delete)
    ("D" Buffer-menu-delete-backwards)
    ("s" Buffer-menu-save)
    ("~" Buffer-menu-not-modified)
    ("x" Buffer-menu-execute)
    ("b" Buffer-menu-bury)
    ("g" revert-buffer)
    ("T" Buffer-menu-toggle-files-only)
    ("O" Buffer-menu-multi-occur :color blue)
    ("I" Buffer-menu-isearch-buffers :color blue)
    ("R" Buffer-menu-isearch-buffers-regexp :color blue)
    ("c" nil "cancel")
    ("v" Buffer-menu-select "select" :color blue)
    ("o" Buffer-menu-other-window "other-window" :color blue)
    ("q" quit-window "quit" :color blue))
  (define-key Buffer-menu-mode-map "." 'hydra-buffer-menu/body)
  ;; apropos
  (defhydra hydra-apropos (:color blue
                                  :hint nil)
    "
_a_propos _c_ommand
_d_ocumentation _l_ibrary
_v_ariable _u_ser-option
^ ^ valu_e_"
    ("a" apropos)
    ("d" apropos-documentation)
    ("v" apropos-variable)
    ("c" apropos-command)
    ("l" apropos-library)
    ("u" apropos-user-option)
    ("e" apropos-value))
  (global-set-key (kbd "C-c h") 'hydra-apropos/body)
  ;; Window managing
  (global-set-key
   (kbd "C-M-o")
   (defhydra hydra-window (:color amaranth)
     "
Move Point^^^^   Move Splitter   ^Ace^                       ^Split^
--------------------------------------------------------------------------------
_w_, _<up>_      Shift + Move    _C-a_: ace-window           _2_: split-window-below
_a_, _<left>_                    _C-s_: ace-window-swap      _3_: split-window-right
_s_, _<down>_                    _C-d_: ace-window-delete    ^ ^
_d_, _<right>_                   ^   ^                       ^ ^
You can use arrow-keys or WASD.
"
     ("2" split-window-below nil)
     ("3" split-window-right nil)
     ("a" windmove-left nil)
     ("s" windmove-down nil)
     ("w" windmove-up nil)
     ("d" windmove-right nil)
     ("A" hydra-move-splitter-left nil)
     ("S" hydra-move-splitter-down nil)
     ("W" hydra-move-splitter-up nil)
     ("D" hydra-move-splitter-right nil)
     ("<left>" windmove-left nil)
     ("<down>" windmove-down nil)
     ("<up>" windmove-up nil)
     ("<right>" windmove-right nil)
     ("<S-left>" hydra-move-splitter-left nil)
     ("<S-down>" hydra-move-splitter-down nil)
     ("<S-up>" hydra-move-splitter-up nil)
     ("<S-right>" hydra-move-splitter-right nil)
     ("C-a" ace-window nil)
     ("u" hydra--universal-argument nil)
     ("C-s" (lambda () (interactive) (ace-window 4)) nil)
     ("C-d" (lambda () (interactive) (ace-window 16)) nil)
     ("q" nil "quit")))
  )

;; regular auto-complete initialization
   (require 'auto-complete-config)
   (ac-config-default)
   (require 'company)

(use-package deft
  :ensure t
  :config
  (progn
    (setq deft-extension "org"
          deft-text-mode 'org-mode
          deft-directory org-notes-directory
          deft-use-filename-as-title t))
  :bind ("<f9>" . deft))

(use-package git-commit-mode
  :ensure t)
(use-package git-rebase-mode
  :ensure t)
(use-package gitignore-mode
  :ensure t)
(use-package gitconfig-mode
  :ensure t)
(use-package gitattributes-mode
  :ensure t)

(use-package magit
  :ensure t
  :bind ("C-c g" . magit-status))
(setq magit-last-seen-setup-instructions "1.4.0")

(use-package magit-svn
  :ensure t)

(use-package git-annex
  :ensure t)
(use-package magit-annex
  :ensure t)

(use-package git-timemachine
  :ensure t)

(use-package git-blame
  :ensure t)

(use-package highlight-symbol
  :ensure t
  :config
  (progn
    (setq highlight-symbol-on-navigation-p t)
    (add-hook 'prog-mode-hook 'highlight-symbol-mode))
  :bind (("C-<f3>" . highlight-symbol-at-point)
         ("<f3>" . highlight-symbol-next)
         ("S-<f3>" . highlight-symbol-prev)
         ("M-<f3>" . highlight-symbol-query-replace)))

(use-package move-text
  :ensure t
  :config (move-text-default-bindings))

(add-hook 'diff-mode-hook (lambda ()
                            (setq-local whitespace-style
                                        '(face
                                          tabs
                                          tab-mark
                                          spaces
                                          space-mark
                                          trailing
                                          indentation::space
                                          indentation::tab
                                          newline
                                          newline-mark))
                            (whitespace-mode 1)))

(use-package multi-term
  :ensure t
  :bind (("M-[" . multi-term-prev)
         ("M-]" . multi-term-next)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package flyspell
  :ensure t
  :init
  (progn
    (use-package flyspell-lazy
      :ensure t))
  :config
  (progn
    (define-key vde/toggle-map "i" #'ispell-change-dictionary)
    (define-key vde/launcher-map "i" #'flyspell-buffer)
    (setq ispell-program-name "aspell")
    (setq ispell-local-dictionary "en_US")
    (setq ispell-local-dictionary-alist
          '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil nil nil utf-8)
            ("fr_FR" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil nil nil utf-8)))
    (add-hook 'text-mode-hook 'flyspell-mode)
    (add-hook 'prog-mode-hook 'flyspell-prog-mode)))

(use-package flycheck
  :ensure t
  :config
  (progn
    (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))
    (setq flycheck-indication-mode 'right-fringe)
    (add-hook 'after-init-hook #'global-flycheck-mode)))

(require 'find-lisp)
(setq org-directory org-root-directory)
(setq org-agenda-files (find-lisp-find-files org-todos-directory "\.org$"))

(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode))

(defface org-progress ; font-lock-warning-face
  (org-compatible-face nil
    '((((class color) (min-colors 16) (background light)) (:foreground "#A197BF" :bold t :background "#E8E6EF" :box (:line-width 1 :color "#A197BF")))
      (((class color) (min-colors 8)  (background light)) (:foreground "blue"  :bold t))
      (t (:inverse-video t :bold t))))
  "Face for PROGRESS keywords."
  :group 'org-faces)
(defface org-cancelled ; font-lock-warning-face
  (org-compatible-face nil
    '((((class color) (min-colors 16) (background light)) (:foreground "#3D3D3D" :bold t :background "#7A7A7A" :box (:line-width 1 :color "#3D3D3D")))
      (((class color) (min-colors 8)  (background light)) (:foreground "black"  :bold t))
      (t (:inverse-video t :bold t))))
  "Face for PROGRESS keywords."
  :group 'org-faces)
(defface org-review ; font-lock-warning-face
  (org-compatible-face nil
    '((((class color) (min-colors 16) (background light)) (:foreground "#FC9B17" :bold t :background "#FEF2C2" :box (:line-width 1 :color "#FC9B17")))
      (((class color) (min-colors 8)  (background light)) (:foreground "yellow"  :bold t))
      (t (:inverse-video t :bold t))))
  "Face for PROGRESS keywords."
  :group 'org-faces)
(defface org-blocked ; font-lock-warning-face
  (org-compatible-face nil
    '((((class color) (min-colors 16) (background light)) (:foreground "#FF8A80" :bold t :background "#ffdad6" :box (:line-width 1 :color "#FF8A80")))
      (((class color) (min-colors 8)  (background light)) (:foreground "red"  :bold t))
      (t (:inverse-video t :bold t))))
  "Face for PROGRESS keywords."
  :group 'org-faces)

(setq org-todo-keywords
      (quote ((sequence "TODO(t!)" "PROGRESS(p!)" "BLOCKED" "REVIEW" "|" "DONE(d!)" "ARCHIVED")
              (sequence "REPORT(r!)" "BUG" "KNOWNCAUSE" "|" "FIXED(f!)")
              (sequence "|" "CANCELLED(c@)"))))


(setq org-todo-keyword-faces
      (quote (("TODO" . org-todo)
              ("PROGRESS" . org-progress)
              ("BLOCKED" . org-blocked)
              ("REVIEW" . org-review)
              ("DONE" . org-done)
              ("ARCHIVED" . org-done)
              ("CANCELLED" . org-cancelled)
              ("REPORT" . org-todo)
              ("BUG" . org-blocked)
              ("KNOWNCAUSE" . org-review)
              ("FIXED" . org-done))))

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t)))))

(defun turn-on-auto-visual-line (expression)
  (cond ((string-match expression buffer-file-name)
         (progn
           (auto-fill-mode -1)
           (visual-line-mode 1))
         )))

(add-hook 'org-mode-hook
          '(lambda ()
             (org-defkey org-mode-map "\C-c[" 'undefined)
             (org-defkey org-mode-map "\C-c]" 'undefined)
             (org-defkey org-mode-map "\C-c;" 'undefined)
             (turn-on-auto-visual-line (concat org-notes-directory "/*")))
          'append)

(run-at-time "00:59" 3600 'org-save-all-org-buffers)

(setq
 org-completion-use-ido t         ;; use IDO for completion
 org-cycle-separator-lines 0      ;; Don't show blank lines
 org-catch-invisible-edits 'error ;; don't edit invisible text
 org-refile-targets '((org-agenda-files . (:maxlevel . 6)))
 )

(define-prefix-command 'vde/org-map)
(global-set-key (kbd "C-c o") 'vde/org-map)
(define-key vde/org-map "p" (lambda () (interactive) (find-file (expand-file-name org-main-file org-todos-directory))))
(define-key vde/org-map "n" (lambda () (interactive) (find-file org-notes-directory)))

(setq org-use-speed-commands t)

(defun my/org-show-next-heading-tidily ()
  "Show next entry, keeping other entries closed."
  (if (save-excursion (end-of-line) (outline-invisible-p))
      (progn (org-show-entry) (show-children))
    (outline-next-heading)
    (unless (and (bolp) (org-on-heading-p))
      (org-up-heading-safe)
      (hide-subtree)
      (error "Boundary reached"))
    (org-overview)
    (org-reveal t)
    (org-show-entry)
    (show-children)))

(defun my/org-show-previous-heading-tidily ()
  "Show previous entry, keeping other entries closed."
  (let ((pos (point)))
    (outline-previous-heading)
    (unless (and (< (point) pos) (bolp) (org-on-heading-p))
      (goto-char pos)
      (hide-subtree)
      (error "Boundary reached"))
    (org-overview)
    (org-reveal t)
    (org-show-entry)
    (show-children)))

(setq org-speed-commands-user '(("n" . my/org-show-next-heading-tidily)
                                ("p" . my/org-show-previous-heading-tidily)
                                (":" . org-set-tags-command)
                                ("c" . org-toggle-checkbox)
                                ("d" . org-cut-special)
                                ("P" . org-set-property)
                                ("C" . org-clock-display)
                                ("z" . (lambda () (interactive)
                                         (org-tree-to-indirect-buffer)
                                         (other-window 1)
                                         (delete-other-windows)))))

(define-key vde/org-map "r" 'org-capture)

(setq org-capture-templates
      '(;; other entries
        ("t" "Inbox list item" entry
         (file+headline (expand-file-name org-main-file org-todos-directory) "Inbox")
         "* %?\n %i\n %a")
        ("j" "Journal entry" plain
         (file+datetree+prompt (exand-file-name org-journal-file org-root-directory))
         "%K - %a\n%i\n%?\n")
        ;; other entries
        ))

(setq org-src-fontify-natively t)

(defun my/org-insert-src-block (src-code-type)
  "Insert a `SRC-CODE-TYPE' type source code block in org-mode."
  (interactive
   (let ((src-code-types
          '("emacs-lisp" "python" "C" "sh" "java" "js" "clojure" "C++" "css"
            "calc" "dot" "gnuplot" "ledger" "R" "sass" "screen" "sql" "awk" 
            "ditaa" "haskell" "latex" "lisp" "matlab" "org" "perl" "ruby"
            "sqlite" "rust" "scala" "golang")))
     (list (ido-completing-read "Source code type: " src-code-types))))
  (progn
    (newline-and-indent)
    (insert (format "#+BEGIN_SRC %s\n" src-code-type))
    (newline-and-indent)
    (insert "#+END_SRC\n")
    (previous-line 2)
    (org-edit-src-code)))

(add-hook 'org-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-c s e") 'org-edit-src-code)
             (local-set-key (kbd "C-c s i") 'my/org-insert-src-block))
          'append)

(require 'org-archive)
(setq org-archive-location (concat org-archive-directory "%s_archive::"))

(setq org-tags-column -90)

(setq org-tag-alist '(
                     ("important" . ?i)
                     ("urgent" . ?u)
                     ("ongoing" . ?o)   ;; ongoing "project", use to filter big project that are on the go
                     ("next" . ?n)      ;; next "project"/"task", use to filter next things to do
                     ("@home" . ?h)     ;; needs to be done at home
                     ("@work" . ?w)     ;; needs to be done at work
                     ("@client" . ?c)   ;; needs to be done at a client place (consulting..)
                     ("dev" . ?e)       ;; this is a development task
                     ("infra" . ?a)     ;; this is a sysadmin/infra task
                     ("document" . ?d)  ;; needs to produce a document (article, post, ..)
                     ("download" . ?D)  ;; needs to download something
                     ("media" . ?m)     ;; this is a media (something to watch, listen, record, ..)
                     ("mail" . ?M)      ;; mail-related (to write & send or to read)
                     ("triage" . ?t)    ;; need "triage", tag it to easily find them
                     ("task" . ?a)      ;; a simple task (no project), the name is kinda misleading
                     ))

(global-set-key (kbd "C-c a") 'org-agenda)

(setq org-agenda-custom-commands
      '(("t" todo "TODO"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("p" todo "PROGRESS"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("r" todo "REVIEW"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("b" todo "BLOCKED"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("o" "Ongoing projects" tags-todo "ongoing"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-tags-exclude-from-inheritance '("ongoing"))
          (org-agenda-prefix-format "  Mixed: ")))
        ("n" "Next tasks" tags-todo "next"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-tags-exclude-from-inheritance '("next"))
          (org-agenda-prefix-format "  Mixed: ")))
        ;; Timelines
        ("d" "Timeline for today" ((agenda "" ))
         ((org-agenda-ndays 1)
          (org-agenda-show-log t)
          (org-agenda-log-mode-items '(clock closed))
          (org-agenda-clockreport-mode t)
          (org-agenda-entry-types '())))
        ("w" "Weekly review" agenda ""
         ((org-agenda-span 7)
          (org-agenda-log-mode 1)))
        ("W" "Weekly review sans DAILY" agenda ""
         ((org-agenda-span 7)
          (org-agenda-log-mode 1)
          (org-agenda-tag-filter-preset '("-DAILY"))))
        ("2" "Bi-weekly review" agenda "" ((org-agenda-span 14) (org-agenda-log-mode 1)))
        ;; Panic tasks : urgent & important
        ;; Probably the most important to do, but try not have to much of them..
        ("P" . "Panic -emergency-")
        ("Pt" "TODOs" tags-todo "important&urgent/!TODO"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("Pb" "BLOCKEDs" tags-todo "important&urgent/!BLOCKED"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("Pr" "REVIEWs" tags-todo "important&urgent/!REVIEW"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ;; Kaizen tasks : important but not urgent
        ("K" . "Kaizen -improvement-")
        ("Kt" "TODOs" tags-todo "important&-urgent/!TODO"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("Kb" "BLOCKEDs" tags-todo "important&-urgent/!BLOCKED"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("Kr" "REVIEWs" tags-todo "important&-urgent/!REVIEW"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ;; Social investment : urgent
        ("S" . "Social -investment-")
        ("St" "TODOs" tags-todo "-important&urgent/!TODO"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("Sb" "BLOCKEDs" tags-todo "-important&urgent/!BLOCKED"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("Sr" "REVIEWs" tags-todo "-important&urgent/!REVIEW"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ;; Organics
        ("O" . "Organics -inspiration-")
        ("Ot" "TODOs" tags-todo "-important&-urgent/!TODO"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("Ob" "BLOCKEDs" tags-todo "-important&-urgent/!BLOCKED"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("Or" "REVIEWs" tags-todo "-important&-urgent/!REVIEW"
         ((org-agenda-sorting-strategy '(priority-down))
          (org-agenda-prefix-format "  Mixed: ")))
        ("N" search ""
         ((org-agenda-files '("~org/notes.org"))
          (org-agenda-text-search-extra-files nil)))))

(use-package org-pomodoro
  :ensure t)

(use-package htmlize
  :ensure t
  :defer t)
;;      (setq org-html-head "<link rel=\"stylesheet\" type=\"text/css\" hrefl=\"css/stylesheet.css\" />")
(setq org-html-include-timestamps nil)
;; (setq org-html-htmlize-output-type 'css)
(setq org-html-head-include-default-style nil)

(use-package ox-publish)
;; (use-package ox-rss)

;; Define some variables to write less :D
(setq sbr-base-directory (expand-file-name "sbr" org-sites-directory)
      sbr-publishing-directory (expand-file-name "sbr" org-publish-folder)
      znk-base-directory (expand-file-name "zenika" org-sites-directory)
      znk-publishing-directory (expand-file-name "zenika" org-publish-folder)
      vdf-base-directory (expand-file-name "vdf" org-sites-directory)
      vdf-site-directory (expand-file-name "blog" sites-folder)
      vdf-publishing-directory (expand-file-name "posts" (expand-file-name "content" vdf-site-directory))
      vdf-static-directory (expand-file-name "static" vdf-site-directory)
      vdf-css-publishing-directory (expand-file-name "css" vdf-static-directory)
      vdf-assets-publishing-directory vdf-static-directory)

;; Project
(setq org-publish-project-alist
      `(("sbr-notes"
         :base-directory ,sbr-base-directory
         :base-extension "org"
         :publishing-directory ,sbr-publishing-directory
         :makeindex t
         :exclude "FIXME"
         :recursive t
         :htmlized-source t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"style/style.css\" />"
         :html-preamble "<div id=\"nav\">
<ul>
<li><a href=\"/\" class=\"home\">Home</a></li>
</ul>
</div>"
         :html-postamble "<div id=\"footer\">
%a %C %c
</div>")
        ("sbr-static"
         :base-directory ,sbr-base-directory
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg"
         :publishing-directory ,sbr-publishing-directory
         :recursive t
         :publishing-function org-publish-attachment
         )
        ("sbr" :components ("sbr-notes" "sbr-static"))
        ("vdf-notes"
         :base-directory ,vdf-base-directory
         :base-extension "org"
         :publishing-directory ,vdf-publishing-directory
         :exclude "FIXME"
         :section-numbers nil
         :with-toc nil
         :with-drawers t
         :htmlized-source t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :body-only t)
        ("vdf-static-css"
         :base-directory ,vdf-base-directory
         :base-extension "css"
         :publishing-directory ,vdf-css-publishing-directory
         :recursive t
         :publishing-function org-publish-attachment
         )
        ("vdf-static-assets"
         :base-directory ,vdf-base-directory
         :base-extension "png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg"
         :publishing-directory ,vdf-assets-publishing-directory
         :recursive t
         :publishing-function org-publish-attachment
         )
        ("vdf" :components ("vdf-notes" "vdf-static-css" "vdf-static-assets"))
        ("znk-notes"
         :base-directory ,znk-base-directory
         :base-extension "org"
         :publishing-directory ,znk-publishing-directory
         :makeindex t
         :exclude "FIXME"
         :recursive t
         :htmlized-source t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t
         :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"style/style.css\" />"
         :html-preamble "<div id=\"nav\">
<ul>
<li><a href=\"/\" class=\"home\">Home</a></li>
</ul>
</div>"
         :html-postamble "<div id=\"footer\">
%a %C %c
</div>")
        ("znk-static"
         :base-directory ,znk-base-directory
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg"
         :publishing-directory ,znk-publishing-directory
         :recursive t
         :publishing-function org-publish-attachment
         )
        ("znk" :components ("znk-notes" "znk-static"))
        ))

(use-package org-capture)
(use-package org-protocol)
(setq org-protocol-default-template-key "l")
(push '("l" "Link" entry (function org-handle-link)
        "* TODO %(org-wash-link)\nAdded: %U\n%(org-link-hooks)\n%?")
      org-capture-templates)

(defun org-wash-link ()
  (let ((link (caar org-stored-links))
        (title (cadar org-stored-links)))
    (setq title (replace-regexp-in-string
                 " - Stack Overflow" "" title))
    (org-make-link-string link title)))

(defvar org-link-hook nil)

(defun org-link-hooks ()
  (prog1
      (mapconcat #'funcall
                 org-link-hook
                 "\n")
    (setq org-link-hook)))

(defun org-handle-link ()
  (let ((link (caar org-stored-links))
        file)
    (cond ((string-match "^https://www.youtube.com/" link)
           (org-handle-link-youtube link))
          ((string-match (regexp-quote
                          "http://stackoverflow.com/") link)
           (find-file ((expand-file-name org-stackoverflow-file org-notes-directory)))
           (goto-char (point-min))
           (re-search-forward "^\\*+ +Questions" nil t))
          (t
           (find-file ((expand-file-name org-web-article-file org-notes-directory)))
           (goto-char (point-min))
           (re-search-forward "^\\*+ +Articles" nil t)))))

(defun org-handle-link-youtube (link)
  (lexical-let*
      ((file-name (org-trim
                   (shell-command-to-string
                    (concat
                     "youtube-dl \""
                     link
                     "\""
                     " -o \"%(title)s.%(ext)s\" --get-filename"))))
       (dir videos-folder)
       (full-name
        (expand-file-name file-name dir)))
    (add-hook 'org-link-hook
              (lambda ()
                (concat
                 (org-make-link-string dir dir)
                 "\n"
                 (org-make-link-string full-name file-name))))
    (async-shell-command
     (format "youtube-dl \"%s\" -o \"%s\"" link full-name))
    (find-file (org-expand "ent.org"))
    (goto-char (point-min))
    (re-search-forward "^\\*+ +videos" nil t)))

(use-package projectile
  :ensure t
  :config
  (progn
    (setq projectile-completion-system 'default)
    (setq projectile-enable-caching t)
    (projectile-global-mode)))

(use-package helm-projectile
  :ensure t
  :config (helm-projectile-on))

(use-package perspective
  :ensure t)
(use-package persp-projectile
  :ensure t
  :requires perspective
  :config
  (progn
    (define-key projectile-mode-map (kbd "s-s") 'projectile-persp-switch-project)
    (persp-mode)))

(use-package compile
  :commands compile
  :bind ("<f5>" . compile)
  :config
  (progn
    (setq compilation-ask-about-save nil
          compilation-always-kill t
          compilation-scroll-output 'first-error)
    ))

(require 'ansi-color)
(defun my/colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'my/colorize-compilation-buffer)

(setq compilation-scroll-output t)

;; The folder is by default $HOME/.emacs.d/provided
(setq user-emacs-provided-directory (concat user-emacs-directory "provided/"))
;; Regexp to find org files in the folder
(setq provided-configuration-file-regexp "\\`[^.].*\\.org\\'")
;; Define the function
(defun load-provided-configuration (dir)
  "Load org file from =use-emacs-provided-directory= as configuration with org-babel"
  (unless (file-directory-p dir) (error "Not a directory '%s'" dir))
  (dolist (file (directory-files dir nil provided-configuration-file-regexp nil) nil)
    (unless (member file '("." ".."))
      (let ((file (concat dir file)))
        (unless (file-directory-p file)
          (message "loading file %s" file)
          (org-babel-load-file file)
          )
        ))
    )
  )
;; Load it
(load-provided-configuration user-emacs-provided-directory)

(use-package lua-mode
  :ensure t)

(use-package paredit
  :ensure t)
(use-package rainbow-delimiters
  :ensure t)
(use-package highlight-parentheses
  :ensure t)

(defun my/lisps-mode-hook ()
  (paredit-mode t)
  (rainbow-delimiters-mode t)
  (highlight-parentheses-mode t)
  )

(defalias 'eb 'eval-buffer)
(defalias 'er 'eval-region)
(defalias 'ed 'eval-defun)

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (my/lisps-mode-hook)
            (eldoc-mode 1))
          )

(use-package clojure-mode
  :ensure t
  :config
  (progn
    (add-hook 'clojure-mode-hook 'my/lisps-mode-hook)))

(use-package cider
  :ensure t)

(add-hook 'sql-interactive-mode-hook
          (lambda ()
            (toggle-truncate-lines t)))

(use-package pkgbuild-mode
  :ensure t)

(use-package markdown-mode
  :ensure t)
(use-package markdown-mode+
  :ensure t)

(use-package yaml-mode
  :ensure t)

(use-package toml-mode
  :ensure t)

(use-package dockerfile-mode
  :ensure t)

(use-package ansible
  :ensure t
  :config
  (progn
    (add-hook 'yaml-mode-hook '(lambda () (ansible 1)))))

(defconst lunaryorn-ansible-doc-buffer " *Ansible Doc*"
  "The Ansible Doc buffer.")

(defvar lunaryorn-ansible-modules nil
  "List of all known Ansible modules.")

(defun lunaryorn-ansible-modules ()
  "Get a list of all known Ansible modules."
  (unless lunaryorn-ansible-modules
    (let ((lines (ignore-errors (process-lines "ansible-doc" "--list")))
          modules)
      (dolist (line lines)
        (push (car (split-string line (rx (one-or-more space)))) modules))
      (setq lunaryorn-ansible-modules (sort modules #'string<))))
  lunaryorn-ansible-modules)

(defun lunaryorn-ansible-doc (module)
  "Show ansible doc for MODULE."
  (interactive
   (list (ido-completing-read "Ansible Module: "
                              (lunaryorn-ansible-modules)
                              nil nil nil nil nil
                              (thing-at-point 'symbol 'no-properties))))
  (let ((buffer (get-buffer-create lunaryorn-ansible-doc-buffer)))
    (with-current-buffer buffer
      (setq buffer-read-only t)
      (view-mode)
      (let ((inhibit-read-only t))
        (erase-buffer)
        (call-process "ansible-doc" nil t t module))
      (goto-char (point-min)))
    (display-buffer buffer)))

(eval-after-load 'yaml-mode
  '(define-key yaml-mode-map (kbd "C-c h a") 'lunaryorn-ansible-doc))

(use-package yasnippet
  :ensure t
  :config
  (progn
    (setq yas-verbosity 1
          yas-snippet-dir (expand-file-name "snippets" user-emacs-directory))
    (define-key yas-minor-mode-map (kbd "<tab>") nil)
    (define-key yas-minor-mode-map (kbd "TAB") nil)
    (define-key yas-minor-mode-map (kbd "<C-tab>") 'yas-expand)
    (yas-global-mode 1)))
(use-package helm-c-yasnippet
  :ensure t
  :bind ("C-c y" . helm-yas-complete))

;; FIXME handle this with provided configuration
(defvar mode-line-cleaner-alist
  `((auto-complete-mode         . " α")
    (yas-minor-mode             . " γ")
    (paredit-mode               . " Φ")
    (eldoc-mode                 . "")
    (abbrev-mode                . "")
    (undo-tree-mode             . " τ")
    (volatile-highlights-mode   . " υ")
    (elisp-slime-nav-mode       . " δ")
    (nrepl-mode                 . " ηζ")
    (nrepl-interaction-mode     . " ηζ")
    (cider-mode                 . " ηζ")
    (cider-interaction          . " ηζ")
    (highlight-parentheses-mode . "")
    (highlight-symbol-mode      . "")
    (projectile-mode            . "")
    (helm-mode                  . "")
    (ace-window-mode            . "")
    (magit-auto-revert-mode     . "")
    (sh-mode                    . "sh")
    (org-mode                   . "ꙮ")
    (go-mode                    . "🐹")
    ;; Major modes
    (term-mode                  . "⌨")
    (clojure-mode               . " Ɩ")
    (hi-lock-mode               . "")
    (visual-line-mode           . " ω")
    (auto-fill-function         . " ψ")
    (python-mode                . " Py")
    (emacs-lisp-mode            . " EL")
    (markdown-mode              . " md")
    (magit                      . " ma")
    (haskell-mode               . " λ")
    (flyspell-mode              . " fs")
    (flymake-mode               . " fm")
    (flycheck-mode              . " fc"))
  "Alist for `clean-mode-line'.

When you add a new element to the alist, keep in mind that you
must pass the correct minor/major mode symbol and a string you
want to use in the modeline *in lieu of* the original.")

(defun clean-mode-line ()
  (interactive)
  (loop for cleaner in mode-line-cleaner-alist
        do (let* ((mode (car cleaner))
                  (mode-str (cdr cleaner))
                  (old-mode-str (cdr (assq mode minor-mode-alist))))
             (when old-mode-str
               (setcar old-mode-str mode-str))
             ;; major mode
             (when (eq mode major-mode)
               (setq mode-name mode-str)))))


(add-hook 'after-change-major-mode-hook 'clean-mode-line)


;;; Greek letters - C-u C-\ greek ;; C-\ to revert to default
;;; ς ε ρ τ υ θ ι ο π α σ δ φ γ η ξ κ λ ζ χ ψ ω β ν μ

(use-package floobits
  :ensure t)

(use-package vagrant
  :ensure t
  :defer t
  :init
  (progn
    (evil-leader/set-key
      "VD" 'vagrant-destroy
      "Ve" 'vagrant-edit
      "VH" 'vagrant-halt
      "Vp" 'vagrant-provision
      "Vr" 'vagrant-resume
      "Vs" 'vagrant-status
      "VS" 'vagrant-suspend
      "VV" 'vagrant-up)))

(use-package vagrant-tramp
  :ensure t
  :defer t)

(use-package gist
  :ensure t
  :config
  (setq gist-view-gist t))



(use-package elpy
  :ensure t
  :init
  (progn
    (elpy-enable)))

;;(when (require 'elpy nil t)
;;  (elpy-enable))
;;(setq elpy-rpc-backend "jedi")
;;(eval-after-load "python"
;;  '(define-key python-mode-map "\C-cx" 'jedi-direx:pop-to-buffer))
;(add-hook 'jedi-mode-hook 'jedi-direx:setup)

(add-to-list 'load-path "~/.emacs.d/emacs-eclim/")
   (require 'eclim)
   (global-eclim-mode)
   (require 'eclimd)


(setq help-at-pt-display-when-idle t)
(setq help-at-pt-timer-delay 0.1)
(help-at-pt-set-timer)


(custom-set-variables
  '(eclim-eclipse-dirs '("~/stage_corbin/eclipse"))
  '(eclim-executable "~/stage_corbin/eclipse/eclim"))

(require 'company-emacs-eclim)
;; add the emacs-eclim source
(require 'ac-emacs-eclim-source)
(ac-emacs-eclim-config)


(company-emacs-eclim-setup)
(global-company-mode t)

(setq help-at-pt-display-when-idle t)
(setq help-at-pt-timer-delay 0.1)
(help-at-pt-set-timer)

(use-package circe
  :ensure t
  :config
  (progn
    (use-package helm-circe
      :ensure t)))

(defvar load-mail-setup (file-exists-p "~/desktop/mails/main"))
(when load-mail-setup

(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")
(require-maybe 'mu4e)
(require-maybe 'helm-mu)

;; (setq mu4e-mu-binary "/usr/local/bin/mu")

(setq mu4e-maildir (expand-file-name "~/desktop/mails"))
(setq mu4e-drafts-folder "/main/Drafts")
(setq mu4e-sent-folder   "/main/Sent")
(setq mu4e-trash-folder  "/main/Trash")

(setq mu4e-get-mail-command "offlineimap")
(setq mu4e-html2text-command "html2text")

(setq message-send-mail-function 'message-send-mail-with-sendmail
      sendmail-program "/usr/bin/msmtp"
      user-full-name "Vincent Demeester")

(add-to-list 'mu4e-view-actions '("retag" . mu4e-action-retag-message))
(add-to-list 'mu4e-headers-actions '("retag" . mu4e-action-retag-message))

)
