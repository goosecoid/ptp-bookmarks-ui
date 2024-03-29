(in-package :ptp-bookmarks-ui)

(defparameter *omdb-api-key* "2f4be310")
(defparameter *omdb-request-root*
  (str:concat "http://www.omdbapi.com/?apikey=" *omdb-api-key*))
(defparameter *watch-list*
  (cl-csv:read-csv #P"~/Downloads/watch-list.csv"))

(defun assoc-val (alist key)
  (alexandria:assoc-value alist key :test #'equal))

(defun get-imdb-id (imdb-link)
  (car
   (last
    (remove-if
     #'str:emptyp
     (str:split #\/ imdb-link)))))

(defparameter *id-lists*
  (let ((wl (subseq *watch-list* 1 10)))
    (loop for (title year imdb-link) in wl
          collect (get-imdb-id imdb-link))))

(defparameter *milk*
  (jonathan:parse
   (dex:get
    (str:concat
     *omdb-request-root*
     "&i="
     (car *id-lists*))) :as :alist))

(defun connect ()
  (mito:connect-toplevel
   :sqlite3
   :database-name "ptp-bookmarks-ui.db"))

(mito:deftable movie ()
  ((imdbid :col-type :text)
   (imdbrating :col-type :text)
   (poster :col-type :text)
   (plot :col-type :text)
   (actors :col-type :text)
   (genre :col-type :text)
   (year :col-type :text)
   (title :col-type :text)))

(mito:table-definition 'movie)

(defun ensure-movies ()
  (mito:ensure-table-exists 'movie)
  (mito:migrate-table 'movie))

(defun create-movie-item (movie-alist)
  (make-instance
   'movie
   :imdbid (assoc-val movie-alist "imdbID")
   :imdbrating (assoc-val movie-alist "imdbRating")
   :poster (assoc-val movie-alist "Poster")
   :plot (assoc-val movie-alist "Plot")
   :actors (assoc-val movie-alist "Actors")
   :genre (assoc-val movie-alist "Genre")
   :year (assoc-val movie-alist "Year")
   :title (assoc-val movie-alist "Title")))

(defvar milk-movie (create-movie-item *milk*))

(mito:insert-dao milk-movie)
(mito:find-dao 'movie :imdbid (assoc-val *milk* "imdbID"))
(mito:select-dao 'movie)
