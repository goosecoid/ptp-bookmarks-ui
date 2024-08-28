LISP ?= sbcl

build:
	$(LISP) --load ptp-bookmarks-ui.asd \
		--eval '(ql:quickload :ptp-bookmarks-ui)' \
		--eval '(asdf:make :ptp-bookmarks-ui)' \
		--eval '(quit)'
