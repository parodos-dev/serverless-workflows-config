MTA
===========

# Installation
From `charts` folder run 
```console
helm install mta workflows/mta --namespace=sonataflow-infra
```

Edit the `mtaanalysis-props` confimap to set the `mta.url` with the value of the following command:
```console
oc -n openshift-mta get route mta -o yaml | yq -r .spec.host
```

Then wait for all resources to be up:
```console
sleep 120s # to wait until the MTA operator has created all requested resources
oc wait --for=jsonpath='{.status.phase}=Succeeded' -n openshift-mta csv/mta-operator.v6.2.1 --timeout=2m
oc wait --for=condition=Ready=true pods -l "app.kubernetes.io/name=mta-ui" -n openshift-mta --timeout=2m
oc wait -n sonataflow-infra sonataflow/mtaanalysis --for=condition=Running --timeout=2m
```