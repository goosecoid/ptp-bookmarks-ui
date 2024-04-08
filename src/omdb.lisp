(in-package :ptp-bookmarks-ui)

(defun get-movie-alist (imdb-id)
  (jonathan:parse
   (dex:get
    (str:concat
     *omdb-request-root*
     "&i="
     imdb-id)) :as :alist))
