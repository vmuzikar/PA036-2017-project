#! /bin/bash

CONTAINER_NAME=${1:-"pgdb"}
IMAGE_NAME="postgres:latest"
PORT=5432
USER="postgres"
PASS="${USER}"
DAEMON="-d"


function test_running(){
    docker inspect -f "{{.State.Running}}" "${1}"
}

function test_exist() {
    docker ps -a -q -f name="${1}"
}

function stop_container {
    docker stop "${1}"
}

function remove_container {
    docker rm "${1}"
}

function start_container {
    docker run ${DAEMON} --name "${CONTAINER_NAME}" -p 5432:5432 -e POSTGRES_USER="${USER}" -e POSTGRES_PASSWORD="${PASS}" "${IMAGE_NAME}"
}



if test_running "${CONTAINER_NAME}"; then
    stop_container "$CONTAINER_NAME"
fi

if test_exist "${CONTAINER_NAME}"; then
    remove_container "$CONTAINER_NAME"
fi

docker pull "${IMAGE_NAME}"

start_container







