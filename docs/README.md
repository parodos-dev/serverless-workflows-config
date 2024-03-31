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
```bash
helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-config
```

Expected output:
```console
"orchestrator-workflows" has been added to your repositories
```

The workflows can be installed by the meta chart or individually. Visit workflows for specific details:
* [Greeting]([./greeting/README.md](https://github.com/parodos-dev/serverless-workflows-config/blob/gh-pages/greeting/README.md))
* [MTA](https://github.com/parodos-dev/serverless-workflows-config/blob/gh-pages/mta/README.md)
* [Move2Kube](https://github.com/parodos-dev/serverless-workflows-config/blob/gh-pages/move2kube/README.md)

By default, all of the workflows are disabled.
To install the workflows by the parent chart, choose which workflow to install either by editing `values.yaml` or by providing additional flags to install command, e.g. `--set ${workflow-id}.enabled=true` (workflow IDs are specified in the values.yaml file):
```bash
helm install orchestrator-workflows orchestrator-workflows/workflows --set greeting.enabled=true
```

Expected output:
```console
NAME: orchestrator-workflows
LAST DEPLOYED: Sun Mar 17 13:25:18 2024
NAMESPACE: orchestrator
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

## Configuration

The following table lists the configurable parameters of the Workflows chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `mta.enabled` | Indicates that mta workflow is enabled | `false` |
| `greeting.enabled` | Indicates that greeting workflow is enabled | `false` |
| `move2kube.enabled` | Indicates that move2kube workflow is enabled | `false` |


## Helm index
[https://www.parodos.dev/serverless-workflows-config/index.yaml](https://www.parodos.dev/serverless-workflows-config/index.yaml)
