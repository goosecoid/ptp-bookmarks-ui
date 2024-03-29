(defpackage ptp-bookmarks-ui
  (:use :cl))
(in-package :ptp-bookmarks-ui)

(defparameter *omdb-api-key* "2f4be310")
(defparameter *omdb-request-root*
  (str:concat "http://www.omdbapi.com/?apikey=" *omdb-api-key*))
(defparameter *watch-list*
  (cl-csv:read-csv #P"~/Downloads/watch-list.csv"))

(defun get-imdb-id (imdb-link)
  (car
   (last
    (remove-if
     #'str:emptyp
     (str:split #\/ imdb-link)))))

(defparameter *id-lists*
  (let ((wl (subseq *watch-list* 1 10)))
    (loop for (title year imdb-link) in wl
          collect (get-imdb-id imdb-link))))

(defparameter *milk*
  (dex:get
   (str:concat
    *omdb-request-root*
    "&i="
    (car *id-lists*))))

(jonathan:parse *milk* :as :alist)
