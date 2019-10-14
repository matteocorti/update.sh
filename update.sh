#!/bin/sh

VERBOSE=""
CLEAR=""
QUIET=""

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

usage() {

    echo "Usage: update.sh [OPTIONS]"
    echo
    echo "Options:"
    echo "   -c,--clear            use client certificate to authenticate"
    echo "   -h,--help,-?          this help message"
    echo "   -q,--quiet            minimal output"
    echo "   -v,--verbose          verbose output"
    echo
    echo "Report bugs to https://github.com/matteocorti/update.sh/issues"
    echo
    
}

while true; do

    case "$1" in
	-c|--clear)
	    CLEAR=1
	    shift
	    ;;
        -h|--help|-\?)
            usage
            exit 0
            ;;
	-q|--quiet)
	    QUIET="1"
	    shift
	    ;;
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

if [ -n "${CLEAR}" ] ; then
    clear
fi

if [ -x /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate ] ; then

    if [ -z "${QUIET}" ] ; then
	echo "################################################################################"
	echo "# Microsoft"
	echo "#"
	echo
    fi

    run_command '/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --list'
    run_command '/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --install'

fi

if [ -z "${QUIET}" ] ; then
    echo
    echo "##############################################################################"
    echo "# Apple"
    echo "#"
    echo
fi

run_command 'sudo softwareupdate -ia'

if command -v mas > /dev/null 2>&1 ; then

    if [ -z "${QUIET}" ] ; then
	echo
	echo "##############################################################################"
	echo "# Apple Store"
	echo "#"
	echo
    fi
    
    run_command 'mas upgrade'
    
fi

if command -v port > /dev/null 2>&1 ; then

    if [ -z "${QUIET}" ] ; then
	echo
	echo "##############################################################################"
	echo "# MacPorts"
	echo "#"
	echo
    fi

    run_command 'sudo port selfupdate'
    run_command 'sudo port installed outdated'

    if port installed outdated | grep -q -v 'None of the specified ports are installed.' ; then
	run_command 'sudo port -N -c upgrade outdated'
	run_command 'sudo port -N -u -q uninstall'
    fi

fi
    
if  command -v brew > /dev/null 2>&1 ; then

    if [ -z "${QUIET}" ] ; then
	echo
	echo "##############################################################################"
	echo "# Homebrew"
	echo "#"
	echo
    fi

    HOMEBREW_NO_COLOR=1
    run_command 'brew update'
    run_command 'brew upgrade'

fi

PERLBREW_ROOT=${HOME}/perl5/perlbrew

if [ -f "${PERLBREW_ROOT}/etc/bashrc" ] ; then

    if [ -z "${QUIET}" ] ; then
	echo
	echo "##############################################################################"
	echo "# Perlbrew"
	echo "#"
	echo
    fi
    
    # shellcheck source=${HOME}/perl5/perlbrew/etc/bashrc
    . "${PERLBREW_ROOT}/etc/bashrc"

    run_command 'perlbrew self-upgrade'

    for version in $( perlbrew list | sed "s/[* ]*\\([^ ]*\\).*/\\1/" ) ; do

	run_command "perlbrew use ${version}"
	run_command 'perlbrew upgrade-perl'
	LIST=$( cpan-outdated -p --exclude-core | tr '\n' ' ' )
	if [ -n "${LIST}" ] ; then
            run_command "cpanm ${LIST}"
	fi
    
    done

fi

echo

