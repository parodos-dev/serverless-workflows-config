## Orchestrator Workflows Helm Repository

This repository serves as a Helm chart repository for deploying serverless workflows with the Sonataflow Operator. It encompasses a collection of pre-defined workflows, each tailored to specific use cases. These workflows have undergone thorough testing and validation through Continuous Integration (CI) processes and are organized according to their chart versions.

The repository includes a variety of serverless workflows, such as:

* Greeting: A basic example workflow to demonstrate functionality.
* Migration Toolkit for Application Analysis (MTA): This workflow performs an evaluation of applications to determine potential risks and the associated costs of containerizing the applications.
* Move2Kube: Designed to facilitate the transition of an application to Kubernetes (K8s) environments.

## Usage

### Pre-requisites
To utilize the workflows contained in this repository, the Orchestrator Deployment must be installed on your OpenShift Container Platform (OCP) cluster. For detailed instructions on installing the Orchestrator, please visit the [Orchestrator Helm Repository](https://www.parodos.dev/orchestrator-helm-chart/)

The workflows are configured to utilize persistence, which entails each workflow storing its data on its dedicated schema. To enable this functionality, the configuration depends on the existence of a Kubernetes secret called `sonataflow-psql-postgresql` within the same namespace as the workflow. This secret must contain the following keys:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sonataflow-psql-postgresql
  namespace: sonataflow-infra
data:
  postgres-password: <set password>
  postgres-username: <set username>
type: Opaque
```

To deploy workflows in different namespaces and utilize the same secret details, you should replicate the secret into the target namespace of the workflows. For instance, you can copy the secret into the `default` namespace as follows:
```bash
kubectl get secret sonataflow-psql-postgresql --namespace=sonataflow-infra -o yaml | sed 's/namespace: .*/namespace: default/' | kubectl apply -f -
```

## Installation
```bash
helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-config
```

View available workflows on the Helm repository:
```
helm search repo orchestrator-workflows
```

The expected result should look like (with different versions):
```
NAME                            	CHART VERSION	APP VERSION	DESCRIPTION                                      
orchestrator-workflows/greeting 	0.4.2        	1.16.0     	A Helm chart for the greeting serverless workflow
orchestrator-workflows/move2kube	0.2.16       	1.16.0     	A Helm chart to deploy the move2kube workflow.   
orchestrator-workflows/mta      	0.2.16       	1.16.0     	A Helm chart for MTA serverless workflow         
orchestrator-workflows/workflows	0.2.24       	1.16.0     	A Helm chart for serverless workflows
```

You can install each workflow separately. For detailed information, please visit the page of each workflow:
* [Greeting](https://github.com/parodos-dev/serverless-workflows-config/blob/gh-pages/docs/greeting/README.md)
* [MTA](https://github.com/parodos-dev/serverless-workflows-config/blob/gh-pages/docs/mta/README.md)
* [Move2Kube](https://github.com/parodos-dev/serverless-workflows-config/blob/gh-pages/docs/move2kube/README.md)

## Helm index
[https://www.parodos.dev/serverless-workflows-config/index.yaml](https://www.parodos.dev/serverless-workflows-config/index.yaml)
