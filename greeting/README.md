# Greeting Workflow

The greeting workflow is a basic workflow without any external dependencies.
Its purpose is to demonstrate functionality of the workflows system.

## Configuration
There is no configuration required for the greeting workflow to run.

## Installation
### Persistence pre-requisites
If persistence is enbaled, you must have a PostgreSQL instance running in the cluster, in the same `namespace` as the workflows.

A `secret` containing the instance credentials must exists as well. 

See https://www.parodos.dev/orchestrator-helm-chart/postgresql on how to install a PostgreSQL instance. Please follow the section detailing how to install using helm. In this document, a `secret` holding the credentials is created.

### Installing helm chart 


```console
helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-config
helm install greeting orchestrator-workflows/workflows --set greeting.enabled=true
```

You need to edit the `sonataflow` resource to set the correct value for the `persistence` `spec`.
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
      databaseSchema: greeting
```

Make sure the above values match what is deployed on your namespace.

You can patch the resource by running (update it if needed with your own values):
```bash
  oc patch sonataflow/greeting \
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
              "databaseSchema": "greeting"
            }
          }
        }
      }
    }'
```

Verify the greeting workflow is ready:
```console
oc wait sonataflow greeting --for=condition=Running=True --timeout=5m
sonataflow.sonataflow.org/greeting condition met
```