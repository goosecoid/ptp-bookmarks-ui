(in-package :ptp-bookmarks-ui)

(defparameter *svg-url*
  "https://raw.githubusercontent.com/n3r4zzurr0/svg-spinners/abfa05c49acf005b8b1e0ef8eb25a67a7057eb20/svg-css/6-dots-rotate.svg")
(defparameter *app* (make-instance 'ningle:app))

(defun bootstrap-routes (app-instance)

  (setf (ningle:route app-instance "/")
        (movie-list (list-all-movies-as-plist)))

  (setf (ningle:route app-instance "/filter-genre")
        #'(lambda (params)
            (let ((movielst
                    (filter-movies
                     *movies-plist*
                     :genre (cdar params))))
              (spinneret:with-html-string ()
                (:raw (table-body movielst))))))

  (setf (ningle:route app-instance "/trailers")
        #'(lambda (params)
            (spinneret:with-html-string ()
              (:div :id "trailer-urls"
                    (:raw (get-trailer-links-el (cdar params))))))))

(defun main ()
  (bootstrap-db)
  (bootstrap-routes *app*)
  (let ((server (clack:clackup *app* :port 8080)))

    (handler-case (bt:join-thread (find-if (lambda (th)
                                             (search "hunchentoot" (bt:thread-name th)))
                                           (bt:all-threads))))

    ;; Catch a C-c
    (#+sbcl sb-sys:interactive-interrupt
     () (progn
          (format *error-output* "Aborting server...~&")
          (clack:stop server)
          (uiop:quit)))
    (error (c) (format t "Unknown error: ~&~a~&" c))))
