DAEMON="-d"

# Function will test whether docker container is running
# @param name - name of the container
function container_test_running(){
    echo "[INFO] Is container running? "
    docker inspect -f "{{.State.Running}}" "${1}"
}

# Function will test whether container does exists
# @param name - name of the container
function container_test_exist() {
    echo "[INFO] Does container exists?"
    docker ps -a -q -f name="${1}"
}

# Function will stop container execution
function container_stop {
    echo "[INFO] Stoping container ${1}"
    docker stop "${1}"
}

# Function will remove container
function container_remove {
    echo "[INFO] Removing container ${1}"
    docker rm "${1}"
}

# Function will start container
function container_start {
    echo "[INFO] Starting container ${CONTAINER_NAME}"
    docker run ${DAEMON} --name "${CONTAINER_NAME}" -p 5432:5432 -e POSTGRES_USER="${USER}" -e POSTGRES_PASSWORD="${PASS}" "${IMAGE_NAME}"
}

# Function will wait for container to be avaible
# until then it will sleep
function container_wait_for_avail {
    until nc -z $(sudo docker inspect --format='{{.NetworkSettings.IPAddress}}' $CONTAINER_NAME) 5432
    do
        echo "[DEBUG] waiting for $CONTAINER_NAME container..."
        sleep 1.5
    done
}

# Container will initialize container 
function container_init {
    if container_test_running "${CONTAINER_NAME}"; then
        container_stop "$CONTAINER_NAME"
    fi

    if container_test_exist "${CONTAINER_NAME}"; then
        container_remove "$CONTAINER_NAME"
    fi

    docker pull "${IMAGE_NAME}"

    container_start

    container_wait_for_avail
}







