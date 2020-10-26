# Assisted Service onprem

```
####################################
# Before deployment
####################################
```

- Dependencies in this repo:
  - `/opt/assisted-service/onprem-environment`
  - `/opt/assisted-service/nginx-ui.conf`

```
####################################
# Deploy Assited Installer 
####################################
podman pod create --name assisted-installer -p 5432 -p 8000:8000 -p 8090:8090 -p 8080:8080

podman run -dt --pod assisted-installer --env-file /opt/assisted-service/onprem-environment \
    --name db quay.io/ocpmetal/postgresql-12-centos7

podman run -dt --pod assisted-installer --env-file /opt/assisted-service/onprem-environment \
    -v /opt/assisted-service/nginx-ui.conf:/opt/bitnami/nginx/conf/server_blocks/nginx.conf:z \
    --name ui quay.io/ocpmetal/ocp-metal-ui:latest 

podman run -dt --pod assisted-installer --env-file /opt/assisted-service/onprem-environment \
    --env DUMMY_IGNITION=False \
    --user assisted-installer  --restart always \
    --name installer quay.io/ocpmetal/assisted-service-onprem:latest
```


- The UI will available at: `http://<host-ip-address>:8080`
- The API will available at: `http://<host-ip-address>:8090/api/assisted-install/v1/` (eg. `http://<host-ip-address>:8090/api/assisted-install/v1/clusters`)

```
####################################
# Remove Assisted Installer onprem
####################################
podman pod rm -f assisted-installer | true
```

References:
- The API for the BM Assisted Installer can be found [here](https://generator.swagger.io/?url=https://raw.githubusercontent.com/openshift/assisted-service/master/swagger.yaml)

