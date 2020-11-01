#!/bin/bash

echo  ####################################
echo  # Deploy Assited Installer 
echo  ####################################

# Note:
# - TCP/5432 Postgres: There is no need to export the PostgreSQL port (5432) outside the Pod
# - TCP/8000: UI
# - TCP/8090: API
# - TCP/8080: Retrieve ISO
#podman pod create --name assisted-installer -p 5432:5432 -p 8000:8000 -p 8090:8090 -p 8080:8080

OAS_IMAGE=quay.io/ocpmetal/assisted-service-onprem:latest
OAS_UI_IMAGE=quay.io/ocpmetal/ocp-metal-ui:latest
OAS_DB_IMAGE=quay.io/ocpmetal/postgresql-12-centos7
OAS_HOSTDIR=/opt/assisted-service
OAS_ENV_FILE=${OAS_HOSTDIR}/onprem-environment

HOST_IPS=`hostname -I | sed 'y/ /,/' | sed 's/.$//'`
# Update onprem-environment with correct IPs
sed -i -e "s/SERVICE_IPS.*/SERVICE_IPS=${HOST_IPS}/g" $OAS_ENV_FILE
sed -i -e "s/SERVICE_BASE_URL.*/SERVICE_BASE_URL=http:\/\/`hostname -f`\:8090/g" $OAS_ENV_FILE

podman pod create --name assisted-installer -p 8000:8000 -p 8090:8090 -p 8080:8080

podman run -dt --pod assisted-installer --env-file $OAS_ENV_FILE \
    --name db $OAS_DB_IMAGE

podman run -dt --pod assisted-installer --env-file $OAS_ENV_FILE \
    -v ${OAS_HOSTDIR}/nginx-ui.conf:/opt/bitnami/nginx/conf/server_blocks/nginx.conf:z \
    --pull always \
    --name ui $OAS_UI_IMAGE

podman run -dt --pod assisted-installer --env-file $OAS_ENV_FILE \
    --env DUMMY_IGNITION=False \
    --pull always \
    --user assisted-installer --restart always \
    --name installer $OAS_IMAGE

