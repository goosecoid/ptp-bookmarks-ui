(defsystem "ptp-bookmarks-ui"
  :version "0.0.1"
  :author "goosecoid"
  :license "MIT"
  :depends-on ("cl-csv"
               "dexador"
               "str"
               "jonathan"
               "mito"
               "alexandria"
               "lquery"
               "spinneret"
               "clack"
               "ningle"
               "clingon"
               "bordeaux-threads"
               "lack")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "omdb")
                 (:file "db")
                 (:file "view")
                 (:file "server")
                 (:file "imdb"))))
  :description "A PassThePopcorn bookmarks UI"
  :build-operation "program-op"
  :build-pathname "ptp"
  :entry-point "ptp-bookmarks-ui:start")
