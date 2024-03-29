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

(defun connect-db ()
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

(defun populate-db (csv-file-path)
  (let ((csv (cl-csv:read-csv csv-file-path)))
    (connect-db)
    (loop for (title year imdb-link) in (rest csv)
          do (format
              t
              "Checking if ID ~a from ~a (~a) is already in the db ~%"
              (get-imdb-id imdb-link) title year)
          do (let ((imdb-id (get-imdb-id imdb-link)))
               (if (and imdb-id (not (mito:find-dao 'movie :imdbid imdb-id)))
                   (progn
                     (format t "Fetching ~a (~a) from omdb ~%" title year)
                     (let ((movie-alist
                             (jonathan:parse
                              (dex:get
                               (str:concat
                                *omdb-request-root*
                                "&i="
                                imdb-id)) :as :alist)))
                       (format t "Inserting ~a (~a) into the db ~%" title year)
                       (mito:insert-dao (create-movie-item movie-alist))
                       (format
                        t
                        "Inserted ~a (~a) into the db successfully ~%"
                        title
                        year)))
                   (format
                    t
                    "Movie ~a (~a) is already in the db ~%"
                    title
                    year))))))