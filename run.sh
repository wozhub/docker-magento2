#!/bin/bash

set -e  # Exit on err
DATE_FMT="%Y-%M-%d %H:%M:%S"
run-log() { echo "$(date "+${DATE_FMT}") | $*"; }

apache_start() {
    run-log "Starting apache"
    apache2-foreground
}

magento_config() {
    . /magento.sh

    magento_setup_install
    magento_deploy_mode_set
}

#
run-log "Greetings $(whoami)!"

if [ "$1" == "" ]; then
    magento_config

    # Default execution
    apache_start
else                            
    # Try to run $@
    run-log "Starting $*"
    exec "$@"
fi
