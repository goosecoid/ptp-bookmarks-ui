(in-package :ptp-bookmarks-ui)

(defparameter *app* (make-instance 'ningle:app))
(defparameter *port* 8080)

(defun bootstrap-routes (app-instance)

  (setf (ningle:route app-instance "/")
        (movie-list (list-all-movies-as-plist)))

  (setf (ningle:route app-instance "/filter-genre")
        #'(lambda (params)
            (let ((movielst
                    (filter-movies
                     (list-all-movies-as-plist)
                     :genre (cdar params))))
              (spinneret:with-html-string ()
                (:raw (table-body movielst))))))

  (setf (ningle:route app-instance "/trailers")
        #'(lambda (params)
            (spinneret:with-html-string ()
              (:div :id "trailer-urls"
                    (:raw (get-trailer-links-el (cdar params))))))))

(defun start ()
  (bootstrap-db)
  (bootstrap-routes *app*)
  (let ((server (clack:clackup
                 (lack:builder
                  (:static
                   :path "/public/"
                   :root (asdf:system-relative-pathname :ptp-bookmarks-ui #P"public/"))
                  *app*)
                 :port 8080)))

    (handler-case (bt:join-thread
                   (find-if (lambda (th)
                              (search "hunchentoot" (bt:thread-name th)))
                            (bt:all-threads))))

    ;; Catch a C-c
    (#+sbcl sb-sys:interactive-interrupt
     () (progn
          (format *error-output* "Aborting server...~&")
          (clack:stop server)
          (uiop:quit)))
    (error (c) (format t "Unknown error: ~&~a~&" c))))
