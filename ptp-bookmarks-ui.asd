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
               "lack")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "db")
                 (:file "ui-builder")
                 (:file "omdb"))))

  :description "")
