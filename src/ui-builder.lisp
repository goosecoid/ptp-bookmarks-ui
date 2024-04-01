(in-package :ptp-bookmarks-ui)

;; (defparameter *svg-url*
;;   "https://raw.githubusercontent.com/n3r4zzurr0/svg-spinners/abfa05c49acf005b8b1e0ef8eb25a67a7057eb20/svg-css/6-dots-rotate.svg")
;; (defparameter *movies-plist* (list-all-movies-as-plist))
;; (defparameter *app* (make-instance 'ningle:app))
;; (defparameter *server* (clack:clackup *app* :port 8080))
;; (clack:stop *server*)

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
                .pure-table { margin: 1% }
                #title { text-align: center  }")
       (:link
        :rel "stylesheet"
        :href "https://cdn.jsdelivr.net/npm/purecss@3.0.0/build/pure-min.css")
       (:script :src "https://unpkg.com/htmx.org@1.9.10")
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
                  ;; TODO: FIXME in the future whe should check if the movie has trailer urls
                  ;; if so, already render them, otherwise, render the fetch button
                  ;; TODO: FIXME button kinda looks weird
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
                    :src *svg-url*)))))))

(defun movie-list (movies-plist)
  (with-page (:title "My PTP watch list")
    (:header
     (:h1 :id "title" "My PTP watch list"))
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
            (:tbody (:raw (table-body movies-plist))))))

(defun get-trailer-links-el (imdbid)
  (let ((trailer-urls (get-trailer-links imdbid)))
    (spinneret:with-html-string ()
      (loop for (url description) in trailer-urls
            do (:a :target "_blank" :href url description)))))

(setf (ningle:route *app* "/")
      (movie-list *movies-plist*))

(setf (ningle:route *app* "/trailers")
      #'(lambda (params)
          (spinneret:with-html-string ()
            (:div :id "trailer-urls"
                  (:raw (get-trailer-links-el (cdar params)))))))
