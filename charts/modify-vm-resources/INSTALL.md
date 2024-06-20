Modify VM resources
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
helm install modify-vm-resources modify-vm-resources --namespace=${TARGET_NS}
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
      databaseSchema: modify-vm-resources
```

Make sure the above values match what is deployed on your namespace `TARGET_NS`.

You can patch the resource by running (update it if needed with your own values):
```bash
  oc patch sonataflow/modify-vm-resources \
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
              "databaseSchema": "modify-vm-resources"
            }
          }
        }
      }
    }'
```


Run the following to set K_SINK and MOVE2KUBE_URL environment variables in the workflow:
```console
oc -n ${TARGET_NS} patch sonataflow modify-vm-resources --type merge -p '{"spec": { "podTemplate": { "container": { "env": [{"name": "JIRA_URL", "value": "<Jira URL>"}, {"name": "JIRA_USERNAME", "value": "<Your jira username>"}, {"name": "JIRA_API_TOKEN", "value": "<Your jira token>"}, {"name": "OCP_API_SERVER_URL", "value": "<Target openshift URL>"}, {"name": "OCP_API_SERVER_TOKEN", "value": "<Token to access the target OCP cluster>"}]}}}}'
```
Ie:
```console
oc -n ${TARGET_NS} patch sonataflow modify-vm-resources --type merge -p '{"spec":  { "podTemplate": { "container": { "env": [{"name": "JIRA_URL", "value": "https://masayag.atlassian.net"}, {"name": "JIRA_USERNAME", "value": "=moti.asayag@gmail.com"}, {"name": "JIRA_API_TOKEN", "value": "<Your jira token>"}, {"name": "OCP_API_SERVER_URL", "value": "https://api.cluster-ddf9q.dynamic.redhatworkshops.io:6443"}, {"name": "OCP_API_SERVER_TOKEN", "value": "<Token to access the target OCP cluster>"}]}}}}'
```

If you are using Jira cloud, you can generate the `JIRA_API_TOKEN` using https://id.atlassian.com/manage-profile/security/api-tokens 

The `OCP_API_SERVER_TOKEN` should be associated with a service account.
