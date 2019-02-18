#!/bin/sh

clear;

VERBOSE=""

error() {
    printf 'Error: %s\n' "${1}" 1>&2
    exit 1
}

run_command() {
    COMMAND="$1"
    if [ -n "${VERBOSE}" ] ; then
	printf 'excuting: "%s"\n' "${COMMAND}"
    fi
    eval "${COMMAND}"
}

while true; do

    case "$1" in
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
	*)
	    if [ -n "${1}" ] ; then
		error "invalid option: ${1}"
	    fi
	    break
	    ;;
    esac

done

echo "################################################################################"
echo "# Microsoft"
echo "#"
echo

run_command '/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --list'
run_command '/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --install'

echo
echo "##############################################################################"
echo "# Apple"
echo "#"
echo

run_command 'sudo softwareupdate -ia'

echo
echo "##############################################################################"
echo "# Apple Store"
echo "#"
echo

if command -v mas > /dev/null 2>&1 ; then

    run_command 'mas upgrade'
    
fi

echo
echo "##############################################################################"
echo "# MacPorts"
echo "#"
echo

run_command 'sudo port selfupdate'
run_command 'sudo port installed outdated'

if port installed outdated | grep -q -v 'None of the specified ports are installed.' ; then
    run_command 'sudo port -c upgrade outdated'
    run_command 'sudo port -u -q uninstall'
fi

if  command -v brew > /dev/null 2>&1 ; then

    echo
    echo "##############################################################################"
    echo "# Homebrew"
    echo "#"
    echo
    
    run_command 'brew update'
    run_command 'brew upgrade'

fi

PERLBREW_ROOT=${HOME}/perl5/perlbrew

if [ -f "${PERLBREW_ROOT}/etc/bashrc" ] ; then

    echo
    echo "##############################################################################"
    echo "# Perlbrew"
    echo "#"
    echo
    
    # shellcheck source=${HOME}/perl5/perlbrew/etc/bashrc
    . "${PERLBREW_ROOT}/etc/bashrc"

    run_command 'perlbrew self-upgrade'

    for version in $( perlbrew list | sed "s/[* ]*\\([^ ]*\\).*/\\1/" ) ; do

	run_command "perlbrew use ${version}"
	run_command 'perlbrew upgrade-perl'
	LIST=$( cpan-outdated -p --exclude-core )
	if [ -n "${LIST}" ] ; then
            run_command "cpanm ${LIST}"
	fi
    
    done

fi

echo

