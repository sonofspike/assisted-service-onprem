#!/bin/bash

echo  ####################################
echo  # Deploy Assited Installer
echo  ####################################

# Note:
# - TCP/5432 Postgres: There is no need to export the PostgreSQL port (5432) outside the Pod
# - TCP/8000:
# - TCP/8090: API
# - TCP/8888: UI

########################################################################
RHCOS_VERSION="latest"

# BASE_OS_IMAGE matches current release, which is 4.8.x
BASE_OS_IMAGE=https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.8/${RHCOS_VERSION}/rhcos-live.x86_64.iso

# For 4.8.2 SNO deployments, replace BASE_OS_IMAGE with the following URL:
# BASE_OS_IMAGE=https://mirror.openshift.com/pub/openshift-v4/amd64/dependencies/rhcos/4.8/4.8.2/rhcos-4.8.2-x86_64-live.x86_64.iso

OAS_UI_IMAGE=quay.io/ocpmetal/ocp-metal-ui:latest
OAS_DB_IMAGE=quay.io/ocpmetal/postgresql-12-centos7
OAS_IMAGE="${OAS_IMAGE:-quay.io/ocpmetal/assisted-service:latest}"
COREOS_INSTALLER=quay.io/coreos/coreos-installer:v0.9.1

OAS_HOSTDIR=/opt/assisted-service
OAS_ENV_FILE=${OAS_HOSTDIR}/onprem-environment
OAS_UI_CONF=${OAS_HOSTDIR}/nginx-ui.conf
OAS_LIVE_CD=${OAS_HOSTDIR}/rhcos-live.x86_64.iso
OAS_COREOS_INSTALLER=${OAS_HOSTDIR}/coreos-installer
########################################################################

SERVICE_FQDN=$(hostname -f)

# Update onprem-environment configuration for local deployment
cp -f onprem-environment $OAS_ENV_FILE

#PULL_SECRET=$(cat pull-secret.json)
#sed -i -e "s/PULL_SECRET.*/PULL_SECRET=${PULL_SECRET}/g" $OAS_ENV_FILE

#HOST_IPS=`hostname -I | sed 'y/ /,/' | sed 's/.$//'`
#sed -i -e "s/SERVICE_IPS.*/SERVICE_IPS=${HOST_IPS}/g" $OAS_ENV_FILE
#sed -i -e "s/SERVICE_BASE_URL.*/SERVICE_BASE_URL=http:\/\/${SERVICE_FQDN}\:8090/g" $OAS_ENV_FILE

cp -f nginx-ui.conf $OAS_UI_CONF

# Download RHCOS live CD
if [[ ! -f $OAS_LIVE_CD ]]; then
    echo "Base Live ISO not found. Downloading RHCOS live CD from $BASE_OS_IMAGE"
    curl -L $BASE_OS_IMAGE -o $OAS_LIVE_CD
fi

# Download RHCOS installer
if [[ ! -f $OAS_COREOS_INSTALLER ]]; then
    podman run --privileged -it --rm \
        -v ${OAS_HOSTDIR}:/data \
        -w /data \
        --entrypoint /bin/bash \
        ${COREOS_INSTALLER} \
        -c 'cp /usr/sbin/coreos-installer /data/coreos-installer'
fi

# Prepare for persistence
# NOTE: Make sure to delete this directory if persistence is not desired for a new environment!
mkdir -p ${OAS_HOSTDIR}/data/postgresql
chown -R 26 ${OAS_HOSTDIR}/data/postgresql/

# Create Pod and deploy containers
#podman pod create --name assisted-installer -p 5432:5432 -p 8000:8000 -p 8090:8090 -p 8888:8080
podman pod create --name assisted-installer  -p 8000:8000 -p 8090:8090 -p 8888:8080

# database
podman run -dt --pod assisted-installer --env-file $OAS_ENV_FILE \
    --volume ${OAS_HOSTDIR}/data/postgresql:/var/lib/pgsql:z \
    --name db $OAS_DB_IMAGE

# ui
podman run -dt --pod assisted-installer --env-file $OAS_ENV_FILE \
    -v ${OAS_HOSTDIR}/nginx-ui.conf:/opt/bitnami/nginx/conf/server_blocks/nginx.conf:z \
    --name ui $OAS_UI_IMAGE

# assisted service
podman run -dt --pod assisted-installer \
    -v ${OAS_LIVE_CD}:/data/livecd.iso:z \
    -v ${OAS_COREOS_INSTALLER}:/data/coreos-installer:z \
    --env-file $OAS_ENV_FILE \
    --env DUMMY_IGNITION=False \
    --restart always \
    --name installer $OAS_IMAGE

echo "Check if service is running..."
podman pod ps
podman ps
#
# END OF FILE
#
