(defun air--config-evil-leader ()
  "Configure evil leader mode."
  (evil-leader/set-leader ",")
  (setq evil-leader/in-all-states 1)
  (evil-leader/set-key
    ","  (lambda () (interactive) (ansi-term (getenv "SHELL")))
    "."  'switch-to-previous-buffer
    "g"  'magit-status))

(use-package evil
    :ensure t
    :config
    (evil-mode 1)

    (use-package evil-leader
      :ensure t
      :config
      (global-evil-leader-mode)
      (air--config-evil-leader)))


(provide 'init-evil)
