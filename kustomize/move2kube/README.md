## Prerequisites
* The manifests are generated without the `namespace` configuration
* Manifest names reflect the `resources` section of [kustomization.yaml](./base/kustomization.yaml)

A brief explanation of the system architecture is provided in the related [document](./move2kube.md).

## Kustomization options
### Image update
Run the following to update the default images to a custom configuration
```
cd base && kustomize edit set image serverless-workflow-move2kube=quay.io/orchestrator/serverless-workflow-move2kube:1234 && cd ..
cd base && kustomize edit set image serverless-workflow-m2k-kfunc=quay.io/orchestrator/serverless-workflow-m2k-kfunc:1234 && cd ..
```

## Configure properties
Edit configuration in [replace-config.yaml](./base/replace-config.yaml), [config.properties](./base/config.properties) and 
[secret.properties](./base/secret.properties) to match your environment configuration.

## Deploy to the cluster
### Deploy the production environment
This environment applies the generated manifests with minimal customizations to:
* Use the latest application images
* Force the `prod` profile for the SonataFlow instance
* Deploy by default on the `sonataflow-infra` namespace
* Mount the configurations defined in [Configure properties](#configure-properties) as environment variables

The default namespace can be customized with:
```bash
TARGET_NS=YOUR-NS
cd base && kustomize edit set namespace=$TARGET_NS && cd ..
```

Once the configuration is set, apply the deployment to the configured namespace with:
```bash
kustomize build base | oc apply -f -
```

You can monitor the deployment status with:
```bash
oc get sonataflow m2k -n sonataflow-infra -owide
```

And finally view the logs with:
```bash
oc logs -f -n sonataflow-infra -l app=m2k
```

### Notes about transformation from Helm chart
* The Helm values is converted to a `move2kube-values` ConfigMap and we use a replacement configuration to update the affected fields one by one, as in
  [replace-config.yaml](./base/replace-config.yamll)
  * The original [YAML](../../charts/workflows/charts/move2kube/values.yaml) is converted to a [properties file](./base/values.properties)
  * The original Helm variable references were transformed accordingly, e.g. `{{ .Values.instance.name }}` is changed to `__instance_name__`
  * The following properties are not managed as values but they were either not used in the chart or we map them differently (e.g. using the image transformer in [kustomization.yaml](./base/kustomization.yaml)):
```
# namespace=sonataflow-infra
# workflow_backstageNotificationURL=http://orchestrator-backstage.orchestrator/api/notifications
# kfunction_image=quay.io/orchestrator/serverless-workflow-m2k-kfunc:latest
# workflow_move2kubeURL=https://move2kube-route-sonataflow-infra.apps.cluster-8xfw.redhatworkshops.io
# workflow_image=quay.io/orchestrator/serverless-workflow-move2kube:latest
```
* In the chart, the name of some resources combined the workflow name to a fixed string. This is no more applicable using the kustomize replacements, because
 it replaces the full content of a target path
  * We left on purpose some "errors" of this kind as in:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: __instance_name__-svc
...
```
  The above name is completely replaced to `name: move2kube`
* Other properties are defined in [config.properties](./base/config.properties) and allow the deployer to define the runtime environment (we can simplify that [values.properties](./base/values.properties) defines instead the deployment configuration)
  * These are mounted to the services that require such customization, e.g. the `SonataFlow` instance and the `m2k-save-transformation-func` Knative Service

You can run the following diff to highlight the main changes:
```bash
diff -r base/ ../../charts/workflows/charts/move2kube/templates
```