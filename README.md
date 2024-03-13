## Orchestrator Workflows Helm Repository

This repository serves as a Helm chart repository for deploying serverless workflows with the Sonataflow Operator. It encompasses a collection of pre-defined workflows, each tailored to specific use cases. These workflows have undergone thorough testing and validation through Continuous Integration (CI) processes and are organized according to their chart versions.

The repository includes a variety of serverless workflows, such as:

* Greeting: A basic example workflow to demonstrate functionality.
* Migration Toolkit for Application Analysis (MTA): This workflow performs an evaluation of applications to determine potential risks and the associated costs of containerizing the applications.
* Move2Kube: Designed to facilitate the transition of an application to Kubernetes (K8s) environments.

## Usage

### Pre-requisites
o utilize the workflows contained in this repository, the Orchestrator Deployment must be installed on your OpenShift Container Platform (OCP) cluster. For detailed instructions on installing the Orchestrator, please visit the [Orchestrator Helm Repository](https://www.parodos.dev/orchestrator-helm-chart/)


## Installation
```
$ helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-helm
"orchestrator-workflows" has been added to your repositories
```

The workflows can be installed by the meta chart or individually. Visit workflows for specific details:
* [Greeting](./greeting/README.md)
* [MTA](./mta/README.md)
* [Move2Kube](./move2kube/README.md)

To install workflows by the meta-chart, run:
```
$ helm install orchestrator-workflows orchestrator-workflows/workflows --namespace=sonataflow-infra
```

Run the following command to apply it to the `move2kubeURL` parameter:
```console
M2K_ROUTE=$(oc -n sonataflow-infra get routes move2kube-route -o yaml | yq -r .spec.host)
oc -n sonataflow-infra delete ksvc m2k-save-transformation-func &&
helm upgrade  orchestrator-workflows  orchestrator-workflows/workflows --set move2kube.workflow.move2kubeURL=https://${M2K_ROUTE} --namespace=sonataflow-infra
```

Then edit the `m2k-props` confimap to set the `quarkus.rest-client.move2kube_yaml.url` and `move2kube_url` properties with the value of `${M2K_ROUTE}`

Run the following to set K_SINK environment variable in the workflow:
```console
BROKER_URL=$(oc -n sonataflow-infra get broker -o yaml | yq -r .items[0].status.address.url)
oc -n sonataflow-infra patch sonataflow m2k --type merge -p '{"spec": { "podTemplate": { "container": { "env": [{"name": "K_SINK", "value": "'${BROKER_URL}'"}]}}}}'
```

Edit the `mtaanalysis-props` confimap to set the `mta.url` with the value of the following command:
```console
oc -n openshift-mta get route mta -o yaml | yq -r .spec.host
```
And to edit the configmap:
```console
oc -n sonataflow-infra edit configmap mtaanalysis-props
```    

## Configuration

The following table lists the configurable parameters of the Workflows chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `mta.enabled` | Indicates that mta workflow is enabled | `true` |
| `greeting.enabled` | Indicates that greeting workflow is enabled | `true` |
| `move2kube.enabled` | Indicates that move2kube workflow is enabled | `true` |
