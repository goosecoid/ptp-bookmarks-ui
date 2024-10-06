(in-package :ptp-bookmarks-ui)

(defvar *port*)
(defvar *csv-file-path*)
(defparameter *app* (make-instance 'ningle:app))
(defvar *server* nil)
(defvar *omdb-api-key* nil)
(defvar *omdb-request-root* nil)

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

(defun read-env-file ()
  (->> ".env"
    (pathname)
    (asdf:system-relative-pathname :ptp-bookmarks-ui)
    (uiop:read-file-lines)
    (remove-if-not (lambda (str) (str:containsp "OMDB_KEY=" str)))
    (first)
    (str:split "=")
    (cadr)
    (remove #\')
    (setq *omdb-api-key*)
    (str:concat "http://www.omdbapi.com/?apikey=")
    (setq *omdb-request-root*)))

(defun start/options ()
  "Returns the options of the `start' command"
  (list
   (clingon:make-option
    :string
    :description "File path to csv file"
    :short-name #\f
    :long-name "file"
    :initial-value "~/Downloads/bookmarks.csv"
    :env-vars '("FILE")
    :key :file)
   (clingon:make-option
    :integer
    :description "HTTP server port"
    :short-name #\p
    :long-name "port"
    :initial-value 8080
    :env-vars '("PORT")
    :key :port)))

(defun start/handler (cmd)
  "Handler for the `start' command"
  (let ((p (clingon:getopt cmd :port))
        (f (clingon:getopt cmd :file)))
    (format t "Loading csv from ~a~%" f)
    (setq *port* p)
    (when f
      (setq *csv-file-path* f))))

(defun start/command ()
  "A command to start the web interface"
  (clingon:make-command
   :name "start"
   :description "Start the web interface"
   :options (start/options)
   :handler #'start/handler))

(defun start ()
  (let ((app (start/command)))
    (clingon:run app)
    (read-env-file)
    (bootstrap-db)
    (bootstrap-routes *app*)
    (setf *server* (clack:clackup
                    (lack:builder
                     (:static
                      :path "/public/"
                      :root (asdf:system-relative-pathname :ptp-bookmarks-ui #P"public/"))
                     *app*)
                    :port *port*))

    (handler-case (bt:join-thread
                   (find-if (lambda (th)
                              (search "hunchentoot" (bt:thread-name th)))
                            (bt:all-threads))))

    ;; Catch a C-c
    (#+sbcl sb-sys:interactive-interrupt
     () (stop))
    (error (c) (format t "Unknown error: ~&~a~&" c))))

(defun stop ()
  (progn
    (format *error-output* "Aborting server...~&")
    (clack:stop *server*)
    (uiop:quit)))

;; (ql:quickload :ptp-bookmarks-ui)
;; (start)
;; (stop)
