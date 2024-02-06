MTA
===========

# Installation
From `charts` folder run 
```console
helm install mta workflows/mta --namespace=sonataflow-infra
```

Then wait for all resources to be up:
```console
oc wait --for=jsonpath='{.status.phase}=Succeeded' -n openshift-mta csv/mta-operator.v6.2.1 --timeout=2m
oc wait --for=condition=Ready=true pods -l "app.kubernetes.io/name=mta-ui" -n openshift-mta --timeout=2m
oc wait -n sonataflow-infra sonataflow/mtaanalysis --for=condition=Running --timeout=2m
```