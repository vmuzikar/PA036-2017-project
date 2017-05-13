#! /bin/bash

export FILE_BASE=`realpath $0`
export BASE_DIR=`dirname ${FILE_BASE}`
export CONFIG_NAME="default"

LOAD_DB=0
DUMP_DB=1
SCENARIO_NAME="policy"
DOCKER_START=1
DOCKER_KILL=0
RUN_TEST_SCENARIO="simple"
function show_help()
{
      echo "Usage: ./start.sh [OPTIONS]"
      echo -e " OPTIONS:"
      echo -e "\t -c Set config name (default: ${CONFIG_NAME})"
      echo -e "\t -l Load dump instead of generate (default: generate)"
      echo -e "\t -s (NAME) Run scenario(default: ${SCENARIO_NAME})"
      echo -e "\t -d Do not start docker container (default: no)"
      echo -e "\t -T Run specific test (default: ${RUN_TEST_SCENARIO})"
      echo -e "\t -k Kill docker after run (default: no)"
      echo -e "\t -h show help"
}



while getopts ":T:c:ldkths:" opt; do
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
    T)
        RUN_TEST_SCENARIO=${OPTARG}
    ;;
    k)
        DOCKER_KILL=1
    ;;
    h)
        show_help
        exit 0
    ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      show_help
      exit 1
      ;;
      *)
      show_help
      exit 1
      ;;
  esac
done

META_CONFIG="${BASE_DIR}/config/_${CONFIG_NAME}.conf"

echo "[INFO] Loading config \"${CONFIG_NAME}\""
source "${BASE_DIR}/config/${CONFIG_NAME}.conf"

if [ -e "${META_CONFIG}" ]; then
    echo "[INFO] Loading meta config \"_${CONFIG_NAME}\""

    source "${META_CONFIG}"
fi

source "${BASE_DIR}/tools/tools.sh"
load_dir_scripts "${BASE_DIR}/tools"


function run_scenario() {    
    load_senarios_script $1
}

if [ $DOCKER_START -eq 1 ] ; then
    container_init
fi

# RUN INIT VIEW

mkdir -p ${PATH_OUT}

ROLES_ARRAY=()
while IFS='' read -r var || [[ -n "$var" ]]; do
    ROLES_ARRAY+=("$var")
done < "$PATH_VALUES"

export ROLES_ARRAY

if [ $LOAD_DB -eq 1 ] ; then
    log_info "Loading database from dump ${DB_DUMP_FILE}"
    load_database

else # Run init scripts
    log_info "Loading database using init"
    load_init_scripts
fi

if [ "$SCENARIO_NAME" != "" ]; then
    run_scenario "${SCENARIO_NAME}"
fi

load_tests_scripts "$RUN_TEST_SCENARIO"


if [ $DOCKER_KILL -eq 1 ] ; then
    container_stop "$CONTAINER_NAME"
fi










