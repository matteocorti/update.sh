#!/bin/sh

VERSION=$( head -n 1 VERSION )

echo "Publishing release ${VERSION}"

echo 'RELEASE_NOTES.md:'
echo '------------------------------------------------------------------------------'

cat RELEASE_NOTES.md

echo '------------------------------------------------------------------------------'

echo 'Did you update the RELEASE_NOTES.md file? '
read -r ANSWER
if [ "${ANSWER}" = "y" ] ; then
    
    make
    gh release create "v${VERSION}" --title "update.sh-${VERSION}" --notes-file RELEASE_NOTES.md "update.sh-${VERSION}.tar.gz" "update.sh-${VERSION}.tar.bz2"

fi
