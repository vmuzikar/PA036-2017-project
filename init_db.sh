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
      echo -e "\t -d Database name"
      echo -e "\t -H Host name"
      echo -e "\t -u Super user name"
      echo -e "\t -P Super user pass"
      echo -e "\t -D User db"
      echo -e "\t -U Users"
      echo -e "\t -W Warehouses"
      echo -e "\t -p port number"
}

function exec_query()
{
    query=${1}
    psql -h "${HOST}" -U "${SUPER_USER_NAME}" -d "${DB_NAME}" -c "${query}"
}


while getopts ":H:p:P:d:u:U:W:h" opt; do
  case $opt in
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