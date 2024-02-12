## Prerequisites
* The manifests are generated without the `namespace` configuration
* Manifest names reflect the `resources` section of [kustomization.yaml](./base/kustomization.yaml)

## Kustomization options
### Image update
Run the following to update the default image to a custom configuration
```
cd overlays/prod && kustomize edit set image serverless-workflow-escalation=quay.io/orchestrator/serverless-workflow-escalation@1234
```

## Configure properties
Edit configuration in [config.properties](./overlays/prod/config.properties) and [secret.properties](./overlays/prod/secret.properties).

## Deploy to the cluster
Apply the deployment to the target namespace with:
```bash
TARGET_NS=sonataflow-infra
kustomize build  overlays/prod | oc apply -n ${TARGET_NS} -f -
```
