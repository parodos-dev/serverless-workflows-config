Move2kube
===========

# Configuration
Set `TARGET_NS` to the target namespace:
```console
TARGET_NS=sonataflow-infra
```

We need to use `initContainers` and `securityContext` in our Knative services to allow SSH key exchange in move2kube workflow, we have to tell Knative to enable that feature:
```bash
  oc patch configmap/config-features \
    -n knative-serving \
    --type merge \
    -p '{"data":{"kubernetes.podspec-init-containers": "enabled", "kubernetes.podspec-securitycontext": "enabled"}}'

```

Also, `move2kube` instance runs as root so we need to allow the `default` service account to use `runAsUser`:
```console
oc -n ${TARGET_NS} adm policy add-scc-to-user anyuid -z default
```

Create the secret that holds the ssh keys:
```console
oc -n ${TARGET_NS} create secret generic sshkeys --from-file=id_rsa=${HOME}/.ssh/id_rsa --from-file=id_rsa.pub=${HOME}/.ssh/id_rsa.pub
```
If you change the name of the secret, you will also have to updated the value of `sshSecretName` in [values.yaml](values.yaml)

If you want to use other ssh keys you should update the `from-file` parameters values to match your own.

If you do not have ssh keys, you can generate them with `ssh-keygen` command. You can for instance refer to https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent 

Note that those ssh keys needs to be added in your git repository as well. For bitbucket it should be on the account level (https://bitbucket.org/account/settings/ssh-keys/)

# Installation
## Persistence pre-requisites
If persistence is enbaled, you must have a PostgreSQL instance running in the cluster, in the same `namespace` as the workflows.

A `secret` containing the instance credentials must exists as well. 

See https://www.parodos.dev/orchestrator-helm-chart/postgresql on how to install a PostgreSQL instance. Please follow the section detailing how to install using helm. In this document, a `secret` holding the credentials is created.


## Installing helm chart 
From `charts` folder run 
```console
helm install move2kube workflows/move2kube --namespace=${TARGET_NS}
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
      databaseSchema: m2k
```

Make sure the above values match what is deployed on your namespace `TARGET_NS`.

You can patch the resource by running (update it if needed with your own values):
```bash
  oc patch sonataflow/m2k \
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
              "databaseSchema": "m2k"
            }
          }
        }
      }
    }'
```


Run the following command to apply it to the `move2kubeURL` parameter:
```console
M2K_ROUTE=$(oc -n ${TARGET_NS} get routes move2kube-route -o yaml | yq -r .spec.host)
oc -n ${TARGET_NS} delete ksvc m2k-save-transformation-func &&
helm upgrade move2kube move2kube --namespace=${TARGET_NS} --set workflow.move2kubeURL=https://${M2K_ROUTE}
```

Then edit the `m2k-props` confimap to set the `quarkus.rest-client.move2kube_yaml.url` and `move2kube_url` properties with the value of `${M2K_ROUTE}`

Run the following to set K_SINK environment variable in the workflow:
```console
BROKER_URL=$(oc -n ${TARGET_NS} get broker -o yaml | yq -r .items[0].status.address.url)
oc -n ${TARGET_NS} patch sonataflow m2k --type merge -p '{"spec": { "podTemplate": { "container": { "env": [{"name": "K_SINK", "value": "'${BROKER_URL}'"}]}}}}'
```
