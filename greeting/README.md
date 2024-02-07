# Greeting Workflow

The greeting workflow is a basic workflow without any external dependencies.
Its purpose is to demonstrate functionality of the workflows system.

## Configuration
There is no configuration required for the greeting workflow to run.

## Installation

```console
helm install greeting workflows/greeting --namespace=sonataflow-infra
```

Verify the greeting workflow is ready:
```console
oc wait sonataflow greeting --for=condition=Running=True --timeout=5m
sonataflow.sonataflow.org/greeting condition met
```