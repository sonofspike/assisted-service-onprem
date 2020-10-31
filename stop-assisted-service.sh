#!/bin/bash

echo ####################################
echo # Remove Assisted Installer onprem
echo ####################################
podman pod rm -f assisted-installer | true

