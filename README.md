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
helm install orchestrator-workflows serverless-workflows/workflows
```
      
To generate `values.schema.json`, next to you `values.yaml` file, run: 
```
npx @socialgouv/helm-schema -f values.yaml
```

To generate `README.md`, run:
```
frigate gen <path to the chart folder> README.md
```
