#! /bin/bash

export FILE_BASE=`realpath $0`
export BASE_DIR=`dirname ${FILE_BASE}`
export CONFIG_NAME=${1:-"default"}

LOAD_DB=0
DUMP_DB=1
TEST_RUN=1
SCENARIO_NAME="policy"
DOCKER_START=1
DOCKER_KILL=0

function show_help()
{
      echo "Usage: ./start.sh [OPTIONS]"
      echo -e " OPTIONS:"
      echo -e "\t -c Set config name (default: ${CONFIG_NAME})"
      echo -e "\t -l Load dump instead of generate (default: generate)"
      echo -e "\t -s (NAME) Run scenario(default: ${SCENARIO_NAME})"
      echo -e "\t -d Do not start docker container (default: no)"
      echo -e "\t -t Do not run tests (default: no)"
      echo -e "\t -k Kill docker after run (default: no)"
      echo -e "\t -h show help"
}



while getopts ":c:ldkths:" opt; do
  case $opt in
    c)
      export CONFIG_NAME=${OPTARG}
      ;;
    l)
      LOAD_DB=1
      ;;
    d)
      DOCKER_START=0
      ;;
    s)
        SCENARIO_NAME=${OPTARG}
    ;;
    t)
        TEST_RUN=0
    ;;
    k)
        DOCKER_KILL=1
    ;;
    h)
        show_help
    ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      show_help
      ;;
      *)
      show_help
      ;;
  esac
done

source "${BASE_DIR}/config/${CONFIG_NAME}.conf"
source "${BASE_DIR}/tools/tools.sh"
source "${BASE_DIR}/tools/docker.sh"


function run_scenario() {    
    load_senarios_script $1
}

if [ $DOCKER_START -eq 1 ] ; then
    container_init
fi

# RUN INIT VIEW

if [ $LOAD_DB -eq 1 ] ; then
    echo "[INFO] Loading database from dump ${DB_DUMP_FILE}"
    load_database

else # Run init scripts
    echo "[INFO] Loading database using init"
    load_init_scripts
fi

if [ "$SCENARIO_NAME" != "" ]; then
    run_scenario "${SCENARIO_NAME}"
fi

if [ $TEST_RUN -eq 1 ]; then
    load_tests_scripts
fi

if [ $DOCKER_KILL -eq 1 ] ; then
    container_stop "$CONTAINER_NAME"
fi










