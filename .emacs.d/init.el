(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(add-to-list 'exec-path "/usr/local/bin")
(require 'init-utils)
(require 'init-elpa)

(package-initialize)

(unless (package-installed-p 'use-package)
    (package-refresh-contents)
      (package-install 'use-package))

(eval-when-compile
    (require 'use-package))

;; Essential settings
(setq inhibit-splash-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(show-paren-mode 1)

(setq custom-safe-themes t)
(setq tramp-default-method "ssh")

(require 'init-global-functions)

(require 'init-fonts)
(require 'init-evil)
(require 'init-powerline)
(require 'init-flycheck)
(require 'init-cmake-ide)

(use-package helm
  :ensure t
  :diminish helm-mode
  :config
  (helm-mode 1)
  (setq helm-buffers-fuzzy-matching t)
  (setq helm-autoresize-mode t)
  (setq helm-buffer-max-length 40)
  (define-key helm-map (kbd "S-SPC") 'helm-toggle-visible-mark)
  (define-key helm-find-files-map (kbd "C-k") 'helm-find-files-up-one-level))

(use-package nlinum-relative
  :ensure t
  :config
  (nlinum-relative-setup-evil)
  (setq nlinum-relative-redisplay-delay 0)
  (add-hook 'prog-mode-hook #'nlinum-relative-mode))

(define-key evil-normal-state-map (kbd "C-k") (lambda ()
                    (interactive)
                    (evil-scroll-up nil)))
(define-key evil-normal-state-map (kbd "C-j") (lambda ()
                        (interactive)
                        (evil-scroll-down nil)))

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)

(add-hook 'window-setup-hook
	  (lambda ()
	    (when (memq window-system '(x))
	      (add-to-list 'default-frame-alist '(font . "Hack"))
	      (set-face-attribute 'default nil :font "Hack")
	      (sanityinc/set-frame-font-size 12))
	    (when (fboundp 'powerline-reset)
	      (powerline-reset))))

(use-package color-theme-approximate
  :ensure t)

(use-package monokai-theme
  :ensure t)

(color-theme-approximate-on)
(add-hook 'window-setup-hook (lambda () (load-theme 'monokai t)))

(setq scroll-margin 5
scroll-conservatively 9999
scroll-step 1)

(provide 'init)
