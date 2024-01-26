Move2kube
===========

# Configuration

We need to use `initContainers` and `securityContext` in our Knative services to allow SSH key exchange in move2kube workflow, we have to tell Knative to enable that feature:
```bash
  oc patch configmap/config-features \
    -n knative-serving \
    --type merge \
    -p '{"data":{"kubernetes.podspec-init-containers": "enabled", "kubernetes.podspec-securitycontext": "enabled"}}'

```

Also, `move2kube` instance runs as root so we need to allow the `default` service account to use `runAsUser`:
```console
oc -n sonataflow-infra adm policy add-scc-to-user anyuid -z default
```

Create the secret that holds the ssh keys:
```console
oc create secret generic sshkeys --from-file=id_rsa=${HOME}/.ssh/id_rsa --from-file=id_rsa.pub=${HOME}/.ssh/id_rsa.pub -n sonataflow-infra
```
If you change the name of the secret, you will also have to updated the value of `sshSecretName` in [values.yaml](values.yaml)

If you want to use other ssh keys you should update the `from-file` parameters values to match your own.

If you do not have ssh keys, you can generate them with `ssh-keygen` command. You can for instance refer to https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent 

Note that those ssh keys needs to be added in your git repository as well. For bitbucket it should be on the account level (https://bitbucket.org/account/settings/ssh-keys/)

# Installation


From `charts` folder run 
```console
helm install move2kube orchestrator/move2kube
```

Get the route of the move2kube instance:
```console
$ oc -n sonataflow-infra get routes move2kube-route 

move2kube-route   move2kube-route-sonataflow-infra.apps.cluster-8xfw6.dynamic.redhatworkshops.io          move2kube-svc   <all>   edge          None
```

and run the following command to apply it to the `move2kubeURL` parameter:
```console
oc -n sonataflow-infra delete ksvc m2k-save-transformation-func &&
 helm upgrade move2kube move2kube --set workflow.move2kubeURL=<url> &&
 oc -n sonataflow-infra scale deployment serverless-workflow-m2k --replicas=0 &&
 oc -n sonataflow-infra scale deployment serverless-workflow-m2k --replicas=1
```

In all of the above commands, the namespace `sonataflow-infra` is used. Beware that the `namespace` shall be the same as the one specify in [values.yaml](values.yaml) under the `namespace` property.