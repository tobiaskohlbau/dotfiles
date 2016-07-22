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
(require 'dockerfile-mode)

(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

(use-package helm
  :ensure t
  :diminish helm-mode
  :config
  (helm-mode 1)
  (setq helm-buffers-fuzzy-matching t)
  (setq helm-autoresize-mode t)
  (setq helm-buffer-max-length 40)
  (setq helm-mode-fuzzy-match t)
  (define-key helm-map (kbd "S-SPC") 'helm-toggle-visible-mark)
  (define-key helm-find-files-map (kbd "S-k") 'helm-find-files-up-one-level)
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
  (global-set-key (kbd "C-x C-f") #'helm-find-files))

(require 'init-spotify)

(use-package nlinum-relative
  :ensure t
  :config
  (nlinum-relative-setup-evil)
  (setq nlinum-relative-redisplay-delay 0)
  (add-hook 'prog-mode-hook #'nlinum-relative-mode))

(use-package magit
  :ensure t
  :defer t
  :config
  (setq magit-branch-arguments nil)
  (setq magit-push-always-verify nil)
  (setq magit-last-seen-setup-instructions "1.4.0")
  (magit-define-popup-switch 'magit-log-popup ?f "first parent" "--first-parent"))

(add-hook 'magit-mode-hook
          (lambda ()
            (define-key magit-mode-map (kbd ",o") 'delete-other-windows)))

(add-hook 'git-commit-mode-hook 'evil-insert-state)

(define-key evil-normal-state-map (kbd "C-k") (lambda ()
                    (interactive)
                    (evil-scroll-up nil)))
(define-key evil-normal-state-map (kbd "C-j") (lambda ()
                        (interactive)
                        (evil-scroll-down nil)))

(setq-default indent-tabs-mode nil)
(setq tab-width 4)
(defvaralias 'c-basic-offset 'tab-width)

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

(use-package projectile
  :ensure t
  :defer t
  :config
  (projectile-global-mode)
  (setq projectile-enable-caching t))

(use-package helm-projectile
  :bind (("C-S-P" . helm-projectile-switch-project)
         :map evil-normal-state-map
         ("C-P" . helm-projectile))
  :after (helm projectile evil)
  :commands (helm-projectile helm-projectile-switch-project)
  :ensure t)

(defun air--mail-mode-hook ()
  (turn-on-auto-fill) ;;; Auto-Fill is necessary for mails
  (turn-on-font-lock) ;;; Font-Lock is always cool *g*
  (flush-lines "^\\(> \n\\)*> -- \n\\(\n?> .*\\)*") 
                      ;;; Kills quoted sigs.
  (not-modified)      ;;; We haven't changed the buffer, haven't we? *g*
  (mail-text)         ;;; Jumps to the beginning of the mail text
  (setq make-backup-files nil)
                      ;;; No backups necessary.
)

(or (assoc "mutt-" auto-mode-alist) 
    (setq auto-mode-alist (cons '("mutt-" . mail-mode) auto-mode-alist)))
(add-hook 'mail-mode-hook 'air--mail-mode-hook)

; Add cmake listfile names to the mode list.
(setq auto-mode-alist
	  (append
	   '(("CMakeLists\\.txt\\'" . cmake-mode))
	   '(("\\.cmake\\'" . cmake-mode))
	   auto-mode-alist))

(autoload 'cmake-mode "/usr/share/cmake-3.5/editors/emacs/cmake-mode.el" t)
(setq cmake-tab-width 4)

(provide 'init)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (monokai-theme color-theme-approximate nlinum-relative helm cmake-ide irony company auto-complete-clang rtags flycheck powerline-evil powerline evil-leader evil use-package fullframe))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
