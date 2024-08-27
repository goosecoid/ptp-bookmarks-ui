(in-package :ptp-bookmarks-ui)

;; TODO: FIXME we should store the trailer urls in the db
(defun get-trailer-links (imdbid)
  "returns a list of lists, each containing a link to a trailer and its description"
  (format t "Getting trailer links for ~a~%" imdbid)
  (format t "Fecthing html from ~a~%" (format nil "https://www.imdb.com/title/~a/" imdbid))
  (let* ((html (dex:get (format nil "https://www.imdb.com/title/~a/" imdbid)))
         (doc (lquery:$ (initialize html)))
         (links-array (lquery:$ doc "a" (combine (attr "href") (text))))
         (trailer-links
           (remove-if-not (lambda (lst)
                            (and (str:containsp "video" (car lst))
                                 (str:containsp "Trailer" (cadr lst))))
                          (coerce links-array 'list))))
    (mapcar
     (lambda (lst)
       (list (format nil "https://www.imdb.com/~a" (car lst)) (cadr lst)))
     trailer-links)))
