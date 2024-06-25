Request VM using CNV
===========

# Configuration
Set `TARGET_NS` to the target namespace:
```console
TARGET_NS=sonataflow-infra
```

# Installation
## Persistence pre-requisites
If persistence is enbaled, you must have a PostgreSQL instance running in the cluster, in the same `namespace` as the workflows.

A `secret` containing the instance credentials must exists as well. 

See https://www.parodos.dev/orchestrator-helm-chart/postgresql on how to install a PostgreSQL instance. Please follow the section detailing how to install using helm. In this document, a `secret` holding the credentials is created.


## Installing helm chart 
From `charts` folder run 
```console
helm install request-vm-cnv request-vm-cnv --namespace=${TARGET_NS}
```

### Post-installation
#### Persistence
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
      databaseSchema: request-vm-cnv
```

Make sure the above values match what is deployed on your namespace `TARGET_NS`.

You can patch the resource by running (update it if needed with your own values):
```bash
  oc patch sonataflow/request-vm-cnv \
    -n ${TARGET_NS} \
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
              "databaseSchema": "request-vm-cnv"
            }
          }
        }
      }
    }'
```

#### Environment variables

##### ConfigMap
Run the following to set the following environment variables values in the workflow:
```console
oc -n sonataflow-infra patch sonataflow request-vm-cnv --type merge -p '{
  "spec": {
    "podTemplate": {
      "container": {
        "env": [
          {
            "name": "JIRA_URL",
            "value": "<jira url>"
          },
          {
            "name": "JIRA_USERNAME",
            "value": "<jira username>"
          },
          {
            "name": "OCP_API_SERVER_URL",
            "value": "<OCP API URL>"
          },
          {
            "name": "OCP_CONSOLE_URL",
            "value": "<OCP console URL>"
          }
        ]
      }
    }
  }
}
'
```

#### Secret

We also need to set the following environment variables:
* JIRA_API_TOKEN
* OCP_API_SERVER_TOKEN

To do so, edit the secret `${WORKFLOW_NAME}-creds` and set those values and the one of `NOTIFICATIONS_BEARER_TOKEN`:
```
WORKFLOW_NAME=request-vm-cnv
oc -n sonataflow-infra patch secret "${WORKFLOW_NAME}-creds" --type merge -p '{
   "data":{
      "NOTIFICATIONS_BEARER_TOKEN":"'$(oc get secrets -n rhdh-operator backstage-backend-auth-secret -o go-template='{{ .data.BACKEND_SECRET  }}')'"
   },
   "stringData":{
      "JIRA_API_TOKEN":"{{ JIRA_API_TOKEN }}",
      "OCP_API_SERVER_TOKEN":"{{ OCP_API_SERVER_TOKEN }}"
   }
}'
```
If you are using Jira cloud, you can generate the `JIRA_API_TOKEN` using https://id.atlassian.com/manage-profile/security/api-tokens 

The `OCP_API_SERVER_TOKEN` should be associated with a service account.
