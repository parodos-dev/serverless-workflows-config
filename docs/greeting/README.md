# Greeting Workflow

The greeting workflow is a basic workflow without any external dependencies.
Its purpose is to demonstrate functionality of the workflows system.

## Configuration
There is no configuration required for the greeting workflow to run.
The chart and the workflow are installed in `sonataflow-infra`.

```console
helm repo add orchestrator-workflows https://parodos.dev/serverless-workflows-config
helm install greeting orchestrator-workflows/greeting -n sonataflow-infra
```

Verify the greeting workflow is ready:
```console
oc wait sonataflow greeting -n sonataflow-infra --for=condition=Running=True --timeout=5m
sonataflow.sonataflow.org/greeting condition met
```