# Move2kube Workflow

## Configuration
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
If you change the name of the secret, you will also have to provide the value of `sshSecretName` when installing the helm chart(`--set sshSecretName=<name of the secret>`)

The list of the overridable values can be found in our [git repository](https://github.com/parodos-dev/serverless-workflows-config/blob/main/charts/move2kube/values.yaml)

If you want to use other ssh keys you should update the `from-file` parameter values to match your own.

If you do not have ssh keys, you can generate them with `ssh-keygen` command. You can for instance refer to https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent 

Note that those ssh keys need to be added to your git repository as well. For bitbucket, it should be on the [account level](https://bitbucket.org/account/settings/ssh-keys/)

View the [Move2Kube README](https://github.com/parodos-dev/serverless-workflows-config/blob/main/charts/move2kube/README.md) on GitHub.

## Installation

Run 
```console
helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-config
helm install move2kube orchestrator-workflows/move2kube -n ${TARGET_NS}
```
Run the following command or follow the steps prompted at the end of the workflow installation to apply it to the `move2kubeURL` parameter:
```console
M2K_ROUTE=$(oc -n ${TARGET_NS} get routes move2kube-route -o yaml | yq -r .spec.host)
oc -n ${TARGET_NS} delete ksvc m2k-save-transformation-func &&
  helm upgrade move2kube orchestrator-workflows/move2kube -n ${TARGET_NS} --set workflow.move2kubeURL=https://${M2K_ROUTE}
```

Then edit the `m2k-props` confimap to set the `quarkus.rest-client.move2kube_yaml.url` and `move2kube_url` properties with the value of `${M2K_ROUTE}`
```
oc edit -n sonataflow-infra configmaps m2k-props
```

Run the following to set K_SINK environment variable in the workflow:
```console
BROKER_URL=$(oc -n ${TARGET_NS} get broker -o yaml | yq -r .items[0].status.address.url)
oc -n ${TARGET_NS} patch sonataflow m2k --type merge -p '{"spec": { "podTemplate": { "container": { "env": [{"name": "K_SINK", "value": "'${BROKER_URL}'"}]}}}}'
```

There is a variable required to be set in the `m2k-props` ConfigMap:
* **NOTIFICATIONS_BEARER_TOKEN** - The token for sending notifications from the m2k workflow to RHDH notifications service

To obtain the value for `NOTIFICATIONS_BEARER_TOKEN` use the value of the following command:
```bash
oc get secrets -n rhdh-operator backstage-backend-auth-secret -o go-template='{{ .data.BACKEND_SECRET | base64decode }}'
```
Or fetch the secret from the app-config.yaml of your RHDH instance if not installed by the Orchestrator operator.

And to edit the configmap:
```console
oc -n <namespace> edit configmap m2k-props
```

**Please note:** Running the upgrade of the chart will cause the NOTIFICATIONS_BEARER_TOKEN value to be reverted. This will be addressed later.
For this version, there is a need to repeat the step of setting the NOTIFICATIONS_BEARER_TOKEN in the configmap after the upgrade of the chart.
