
Modify VM resources
===========

A Helm chart for the modify VM resources serverless workflow


# Helm chart Configuration

The following table lists the configurable parameters of the Modify VM resources chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
|                          |                         |                |

# Workflow application configuration
Please refer to [the workflow README](https://github.com/rhdhorchestrator/serverless-workflows/blob/main/workflows/modify-vm-resources/README.md#workflow-application-configuration)


# Pre-installation Configuration
Set `TARGET_NS` to the target namespace:
```console
TARGET_NS=sonataflow-infra
```

# Installation
## Pre-requisites
* Access to an OCP cluster with OpenShift Virtualization operator installed. 

## Persistence pre-requisites
If persistence is enabled, you must have a PostgreSQL instance running in the cluster, in the same `namespace` as the workflows.

A `secret` containing the instance credentials must exists as well. 

See https://www.rhdhorchestrator.io/orchestrator-helm-chart/postgresql on how to install a PostgreSQL instance. Please follow the section detailing how to install using helm. In this document, a `secret` holding the credentials is created.


## Installing helm chart 
From `charts` folder run 
```console
helm install modify-vm-resources modify-vm-resources --namespace=${TARGET_NS}
```

### Post-installation

#### Environment variables


#### Secret

We also need to set the following environment variables:
* JIRA_API_TOKEN
* OCP_API_SERVER_TOKEN

To do so, edit the secret `${WORKFLOW_NAME}-creds` and set those values and the one of `NOTIFICATIONS_BEARER_TOKEN`:
```
WORKFLOW_NAME=modify-vm-resources
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

Once the secret is updated, to have it applied, the pod shall be restarted. 
Note that the modification of the secret does not currently restart the pod, the action shall be performed manually or, if you are following the next section, any change to the sonataflow CR will restart the pod.

Note that if you run the `helm upgrade` command, the values of the secret are reseted.

##### Sontaflow CR

To ensure the workflow runs successfully, specific environment variables must be configured. If you want to run the workflow against a Backstage instance other than the default one, you need to set the `BACKSTAGE_NOTIFICATIONS_URL` environment variable to the appropriate URL of the Backstage service (using its Kubernetes service URL). 

The entry for `BACKSTAGE_NOTIFICATIONS_URL` in the command below is using the current default value, if the name of the backstage deployment or its namespace does not match, please update the value with the correct value from your cluster.

Run the following to set the following environment variables values in the workflow:
```console
oc -n sonataflow-infra patch sonataflow modify-vm-resources --type merge -p '{
  "spec": {
    "podTemplate": {
      "container": {
        "env": [
          {
            "name": "BACKSTAGE_NOTIFICATIONS_URL",
            "value": "http://backstage-backstage.rhdh-operator"
          },
          {
            "name": "JIRA_URL",
            "value": "<jira url with schema prefix (http(s)://)>"
          },
          {
            "name": "JIRA_USERNAME",
            "value": "<jira username>"
          },
          {
            "name": "OCP_API_SERVER_URL",
            "value": "<OCP API URL with schema prefix (http(s)://)>"
          },
          {
            "name": "OCP_CONSOLE_URL",
            "value": "<OCP console URL with schema prefix (http(s)://)>"
          }
        ]
      }
    }
  }
}
'
```

