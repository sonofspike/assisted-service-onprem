#!/bin/bash

echo ####################################
echo # Removing Assisted Installer onprem
echo ####################################

podman pod rm -f assisted-installer | true

