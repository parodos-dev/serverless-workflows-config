## Orchestrator Workflows Helm Repository

This repository serves as a Helm chart repository for deploying serverless workflows with the Sonataflow Operator. It encompasses a collection of pre-defined workflows, each tailored to specific use cases. These workflows have undergone thorough testing and validation through Continuous Integration (CI) processes and are organized according to their chart versions.

The repository includes a variety of serverless workflows, such as:

* Greeting: A basic example workflow to demonstrate functionality.
* Migration Toolkit for Application Analysis (MTA): This workflow evaluates applications to determine potential risks and the associated costs of containerizing the applications.
* Move2Kube: Designed to facilitate the transition of an application to Kubernetes (K8s) environments.

## Usage

### Prerequisites
To utilize the workflows contained in this repository, the Orchestrator Deployment must be installed on your OpenShift Container Platform (OCP) cluster. For detailed instructions on installing the Orchestrator, please visit the [Orchestrator Helm Repository](https://www.parodos.dev/orchestrator-helm-chart/)

**Note** With the existing version of the Orchestrator helm chart, all workflows should be created under the `sonataflow-infra` namespace.

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

## Installing workflows in another namespace
When deploying a workflow in a namespace other than the one where Sonataflow services are running (e.g., sonataflow-infra), there are two essential steps to follow if persistence is required for the workflow:
1. Create a Secret with PostgreSQL Credentials in the target namespace:
    1. The workflow needs to create its own schema in PostgreSQL. To enable this, you must create a secret containing the PostgreSQL credentials in the same namespace as the workflow.
2. Configure the Namespace Attribute:
    1. Add the namespace attribute under the serviceRef where the PostgreSQL server is deployed.

**Example Configuration:**
```
apiVersion: sonataflow.org/v1alpha08
kind: SonataFlow
...
spec:
  ...
  persistence:
    postgresql:
      secretRef:
        name: sonataflow-psql-postgresql
        passwordKey: postgres-password
        userKey: postgres-username
      serviceRef:
        databaseName: sonataflow
        databaseSchema: greeting
        name: sonataflow-psql-postgresql
        namespace: <postgresql-namespace>
        port: 5432
```
In this configuration:
* Replace <postgresql-namespace> with the namespace where the PostgreSQL server is deployed.

By following these steps, the workflow will have the necessary credentials to access PostgreSQL and will correctly reference the service in a different namespace.

## Version Compatability
The workflows rely on components included in the [Orchestrator chart](https://www.parodos.dev/orchestrator-helm-chart/). Therefore, it is crucial to match the workflow version with the corresponding Orchestrator version that supports it. The list below outlines the compatibility between the workflows and Orchestrator versions:
| Workflows          | Chart Version | Orchestrator Chart Version |
|--------------------|---------------|----------------------|
| mta-analysis       | 0.2.x         | 1.0.x                |
| mta-analysis       | 0.3.x         | 1.2.x                |
| move2kube          | 0.2.x         | 1.0.x                |
| move2kube          | 0.3.x         | 1.2.x                |
| create-ocp-project | 0.1.x         | 1.2.x                |
| request-vm-cnv     | 0.1.x         | 1.2.x                |
| modify-vm-resources| 0.1.x         | 1.2.x                |
| mta-v6             | 0.2.x         | 1.2.x                |
| mta-v7             | 0.2.x         | 1.2.x                |
| mtv-migration      | 0.0.x         | 1.2.x                |
| mtv-plan           | 0.0.x         | 1.2.x                |


## Helm index
[https://www.parodos.dev/serverless-workflows-config/index.yaml](https://www.parodos.dev/serverless-workflows-config/index.yaml)
