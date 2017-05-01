
function load_script() {
    echo "[INFO] Loading script: ${1}"
    source "${1}"
}

function load_dir_scripts() {
    DIR_PATH=$1
    for f in `ls "${DIR_PATH}"/*.sh | sort`; do
        load_script "${f}"
    done
}

function load_init_scripts() {
    load_dir_scripts "${BASE_DIR}/init"
}

function load_tests_scripts() {
    path="${BASE_DIR}/tests/"

    if [ "${1}" != "" ]; then
        path="${path}/${1}"
    fi

    load_dir_scripts "${path}"
}

function load_senarios_script() {
    load_dir_scripts "${BASE_DIR}/scenarios/${1}"
}

function load_sql_scripts() {
    DIR_PATH=$1
    for f in `ls "${DIR_PATH}"/*.sql | sort`; do
        echo -e "\t[INFO] Loading file: ${f}"
        exec_file "${f}"
    done
}

function exec_query()
{
    query=${1}
    psql -h "${HOST}" -U "${SUPER_USER_NAME}" -d "${DB_NAME}" -c "${query}"
}

function exec_file() {
    file=${1}
    psql -h "${HOST}" -U "${SUPER_USER_NAME}" -d "${DB_NAME}" -f "${file}"
}

function dump_database() {
    pg_dump -h "${HOST}" -p "${PORT}" -U "${SUPER_USER_NAME}" "${DB_NAME}" > "${DB_DUMP_FILE}" 
}


function load_database() {
    psql -h "${HOST}" -U "${SUPER_USER_NAME}" -c "CREATE USER ${DB_USER} PASSWORD '${DB_USER_PASS}'"
    psql -h "${HOST}" -U "${SUPER_USER_NAME}" -f "${DB_DUMP_FILE}" "postgres"
}

