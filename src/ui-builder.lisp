(in-package :ptp-bookmarks-ui)

(defparameter *movies-plist* (list-all-movies-plist))

(defmacro with-page ((&key title) &body body)
  `(spinneret:with-html-string
     (:doctype)
     (:html
      (:head
       (:style "img {
                border: 1px solid #ddd;
                border-radius: 4px;
                padding: 5px;
                width: 150px;}")
       (:title ,title))
      (:body ,@body))))

(defun movie-list (movies-plist)
  (with-page (:title "My PTP watch list")
    (:header
     (:h1 "My PTP watch list"))
    (:section
     (:ul
      (loop for movie in movies-plist
            collect
            (let ((title (getf movie :title))
                  (year (getf movie :year))
                  (poster (getf movie :poster))
                  (genre (getf movie :genre))
                  (actors (getf movie :actors))
                  (synopsis (getf movie :synopsis))
                  (rating (getf movie :rating)))
              (:li
               (:h3 (format nil "~A (~A)" title year))
               (:img :src (getf movie :poster))
               (:p "Genre: " genre)
               (:p "Actors: " actors)
               (:p "Synopsis: " synopsis)
               (:p "Rating: " rating))))))))

(str:to-file "index.html" (movie-list *movies-plist*))
