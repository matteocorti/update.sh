VERSION=`cat VERSION`
DIST_DIR=update.sh-$(VERSION)
DIST_FILES=update.sh VERSION README.md NEWS Makefile COPYRIGHT COPYING ChangeLog
FORMATTED_FILES=update.sh VERSION README.md NEWS COPYRIGHT COPYING RELEASE_NOTES.md publish_release.sh
SHELLCHECK_FILES=update.sh publish_release.sh
YEAR=`date +"%Y"`

dist: version_check formatting_check copyright_check shellcheck
	rm -rf $(DIST_DIR) $(DIST_DIR).tar.gz
	mkdir $(DIST_DIR)
	cp -r $(DIST_FILES) $(DIST_DIR)
# avoid to include extended attribute data files
# see https://superuser.com/questions/259703/get-mac-tar-to-stop-putting-filenames-in-tar-archives
	export COPY_EXTENDED_ATTRIBUTES_DISABLE=1; \
	export COPYFILE_DISABLE=1; \
	tar cfz $(DIST_DIR).tar.gz  $(DIST_DIR)
	tar cfj $(DIST_DIR).tar.bz2 $(DIST_DIR)

remove_blanks:
	sed -i '' 's/[[:blank:]]*$$//' $(DIST_FILES)

formatting_check:
	! grep -q '\\t' $(FORMATTED_FILES)
	! grep -q '[[:blank:]]$$' $(DIST_FILES)

SHFMT= := $(shell command -v shfmt 2> /dev/null)
format:
ifndef SHFMT
	echo "No shfmt installed"
else
# -p POSIX
# -w write to file
# -s simplify
# -i 4 indent with 4 spaces
	shfmt -p -w -s -i 4 $(SHELLCHECK_FILES)
endif

version_check:
	grep -q "VERSION\ *=\ *[\'\"]*$(VERSION)" update.sh
	grep -q "${VERSION}" NEWS
        echo "Version check: OK"

copyright_check:
	grep -q "&copy; Matteo Corti, 2018-$(YEAR)" README.md
	grep -q "Copyright (c) 2018-$(YEAR) Matteo Corti" COPYRIGHT
	grep -q "Copyright (c) 2018-$(YEAR) Matteo Corti <matteo@corti.li>" update.sh
	echo "Copyright year check: OK"

SHELLCHECK := $(shell command -v shellcheck 2> /dev/null)

shellcheck:
ifndef SHELLCHECK
	echo "No shellcheck installed: skipping test"
else
	if shellcheck --help 2>&1 | grep -q -- '-o\ ' ; then shellcheck -o all $(SHELLCHECK_FILES) ; else shellcheck $(SHELLCHECK_FILES) ; fi
endif

distclean:
	rm -rf update.sh-[0-9]*

.PHONY: distclean version_check copyright_check remove_blanks dist
