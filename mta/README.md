# MTA Workflow

Migration Toolkit for Application Analysis (MTA) workflow performs an evaluation of applications to determine potential risks and the associated costs of containerizing the applications. It uses the [MTA Operator](https://access.redhat.com/documentation/en-us/migration_toolkit_for_applications/6.2/html/introduction_to_the_migration_toolkit_for_applications/index) to perform the analysis.
At the end of a successful assessment workflow, a link to the report will be available in Backstage, under the notifications plugin.

## Configuration
[View the MTA README on GitHub](https://github.com/parodos-dev/serverless-workflows-helm/blob/main/charts/workflows/charts/mta/README.md)

## Installation
- Run 
```console
helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-helm
helm install mta orchestrator-workflows/workflows --set greeting.enabled=false --set move2kube.enabled=false
```

- Edit the `mtaanalysis-props` confimap to set the `mta.url` with the value of the following command:
```console
echo "https://"$(oc -n openshift-mta get route mta -o yaml | yq -r .spec.host)
```

And to edit the configmap:
```console
oc -n <namespace> edit configmap mtaanalysis-props
```

- Verify MTA resources and workflow are ready:
```console
sleep 120s # to wait until the MTA operator has created all requested resources
oc wait --for=jsonpath='{.status.phase}=Succeeded' -n openshift-mta csv/mta-operator.v6.2.2 --timeout=2m
oc wait --for=condition=Ready=true pods -l "app.kubernetes.io/name=mta-ui" -n openshift-mta --timeout=2m
oc wait sonataflow/mtaanalysis --for=condition=Running --timeout=2m
```