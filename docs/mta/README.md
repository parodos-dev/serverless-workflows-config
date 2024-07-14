# MTA Workflow

Migration Toolkit for Application Analysis (MTA) workflow evaluates applications to determine potential risks and the associated costs of containerizing the applications. It uses the [MTA Operator](https://access.redhat.com/documentation/en-us/migration_toolkit_for_applications/6.2/html/introduction_to_the_migration_toolkit_for_applications/index) to perform the analysis.
At the end of a successful assessment workflow, a link to the report will be available in Backstage, under the notifications plugin.

**Note**: The *MTA* workflow type functions as an assessment tool, evaluating the provided code repository and suggesting the next workflow to execute for that repository. Currently, there is a correlation between the *MTA* and *Move2Kube* workflow, where *Move2Kube* is recommended by the *MTA*. Consequently, it is necessary to install both to leverage their benefits fully.

## Configuration
View the [MTA README on GitHub](https://github.com/parodos-dev/serverless-workflows-config/blob/main/charts/mta/README.md)

## Installation
- Run 
```console
helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-config
helm install mta orchestrator-workflows/mta -n sonataflow-infra
```

### Edit the `mtaanalysis-props` ConfigMap:

There are two variables required to be set in the `mtaanalysis-props` ConfigMap:
* **mta.url** - The URL to the MTA application
* **NOTIFICATIONS_BEARER_TOKEN** - The token for sending notifications from the MTA workflow to RHDH notifications service

To set the `mta.url` with the value of the following command:
- **Please note** that it may take several minutes for the MTA Operator to become available and for the route to be reachable.
```console
while [[ $retry_count -lt 5 ]]; do
    oc -n openshift-mta get route mta && break || sleep 60
    retry_count=$((retry_count + 1))
done
echo "https://"$(oc -n openshift-mta get route mta -o yaml | yq -r .spec.host)
```

To obtain the value for `NOTIFICATIONS_BEARER_TOKEN` use the value of the following command:
```bash
oc get secrets -n rhdh-operator backstage-backend-auth-secret -o go-template='{{ .data.BACKEND_SECRET | base64decode }}'
```
Or fetch the secret from the app-config.yaml of your RHDH instance if not installed by the Orchestrator operator.

And to edit the configmap:
```console
oc -n <namespace> edit configmap mtaanalysis-props
```

- Verify MTA resources and workflow are ready:
```console
sleep 120s # to wait until the MTA operator has created all requested resources
oc wait --for=jsonpath='{.status.phase}=Succeeded' -n openshift-mta csv/mta-operator.v6.2.2 --timeout=2m
oc wait --for=condition=Ready=true pods -l "app.kubernetes.io/name=mta-ui" -n openshift-mta --timeout=2m
oc wait -n sonataflow-infra sonataflow/mtaanalysis --for=condition=Running --timeout=2m
```
