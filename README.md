# Assisted Service onprem

```
########################################################################
# A PRESCRIPTIVE ONPREMISE DEPLOYMENT OF ASSISTED INSTALLER FOR LABS
########################################################################
```

## Dependencies
- Create and update required configuration files:
  - [`/opt/assisted-service/onprem-environment`](./onprem-environment)
  - [`/opt/assisted-service/nginx-ui.conf`](./nginx-ui.conf)

## Deploying Assisted Installer onprem (podman)

```
export OAS_UI_IMAGE=quay.io/ocpmetal/ocp-metal-ui:latest
export OAS_DB_IMAGE=quay.io/ocpmetal/postgresql-12-centos7
export OAS_HOSTDIR=/opt/assisted-service
export OAS_ENV_FILE=${OAS_HOSTDIR}/onprem-environment

podman pod create --name assisted-installer  -p 8000:8000 -p 8090:8090 -p 8888:8080

# database
podman run -dt --pod assisted-installer --env-file $OAS_ENV_FILE \
    --name db $OAS_DB_IMAGE

# ui
podman run -dt --pod assisted-installer --env-file $OAS_ENV_FILE \
    -v ${OAS_HOSTDIR}/nginx-ui.conf:/opt/bitnami/nginx/conf/server_blocks/nginx.conf:z \
    --pull always \
    --name ui $OAS_UI_IMAGE

# assisted service
podman run -dt --pod assisted-installer --env-file $OAS_ENV_FILE \
    --env DUMMY_IGNITION=False \
    --pull always \
    --user assisted-installer --restart always \
    --name installer $OAS_IMAGE
```
Note: The `--pull always` make sure the latest version is always the one in use.

- The UI will available at: `http://<host-ip-address>:8888`
- The API will available at: `http://<host-ip-address>:8090/api/assisted-install/v1/`
  (eg. `http://<host-ip-address>:8090/api/assisted-install/v1/clusters`)

## Removing Assisted Installer

```
podman pod rm -f assisted-installer | true
```

## References:
- The API for the BM Assisted Installer can be found [here](https://generator.swagger.io/?url=https://raw.githubusercontent.com/openshift/assisted-service/master/swagger.yaml)

