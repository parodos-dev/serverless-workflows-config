# Greeting Workflow

The greeting workflow is a basic workflow without any external dependencies.
Its purpose is to demonstrate functionality of the workflows system.

## Configuration
There is no configuration required for the greeting workflow to run.

## Installation

```console
helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-helm
helm install greeting orchestrator-workflows/workflows --set greeting.enabled=true
```

Verify the greeting workflow is ready:
```console
oc wait sonataflow greeting --for=condition=Running=True --timeout=5m
sonataflow.sonataflow.org/greeting condition met
```