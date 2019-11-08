#!/bin/bash

docker-compose -v
docker -v
docker-compose -p domoticz down
git clone https://gitlab-ci-token:${CI_JOB_TOKEN}@${ENV_DEPLOY_MYSENSORS_GATEWAY_REPO_URL} app
cd app
git checkout $APP_COMMIT_SHA
arduino-cli lib install "MySensors"
arduino-cli lib install "Bounce2"
arduino-cli compile --fqbn arduino:avr:mega App
arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:mega App
cd ..
docker-compose -p domoticz up -d