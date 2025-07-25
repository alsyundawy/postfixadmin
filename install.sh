#!/bin/bash

set -eu

# PostfixAdmin install script.
# 1. Downloads 'composer.phar' to the current directory, if 'composer' is not found in your PATH
# 2. Runs 'php composer install' which should install required runtime libraries for Postfixadmin
# 3. Runs 'mkdir templates_c && chmod 777 templates_c'

PATH=/bin:/usr/bin:/usr/local/bin
export PATH

COMPOSER_URL=https://getcomposer.org/download/latest-stable/composer.phar

type php >/dev/null 2>&1 || { echo >&2 "I require php but it's not installed.  Aborting."; exit 1; }

cd "$(dirname "$0")"

# Check for $(pwd)/composer.phar

echo " * Checking for composer.phar "

if ! command -v composer >/dev/null 2>&1 ; then
    # not in path, try and fall back to a local version
    if [ ! -f composer.phar ]; then
        echo " * 'composer' not found in your path, will try to download from $COMPOSER_URL "

        # try and download it one way or another
        if [ -x /usr/bin/wget ]; then
            wget -q -O composer.phar $COMPOSER_URL
        else
            if [ -x /usr/bin/curl ]; then
                curl -o composer.phar $COMPOSER_URL
            else
                echo " ** Could not find wget or curl; please download $COMPOSER_URL to pwd" >/dev/stderr
                exit 1
            fi
        fi
    fi

    COMPOSER="$(pwd)/composer.phar"

    # not sure if we can actually get here, wget/curl failing should kill the script due to 'set -e'
    if [ ! -f "${COMPOSER}" ]; then
        echo "Failed to download composer, download $COMPOSER_URL manually into this directory." > /dev/stderr
        exit 1
    fi

else
    COMPOSER="$(which composer)"
fi

echo " * Using composer ( $COMPOSER )"
echo " * Installing libraries ( composer install --no-dev ... )"

php "${COMPOSER}" install --prefer-dist -n --no-dev

if [ ! -d templates_c ]; then

    mkdir -p templates_c && chmod 777 templates_c

    echo
    echo " Warning: "
    echo "   templates_c directory didn't exist, now created."
    echo
    echo "   You should change the ownership and reduce permissions on templates_c to 750. "
    echo "   The ownership needs to match the user used to execute PHP scripts, perhaps 'www-data' or 'httpd'"
    echo
    echo "   e.g. chown www-data templates_c && chmod 750 templates_c"
    echo
fi
echo
echo "Please continue configuration / setup within your web browser. "
echo "See also : https://github.com/postfixadmin/postfixadmin/blob/master/INSTALL.TXT#L58 "
echo
