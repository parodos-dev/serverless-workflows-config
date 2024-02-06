## Prerequisites
* The manifests are generated without the `namespace` configuration
* Manifest names reflect the `resources` section of [kustomization.yaml](./base/kustomization.yaml)

## Configure properties
Edit configuration in [config.properties](./overlays/prod/config.properties) and [secret.properties](./overlays/prod/secret.properties).
Apply the deployment to the target namespace:
```bash
TARGET_NS=sonataflow-infra
kustomize build  overlays/prod | oc apply -n ${TARGET_NS} -f -
```
