#!/bin/sh

# Copyright (c) 2018-2022 Matteo Corti <matteo@corti.li>

VERSION=1.4.1

VERBOSE=""
CLEAR=""
QUIET=""

if [ -x /Applications/MacUpdater.app/Contents/Resources/macupdater_client ]; then
    MACUPDATER='YES'
fi

error() {
    printf 'Error: %s\n' "${1}" 1>&2
    exit 1
}

run_command() {

    COMMAND="$1"

    if [ -n "${VERBOSE}" ]; then
        printf 'executing: "%s"\n' "${COMMAND}"
    fi

    HOMEBREW_NO_EMOJI=1
    export HOMEBREW_NO_EMOJI
    HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_ANALYTICS
    HOMEBREW_NO_COLOR=1
    export HOMEBREW_NO_COLOR

    if [ -n "${QUIET}" ]; then
        # suppress standard output
        COMMAND="${COMMAND} > /dev/null"
    fi

    eval "${COMMAND}"

}

usage() {

    echo "Usage: update.sh [OPTIONS]"
    echo
    echo "Options:"
    echo "   -c,--clear            clear the terminal screen before updating"
    echo "   -h,--help,-?          this help message"
    echo "   -n,--name             show machine name"
    echo "   -q,--quiet            minimal output"
    echo "   -v,--verbose          verbose output"
    echo
    echo "Report bugs to https://github.com/matteocorti/update.sh/issues"
    echo

}

while true; do

    case "$1" in
    -c | --clear)
        CLEAR=1
        shift
        ;;
    -h | --help | -\?)
        usage
        exit 0
        ;;
    -n | --name)
        NAME=$(hostname)
        NAME=" (${NAME})"
        shift
        ;;
    -q | --quiet)
        QUIET="1"
        shift
        ;;
    -v | --verbose)
        VERBOSE=1
        shift
        ;;
    -V | --version)
        echo "update.sh version ${VERSION}"
        exit 0
        ;;
    *)
        if [ -n "${1}" ]; then
            error "invalid option: ${1}"
        fi
        break
        ;;
    esac

done

if [ -n "${CLEAR}" ]; then
    clear
fi

if [ -x /Applications/MacUpdater.app/Contents/Resources/macupdater_client ]; then

    if [ -z "${QUIET}" ]; then
        echo
        echo "##############################################################################"
        echo "# MacUpdater${NAME}"
        echo "#"
        echo
    fi

    run_command '/Applications/MacUpdater.app/Contents/Resources/macupdater_client scan --quiet'
    run_command '/Applications/MacUpdater.app/Contents/Resources/macupdater_client update --quiet'

fi

if [ -x /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate ]; then

    
    if [ -z "${QUIET}" ]; then
        echo "################################################################################"
        echo "# Microsoft${NAME}"
        echo "#"
        echo
    fi
    
    if [ -n "${VERBOSE}" ]; then
        # we don't need the list
        run_command '/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --list'
    fi
    run_command '/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --install'
        
    if [ -z "${QUIET}" ]; then
        echo
    fi

fi

if [ -x /usr/local/bin/RemoteUpdateManager ]; then

    if [ -z "${QUIET}" ]; then
        echo "################################################################################"
        echo "# Adobe${NAME}"
        echo "#"
        echo
    fi

    if [ -n "${MACUPDATER}" ] ; then
        
        echo "Skipping: will be handled by MacUpdater"
        echo

    else
        
        run_command 'sudo /usr/local/bin/RemoteUpdateManager  --action=install'

    fi

fi

if [ -z "${QUIET}" ]; then
    echo
    echo "##############################################################################"
    echo "# Apple${NAME}"
    echo "#"
    echo
fi

# softwareupdates writes information messages to stderr
#  we try to filter the informational messages away
if [ -n "${QUIET}" ]; then
    COMMAND="( sudo softwareupdate -ia > /dev/null)  2>&1 | grep -v '^No\ updates\ available$'"
else
    COMMAND='sudo softwareupdate -ia'
fi
run_command "${COMMAND}"

if command -v mas >/dev/null 2>&1; then

    if [ -z "${QUIET}" ]; then
        echo
        echo "##############################################################################"
        echo "# Apple Store${NAME}"
        echo "#"
        echo
    fi

    run_command 'mas upgrade'

fi

if command -v port >/dev/null 2>&1; then

    if [ -z "${QUIET}" ]; then
        echo
        echo "##############################################################################"
        echo "# MacPorts${NAME}"
        echo "#"
        echo
    fi

    run_command 'sudo port selfupdate'
    run_command 'sudo port installed outdated'

    if port installed outdated | grep -q -v 'None of the specified ports are installed.'; then

        run_command 'sudo port -N -c upgrade outdated'
        run_command 'sudo port -N -u -q uninstall'

    fi

fi

if command -v brew >/dev/null 2>&1; then

    if [ -z "${QUIET}" ]; then
        echo
        echo "##############################################################################"
        echo "# Homebrew${NAME}"
        echo "#"
        echo
    fi

    run_command 'brew update'
    run_command 'brew upgrade'

    # Cask
    run_command 'brew upgrade --cask'

    run_command 'brew autoremove'
    run_command 'brew cleanup'

fi

PERLBREW_ROOT=${HOME}/perl5/perlbrew

if [ -f "${PERLBREW_ROOT}/etc/bashrc" ]; then

    if [ -z "${QUIET}" ]; then
        echo
        echo "##############################################################################"
        echo "# Perlbrew${NAME}"
        echo "#"
        echo
    fi

    # shellcheck disable=SC1091
    . "${PERLBREW_ROOT}/etc/bashrc"

    run_command 'perlbrew self-upgrade'

    for version in $(perlbrew list | sed 's/[* ]*\([^ ]*\).*/\1/'); do

        run_command "perlbrew use ${version}"
        run_command 'perlbrew upgrade-perl'
        LIST=$(cpan-outdated -p --exclude-core | tr '\n' ' ')
        if [ -n "${LIST}" ]; then
            run_command "cpanm ${LIST}"
        fi

    done

fi

if [ -z "${QUIET}" ]; then
    echo
fi
