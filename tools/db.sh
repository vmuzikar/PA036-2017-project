HOST_PORT=" -h ${HOST} -p ${PORT}"

# Function executes query
# @param $1 - query string
# @param $2 - user that will execute the query
function exec_query()
{
    query=${1}
    user=${2:-${SUPER_USER_NAME}}
    psql -h "${HOST}" -U "${user}" -d "${DB_NAME}" -c "${query}"
}
# Function executes file
# @param $1 - file path
# @param $2 - user that will execute the query
function exec_file() {
    file=${1}
    user=${2:-${SUPER_USER_NAME}}
    psql ${HOST_PORT} -U "${user}" -d "${DB_NAME}" -f "${file}"
}

# Function dumps database
function dump_database() {
    set -x
    pg_dump ${HOST_PORT} -U "${SUPER_USER_NAME}" "${DB_NAME}" > "${DB_DUMP_FILE}" 
    set +x

}

# Function dumps database users
function dump_global() {
    set -x
    pg_dumpall ${HOST_PORT} -U "${SUPER_USER_NAME}" -g > "${DB_DUMP_USER}"
    set +x
}

function load_dump() {
    log_info "Loading database from dump \"$1\" to [${2}]"
    psql ${HOST_PORT} -U "${SUPER_USER_NAME}" -f "${1}" "${2}"
}


# Loads database from dump and creates required user
function load_database() {
    psql ${HOST_PORT} -U "${SUPER_USER_NAME}" -c "CREATE USER ${DB_USER} PASSWORD '${DB_USER_PASS}';"
    psql ${HOST_PORT} -U "${SUPER_USER_NAME}" -c "ALTER USER ${DB_USER} WITH SUPERUSER;"
    psql ${HOST_PORT} -U "${SUPER_USER_NAME}" -c "CREATE DATABASE ${DB_USER_PASS} OWNER ${DB_USER};"

    load_dump "${DB_DUMP_USER}" "${ADMIN_DB_NAME}"
    load_dump "${DB_DUMP_FILE}" "${DB_USER_PASS}"
    log_info "Loading ended"
}

# Function executes timed query 
function exec_timed_query() {
    exec_query "\timing on"
    exec_query $1 $2
    exec_query "\timing off"
}

# Functil will load all scripts from specified directory
# @param $1 - directory from which all the files will be loaded
function load_sql_scripts() {
    DIR_PATH=$1
    for f in `ls "${DIR_PATH}"/*.sql | sort`; do
        log_info "\t Loading file: ${f}"
        exec_file "${f}"
    done
}

# Creates user in database
# @param $1 - username
function db_user_create()
{
    user=${1}
    log_info "Creating user: ${user}"
    exec_query "CREATE USER ${user};"
}

# Grants user to user
# @param $1 - who
# @param $2 - to which
function db_user_grant_user()
{
    who=$1
    to=$2
    log_info "Granting user '${who}' TO ${to}"
    exec_query "GRANT ${who} TO ${to};"
}

# Grants user to table with permissions
# @param $1 - who
# @param $2 - to which
# @param $3 - permissions
function db_user_grant_table()
{
    table=$1
    user=$2
    perm=${3:-"ALL"}
    log_info "Granting [${perm}] for ${user} on ${table}"
    exec_query "GRANT ${perm} ON ${table} TO ${user}"
}
