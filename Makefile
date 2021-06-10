VERSION=`cat VERSION`
DIST_DIR=update.sh-$(VERSION)
DIST_FILES=update.sh VERSION README.md NEWS Makefile COPYRIGHT COPYING
FORMATTED_FILES=update.sh VERSION README.md NEWS COPYRIGHT COPYING
YEAR=`date +"%Y"`

dist: version_check formatting_check copyright_check shellcheck
	rm -rf $(DIST_DIR) $(DIST_DIR).tar.gz
	mkdir $(DIST_DIR)
	cp -r $(DIST_FILES) $(DIST_DIR)
# avoid to include extended attribute data files
# see https://superuser.com/questions/259703/get-mac-tar-to-stop-putting-filenames-in-tar-archives
	env COPYFILE_DISABLE=1 tar cfz $(DIST_DIR).tar.gz  $(DIST_DIR)
	env COPYFILE_DISABLE=1 tar cfj $(DIST_DIR).tar.bz2 $(DIST_DIR)

remove_blanks:
	sed -i '' 's/[[:blank:]]*$$//' $(DIST_FILES)

formatting_check:
	! grep -q '\\t' $(FORMATTED_FILES)
	! grep -q '[[:blank:]]$$' $(DIST_FILES)

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
	if shellcheck --help 2>&1 | grep -q -- '-o\ ' ; then shellcheck -o all update.sh ; else shellcheck update.sh ; fi
endif
