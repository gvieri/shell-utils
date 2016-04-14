#!/bin/bash


docker ps --no-trunc -aqf "status=exited" | xargs docker rm
docker images --no-trunc -aqf "dangling=true" | xargs docker rmi
docker volume ls -qf dangling=true | xargs --no-run-if-empty docker volume rm


