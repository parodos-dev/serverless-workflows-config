# Move2kube Workflow

## Configuration
The list of the overridable values can be found in our [git repository](https://github.com/parodos-dev/serverless-workflows-config/blob/main/charts/move2kube/values.yaml)

You can also view the [Move2Kube README on GitHub](https://github.com/parodos-dev/serverless-workflows-config/blob/main/charts/move2kube/README.md)

## Prerequisites 
Set `TARGET_NS` to the target namespace:
```console
TARGET_NS=sonataflow-infra
```

### For Knative
We need to use `initContainers` and `securityContext` in our Knative services to allow SSH key exchange in move2kube workflow, we have to tell Knative to enable that feature:
```bash
  oc patch configmap/config-features \
    -n knative-serving \
    --type merge \
    -p '{"data":{"kubernetes.podspec-init-containers": "enabled", "kubernetes.podspec-securitycontext": "enabled"}}'

```
### For move2kube instance
Also, `move2kube` instance runs as root so we need to allow the `default` service account to use `runAsUser`:
```console
oc -n ${TARGET_NS} adm policy add-scc-to-user anyuid -z default
```

Create the secret that holds the ssh keys:
```console
oc -n ${TARGET_NS} create secret generic sshkeys --from-file=id_rsa=${HOME}/.ssh/id_rsa --from-file=id_rsa.pub=${HOME}/.ssh/id_rsa.pub
```
If you change the name of the secret, you will also have to provide the value of `sshSecretName` when installing the helm chart(`--set sshSecretName=<name of the secret>`)

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

## Post-installation

### Set `M2K_ROUTE` and `BROKER_URL` for the Knative service
As the Knative service cannot be updated, we need to delete if first and then re-create it with the helm command.

Run the following command or follow the steps prompted at the end of the workflow installation to apply it to the `move2kubeURL` parameter:
```console
M2K_ROUTE=$(oc -n ${TARGET_NS} get routes move2kube-route -o yaml | yq -r .spec.host)
oc -n ${TARGET_NS} delete ksvc m2k-save-transformation-func &&
  helm upgrade move2kube orchestrator-workflows/move2kube -n ${TARGET_NS} --set workflow.move2kubeURL=https://${M2K_ROUTE}
```

### Edit the `${WORKFLOW_NAME}-creds` Secret
The token for sending notifications from the m2k workflow to RHDH notifications service needs to be provided to the workflow.

Edit the secret `${WORKFLOW_NAME}-creds` and set the value of `NOTIFICATIONS_BEARER_TOKEN`:
```
WORKFLOW_NAME=m2k
oc -n ${TARGET_NS} patch secret "${WORKFLOW_NAME}-creds" --type merge -p '{"data": { "NOTIFICATIONS_BEARER_TOKEN": "'$(oc get secrets -n rhdh-operator backstage-backend-auth-secret -o go-template='{{ .data.BACKEND_SECRET  }}')'"}}'
```

This secret is used in the `sonataflow` CR to inject the token as an environment variable that will be used by the workflow.

Once the secret is updated, to have it applied, the pod shall be restarted. 
Note that the modification of the secret does not currently restart the pod, the action shall be performed manually or, if you are following the next section, any change to the sonataflow CR will restart the pod.

Note that when you run the `helm upgrade` command, the values of the secret are reseted.

### Set `M2K_ROUTE` and `K_SINK` for the Sonataflow CR

Run the following to set `K_SINK` and `MOVE2KUBE_URL` environment variable in the workflow:
```console
BROKER_URL=$(oc -n ${TARGET_NS} get broker -o yaml | yq -r .items[0].status.address.url)
oc -n ${TARGET_NS} patch sonataflow m2k --type merge -p '{"spec": { "podTemplate": { "container": { "env": [{"name": "K_SINK", "value": "'${BROKER_URL}'"}, {"name": "MOVE2KUBE_URL", "value": "https://'${M2K_ROUTE}'"}]}}}}'
```