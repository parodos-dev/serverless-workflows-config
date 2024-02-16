## Prerequisites
* The manifests are generated without the `namespace` configuration
* Manifest names reflect the `resources` section of [kustomization.yaml](./base/kustomization.yaml)

A brief explanation of the system architecture is provided in the related [document](./move2kube.md).

## Kustomization options
### Image update
Run the following to update the default images to a custom configuration
```
cd base && kustomize edit set image serverless-workflow-greeting=quay.io/orchestrator/serverless-workflow-greeting:1234
```

## Deploy to the cluster
### Deploy the production environment
This environment applies the generated manifests with minimal customizations to:
* Use the latest application images
* Force the `prod` profile for the SonataFlow instance
* Deploy by default on the `sonataflow-infra` namespace

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
oc get sonataflow greeting  -n sonataflow-infra -owide
```

And finally view the logs with:
```bash
oc logs -f  -n sonataflow-infra -l app=greeting
```
