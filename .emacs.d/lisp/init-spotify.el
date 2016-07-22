(require 'url)
(require 'json)
(require 'helm)

(defun air--alist-get (symbols alist)
  (if symbols
      (air--alist-get (cdr symbols)
		 (assoc (car symbols) alist))
    (cdr alist)))

(defun spotify-play-href (href)
    (shell-command "dbus-send --print-reply --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause")
    (shell-command (format "dbus-send --session --type=method_call --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.OpenUri \"string:%s\""
			   href)))

(defun spotify-play-track (track)
  "Get the Spotify app to play the TRACK."
  (spotify-play-href (air--alist-get '(uri) track)))

(defun spotify-play-album (track)
  "Get the Spotify app to play the album for this TRACK."
  (spotify-play-href (air--alist-get '(album href) track)))

(defun spotify-search (search-term)
  "Search spotify for SEARCH-TERM, returning the results as a lisp structure."
  (let ((a-url (format "https://api.spotify.com/v1/search?q=%s&type=track" search-term)))
    (with-current-buffer
      (url-retrieve-synchronously a-url)
    (goto-char url-http-end-of-headers)
    (json-read))))

(defun spotify-format-track (track)
  "Given a TRACK, return a formatted string suitable for displaying."
  (let ((track-name (air--alist-get '(name) track))
	(track-length (/ (air--alist-get '(duration_ms) track) 1000))
	(album-name (air--alist-get '(album name) track))
	(artist-names (mapcar (lambda (artist)
				(air--alist-get '(name) artist))
			      (air--alist-get '(artists) track))))
    (format "%s (%dm%0.2ds)\n%s - %s"
	    track-name
	    (/ track-length 60) (mod track-length 60)
	    (mapconcat 'identity artist-names "/")
	    album-name)))

(defun spotify-search-formatted (search-term)
  (mapcar (lambda (track)
	    (cons (spotify-format-track track) track))
	  (air--alist-get '(tracks items) (spotify-search search-term))))

(defun helm-spotify-search ()
  (spotify-search-formatted helm-pattern))

(defun helm-spotify-actions-for-track (actions track)
  "Return a list of helm ACTIONS available for this TRACK."
  `((,(format "Play Track - %s" (air--alist-get '(name) track)) . spotify-play-track)
    (,(format "Play Album - %s" (air--alist-get '(album name) track)) . spotify-play-album)
    ("Show Track Metadata" . pp)))

(defvar helm-source-spotify-track-search
  '((name . "Spotify")
    (volatile)
    (delayed)
    (multiline)
    (requires-pattern . 2)
    (candidates-process . helm-spotify-search)
    (action-transformer . helm-spotify-actions-for-track)))

(defun helm-spotify ()
  "Bring up a Spotify search interface in helm."
  (interactive)
  (helm :sources '(helm-source-spotify-track-search)
	:buffer "*helm-spotify*"))

(global-set-key (kbd "C-x C-s") 'helm-spotify)

(provide 'init-spotify)
