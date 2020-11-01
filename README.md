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
# Note:
# - TCP/5432 Postgres: There is no need to export the PostgreSQL port (5432) outside the Pod
# - TCP/8000: UI
# - TCP/8090: API
# - TCP/8080: Retrieve ISO

#podman pod create --name assisted-installer -p 5432:5432 -p 8000:8000 -p 8090:8090 -p 8080:8080

podman pod create --name assisted-installer -p 8000:8000 -p 8090:8090 -p 8080:8080

podman run -dt --pod assisted-installer --env-file /opt/assisted-service/onprem-environment \
    --name db quay.io/ocpmetal/postgresql-12-centos7

podman run -dt --pod assisted-installer --env-file /opt/assisted-service/onprem-environment \
    --pull always \
    -v /opt/assisted-service/nginx-ui.conf:/opt/bitnami/nginx/conf/server_blocks/nginx.conf:z \
    --name ui quay.io/ocpmetal/ocp-metal-ui:latest 

podman run -dt --pod assisted-installer --env-file /opt/assisted-service/onprem-environment \
    --env DUMMY_IGNITION=False \
    --pull always \
    --user assisted-installer  --restart always \
    --name installer quay.io/ocpmetal/assisted-service-onprem:latest
```
Note: The `--pull always` make sure the latest version is always the one in use.

- The UI will available at: `http://<host-ip-address>:8080`
- The API will available at: `http://<host-ip-address>:8090/api/assisted-install/v1/`
  (eg. `http://<host-ip-address>:8090/api/assisted-install/v1/clusters`)

## Removing Assisted Installer

```
podman pod rm -f assisted-installer | true
```

## References:
- The API for the BM Assisted Installer can be found [here](https://generator.swagger.io/?url=https://raw.githubusercontent.com/openshift/assisted-service/master/swagger.yaml)

