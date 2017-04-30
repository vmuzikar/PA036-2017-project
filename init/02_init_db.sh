#! /bin/bash

PATH_CREATE_FILE="${BASE_DIR}/scripts/tcl/create.tcl"

function show_help()
{
      echo "Usage: ./create_db.sh [OPTIONS]"
      echo -e " OPTIONS:"
      echo -e "\t -d Admin Database name (default: ${ADMIN_DB_NAME})"
      echo -e "\t -D Testing Database name (default: ${DB_NAME})"
      echo -e "\t -H Host name (default: ${HOST})"
      echo -e "\t -u Super user name (default: ${SUPER_USER_NAME})"
      echo -e "\t -P Super user pass (default: ${SUPER_USER_PASS})"
      echo -e "\t -U Users (default: ${USERS})"
      echo -e "\t -W Warehouses (default: ${WAREHOUSES})"
      echo -e "\t -p port number (default: ${PORT})"
      echo -e "\t -X HAMMER_DB installation path (default: ${PATH_HAMMERDB})"
}

while getopts ":X:H:p:P:d:u:U:W:D:h" opt; do
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
      ADMIN_DB_NAME=${OPTARG}
      ;;
    D)
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


EXEC_CREATE="${PATH_HDB_TCLSH} ${PATH_CREATE_FILE} ${HOST} ${PORT} ${SUPER_USER_NAME} ${SUPER_USER_PASS} ${ADMIN_DB_NAME} ${WAREHOUSES} ${USERS} ${DB_NAME} ${DB_USER} ${DB_USER_PASS}"

time eval "${EXEC_CREATE}"