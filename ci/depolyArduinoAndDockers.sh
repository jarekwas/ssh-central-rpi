#!/bin/bash

docker-compose -v
docker -v
docker-compose -p domoticz down
echo ${ENV_DEPLOY_MYSENSORS_GATEWAY_REPO_URL}
git clone https://gitlab-ci-token:${CI_JOB_TOKEN}@${ENV_DEPLOY_MYSENSORS_GATEWAY_REPO_URL} app
cd app
git checkout $APP_COMMIT_SHA
git submodule update --init
sh ci/compile.sh
arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:mega App
cd ..
docker-compose -p domoticz up -d