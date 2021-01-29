# OpenShift Assisted Service onprem

```bash
#####################################################################
# A PRESCRIPTIVE DEPLOYMENT OF OPENSHIFT ASSISTED INSTALLER ON PREM #
#####################################################################
```

## Dependencies
- Requires [podman](https://podman.io/)
- Requires [skopeo](https://github.com/containers/skopeo) - restricted network installs

- Create and update required configuration files:
  - [`/opt/assisted-service/onprem-environment`](./onprem-environment)
  - [`/opt/assisted-service/nginx-ui.conf`](./nginx-ui.conf)

## Restricted Network installs
- Be sure to mirror required images for the OpenShift Assisted Service if installing on a network that cannot access `quay.io` or `registry.redhat.io` directly.
- `assisted-restrictednetwork-images.sh` is provided to assist with this task.

## Running Assisted Service

- To start the assisted service

  ```bash
  ./start-assisted-service.sh
  ```

- To stop the assisted service

  ```bash
  ./stop-assisted-service.sh
  ```

## Using Assisted Service

- The UI will available at: `http://<host-ip-address>:8888`
- The API will available at: `http://<host-ip-address>:8090/api/assisted-install/v1/`
  (eg. `http://<host-ip-address>:8090/api/assisted-install/v1/clusters`)

## References

- The API for the BM Assisted Installer can be found [here](https://generator.swagger.io/?url=https://raw.githubusercontent.com/openshift/assisted-service/master/swagger.yaml)
