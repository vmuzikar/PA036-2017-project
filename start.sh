#! /bin/bash

export FILE_BASE=`realpath $0`
export BASE_DIR=`dirname ${FILE_BASE}`
export CONFIG_NAME=${1:-"default"}

source "${BASE_DIR}/config/${CONFIG_NAME}.conf"
source "${BASE_DIR}/tools/tools.sh"
source "${BASE_DIR}/tools/docker.sh"

# INIT DOCKER
container_init

# RUN INIT VIEW


load_init_scripts

# RUN VIEW SCENARIO

function run_view() {
    load_senarios_script "view"
    load_tests_scripts
}

#container_init
#time load_database

function run_policy() {
    load_senarios_script "policy"
    load_tests_scripts
}









