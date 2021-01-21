# Assisted Service onprem

```bash
########################################################################
# A PRESCRIPTIVE ONPREMISE DEPLOYMENT OF ASSISTED INSTALLER FOR LABS
########################################################################
```

## Dependencies
- Requires [podman](https://podman.io/)

- Create and update required configuration files:
  - [`/opt/assisted-service/onprem-environment`](./onprem-environment)
  - [`/opt/assisted-service/nginx-ui.conf`](./nginx-ui.conf)

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
