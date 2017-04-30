#! /bin/bash

export FILE_BASE=`realpath $0`
export BASE_DIR=`dirname ${FILE_BASE}`
export CONFIG_NAME=${1:-"default"}

source "${BASE_DIR}/config/${CONFIG_NAME}.conf"
source "${BASE_DIR}/tools/tools.sh"

# RUN INIT

load_init_scripts

load_senarios_script "view"

load_tests_scripts










