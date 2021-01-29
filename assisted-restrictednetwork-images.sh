#!/bin/bash

echo  ########################################################################
echo  # Mirror Extra Images for Assisted Installer, Restricted Network Install
echo  ########################################################################

# Input environment variables suiting your installation below

LOCAL_REGISTRY="yourregistry.fqdn:5000"
PULL_SECRET_JSON=../../pull-secret-full.json

IMAGE="coreos-installer"
oc -a $PULL_SECRET_JSON image mirror quay.io/coreos/$IMAGE:v0.7.0 $LOCAL_REGISTRY/coreos/$IMAGE:v0.7.0 --insecure=true

for IMAGE in postgresql-12-centos7 ocp-metal-ui agent assisted-installer-agent assisted-iso-create assisted-installer assisted-installer-controller assisted-service
do
   oc -a $PULL_SECRET_JSON image mirror quay.io/ocpmetal/$IMAGE:latest $LOCAL_REGISTRY/ocpmetal/$IMAGE:latest --insecure=true
   echo "Pushed to $LOCAL_REGISTRY/ocpmetal/$IMAGE:latest"
done

echo ""
echo "Ensure that the onprem-environment file, in this directory, contains the proper digest for the assisted-installer-controller."
echo "This should be `skopeo inspect docker://quay.io/ocpmetal/assisted-installer-controller:latest | jq .Digest`"
