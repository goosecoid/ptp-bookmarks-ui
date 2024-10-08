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
