DAEMON="-d"

function container_test_running(){
    echo "[INFO] Is container running? "
    docker inspect -f "{{.State.Running}}" "${1}"
}

function container_test_exist() {
    echo "[INFO] Does container exists?"
    docker ps -a -q -f name="${1}"
}

function container_stop {
    echo "[INFO] Stoping container ${1}"
    docker stop "${1}"
}

function container_remove {
    echo "[INFO] Removing container ${1}"
    docker rm "${1}"
}

function container_start {
    echo "[INFO] Starting container ${CONTAINER_NAME}"
    docker run ${DAEMON} --name "${CONTAINER_NAME}" -p 5432:5432 -e POSTGRES_USER="${USER}" -e POSTGRES_PASSWORD="${PASS}" "${IMAGE_NAME}"
}


function container_init {
    if container_test_running "${CONTAINER_NAME}"; then
        container_stop "$CONTAINER_NAME"
    fi

    if container_test_exist "${CONTAINER_NAME}"; then
        container_remove "$CONTAINER_NAME"
    fi

    docker pull "${IMAGE_NAME}"

    container_start

    sleep 5
}







