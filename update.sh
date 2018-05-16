#!/bin/sh

clear;

echo "################################################################################"
echo "# Microsoft"
echo "#"
echo

/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --list

/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --install

echo
echo "##############################################################################"
echo "# Apple"
echo "#"
echo

sudo softwareupdate -ia

echo
echo "##############################################################################"
echo "# MacPorts"
echo "#"
echo

sudo port selfupdate
sudo port installed outdated

if port installed outdated | grep -q -v 'None of the specified ports are installed.' ; then
    sudo port -c upgrade outdated
    sudo port -u -q uninstall
fi

echo
echo "##############################################################################"
echo "# Homebrew"
echo "#"
echo

if  command -v brew > /dev/null 2>&1 ; then

    brew update
    brew upgrade

fi

echo
echo "##############################################################################"
echo "# Perlbrew"
echo "#"
echo

PERLBREW_ROOT=${HOME}/perl5/perlbrew

if [ -f "${PERLBREW_ROOT}/etc/bashrc" ] ; then

    # shellcheck source=${HOME}/perl5/perlbrew/etc/bashrc
    . "${PERLBREW_ROOT}/etc/bashrc"

    perlbrew self-upgrade

    for version in $( perlbrew list | sed "s/[* ]*\\([^ ]*\\).*/\\1/" ) ; do

	perlbrew use "${version}"
	perlbrew upgrade-perl   
	LIST=$( cpan-outdated -p --exclude-core )
	if [ -n "${LIST}" ] ; then
            cpanm $LIST
	fi
    
    done

fi

