#!/bin/bash

. /magento.env

magento_setup_install() {
    set -x
    php bin/magento ${MAGENTO_CLI_OPTS} \
        setup:install "${MAGENTO_SETUP_INSTALL_OPTS[@]}"
    set +x
}

magento_deploy_mode_set() {
    set -x
    php bin/magento deploy:mode:set "${MAGENTO_MODE}"
    set +x
}
