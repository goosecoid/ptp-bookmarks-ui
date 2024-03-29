(defsystem "ptp-bookmarks-ui"
  :version "0.0.1"
  :author ""
  :license ""
  :depends-on ("cl-csv"
               "dexador"
               "str"
               "jonathan")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "ptp-bookmarks-ui/tests"))))

(defsystem "ptp-bookmarks-ui/tests"
  :author ""
  :license ""
  :depends-on ("ptp-bookmarks-ui"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for ptp-bookmarks-ui"
  :perform (test-op (op c) (symbol-call :rove :run c)))
