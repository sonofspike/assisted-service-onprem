#!/bin/bash

PWD=`pwd`

echo  ####################################
echo  # Deploy Assited Installer 
echo  ####################################

podman pod create --name assisted-installer -p 5432,8000,8090,8080

podman run -dt --pod assisted-installer --env-file onprem-environment \
    --name db quay.io/ocpmetal/postgresql-12-centos7

podman run -dt --pod assisted-installer --env-file onprem-environment \
    -v $PWD/nginx-ui.conf:/opt/bitnami/nginx/conf/server_blocks/nginx.conf:z \
    --name ui quay.io/ocpmetal/ocp-metal-ui:latest

podman run -dt --pod assisted-installer --env-file onprem-environment \
    --env DUMMY_IGNITION=False \
    --user assisted-installer --restart always \
    --name installer quay.io/ocpmetal/assisted-service-onprem:latest

