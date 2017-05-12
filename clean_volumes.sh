#!/usr/bin/env bash



sudo docker volume ls -qf dangling=true | sudo xargs -r docker volume rm 