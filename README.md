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

## Configuration

The following table lists the configurable parameters of the Workflows chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `mta.enabled` | Indicates that mta workflow is enabled | `true` |
| `greeting.enabled` | Indicates that greeting workflow is enabled | `true` |
| `move2kube.enabled` | Indicates that move2kube workflow is enabled | `true` |
