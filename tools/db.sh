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
    psql -h "${HOST}" -U "${user}" -d "${DB_NAME}" -f "${file}"
}

# Function dumps database
function dump_database() {
    pg_dump -h "${HOST}" -p "${PORT}" -U "${SUPER_USER_NAME}" "${DB_NAME}" > "${DB_DUMP_FILE}" 
}

# Loads database from dump and creates required user
function load_database() {
    psql -h "${HOST}" -U "${SUPER_USER_NAME}" -c "CREATE USER ${DB_USER} PASSWORD '${DB_USER_PASS}'"
    psql -h "${HOST}" -U "${SUPER_USER_NAME}" -c "ALTER USER ${DB_USER} WITH SUPERUSER"
    psql -h "${HOST}" -U "${SUPER_USER_NAME}" -f "${DB_DUMP_FILE}" "postgres"
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
        echo -e "\t[INFO] Loading file: ${f}"
        exec_file "${f}"
    done
}

# Creates user in database
# @param $1 - username
function db_user_create()
{
    user=${1}
    echo "[INFO] Creating user: ${user}"
    exec_query "CREATE USER ${user};"
}

# Grants user to user
# @param $1 - who
# @param $2 - to which
function db_user_grant_user()
{
    who=$1
    to=$2
    echo "[INFO] Granting user '${who}' TO ${to}"
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
    echo "[INFO] Granting [${perm}] for ${user} on ${table}"
    exec_query "GRANT ${perm} ON ${table} TO ${user}"
}
