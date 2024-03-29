(defsystem "ptp-bookmarks-ui"
  :version "0.0.1"
  :author ""
  :license ""
  :depends-on ("cl-csv"
               "dexador"
               "str"
               "jonathan"
               "mito"
               "alexandria")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "main"))))

  :description "")
