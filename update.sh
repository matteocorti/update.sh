#!/bin/sh

# Copyright (c) 2018-2023 Matteo Corti <matteo@corti.li>

VERSION=2.3.0

VERBOSE=""
CLEAR=""
QUIET=""

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
    echo "      --adobe            update Adobe products"
    echo "      --apple            update Apple products"
    echo "      --brew             update Homebrew packages"
    echo "   -c,--clear            clear the terminal screen before updating"
    echo "      --emacs            update emacs packages"
    echo "   -h,--help,-?          this help message"
    echo "      --macupdater       update with MacUpdater"
    echo "      --mas              update Apple Store applications"
    echo "      --msupdate         update Microsoft products"
    echo "   -n,--name             show machine name"
    echo "      --no-adobe         do not update Adobe products"
    echo "      --no-apple         do not update Apple products"
    echo "      --no-brew          do not update Homebrew packages"
    echo "      --no-emacs         do not update emacs packages"
    echo "      --no-macupdater    do not update with MacUpdater"
    echo "      --no-mas           do not update Apple Store applications"
    echo "      --no-msupdate      do not update Microsoft products"
    echo "      --no-perl          do not update Perl and CPAN modules with Perlbrew"
    echo "      --no-ruby          do not update ruby"
    echo "      --perl             update Perl and CPAN modules with Perlbrew"
    echo "   -q,--quiet            minimal output"
    echo "      --ruby             update ruby"
    echo "   -v,--verbose          verbose output"
    echo
    echo "Report bugs to https://github.com/matteocorti/update.sh/issues"
    echo

}

ALL=1

# source the settings file
if [ -r "${HOME}/.update.sh.rc" ] ; then
    # shellcheck disable=SC1091
    . "${HOME}/.update.sh.rc"
fi

while true; do

    case "$1" in
    --adobe)
        ADOBE=1
        ALL=
        shift
        ;;
    --apple)
        APPLE=1
        ALL=
        shift
        ;;
    --brew)
        BREW=1
        ALL=
        shift
        ;;
    -c | --clear)
        CLEAR=1
        shift
        ;;
    --emacs)
        EMACS=1
        ALL=
        shift
        ;;
    -h | --help | -\?)
        usage
        exit 0
        ;;
    --mas)
        MAS=1
        ALL=
        shift
        ;;
    --macupdater)
        MAC_UPDATER=1
        ALL=
        shift
        ;;
    --msupdate)
        MSUPDATE=1
        ALL=
        shift
        ;;
    -n | --name)
        NAME=$(hostname)
        NAME=" (${NAME})"
        shift
        ;;
    --no-adobe)
        NO_ADOBE=1
        shift
        ;;
    --no-apple)
        NO_APPLE=1
        shift
        ;;
    --no-brew)
        NO_BREW=1
        shift
        ;;
    --no-emacs)
        NO_EMACS=1
        shift
        ;;
    --no-macupdater)
        NO_MAC_UPDATER=1
        shift
        ;;
    --no-mas)
        NO_MAS=1
        shift
        ;;
    --no-msupdate)
        NO_MSUPDATE=1
        shift
        ;;
    --no-perl)
        NO_PERL=1
        shift
        ;;
    --no-ruby)
        NO_RUBY=1
        shift
        ;;
    --perl)
        PERL=1
        ALL=
        shift
        ;;
    --port)
        PORT=1
        ALL=
        shift
        ;;
    -q | --quiet)
        QUIET="1"
        shift
        ;;
    --ruby)
        RUBY=1
        ALL=
        shift
        ;;
    -v | --verbose)
        VERBOSE=1
        echo "Enabling verbose output"
        echo
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

if [ -n "${ALL}" ]; then
    ADOBE=1
    APPLE=1
    BREW=1
    EMACS=1
    MAC_UPDATER=1
    MAS=1
    MSUPDATE=1
    PERL=1
    PORT=1
    RUBY=1
fi

if [ -n "${NO_ADOBE}" ]; then
    ADOBE=
fi
if [ -n "${NO_APPLE}" ]; then
    APPLE=
fi
if [ -n "${NO_BREW}" ]; then
    NO_BREW=
fi
if [ -n "${NO_EMACS}" ]; then
    NO_EMACS=
fi
if [ -n "${NO_MAC_UPDATER}" ]; then
    MAC_UPDATER=
fi
if [ -n "${NO_MAS}" ]; then
    MAS=
fi
if [ -n "${NO_MSUPDATE}" ]; then
    MSUPDATE=
fi
if [ -n "${NO_PERL}" ]; then
    PERL=
fi
if [ -n "${NO_RUBY}" ]; then
    RUBY=
fi

if [ -n "${CLEAR}" ]; then
    clear
fi

if [ -n "${MAC_UPDATER}" ] && [ -x /Applications/MacUpdater.app/Contents/Resources/macupdater_client ]; then

    if [ -z "${QUIET}" ]; then
        echo
        echo "##############################################################################"
        echo "# MacUpdater${NAME}"
        echo "#"
        echo
    fi

    if [ -z "${VERBOSE}" ]; then
        QUIET_OPT="--quiet"
    fi

    run_command "/Applications/MacUpdater.app/Contents/Resources/macupdater_client scan ${QUIET_OPT}"
    run_command "/Applications/MacUpdater.app/Contents/Resources/macupdater_client update ${QUIET_OPT}"

fi

if [ -n "${MSUPDATE}" ] && [ -x /Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate ]; then

    if [ -z "${QUIET}" ]; then
        echo
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

if [ -n "${ADOBE}" ] && [ -x /usr/local/bin/RemoteUpdateManager ]; then

    if [ -z "${QUIET}" ]; then
        echo
        echo "################################################################################"
        echo "# Adobe${NAME}"
        echo "#"
        echo
    fi

    run_command 'sudo /usr/local/bin/RemoteUpdateManager  --action=install'

fi

if [ -n "${APPLE}" ]; then

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
        COMMAND="( sudo softwareupdate --install --all --agree-to-license > /dev/null)  2>&1 | grep -v '^No\ updates\ available$'"
    else
        if [ -n "${VERBOSE}" ]; then
            VERBOSE_OPT="--verbose"
        fi
        COMMAND="sudo softwareupdate --install --all --agree-to-license ${VERBOSE_OPT}"
    fi
    run_command "${COMMAND}"

fi

if [ -n "${MAS}" ]; then

    if command -v mas >/dev/null 2>&1; then

        if [ -z "${QUIET}" ]; then
            echo
            echo "##############################################################################"
            echo "# Apple Store${NAME}"
            echo "#"
            echo
        fi

        # remove color from output
        # https://stackoverflow.com/a/18000433/387981

        if [ -n "${QUIET}" ]; then
            run_command 'mas upgrade 2>&1 | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g" |  grep -v Nothing\ found\ to\ upgrade'
        else
            run_command 'mas upgrade 2>&1 | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g"'
        fi

    fi

fi

if [ -n "${PORT}" ]; then

    if command -v port >/dev/null 2>&1; then

        if [ -z "${QUIET}" ]; then
            echo
            echo "##############################################################################"
            echo "# MacPorts${NAME}"
            echo "#"
            echo
        fi

        if [ -n "${VERBOSE}" ]; then
            VERBOSE_OPT='-v'
        fi

        run_command "sudo port ${VERBOSE_OPT} selfupdate"
        run_command "sudo port ${VERBOSE_OPT} installed outdated"

        if port installed outdated | grep -q -v 'None of the specified ports are installed.'; then

            run_command "sudo port ${VERBOSE_OPT} -N -c -p upgrade outdated"
            run_command "sudo port ${VERBOSE_OPT} -N -u -q -p uninstall"

        fi

    fi

fi

if [ -n "${BREW}" ]; then

    if command -v brew >/dev/null 2>&1; then

        if [ -z "${QUIET}" ]; then
            echo
            echo "##############################################################################"
            echo "# Homebrew${NAME}"
            echo "#"
            echo
        fi

        if [ -n "${VERBOSE}" ]; then
            VERBOSE_OPT='-v'
        fi

        run_command "brew ${VERBOSE_OPT} update"
        run_command "brew ${VERBOSE_OPT} upgrade"

        # Cask
        run_command "brew ${VERBOSE_OPT} upgrade --cask"

        run_command "brew ${VERBOSE_OPT} autoremove"
        run_command "brew ${VERBOSE_OPT} cleanup"

    fi

fi

if [ -n "${EMACS}" ] ; then

    if [ -x /Applications/Emacs.app/Contents/MacOS/emacs-nw ] ; then

        if [ -z "${QUIET}" ]; then
            echo
            echo "##############################################################################"
            echo "# Emacs ${NAME}"
            echo "#"
            echo
        fi

        run_command "/Applications/Emacs.app/Contents/MacOS/emacs-nw -l ~/.emacs --batch -f auto-package-update-now"

    fi

fi


if [ -n "${RUBY}" ] ; then

    if command -v bundle >/dev/null 2>&1; then

        if [ -z "${QUIET}" ]; then
            echo
            echo "##############################################################################"
            echo "# Ruby ${NAME}"
            echo "#"
            echo
        fi

        if [ -n "${VERBOSE}" ]; then
            VERBOSE_OPT='--verbose'
        fi

        run_command "bundle update --no-color ${VERBOSE_OPT}"
        run_command "gem update --system ${VERBOSE_OPT}"
        run_command "gem update ${VERBOSE_OPT}"

    fi

fi

if [ -n "${PERL}" ]; then

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

        if [ -n "${VERBOSE}" ]; then
            VERBOSE_OPT='-v'
        fi

        run_command "perlbrew ${VERBOSE_OPT} self-upgrade"

        for version in $(perlbrew list | sed 's/[* ]*\([^ ]*\).*/\1/'); do

            run_command "perlbrew ${VERBOSE_OPT} use ${version}"
            run_command "perlbrew ${VERBOSE_OPT} upgrade-perl"

            COMMAND=$(command -v cpan-outdated)
            if [ -n "${COMMAND}" ]; then

                LIST=$(cpan-outdated -p --exclude-core | tr '\n' ' ')

                if [ -n "${LIST}" ]; then

                    if [ -n "${VERBOSE}" ]; then
                        VERBOSE_OPT='-v'
                    fi

                    run_command "cpanm ${VERBOSE_OPT} ${LIST}"

                fi

            fi

        done

    fi

fi

if [ -z "${QUIET}" ]; then
    echo
fi
