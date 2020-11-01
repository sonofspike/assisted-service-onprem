#!/bin/bash

PWD=`pwd`

echo  ####################################
echo  # Deploy Assited Installer 
echo  ####################################

# Note:
# - TCP/5432 Postgres: There is no need to export the PostgreSQL port (5432) outside the Pod
# - TCP/8000: UI
# - TCP/8090: API
# - TCP/8080: Retrieve ISO
#podman pod create --name assisted-installer -p 5432:5432 -p 8000:8000 -p 8090:8090 -p 8080:8080

podman pod create --name assisted-installer -p 8000:8000 -p 8090:8090 -p 8080:8080

podman run -dt --pod assisted-installer --env-file onprem-environment \
    --name db quay.io/ocpmetal/postgresql-12-centos7

podman run -dt --pod assisted-installer --env-file onprem-environment \
    -v $PWD/nginx-ui.conf:/opt/bitnami/nginx/conf/server_blocks/nginx.conf:z \
    --pull always \
    --name ui quay.io/ocpmetal/ocp-metal-ui:latest

podman run -dt --pod assisted-installer --env-file onprem-environment \
    --env DUMMY_IGNITION=False \
    --pull always \
    --user assisted-installer --restart always \
    --name installer quay.io/ocpmetal/assisted-service-onprem:latest

