
#!/bin/sh -
#======================================================================================================================
# vim: softtabstop=4 shiftwidth=4 expandtab fenc=utf-8 spell spelllang=en cc=120
#======================================================================================================================
#
#          FILE: bootstrap-cs.sh
#
#   DESCRIPTION: Bootstrap Contentserv installation for various systems/distributions
#
#          BUGS: https://contentserv.atlassian.net/issues
#
#     COPYRIGHT: (c) 2017 by Contentserv GmbH
#
#        AUTHOR: Chaitanya Kore
#       LICENSE: Proprietary
#  ORGANIZATION: Contentserv GmbH (contentserv.com)
#       CREATED: 07/08/2017 09:49:37 AM CET
#======================================================================================================================
set -o nounset                              # Treat unset variables as an error

# Bootstrap script truth values
BS_TRUE=1
BS_FALSE=0

__ScriptVersion="0.2.10"
__ScriptName="bootstrap-cs.sh"

__ScriptFullName="$0"
__ScriptArgs="$*"

# Default sleep time used when waiting for daemons to start, restart and checking for these running
__DEFAULT_SLEEP=3




#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __detect_color_support
#   DESCRIPTION:  Try to detect color support.
#----------------------------------------------------------------------------------------------------------------------
_COLORS=${BS_COLORS:-$(tput colors 2>/dev/null || echo 0)}
__detect_color_support() {
    if [ $? -eq 0 ] && [ "$_COLORS" -gt 2 ]; then
        RC="\033[1;31m"
        GC="\033[1;32m"
        BC="\033[1;34m"
        YC="\033[1;33m"
        EC="\033[0m"
    else
        RC=""
        GC=""
        BC=""
        YC=""
        EC=""
    fi
}
__detect_color_support

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echoerr
#   DESCRIPTION:  Echo errors to stderr.
#----------------------------------------------------------------------------------------------------------------------
echoerror() {
    printf "${RC} * ERROR${EC}: %s\n" "$@" 1>&2;
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echoinfo
#   DESCRIPTION:  Echo information to stdout.
#----------------------------------------------------------------------------------------------------------------------
echoinfo() {
    printf "${GC} *  INFO${EC}: %s\n" "$@";
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echowarn
#   DESCRIPTION:  Echo warning informations to stdout.
#----------------------------------------------------------------------------------------------------------------------
echowarn() {
    printf "${YC} *  WARN${EC}: %s\n" "$@";
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echodebug
#   DESCRIPTION:  Echo debug information to stdout.
#----------------------------------------------------------------------------------------------------------------------
echodebug() {
    if [ "$_ECHO_DEBUG" -eq $BS_TRUE ]; then
        printf "${BC} * DEBUG${EC}: %s\n" "$@";
    fi
}


#----------------------------------------------------------------------------------------------------------------------
#  Handle command line arguments
#----------------------------------------------------------------------------------------------------------------------
_CS_APT_REPO_URL="https://apt.contentserv.com/"

_CS_ENABLE_UNSTABLE=$BS_FALSE
_CS_ENABLE_TESTING=$BS_FALSE
_CS_COMPONENTS_DEFAULT="cs-main cs-3rdparty cs-backports"
_CS_COMPONENT_UNSTABLE="cs-unstable"
_CS_COMPONENT_TESTING="cs-testing"
_CS_RELEASE=""


_TOTAL_CLEANUP=$BS_FALSE

_SLEEP="${__DEFAULT_SLEEP}"
_INSTALL_CS_CORE=$BS_TRUE
_INSTALL_CS_LIVE=$BS_FALSE
_INSTALL_CS_DOCS=$BS_FALSE
_INSTALL_CS_DEV=$BS_FALSE
_INSTALL_CS_SVN=$BS_TRUE
_CS_BLANK_NAME=""
_ACTIVATE_CS_LIVE=$BS_FALSE
_SERVER_TYPE=$BS_TRUE
_CS_ENV=""
_CS_SET_ENV=$BS_FALSE
_INSTALL_MARIADB=$BS_FALSE
_INSTALL_MYSQL=$BS_FALSE
_INSTALL_LOCAL_DB_SERVER=$BS_FALSE

_START_DAEMONS=$BS_FALSE

_CONFIGURE_CS_AS_ALIAS=$BS_FALSE
_CS_ALIAS=""
_CONFIGURE_CS_AS_VHOST=$BS_FALSE
_CS_VHOST=""

_DB_PASS=""
_DB_ROOT_PASS=""
_DB_USER="root"
_DB_HOST="localhost"
_DB_PREFIX="cs_"
_DB_NAME="contentserv"

_ECHO_DEBUG=${BS_ECHO_DEBUG:-$BS_FALSE}
_CURL_ARGS=${BS_CURL_ARGS:-}
_EXTRA_PACKAGES=""
_HTTP_PROXY=""

_APT_USERNAME=""
_APT_PASSWORD=""

_APT_MARIADB_LIST_FILE=/etc/apt/sources.list.d/mariadb-cs.list
_APT_MYSQL_LIST_FILE=/etc/apt/sources.list.d/mysql-cs.list
#_MARIADB_VERSION=10.1
_MYSQL_VERSION=5.7

_APT_CS_LIST_FILE=/etc/apt/sources.list.d/contentserv.list

_SUPERVISORD_EE_CONF=/etc/supervisor/conf.d/cs-ee.conf
_SUPERVISORD_CASSANDRA_CONF=/etc/supervisor/conf.d/cs-cassandra.conf
_SUPERVISORD_ELASTICSEARCH_CONF=/etc/supervisor/conf.d/cs-elasticsearch.conf

_CS_EE_STARTUP_SCRIPT="/var/lib/contentserv-cs/admin/core/extensions/exportstaging/java/dist/ExportExecutorNG.sh"


_CS_MARIADB_VERSION=""


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __gather_os_info
#   DESCRIPTION:  Discover operatingf system information
#----------------------------------------------------------------------------------------------------------------------
__gather_os_info() {
    OS_NAME=$(uname -s 2>/dev/null)
    OS_NAME_L=$( echo "$OS_NAME" | tr '[:upper:]' '[:lower:]' )
    OS_KERNEL_VERSION=$(uname -r)
    # shellcheck disable=SC2034
    OS_KERNEL_VERSION_L=$( echo "$OS_KERNEL_VERSION" | tr '[:upper:]' '[:lower:]' )
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __parse_version_string
#   DESCRIPTION:  Parse version strings ignoring the revision.
#                 MAJOR.MINOR.REVISION becomes MAJOR.MINOR
#----------------------------------------------------------------------------------------------------------------------
__parse_version_string() {
    VERSION_STRING="$1"
    PARSED_VERSION=$(
        echo "$VERSION_STRING" |
        sed -e 's/^/#/' \
            -e 's/^#[^0-9]*\([0-9][0-9]*\.[0-9][0-9]*\)\(\.[0-9][0-9]*\).*$/\1/' \
            -e 's/^#[^0-9]*\([0-9][0-9]*\.[0-9][0-9]*\).*$/\1/' \
            -e 's/^#[^0-9]*\([0-9][0-9]*\).*$/\1/' \
            -e 's/^#.*$//'
    )
    echo "$PARSED_VERSION"
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __derive_debian_numeric_version
#   DESCRIPTION:  Derive the numeric version from a Debian version string.
#----------------------------------------------------------------------------------------------------------------------
__derive_debian_numeric_version() {
    NUMERIC_VERSION=""
    INPUT_VERSION="$1"
    if echo "$INPUT_VERSION" | grep -q '^[0-9]'; then
        NUMERIC_VERSION="$INPUT_VERSION"
    elif [ -z "$INPUT_VERSION" ] && [ -f "/etc/debian_version" ]; then
        INPUT_VERSION="$(cat /etc/debian_version)"
    fi
    if [ -z "$NUMERIC_VERSION" ]; then
        if [ "$INPUT_VERSION" = "wheezy/sid" ]; then
            # I've found an EC2 wheezy image which did not tell its version
            NUMERIC_VERSION=$(__parse_version_string "7.0")
        elif [ "$INPUT_VERSION" = "jessie/sid" ]; then
            NUMERIC_VERSION=$(__parse_version_string "8.0")
        elif [ "$INPUT_VERSION" = "stretch/sid" ]; then
            # Let's start detecting the upcoming Debian 9 (Stretch)
            NUMERIC_VERSION=$(__parse_version_string "9.0")
        else
            echowarn "Unable to parse the Debian Version (codename: '$INPUT_VERSION')"
        fi
    fi
    echo "$NUMERIC_VERSION"
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __unquote_string
#   DESCRIPTION:  Strip single or double quotes from the provided string.
#----------------------------------------------------------------------------------------------------------------------
__unquote_string() {
    echo "$*" | sed -e "s/^\([\"\']\)\(.*\)\1\$/\2/g"
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __camelcase_split
#   DESCRIPTION:  Convert 'CamelCased' strings to 'Camel Cased'
#----------------------------------------------------------------------------------------------------------------------
__camelcase_split() {
    echo "$*" | sed -e 's/\([^[:upper:][:punct:]]\)\([[:upper:]]\)/\1 \2/g'
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __strip_duplicates
#   DESCRIPTION:  Strip duplicate strings
#----------------------------------------------------------------------------------------------------------------------
__strip_duplicates() {
    echo "$*" | tr -s '[:space:]' '\n' | awk '!x[$0]++'
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __sort_release_files
#   DESCRIPTION:  Custom sort function. Alphabetical or numerical sort is not
#                 enough.
#----------------------------------------------------------------------------------------------------------------------
__sort_release_files() {
    KNOWN_RELEASE_FILES=$(echo "(arch|alpine|centos|debian|ubuntu|fedora|redhat|suse|\
        mandrake|mandriva|gentoo|slackware|turbolinux|unitedlinux|void|lsb|system|\
        oracle|os)(-|_)(release|version)" | sed -r 's:[[:space:]]::g')
    primary_release_files=""
    secondary_release_files=""
    # Sort know VS un-known files first
    for release_file in $(echo "${@}" | sed -r 's:[[:space:]]:\n:g' | sort -f | uniq); do
        match=$(echo "$release_file" | egrep -i "${KNOWN_RELEASE_FILES}")
        if [ "${match}" != "" ]; then
            primary_release_files="${primary_release_files} ${release_file}"
        else
            secondary_release_files="${secondary_release_files} ${release_file}"
        fi
    done

    # Now let's sort by know files importance, max important goes last in the max_prio list
    max_prio="redhat-release centos-release oracle-release"
    for entry in $max_prio; do
        if [ "$(echo "${primary_release_files}" | grep "$entry")" != "" ]; then
            primary_release_files=$(echo "${primary_release_files}" | sed -e "s:\(.*\)\($entry\)\(.*\):\2 \1 \3:g")
        fi
    done
    # Now, least important goes last in the min_prio list
    min_prio="lsb-release"
    for entry in $min_prio; do
        if [ "$(echo "${primary_release_files}" | grep "$entry")" != "" ]; then
            primary_release_files=$(echo "${primary_release_files}" | sed -e "s:\(.*\)\($entry\)\(.*\):\1 \3 \2:g")
        fi
    done

    # Echo the results collapsing multiple white-space into a single white-space
    echo "${primary_release_files} ${secondary_release_files}" | sed -r 's:[[:space:]]+:\n:g'
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __gather_linux_system_info
#   DESCRIPTION:  Discover Linux system information
#----------------------------------------------------------------------------------------------------------------------
__gather_linux_system_info() {
    DISTRO_NAME=""
    DISTRO_VERSION=""

    # Detect CPU Architecture
    CPU_ARCH=$(uname -m 2>/dev/null)

    # Let's test if the lsb_release binary is available
    rv=$(lsb_release >/dev/null 2>&1)
    if [ $? -eq 0 ]; then
        DISTRO_NAME=$(lsb_release -si)
        if [ "${DISTRO_NAME}" = "Scientific" ]; then
            DISTRO_NAME="Scientific Linux"
        elif [ "$(echo "$DISTRO_NAME" | grep ^CloudLinux)" != "" ]; then
            DISTRO_NAME="Cloud Linux"
        elif [ "$(echo "$DISTRO_NAME" | grep ^RedHat)" != "" ]; then
            # Let's convert 'CamelCased' to 'Camel Cased'
            n=$(__camelcase_split "$DISTRO_NAME")
            # Skip setting DISTRO_NAME this time, splitting CamelCase has failed.
            # See https://github.com/saltstack/salt-bootstrap/issues/918
            [ "$n" = "$DISTRO_NAME" ] && DISTRO_NAME="" || DISTRO_NAME="$n"
        elif [ "${DISTRO_NAME}" = "openSUSE project" ]; then
            # lsb_release -si returns "openSUSE project" on openSUSE 12.3
            DISTRO_NAME="opensuse"
        elif [ "${DISTRO_NAME}" = "SUSE LINUX" ]; then
            if [ "$(lsb_release -sd | grep -i opensuse)" != "" ]; then
                # openSUSE 12.2 reports SUSE LINUX on lsb_release -si
                DISTRO_NAME="opensuse"
            else
                # lsb_release -si returns "SUSE LINUX" on SLES 11 SP3
                DISTRO_NAME="suse"
            fi
        elif [ "${DISTRO_NAME}" = "EnterpriseEnterpriseServer" ]; then
            # This the Oracle Linux Enterprise ID before ORACLE LINUX 5 UPDATE 3
            DISTRO_NAME="Oracle Linux"
        elif [ "${DISTRO_NAME}" = "OracleServer" ]; then
            # This the Oracle Linux Server 6.5
            DISTRO_NAME="Oracle Linux"
        elif [ "${DISTRO_NAME}" = "AmazonAMI" ]; then
            DISTRO_NAME="Amazon Linux AMI"
        elif [ "${DISTRO_NAME}" = "ManjaroLinux" ]; then
            DISTRO_NAME="Arch Linux"
        elif [ "${DISTRO_NAME}" = "Arch" ]; then
            DISTRO_NAME="Arch Linux"
            return
        fi
        rv=$(lsb_release -sr)
        [ "${rv}" != "" ] && DISTRO_VERSION=$(__parse_version_string "$rv")
    elif [ -f /etc/lsb-release ]; then
        # We don't have the lsb_release binary, though, we do have the file it parses
        DISTRO_NAME=$(grep DISTRIB_ID /etc/lsb-release | sed -e 's/.*=//')
        rv=$(grep DISTRIB_RELEASE /etc/lsb-release | sed -e 's/.*=//')
        [ "${rv}" != "" ] && DISTRO_VERSION=$(__parse_version_string "$rv")
    fi

    if [ "$DISTRO_NAME" != "" ] && [ "$DISTRO_VERSION" != "" ]; then
        # We already have the distribution name and version
        return
    fi
    # shellcheck disable=SC2035,SC2086
    for rsource in $(__sort_release_files "$(
            cd /etc && /bin/ls *[_-]release *[_-]version 2>/dev/null | env -i sort | \
            sed -e '/^redhat-release$/d' -e '/^lsb-release$/d'; \
            echo redhat-release lsb-release
            )"); do

        [ -L "/etc/${rsource}" ] && continue        # Don't follow symlinks
        [ ! -f "/etc/${rsource}" ] && continue      # Does not exist

        n=$(echo "${rsource}" | sed -e 's/[_-]release$//' -e 's/[_-]version$//')
        shortname=$(echo "${n}" | tr '[:upper:]' '[:lower:]')
        if [ "$shortname" = "debian" ]; then
            rv=$(__derive_debian_numeric_version "$(cat /etc/${rsource})")
        else
            rv=$( (grep VERSION "/etc/${rsource}"; cat "/etc/${rsource}") | grep '[0-9]' | sed -e 'q' )
        fi
        [ "${rv}" = "" ] && [ "$shortname" != "arch" ] && continue  # There's no version information. Continue to next rsource
        v=$(__parse_version_string "$rv")
        case $shortname in
            redhat             )
                if [ "$(egrep 'CentOS' /etc/${rsource})" != "" ]; then
                    n="CentOS"
                elif [ "$(egrep 'Scientific' /etc/${rsource})" != "" ]; then
                    n="Scientific Linux"
                elif [ "$(egrep 'Red Hat Enterprise Linux' /etc/${rsource})" != "" ]; then
                    n="<R>ed <H>at <E>nterprise <L>inux"
                else
                    n="<R>ed <H>at <L>inux"
                fi
                ;;
            arch               ) n="Arch Linux"     ;;
            alpine             ) n="Alpine Linux"   ;;
            centos             ) n="CentOS"         ;;
            debian             ) n="Debian"         ;;
            ubuntu             ) n="Ubuntu"         ;;
            fedora             ) n="Fedora"         ;;
            suse               ) n="SUSE"           ;;
            mandrake*|mandriva ) n="Mandriva"       ;;
            gentoo             ) n="Gentoo"         ;;
            slackware          ) n="Slackware"      ;;
            turbolinux         ) n="TurboLinux"     ;;
            unitedlinux        ) n="UnitedLinux"    ;;
            void               ) n="VoidLinux"      ;;
            oracle             ) n="Oracle Linux"   ;;
            system             )
                while read -r line; do
                    [ "${n}x" != "systemx" ] && break
                    case "$line" in
                        *Amazon*Linux*AMI*)
                            n="Amazon Linux AMI"
                            break
                    esac
                done < "/etc/${rsource}"
                ;;
            os                 )
                nn="$(__unquote_string "$(grep '^ID=' /etc/os-release | sed -e 's/^ID=\(.*\)$/\1/g')")"
                rv="$(__unquote_string "$(grep '^VERSION_ID=' /etc/os-release | sed -e 's/^VERSION_ID=\(.*\)$/\1/g')")"
                [ "${rv}" != "" ] && v=$(__parse_version_string "$rv") || v=""
                case $(echo "${nn}" | tr '[:upper:]' '[:lower:]') in
                    alpine      )
                        n="Alpine Linux"
                        v="${rv}"
                        ;;
                    amzn        )
                        # Amazon AMI's after 2014.09 match here
                        n="Amazon Linux AMI"
                        ;;
                    arch        )
                        n="Arch Linux"
                        v=""  # Arch Linux does not provide a version.
                        ;;
                    cloudlinux  )
                        n="Cloud Linux"
                        ;;
                    debian      )
                        n="Debian"
                        v=$(__derive_debian_numeric_version "$v")
                        ;;
                    sles        )
                        n="SUSE"
                        v="${rv}"
                        ;;
                    *           )
                        n=${nn}
                        ;;
                esac
                ;;
            *                  ) n="${n}"           ;
        esac
        DISTRO_NAME=$n
        DISTRO_VERSION=$v
        break
    done
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __gather_debian_codename
#   DESCRIPTION:  Map Distro Version to unique codename (works for Ubuntu and Debian)
#----------------------------------------------------------------------------------------------------------------------
__gather_debian_codename() {
    case $DISTRO_NAME in
        Ubuntu )
            case $DISTRO_VERSION in
                "12.04" )       DISTRO_CODENAME="precise"
                                DISTRO_CODENAME_FULL="Precise Pangolin"
                                ;;
                "14.04" )       DISTRO_CODENAME="trusty"
                                DISTRO_CODENAME_FULL="Trusty Tahr"
                                ;;
                "16.04" )       DISTRO_CODENAME="xenial"
                                DISTRO_CODENAME_FULL="Xenial Xerus"
                                ;;
                "16.10" )       DISTRO_CODENAME="yakkety"
                                DISTRO_CODENAME_FULL="Yakkety Yak"
                                ;;
                "17.04" )       DISTRO_CODENAME="zesty"
                                DISTRO_CODENAME_FULL="Zesty Zapus"
                                ;;
                "18.04" )        DISTRO_CODENAME="bionic"
                                DISTRO_CODENAME_FULL="Bionic Beaver"
                                ;;            
esac
            ;;
        Debian )
            case $DISTRO_VERSION in
                7* )            DISTRO_CODENAME="wheezy"
                                DISTRO_CODENAME_FULL="Wheezy"
                                ;;
                8* )            DISTRO_CODENAME="jessie"
                                DISTRO_CODENAME_FULL="Jessie"
                                ;;
                9* )            DISTRO_CODENAME="stretch"
                                DISTRO_CODENAME_FULL="Stretch"
                                ;;
            esac
            ;;
    esac
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __install_system_tools
#  DESCRIPTION:  Install platform-dependent essential system tools
#----------------------------------------------------------------------------------------------------------------------
__install_system_tools() {
    echodebug "System tools installation"
    if [ "$DISTRO_NAME" = "Ubuntu" ] || [ "$DISTRO_NAME" = "Debian" ]; then
        echodebug "System tools installation for Ubuntu/Debian"
        apt-get -y update
        if ! apt-get -y install debconf debconf-utils python-pip curl apache2 apt-transport-https supervisor sed; then
            echoerror "Unable to install essential system packages"
            exit 1
        fi
        echodebug "Bringing supervisord up"
        service supervisor start
    fi
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __install_extra_tools
#  DESCRIPTION:  Install system tools from non-OS sources (such as Python-pip, php PEAR/PECL, etc.)
#----------------------------------------------------------------------------------------------------------------------
__install_extra_tools() {
    echodebug "Additional non-system tools installation"
    echodebug "PIP installation(s)"
    if ! pip install crudini; then
        echoerror "Unable to install additional packages/tool"
        exit 1
    fi
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __install_db_components
#  DESCRIPTION:  Install DB client, activating platform-dependent repositories
#----------------------------------------------------------------------------------------------------------------------
__install_db_components() {
    echodebug "DB client installation"
    if [ "$DISTRO_NAME" = "Ubuntu" ] || [ "$DISTRO_NAME" = "Debian" ]; then
        echodebug "DB client installation for Ubuntu/Debian"
        if [ "$_INSTALL_MYSQL" -eq $BS_TRUE ]; then
            if ! [ "$DISTRO_CODENAME" = "xenial" ]; then
                echodebug "Activating MySQL upstream repository for distros except xenial"
                echodebug "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5072E1F5"
                apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5072E1F5
                echodebug "deb http://repo.mysql.com/apt/$DISTRO_NAME_LOWER/ $DISTRO_CODENAME mysql-5.7"
                echo "deb http://repo.mysql.com/apt/$DISTRO_NAME_LOWER/ $DISTRO_CODENAME mysql-5.7" >$_APT_MYSQL_LIST_FILE
            fi
            apt-get -y update
            apt-get -y install mysql-client-${_MYSQL_VERSION}
        fi
        if [ "$_INSTALL_MARIADB" -eq $BS_TRUE ]; then
            echodebug "Activating MariaDB upstream repository"
            echodebug "apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8"
            apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xF1656F24C74CD1D8
            if [ "$_CS_RELEASE" = "18.0" ]; then
	    _CS_MARIADB_VERSION=$(__parse_version_string "10.3")
	    elif [ "$_CS_RELEASE" = "17.0" ]; then 	    
	    _CS_MARIADB_VERSION=$(__parse_version_string "10.1")
            fi
	    echodebug "deb http://ftp.hosteurope.de/mirror/mariadb.org/repo/$_CS_MARIADB_VERSION/$DISTRO_NAME_LOWER $DISTRO_CODENAME main"
            echo "deb [arch=amd64] http://ftp.hosteurope.de/mirror/mariadb.org/repo/$_CS_MARIADB_VERSION/$DISTRO_NAME_LOWER $DISTRO_CODENAME main" >$_APT_MARIADB_LIST_FILE
            apt-get -y update
            apt-get -y install mariadb-client-${_CS_MARIADB_VERSION}
        fi

    fi
echo "install db"

    if [ "$_INSTALL_LOCAL_DB_SERVER" -eq $BS_TRUE ] ; then
        echodebug "Installing local DB Server"
        if [ "$_INSTALL_MYSQL" -eq $BS_TRUE ]; then
            echo "mysql"
	    apt-get -y update
            apt-get -y install mysql-server-${_MYSQL_VERSION}
        elif [ "$_INSTALL_MARIADB" -eq $BS_TRUE ]; then
            echo "mariadb"
	    apt-get -y update
            apt-get -y install mariadb-server-${_CS_MARIADB_VERSION}
        fi
    fi
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __configure_cs_apt_repo
#  DESCRIPTION:  Configure APT repository for Contentserv-CS and third-party packages
#----------------------------------------------------------------------------------------------------------------------
__configure_cs_apt_repo() {
    echodebug "Contentserv proprietary APT repo setup"

    _CS_COMPONENTS="$_CS_COMPONENTS_DEFAULT"

    if [ "$_CS_ENABLE_UNSTABLE" -eq $BS_TRUE ]; then
        echodebug "Add unstable component to the repo configuration string"
        _CS_COMPONENTS="$_CS_COMPONENTS $_CS_COMPONENT_UNSTABLE"
    fi

    if [ "$_CS_ENABLE_TESTING" -eq $BS_TRUE ]; then
        echodebug "Add testing component to the repo configuration string (development/testing feature, functionality not guaranteed!)"
        _CS_COMPONENTS="$_CS_COMPONENTS $_CS_COMPONENT_TESTING"
    fi


    echodebug "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 1D6B9779"
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 1D6B9779

    while [ "$_APT_USERNAME" = "" ]; do
        printf "Enter APT repository username (cannot be empty): "
        read _APT_USERNAME
    done

    while [ "$_APT_PASSWORD" = "" ]; do
        stty -echo
        printf "Enter APT repository password (cannot be empty, will not echo): "
        read _APT_PASSWORD
        stty echo
        printf "\n"
    done

    echodebug "deb https://\"${_APT_USERNAME}\":\"********\"@apt.contentserv.com/ $DISTRO_CODENAME $_CS_COMPONENTS"
    echo "deb https://\"${_APT_USERNAME}\":\"${_APT_PASSWORD}\"@apt.contentserv.com/ $DISTRO_CODENAME $_CS_COMPONENTS" >$_APT_CS_LIST_FILE
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __password_wipe_cs_apt_repo
#  DESCRIPTION:  Removing stoted password from the list file for Contentserv-CS APT repository
#----------------------------------------------------------------------------------------------------------------------
__password_wipe_cs_apt_repo() {
    echodebug "Removing stored password from the list file for Contentserv-CS APT repository and disabling the entry"
    echo "# deb https://\"******\":\"******\"@apt.contentserv.com/ $DISTRO_CODENAME $_CS_COMPONENTS" >$_APT_CS_LIST_FILE
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __activate_java_daemons
#  DESCRIPTION:  Tweaks installed supervisord java daemon config files to enable autostart
#----------------------------------------------------------------------------------------------------------------------
__activate_java_daemons() {
    echodebug "Tweaking supervisord daemon config files and starting java daemons"
    sed -i -e "s#^\(\s*autostart\).*#\1=true#g" ${_SUPERVISORD_ELASTICSEARCH_CONF}
    sed -i -e "s#^\(\s*autostart\).*#\1=true#g" ${_SUPERVISORD_EE_CONF}
    sed -i -e "s#^\(\s*autostart\).*#\1=true#g" ${_SUPERVISORD_CASSANDRA_CONF}
    supervisorctl update all
    supervisorctl start all
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __preseed_debconf_values
#  DESCRIPTION:  Preseed all possible default and collected values to minimize manual input during install
#----------------------------------------------------------------------------------------------------------------------
__preseed_debconf_values() {
    echodebug "Preseeding debconf for contentserv-cs-core package..."

    if [ "$_INSTALL_LOCAL_DB_SERVER" -eq $BS_TRUE ] ; then
        echodebug "Set DB server name to localhost"
        echo "contentserv-cs-core contentserv-cs-core/db_host string localhost" | debconf-set-selections
    fi


if [ "$_CONFIGURE_CS_AS_VHOST" -eq $BS_FALSE ] && [ "$_CONFIGURE_CS_AS_ALIAS" -eq $BS_FALSE ]; then
        echodebug "No options selected, Sodefault vhost will be configured"
        echo "contentserv-cs-core contentserv-cs-core/installation_type select default-vhost" | debconf-set-selections
        echo "contentserv-cs-live contentserv-cs-live/activate_cslive boolean true" | debconf-set-selections
    else
        echodebug "Activating CS in apache config"
        if [ "$_CONFIGURE_CS_AS_VHOST" -eq $BS_TRUE ]; then
            echodebug "Setting CS as Apache vhost: $_CS_VHOST"
            echo "contentserv-cs-core contentserv-cs-core/installation_type select vhost" | debconf-set-selections
            echo "contentserv-cs-core contentserv-cs-core/app_vhost string $_CS_VHOST" | debconf-set-selections
        fi

        if [ "$_CONFIGURE_CS_AS_ALIAS" -eq $BS_TRUE ]; then
            echodebug "Setting CS as Apache alias: /$_CS_ALIAS"
            echo "contentserv-cs-core contentserv-cs-core/installation_type select alias" | debconf-set-selections
            echo "contentserv-cs-core contentserv-cs-core/app_subfolder string $_CS_ALIAS" | debconf-set-selections
        fi
fi
   
        if ! [ "$_CS_BLANK_NAME" = "" ]; then
            echodebug "Creating blank project: $_CS_BLANK_NAME"
            echo "contentserv-cs-core contentserv-cs-core/create_new_project boolean true" | debconf-set-selections
            echo "contentserv-cs-core contentserv-cs-core/project_name string $_CS_BLANK_NAME" | debconf-set-selections

            if ! [ "$_DB_HOST" = "" ]; then
                echodebug "Setting DB host for the blank project: $_DB_HOST"
                echo "contentserv-cs-core contentserv-cs-core/db_host string $_DB_HOST" | debconf-set-selections
            fi

            if ! [ "$_DB_NAME" = "" ]; then
                echodebug "Setting DB name for the blank project: $_DB_NAME"
                echo "contentserv-cs-core contentserv-cs-core/db_name string $_DB_NAME" | debconf-set-selections
            fi

            if ! [ "$_DB_PREFIX" = "" ]; then
                echodebug "Setting DB table prefix for the blank project: $_DB_PREFIX"
                echo "contentserv-cs-core contentserv-cs-core/db_table_prefix string $_DB_PREFIX" | debconf-set-selections
            fi

            if ! [ "$_DB_USER" = "" ]; then
                echodebug "Setting DB user for the blank project: $_DB_USER"
                echo "contentserv-cs-core contentserv-cs-core/db_user string $_DB_USER" | debconf-set-selections
            fi

            if ! [ "$_DB_PASS" = "" ]; then
                echodebug "Setting DB password for the blank project..."
                echo "contentserv-cs-core contentserv-cs-core/db_password password $_DB_PASS" | debconf-set-selections
                echo "contentserv-cs-core contentserv-cs-core/db_password_again password $_DB_PASS" | debconf-set-selections
            fi
        else
            echo "contentserv-cs-core contentserv-cs-core/create_new_project boolean false" | debconf-set-selections
        fi
       
        if [ "$_ACTIVATE_CS_LIVE" -eq $BS_TRUE ]; then
            echodebug "Activating demo project: CSLive"

            echo "contentserv-cs-live contentserv-cs-live/activate_cslive boolean true" | debconf-set-selections

            if ! [ "$_DB_HOST" = "" ]; then
                echodebug "Setting DB host for CSLive demo project: $_DB_HOST"
                echo "contentserv-cs-live contentserv-cs-live/db_host string $_DB_HOST" | debconf-set-selections
            fi

            if ! [ "$_DB_NAME" = "" ]; then
                echodebug "Setting DB name for CSLive demo project: $_DB_NAME"
                echo "contentserv-cs-live contentserv-cs-live/db_name string $_DB_NAME" | debconf-set-selections
            fi

            if ! [ "$_DB_PREFIX" = "" ]; then
                echodebug "Setting DB table prefix for CSLive demo project: $_DB_PREFIX"
                echo "contentserv-cs-live contentserv-cs-live/db_table_prefix string $_DB_PREFIX" | debconf-set-selections
            fi

            if ! [ "$_DB_USER" = "" ]; then
                echodebug "Setting DB user for CSLive demo project: $_DB_USER"
                echo "contentserv-cs-live contentserv-cs-live/db_user string $_DB_USER" | debconf-set-selections
            fi

            if ! [ "$_DB_PASS" = "" ]; then
                echodebug "Setting DB password for CSLive demo project..."
                echo "contentserv-cs-live contentserv-cs-live/db_password password $_DB_PASS" | debconf-set-selections
                echo "contentserv-cs-live contentserv-cs-live/db_password_again password $_DB_PASS" | debconf-set-selections
            fi
        else
            echo "contentserv-cs-live contentserv-cs-live/activate_cslive boolean false" | debconf-set-selections
        fi



    echodebug "Preseeding debconf for MySQL/MariaDB local server package..."

    if ! [ "$_DB_ROOT_PASS" = "" ]; then
        echo "mysql-server mysql-server/root_password password $_DB_ROOT_PASS" | debconf-set-selections
        echo "mysql-server mysql-server/root_password_again password $_DB_ROOT_PASS" | debconf-set-selections
    fi

}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __do_cs_install
#  DESCRIPTION:  Proceed to actual Contentserv-CS installation
#----------------------------------------------------------------------------------------------------------------------
__do_cs_install() {

    apt-get -y update

    _CS_PKG_PREFIX="contentserv-cs${_CS_RELEASE}"
    echodebug "CS core installation (mandatory)"

    apt-get install -y software-properties-common
    add-apt-repository -y  ppa:ondrej/php
    apt-get -y update

    if ! apt-get -y install ${_CS_PKG_PREFIX}-core --allow-unauthenticated ; then
        echoerror "CS-Core install failed"
        __password_wipe_cs_apt_repo
        exit 1
    fi

    if [ "$_INSTALL_LOCAL_DB_SERVER" -eq $BS_TRUE ] ; then
        echodebug "Enforce MySQL/MariaDB server restart"
        service mysql restart
    fi

    echodebug "CS optional components installation"


 if [ "$_INSTALL_CS_SVN" -eq $BS_TRUE ] ; then
	if ! apt-get -y install ${_CS_PKG_PREFIX}-svn --allow-unauthenticated ; then
            echoerror "CS-svn install failed"
            __password_wipe_cs_apt_repo
            exit 1
        fi
    
      elif [ "$_INSTALL_CS_LIVE" -eq $BS_TRUE ] ; then
        if ! apt-get -y install ${_CS_PKG_PREFIX}-live ; then
               echoerror "CSLive install failed"
          __password_wipe_cs_apt_repo
           exit 1
      fi 



   elif [ "$_INSTALL_CS_DOCS" -eq $BS_TRUE ] ; then
        if ! apt-get -y install ${_CS_PKG_PREFIX}-docs --allow-unauthenticated ; then
            echoerror "CS-Docs install failed"
            __password_wipe_cs_apt_repo
            exit 1
        fi
    
   elif [ "$_INSTALL_CS_DEV" -eq $BS_TRUE ] ; then
        if ! apt-get -y install ${_CS_PKG_PREFIX}-dev --allow-unauthenticated ; then
            echoerror "CS-Dev install failed"
            __password_wipe_cs_apt_repo
            exit 1
        fi   
 fi 

    __password_wipe_cs_apt_repo

}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __do_total_cleanup
#  DESCRIPTION:  Totally wipes all Contentserv-CS components from the system with all dependencies
#----------------------------------------------------------------------------------------------------------------------
__do_total_cleanup() {
    echodebug "Proceeding to total cleanup..."
    supervisorctl stop all
    if [ -x "$_CS_EE_STARTUP_SCRIPT" ];
    then
        echodebug "Stopping contentserv-cs background services..."
        if [ "$_ECHO_DEBUG" -eq $BS_TRUE ]; then
            CS_ENABLE_DEBUG=true
            export CS_ENABLE_DEBUG
        fi
        $_CS_EE_STARTUP_SCRIPT stop
    fi
    apt-get -y purge contentserv-cs* mysql-server* mysql-client* mysql-server-core* mysql-common* mariadb* libmysqlclient* libdbd-mysql-perl libqt4-sql-mysql
    rm -rf /var/lib/contentserv-cs/ /var/lib/mysql /etc/mysql/ /etc/supervisor/conf.d/cs-*
    echo PURGE | debconf-communicate contentserv-cs-core
    echo PURGE | debconf-communicate contentserv-cs-live
    echo PURGE | debconf-communicate mysql-server
    apt-get -y autoremove
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __usage
#  DESCRIPTION:  Display usage information.
#----------------------------------------------------------------------------------------------------------------------
__usage() {
    cat << EOT

  Usage :  ${__ScriptName} <-A|-M> [option2] [args] [option3] [args] ...

  At least one option is necessary: either -A or -M

  Examples:
    - ${__ScriptName} -A
    - ${__ScriptName} -M -S
    - ${__ScriptName} -A -H 'my-dbhost' -b 'my-csdb' -v 'csvhost.myhost.mydomain'

  Options:
    -h  Display this message
    -V  Display bootstrap script version
    -n  Disable colors
    -D  Enable debug output
    -A  Install MariaDB client (conflicts with -M)
    -E  Set CS Environment eg prod, test, dev
    -M  Install MySQL client (conflicts with -A)
    -S  Install DB server locally (either MariaDB or MySQL, depending on -A or -M option)
    -Q  Set the root user password for the locally installed MySQL/MariaDB server
        works only for fresh MySQL/MariaDB installation, will be ignored if the server is
        already installed or option -S not set
    -d  Configure Apache to run Contentserv under alias (or Application direcrory, e.g. http://myhost/contentserv)
        the name should be provided as an argument
    -v  Configure Apache to run Contentserv as vhost (vhost name should be provided as an argument)
    -e  Enable autostart of Export Module and locally configured Elasticsearch and Cassandra.
        Should be used only in combination with CSLive demo project activation
    -l  Install CSLive demo project
    -i  Install Contentserv Info/Documentation package
    -T  Install Contentserv Test files package
    -s  Skip Contentserv Subversion files for all packages
    -R  Install specific CS release, use the form like "16.1", if this option omitted,
        latest official stable release will be installed
    -L  Activate CSLive demo project after core package installation (enforces -l option, conflicts with -B)
    -B  Activate blank project with specified name after core package installation (conflicts with -L option)
        project name cannot be empty and cannot be 'CSLive' as it would conflict with pre-defined
        name for the demo CSLive project
    -H  Name or IP of the remote database host, will be set to "localhost" if -S option is used
    -b  Database name to create or connect to (see the table prefix option below). If not provided
        default name "contentserv" will be used
    -t  Table prefix for the project. Cannot be left empty. If the database is not empty
        and tables with the same prefix already exist, project activation process
        will overwrite all the tables
    -u  Database user name. If not provided, "root" will be used
    -p  Database password. Use single quotes if any non-alphanumeric character used, e.g. 'My\$3cur3P@\$\$'
        if you have security concerns and would like to avoid password leaking via 'ps' or .bash_history,
        you can simply omit this option so the script will ask for the password interactively later on
    -U  Enable cs-unstable repository component to allow installation of unstable package versions
    -r  APT repository user name
    -P  APT repository user password, if omitted, the script will ask for the password interactively
    -W  Very destructive option, use with care! It stops all local java daemons controlled by supervisord,
        wipes out all Contentserv componens and data (!), uninstalls all dependencies
        including locally installed DB server (MySQL or MariaDB) and its data and config directories
        wipes out:
            /var/lib/contentserv-cs/
            /var/lib/mysql/
            /etc/mysql/
            /etc/supervisor/conf.d/cs*.conf
        and purges all pre-seeded values from debconf database for contentserv-cs-core,
        contentserv-cs-live and mysql-server packages

EOT

}

__set_env() {


if [ "$_CS_ENV" = "prod" ]; then
            echodebug "Setting CS as Apache vhost: $_CS_ENV"
elif [ "$_CS_ENV" = "test" ]; then
            echodebug "Setting CS as Apache vhost: $_CS_ENV"
elif [ "$_CS_ENV" = "dev" ]; then
            echodebug "Setting CS as Apache vhost: $_CS_ENV"

if [ "$_CS_RELEASE" = "16.0" ]; then
echo "$_CS_RELEASE"
a2enmod deflate
a2enmod expires
a2enmod status

cat << EOF > /etc/php/5.6/apache2/conf.d/90-contentserv.ini
max_execution_time = 900
max_input_vars = 100000
memory_limit = 1024M
post_max_size = 256M
realpath_cache_size = 4096K
upload_max_filesize = 1024M
opcache.enable=1
engine=On
error_reporting = 22527
EOF
echo "Restarting apache2"
service apache2 restart
elif [ "$_CS_RELEASE" = "16.1" ]; then
echo "$_CS_RELEASE"
a2enmod deflate
a2enmod expires
a2enmod status

cat << EOF > /etc/php/7.1/apache2/conf.d/90-contentserv.ini
max_input_vars = 100000
memory_limit = 1024M
post_max_size = 256M
realpath_cache_size = 4096K
upload_max_filesize = 1024M
opcache.enable=1
engine=On
error_reporting = 22527
EOF
echo "Restarting apache2"
service apache2 restart

elif [ "$_CS_RELEASE" = "17.0" ] || [ "$_CS_RELEASE" = "" ]; then
echo "$_CS_RELEASE"
a2enmod deflate
a2enmod expires
a2enmod status

cat << EOF > /etc/php/7.1/apache2/conf.d/90-contentserv.ini
max_execution_time = 900
max_input_vars = 100000
memory_limit = 1024M
post_max_size = 256M
realpath_cache_size = 4096K
upload_max_filesize = 1024M
opcache.enable=1
engine=On
error_reporting = 22527
EOF
echo "Restarting apache2"
service apache2 restart


elif [ "$_CS_RELEASE" = "18.0" ] || [ "$_CS_RELEASE" = "" ]; then
echo "$_CS_RELEASE"
a2enmod deflate
a2enmod expires
a2enmod status

cat << EOF > /etc/php/7.1/apache2/conf.d/90-contentserv.ini
error_reporting = 24575
max_execution_time = 900
max_input_vars = 100000
memory_limit = 1024M
post_max_size = 256M
realpath_cache_size = 4096K
upload_max_filesize = 1024M
opcache.enable=1
engine=On
EOF
echo "Restarting apache2"
service apache2 restart

fi


fi

}



#---  END OF FUNCTIONS SECTION-----------------------------------------------------------------------------------------
#
#  DESCRIPTION:  Main execution part below
#----------------------------------------------------------------------------------------------------------------------
while getopts ':hVenDAMSQ:d:v:H:R:lsiTLB:b:t:u:p:Ur:P:WZ:E:' opt
do
  case "${opt}" in

    h )  __usage; exit 0                                             ;;
    V )  echo "$0 -- Version $__ScriptVersion"; exit 0               ;;
    n )  _COLORS=0; __detect_color_support                           ;;
    D )  _ECHO_DEBUG=$BS_TRUE                                        ;;
    A )  _INSTALL_MARIADB=$BS_TRUE                                   ;;
    M )  _INSTALL_MYSQL=$BS_TRUE                                     ;;
    e )  _START_DAEMONS=$BS_TRUE                                     ;;
    S )  _INSTALL_LOCAL_DB_SERVER=$BS_TRUE; _DB_HOST="localhost"     ;;
    Q )  _DB_ROOT_PASS="$OPTARG"                                     ;;
    d )  _CONFIGURE_CS_AS_ALIAS=$BS_TRUE; _CS_ALIAS="$OPTARG"        ;;
    v )  _CONFIGURE_CS_AS_VHOST=$BS_TRUE; _CS_VHOST="$OPTARG"        ;;
    H )  _DB_HOST="$OPTARG"                                          ;;
    u )  _DB_USER="$OPTARG"                                          ;;
    p )  _DB_PASS="$OPTARG"                                          ;;
    b )  _DB_NAME="$OPTARG"                                          ;;
    t )  _DB_PREFIX="$OPTARG"                                        ;;
    l )  _INSTALL_CS_LIVE=$BS_TRUE;  _ACTIVATE_CS_LIVE=$BS_TRUE      ;;
    s )  _INSTALL_CS_SVN=$BS_FALSE                                   ;;
    i )  _INSTALL_CS_DOCS=$BS_TRUE                                   ;;
    T )  _INSTALL_CS_DEV=$BS_TRUE                                    ;;
    B )  _CS_BLANK_NAME="$OPTARG"                                    ;;
    L )  _INSTALL_CS_LIVE=$BS_TRUE; _ACTIVATE_CS_LIVE=$BS_TRUE       ;;
    R )  _CS_RELEASE="$OPTARG"                                       ;;
    U )  _CS_ENABLE_UNSTABLE=$BS_TRUE                                ;;
    r )  _APT_USERNAME="$OPTARG"                                     ;;
    P )  _APT_PASSWORD="$OPTARG"                                     ;;
    W )  _TOTAL_CLEANUP=$BS_TRUE                                     ;;
    Z )  _CS_ENABLE_TESTING=$BS_TRUE                                 ;;
    E )  _CS_SET_ENV=$BS_TRUE; _CS_ENV="$OPTARG"                                               ;;



    \?)  echo
         echoerror "Option does not exist : $OPTARG"
         __usage
         exit 1
         ;;
    :)   echo
         echoerror "Option -$OPTARG requires an argument."
         __usage
         exit 1
         ;;

  esac    # --- end of case ---
done
#----------------------------------------------------------------------------------------------------------------------
#
#  DESCRIPTION:  Stop if called without options at all
#----------------------------------------------------------------------------------------------------------------------

__gather_os_info


if [ "$OS_NAME_L" = "linux" ]; then
    __gather_linux_system_info
    echodebug "Distro: $DISTRO_NAME $DISTRO_VERSION $CPU_ARCH"
else
    echoerror "Unsupported Operating System (non-Linux)"
    exit 1
fi

if ! [ "$CPU_ARCH" = "x86_64" ]; then
    echoerror "Unsupported Architecture: $CPU_ARCH"
    exit 1
fi

if [ "$DISTRO_NAME" = "Ubuntu" ] || [ "$DISTRO_NAME" = "Debian" ]; then
    __gather_debian_codename
    echodebug "DISTRO_CODENAME: $DISTRO_CODENAME"
else
    echoerror "Unsupported Linux Distro: $DISTRO_NAME"
    exit 1
fi

#if ! [ "$DISTRO_VERSION" = "16.04" ]; then
#    echoerror "Unsupported $DISTRO_NAME Version: $DISTRO_VERSION ($DISTRO_CODENAME)"
#    exit 1
#fi

DISTRO_NAME_LOWER=$(echo "$DISTRO_NAME" | tr '[:upper:]' '[:lower:]')

echodebug "DISTRO_NAME: $DISTRO_NAME"
echodebug "DISTRO_VERSION: $DISTRO_VERSION"
echodebug "DISTRO_NAME_LOWER: $DISTRO_NAME_LOWER"

if [ "$_TOTAL_CLEANUP" -eq $BS_TRUE ]; then
    echowarn "Total cleanup option called, you've got 10 seconds to break"
    counter=1
    while [ $counter -le 10 ]
    do
        echo -n "."
        sleep 1
        counter=`expr $counter + 1`
    done

    __do_total_cleanup
    exit 0
fi

# Check that we're not trying to install MySQL and MariaDB at the same time
if [ "$_INSTALL_MARIADB" -eq $BS_TRUE ] && [ "$_INSTALL_MYSQL" -eq $BS_TRUE ]; then
    echo
    echoerror "We're going to install either MariaDB or MySQL, not both"
    __usage
    exit 1
fi

# Check that we're not trying to activate both CSLive and blank projects at the same time
if [ ! "$_CS_BLANK_NAME" = "" ] && [ "$_ACTIVATE_CS_LIVE" -eq $BS_TRUE ]; then
    echo
    echoerror "We're going to activate either Blank project or CSLive demo, not both"
    __usage
    exit 1
fi

# Check that we're not trying to activate java daemons without activated CSLive demo project
if [ "$_START_DAEMONS" -eq $BS_TRUE ] && [ "$_ACTIVATE_CS_LIVE" -eq $BS_FALSE ]; then
    echo
    echoerror "Without CSLive demo project activation, autostart of Java processes makes no sense"
    __usage
    exit 1
fi

# Check that we're not trying to activate both Apache alias and vhost at the same time
if [ "$_CONFIGURE_CS_AS_VHOST" -eq $BS_TRUE ] && [ "$_CONFIGURE_CS_AS_ALIAS" -eq $BS_TRUE ]; then
    echo
    echoerror "We're going to configure either Apache alias or vhost, not both"
    __usage
    exit 1
fi

# Check that we're not installing DB client at all
if [ "$_INSTALL_MARIADB" -eq $BS_FALSE ] && [ "$_INSTALL_MYSQL" -eq $BS_FALSE ] && [ "$_TOTAL_CLEANUP" -eq $BS_FALSE ]; then
    echo
    echoerror "Neither MariaDB nor MySQL client is about to be installed, nor total cleanup called, aborting"
    __usage
    exit 1
fi

# Install some essential system and non-system tools & packages
__install_system_tools
__install_extra_tools

# Preseed some debconf values, so the apt installer can run (almost) unattended
__preseed_debconf_values

# Install DB components (client is always mandatory, server is optional)
 
__install_db_components

# Configure APT repo
__configure_cs_apt_repo

# Ready, set, go!
__do_cs_install

# Do some postinstall
if [ "$_START_DAEMONS" -eq $BS_TRUE ]; then
    __activate_java_daemons
fi

if [ "$_CS_SET_ENV" -eq $BS_TRUE ]; then
    __set_env
fi

service apache2 restart
#----------------------------------------------------------------------------------------------------------------------
#


