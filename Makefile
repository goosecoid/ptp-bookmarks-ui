LISP ?= sbcl

build:
	$(LISP) --eval '(require :asdf)' \
			--eval '(asdf:load-asd "ptp-bookmarks-ui.asd")' \
			--eval '(ql:quickload :ptp-bookmarks-ui)' \
			--eval '(asdf:make :ptp-bookmarks-ui)' \
			--eval '(quit)'
