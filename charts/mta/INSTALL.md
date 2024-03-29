MTA
===========

# Installation
## Persistence pre-requisites
If persistence is enbaled, you must have a PostgreSQL instance running in the cluster, in the same `namespace` as the workflows.

A `secret` containing the instance credentials must exists as well. 

See https://www.parodos.dev/orchestrator-helm-chart/postgresql on how to install a PostgreSQL instance. Please follow the section detailing how to install using helm. In this document, a `secret` holding the credentials is created.

## Installing helm chart 
From `charts` folder run 
```console
helm install mta workflows/mta
```

Edit the `mtaanalysis-props` confimap to set the `mta.url` with the value of the following command:
```console
oc -n openshift-mta get route mta -o yaml | yq -r .spec.host
```

Edit the `sonataflow` resource to set the correct value for the `persistence` `spec`.
The defaults are:
```
persistence:
  postgresql:
    secretRef:
      name: sonataflow-psql-postgresql
      userKey: postgres-username
      passwordKey: postgres-password
    serviceRef:
      name: sonataflow-psql-postgresql
      port: 5432
      databaseName: sonataflow
      databaseSchema: mtaanalysis
```

Make sure the above values match what is deployed on your namespace.

You can patch the resource by running (update it if needed with your own values):
```bash
  oc patch sonataflow/mtaanalysis \
    --type merge \
    -p '
    {
      "spec": {
        "persistence": {
          "postgresql": {
            "secretRef": {
              "name": "sonataflow-psql-postgresql",
              "userKey": "postgres-username",
              "passwordKey": "postgres-password"
            },
            "serviceRef": {
              "name": "sonataflow-psql-postgresql",
              "port": 5432,
              "databaseName": "sonataflow",
              "databaseSchema": "mtaanalysis"
            }
          }
        }
      }
    }'
```

Then wait for all resources to be up:
```console
sleep 120s # to wait until the MTA operator has created all requested resources
oc wait --for=jsonpath='{.status.phase}=Succeeded' -n openshift-mta csv/mta-operator.v6.2.2 --timeout=2m
oc wait --for=condition=Ready=true pods -l "app.kubernetes.io/name=mta-ui" -n openshift-mta --timeout=2m
oc wait sonataflow/mtaanalysis --for=condition=Running --timeout=2m
```
