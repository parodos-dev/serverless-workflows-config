# serverless-workflows-helm

*UNDER DEVELOPMENT*

serverless workflows helm charts 

This is a chart repo for serverless workflows to be deployed using Sonataflow Operator.
All the workflows address defined use-cases, tested and validated using CI, and versioned by the chart version.

The chart contains the workflows and all their needed dependencies and it may reference other workflows chart repo 
by dependency resolution, meaning we don't have to have all the worlflows definition here. 
Consider this chart as a meta chart or template chart for other workflows or sub-workflows:

```
/
  charts/              
    workflows/
      Chart.yaml
      values.yaml
      charts/
        workflow-1/
          Chart.yaml
          values.yaml
          templates/
        workflow-2-0.1.0.tgz
        workflow-3-0.1.1.tgz
```

Notice that workflow-1 has the code embedded while workflow-2 and 3 is a dependency resolved from the root Chart.yaml


# Usage      

```
helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-helm
helm install orchestrator-workflows orchestrator-workflows/workflows
```

Run the following command to apply it to the `move2kubeURL` parameter:
```console
M2K_ROUTE=$(oc get routes move2kube-route -o yaml | yq -r .spec.host)
oc delete ksvc m2k-save-transformation-func &&
helm upgrade  orchestrator-workflows orchestrator-workflows/workflows --set move2kube.workflow.move2kubeURL=https://${M2K_ROUTE}
```

Then edit the `m2k-props` confimap to set the `quarkus.rest-client.move2kube_yaml.url` and `move2kube_url` properties with the value of `${M2K_ROUTE}`

Run the following to set K_SINK environment variable in the workflow:
```console
BROKER_URL=$(oc get broker -o yaml | yq -r .items[0].status.address.url)
oc patch sonataflow m2k --type merge -p '{"spec": { "podTemplate": { "container": { "env": [{"name": "K_SINK", "value": "'${BROKER_URL}'"}]}}}}'
```

Edit the `mtaanalysis-props` confimap to set the `mta.url` with the value of the following command:
```console
oc -n openshift-mta get route mta -o yaml | yq -r .spec.host
```
      
To generate `values.schema.json`, next to you `values.yaml` file, run: 
```
npx @socialgouv/helm-schema -f values.yaml
```

To generate `README.md`, run:
```
frigate gen <path to the chart folder> README.md
```
