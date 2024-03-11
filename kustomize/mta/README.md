## Prerequisites
* The manifests are generated without the `namespace` configuration
* Manifest names reflect the `resources` section of [kustomization.yaml](./base/kustomization.yaml)

A brief explanation of the system architecture is provided in the related [document](./mta.md).

## Kustomization options
### Image update
Run the following to update the default images to a custom configuration
```
cd base && kustomize edit set image serverless-workflow-mta=quay.io/orchestrator/serverless-workflow-mta:1234 && cd ..
```

## Configure properties
Edit configuration in [values.properties](./base/values.properties), [config.properties](./base/config.properties) and 
[secret.properties](./base/secret.properties) to match your environment configuration.

**Note**: in particular, please update the value of `MTA_URL` to match the URL of the route exposed by
the `mta` instance (e.g. `https://mta-openshift-mta.apps.<CLUSTER DOMAIN>/`)

## Deploy to the cluster
### Deploy the operator
The default namespace can be customized by running the following:
```bash
TARGET_NS=YOUR-NS
```
Then apply the changes with:
```bash
cd operator && kustomize edit set namespace $TARGET_NS && cd ..
```

Apply the deployment to the configured namespace with:
```bash
kustomize build operator | oc apply -f -
```
Verify the operator installed propertly:
```bash
oc get tackle -n openshift-mta -owide
```

Verify the MTA application is running:
```bash
oc get pods -n openshift-mta --watch
```

### Deploy the production environment
This environment applies the generated manifests with minimal customizations to:
* Use the latest application images
* Force the `prod` profile for the SonataFlow instance
* Deploy by default on the `sonataflow-infra` namespace
* Mount the configurations defined in [Configure properties](#configure-properties) as environment variables

The default namespace can be customized by running the following:
```bash
TARGET_NS=YOUR-NS
```
Then apply the changes with:
```bash
cd base && kustomize edit set namespace $TARGET_NS && cd ..
```

Once the configuration is set, apply the deployment to the configured namespace with:
```bash
kustomize build base | oc apply -f -
```

You can monitor the deployment status with:
```bash
oc get sonataflow mtaanalysis -n ${TARGET_NS} -owide
```

And finally view the logs with:
```bash
oc logs -f -n ${TARGET_NS} -l app=mtaanalysis
```
