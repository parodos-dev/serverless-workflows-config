# MTA Workflow

Migration Toolkit for Application Analysis (MTA) workflow performs an evaluation of applications to determine potential risks and the associated costs of containerizing the applications. It uses the [MTA Operator](https://access.redhat.com/documentation/en-us/migration_toolkit_for_applications/6.2/html/introduction_to_the_migration_toolkit_for_applications/index) to perform the analysis.
At the end of a successful assessment workflow, a link to the report will be available in Backstage, under the notifications plugin.

## Configuration
[View the MTA README on GitHub](https://github.com/parodos-dev/serverless-workflows-helm/blob/main/charts/workflows/charts/mta/README.md)

## Installation
Run 

```console
helm install mta workflows/mta --namespace=sonataflow-infra
```

Verify MTA resources and workflow are ready:
```console
oc wait --for=jsonpath='{.status.phase}=Succeeded' -n openshift-mta csv/mta-operator.v6.2.1 --timeout=2m
oc wait --for=condition=Ready=true pods -l "app.kubernetes.io/name=mta-ui" -n openshift-mta --timeout=2m
oc wait sonataflow/mtaanalysis --for=condition=Running --timeout=2m
```