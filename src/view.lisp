(in-package :ptp-bookmarks-ui)

(defvar *table-state* nil)

(defparameter *table-titles* '("Title"
                               "Cover"
                               "Year"
                               "Genre"
                               "Actors"
                               "Synopsis"
                               "Rating"
                               "Trailers"))

(defmacro with-page ((&key title) &body body)
  `(spinneret:with-html-string
     (:doctype)
     (:html
      (:head
       (:link
        :rel "stylesheet"
        :href "public/pure-min.css")
       (:link
        :rel "stylesheet"
        :href "public/main.css")
       (:script :src "public/htmx.min.js")
       (:title ,title))
      (:body ,@body))))

(defun movie-list (movies-plist)
  (with-page (:title "My PTP watch list")
    (:header
     (:h1 :id "title" "My PTP watch list"))
    (:div :class "container"
          (:div (:raw (genre-dropdown-filter
                       (extract-genres movies-plist))))
          (:table :class "pure-table"
                  (:thead
                   (:tr
                    (loop for title in *table-titles*
                          do (:th (:raw (t-header-item title))))))
                  (:tbody :id "table-body"
                          (:raw (movie-list-body movies-plist)))))))

(defun movie-list-body (movies-plist)
  (spinneret:with-html-string ()
    (loop for movie in movies-plist
          for counter from 1 do
            (:tr :class (if (oddp counter)
                            "pure-table-odd"
                            "pure-table-even")
                 (:td (getf movie :title))
                 (:td
                  (:img :class "pure-img" :src (getf movie :poster)))
                 (:td (getf movie :year))
                 (:td (getf movie :genre))
                 (:td (getf movie :actors))
                 (:td (getf movie :synopsis))
                 (:td (getf movie :rating))
                 (:td
                  :id "trailer-grid-box"
                  (:div
                   :id "trailer-button"
                   :class "pure-button"
                   :data-hx-trigger "click"
                   :data-hx-swap "outerHTML"
                   :data-hx-get
                   (format
                    nil
                    "/trailers?imdbid=~A"
                    (getf movie :imdbid))
                   (:span "Get trailers")
                   (:img
                    :id "spinner"
                    :class "htmx-indicator"
                    :src "public/spinner.svg")))))))

(defun get-trailer-links-el (imdbid)
  (let ((trailer-urls (get-trailer-links imdbid)))
    (spinneret:with-html-string ()
      (loop for (url description) in trailer-urls
            do (:a :target "_blank" :href url description)))))

(defun genre-dropdown-filter (genres)
  (spinneret:with-html-string ()
    (:div :id "dropdown"
          (:p "Filter by genre: ")
          (:form :class "pure-form"
                 (:select
                     :name "genre"
                   :data-hx-get
                   "/filter-genre"
                   :data-hx-trigger "change"
                   :data-hx-target "#table-body"
                   (loop for genre in genres
                         do (:option :id "genre" :value genre genre)))))))

(defun t-header-item (title)
  (spinneret:with-html-string ()
    (:div :id "table-head-title"
          (:p title)
          (when (or (string-equal title "Year")
                    (string-equal title "Rating")
                    (string-equal title "Title"))
            (:img
             :id "sort-icon"
             :src "public/sort.svg"
             :width "10px"
             :data-hx-trigger "click"
             :data-hx-target "#table-body"
             :data-hx-get
             (let ((keyword-title (keywordize-string title)))
               (if (and *table-state*
                        (eq (car *table-state*) keyword-title)
                        (eq (cdr *table-state*) :desc))
                   (setf *table-state* (cons keyword-title :asc))
                   (setf *table-state* (cons keyword-title :desc)))
               (format nil
                       "/sort-table?key=~A&order=~A"
                       (car *table-state*)
                       (cdr *table-state*))))))))
