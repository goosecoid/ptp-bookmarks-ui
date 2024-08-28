(defsystem "ptp-bookmarks-ui"
  :version "0.0.1"
  :author ""
  :license ""
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
               "bordeaux-threads"
               "lack")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "omdb")
                 (:file "db")
                 (:file "view")
                 (:file "server")
                 (:file "imdb")
                 )))

  :description ""
  :build-operation "program-op"
  :build-pathname "ptp"
  :entry-point "ptp-bookmarks-ui:main")
