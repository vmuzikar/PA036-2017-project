
# Wrapper over shell script load
function load_script() {
    echo "[INFO] Loading script: ${1}"
    source "${1}"
}

# Function to load all scripts in given directory
# Example: load_dir_scripts "${BASE_DIR}/init"
# Example will execute all scripts that are in directory init
function load_dir_scripts() {
    DIR_PATH=$1
    for f in `ls "${DIR_PATH}"/*.sh | sort`; do
        load_script "${f}"
    done
}

# Wrapper to load init scripts
function load_init_scripts() {
    load_dir_scripts "${BASE_DIR}/init"
}

# Wrapper to load test scripts
# if given an argument it will load files from subdir in tests
function load_tests_scripts() {
    path="${BASE_DIR}/tests/"

    if [ "${1}" != "" ]; then
        path="${path}/${1}"
    fi

    load_dir_scripts "${path}"
}

# Load all scripts from scenarios directory
function load_senarios_script() {
    load_dir_scripts "${BASE_DIR}/scenarios/${1}"
}




