#!/bin/sh

clear;

PERLBREW_ROOT=${HOME}/perl5/perlbrew
# shellcheck source=${HOME}/perl5/perlbrew/etc/bashrc
. "${PERLBREW_ROOT}/etc/bashrc"

verbose_exec() {
    echo "################################################################################"
    echo "### $1"
    $1
}

verbose_exec "sudo port selfupdate"
verbose_exec "sudo port installed outdated"

if port installed outdated | grep -q -v 'None of the specified ports are installed.' ; then
    verbose_exec "nice sudo port -c upgrade outdated"
    verbose_exec "nice sudo port -u -q uninstall"
fi

verbose_exec "perlbrew self-upgrade"

for version in $( perlbrew list | sed "s/[* ]*\\([^ ]*\\).*/\\1/" ) ; do

    verbose_exec "perlbrew use ${version}"
    verbose_exec "perlbrew upgrade-perl"    
    LIST=$( cpan-outdated -p --exclude-core )
    if [ -n "${LIST}" ] ; then
        verbose_exec "cpanm $LIST"
    fi
    
done

