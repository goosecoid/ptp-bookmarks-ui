(in-package :ptp-bookmarks-ui)

(defun bootstrap-db ()

  (mito:connect-toplevel
   :sqlite3
   :database-name "ptp-bookmarks-ui.db")

  (mito:deftable movie ()
    ((imdbid :col-type :text)
     (imdbrating :col-type :text)
     (poster :col-type :text)
     (plot :col-type :text)
     (actors :col-type :text)
     (genre :col-type :text)
     (year :col-type :text)
     (title :col-type :text)))

  (mito:ensure-table-exists 'movie)
  (mito:migrate-table 'movie)
  (populate-db-from-csv *csv-file-path*))

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

(defun populate-db-from-csv (csv-file-path)
  (let ((csv (cl-csv:read-csv (pathname csv-file-path))))
    (loop for (title year imdb-link) in (rest csv)
          for imdb-id = (get-imdb-id imdb-link)
          do (format
              t
              "Checking if ID ~a from ~a (~a) is already in the db ~%"
              imdb-id title year)
          do (if (and imdb-id (not (mito:find-dao 'movie :imdbid imdb-id)))
                 (progn
                   (format t "Fetching ~a (~a) from omdb ~%" title year)
                   (let ((movie-alist
                           (get-movie-alist imdb-id)))
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
                  year)))))

(defun list-all-movies-as-plist (&key (key :year) (order :desc))
  "Return all movies in db. :KEY to sort can be :TITLE or :RATING. :ORDER can be :ASC or DESC"
  (let ((db-list (mito:select-dao 'movie))
        (predicate (if (eq order :desc) #'string-greaterp #'string-lessp)))
    (sort (loop for db-item in db-list
                collect (with-slots
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
          predicate
          :key (lambda (plist)
                 (getf plist key)))))
