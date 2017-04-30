#! /bin/bash

PATH_HAMMERDB="/opt/hammerdb"
PATH_HDB_BIN="${PATH_HAMMERDB}/bin"
PATH_HDB_TCLSH="${PATH_HDB_BIN}/tclsh8.6"

HOST="localhost"
PORT=5432
SUPER_USER_NAME="postgres"
SUPER_USER_PASS="postgres"
DB_NAME="postgres"
WAREHOUSES=1
USERS=1


function show_help()
{
      echo "Usage: ./create_db.sh [OPTIONS]"
      echo -e " OPTIONS:"
      echo -e "\t -d Database name (default: ${DB_NAME})"
      echo -e "\t -H Host name (default: ${HOST})"
      echo -e "\t -u Super user name (default: ${SUPER_USER_NAME})"
      echo -e "\t -P Super user pass (default: ${SUPER_USER_PASS})"
      echo -e "\t -U Users (default: ${USERS})"
      echo -e "\t -W Warehouses (default: ${WAREHOUSES})"
      echo -e "\t -p port number (default: ${PORT})"
      echo -e "\t -X HAMMER_DB installation path (default: ${PATH_HAMMERDB})"
}

function exec_query()
{
    query=${1}
    psql -h "${HOST}" -U "${SUPER_USER_NAME}" -d "${DB_NAME}" -c "${query}"
}


while getopts ":X:H:p:P:d:u:U:W:h" opt; do
  case $opt in
    X)
        PATH_HAMMERDB=${OPTARG}
        ;;
    H)
        HOST=${OPTARG}
        ;;
    p)
      PORT=${OPTARG}
      ;;
    d)
      DB_NAME=${OPTARG}
      ;;
    u)
      SUPER_USER_NAME=${OPTARG}
      ;;
    P)
      SUPER_USER_PASS=${OPTARG}
      ;;
    W)
      WAREHOUSES=${OPTARG}
      ;;
    U)
      USERS=${OPTARG}
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
    :)
      echo "Option -$OPTARG requires an argument." >&2
      show_help
      exit 1
      ;;
  esac
done


eval "${PATH_HDB_TCLSH} ./create.tcl ${HOST} ${PORT} ${SUPER_USER_NAME} ${SUPER_USER_PASS} ${DB_NAME} ${WAREHOUSES} ${USERS}"