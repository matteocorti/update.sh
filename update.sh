#!/bin/sh

clear;

verbose_exec() {
    echo "################################################################################"
    echo "### $1"
    $1
}

##############################################################################
# macports

verbose_exec "sudo port selfupdate"
verbose_exec "sudo port installed outdated"

if port installed outdated | grep -q -v 'None of the specified ports are installed.' ; then
    verbose_exec "nice sudo port -c upgrade outdated"
    verbose_exec "nice sudo port -u -q uninstall"
fi

##############################################################################
# brew

if type brew > /dev/null 2>&1 ; then

    verbose_exec 'brew update'
    verbose_exec 'brew upgrade'

fi

##############################################################################
# Perlbrew

PERLBREW_ROOT=${HOME}/perl5/perlbrew

if [ -f "${PERLBREW_ROOT}/etc/bashrc" ] ; then

    # shellcheck source=${HOME}/perl5/perlbrew/etc/bashrc
    . "${PERLBREW_ROOT}/etc/bashrc"

    verbose_exec "perlbrew self-upgrade"

    for version in $( perlbrew list | sed "s/[* ]*\\([^ ]*\\).*/\\1/" ) ; do

	verbose_exec "perlbrew use ${version}"
	verbose_exec "perlbrew upgrade-perl"    
	LIST=$( cpan-outdated -p --exclude-core )
	if [ -n "${LIST}" ] ; then
            verbose_exec "cpanm $LIST"
	fi
    
    done

fi

