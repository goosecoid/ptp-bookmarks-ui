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

(defmacro with-page ((&key title) &body body)
  `(spinneret:with-html-string
       (:doctype)
     (:html
      (:head
       (:style "#trailer-button { display: flex;
                                  flex-flow: row nowrap;
                                  justify-content: space-between;
                                  align-items: center;
                                  gap: 10px; }
                #trailer-urls { display: flex;
                                flex-flow: column wrap;
                                justify-content: center; }
                .container { margin: 1% }
                .dropdown { display: flex;
                            flex-flow: row nowrap;
                            justify-content: flex-start;
                            align-items: center;
                            gap: 10px; }
                #title { text-align: center  }")
       (:link
        :rel "stylesheet"
        :href "public/pure-min.css")
       (:script :src "public/htmx.min.js")
       (:title ,title))
      (:body ,@body))))

(defun table-body (movies-plist)
  (spinneret:with-html-string ()
    (loop for movie in movies-plist
          for counter from 1 do
            (:tr :class (if (oddp counter)
                            "pure-table-odd"
                            "pure-table-even")
                 (:td (getf movie :title))
                 (:td (:img :class "pure-img" :src (getf movie :poster)))
                 (:td (getf movie :year))
                 (:td (getf movie :genre))
                 (:td (getf movie :actors))
                 (:td (getf movie :synopsis))
                 (:td (getf movie :rating))
                 (:td
                  ;; TODO: in the future whe should check if the movie has trailer urls
                  ;; if so, already render them, otherwise, render the fetch button
                  ;; TODO: button kinda looks weird
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
    (:div :class "dropdown"
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
                    (:th "Title")
                    (:th "Cover")
                    (:th "Year")
                    (:th "Genre")
                    (:th "Actors")
                    (:th "Synopsis")
                    (:th "Rating")
                    (:th "Trailers")))
                  (:tbody :id "table-body"
                          (:raw (table-body movies-plist)))))))
