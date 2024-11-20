(in-package :ptp-bookmarks-ui)

(defun extract-genres (movies-plist)
  (sort
   (remove-duplicates
    (loop for movie in movies-plist
          for genres = (str:split "," (getf movie :genre))
          nconc (loop for genre in genres
                      collect (str:trim genre)))
    :test #'equal)
   #'string-lessp))

(defun filter-movies (lst &key (genre nil))
  (when genre
    (let ((genre-lst
            (remove-if-not
             (lambda (movie) (str:containsp genre (getf movie :genre)))
             lst)))
      genre-lst)))

(defun assoc-val (alist key)
  (alexandria:assoc-value alist key :test #'equal))

(defun get-imdb-id (imdb-link)
  (car
   (last
    (remove-if
     #'str:emptyp
     (str:split #\/ imdb-link)))))

(defun keywordize-string (str)
  (-<> str (string-upcase <>) (intern :keyword)))

(defun read-env-file ()
  (->> ".env"
    (pathname)
    (asdf:system-relative-pathname :ptp-bookmarks-ui)
    (uiop:read-file-lines)
    (remove-if-not (lambda (str) (str:containsp "OMDB_KEY=" str)))
    (first)
    (str:split "=")
    (cadr)
    (remove #\')
    (setq *omdb-api-key*)
    (str:concat "http://www.omdbapi.com/?apikey=")
    (setq *omdb-request-root*)))

(defun map-movie-obj-to-plist (db-item)
  (with-slots
        (title year imdbrating poster plot actors genre imdbid)
      db-item
    `(:title ,title
      :imdbid ,imdbid,
      :year ,year
      :rating ,imdbrating
      :poster ,poster
      :synopsis ,plot
      :actors ,actors
      :genre ,genre)))

(defun sanitize-year (str)
  (str:remove-punctuation str))

(defun sanitize-rating (str)
  (str:replace-all "N/A" "0" str))
