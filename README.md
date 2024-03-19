# serverless-workflows-config

serverless workflows helm charts 

This is a chart repo for serverless workflows to be deployed using Sonataflow Operator.
All the workflows address defined use-cases, tested and validated using CI, and versioned by the chart version.

The chart contains the workflows and all their needed dependencies and it may reference other workflows chart repo 
by dependency resolution, meaning we don't have to have all the worklflows definition here. 
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

To install the workflow from sources directly:
- Clone the project
- Choose which workflow to install either by editing `values.yaml` or by providing additional flags to install command, e.g. `--set ${workflow-id}.enabled=true`:
```
git clone git@github.com:parodos-dev/serverless-workflows-config.git
cd serverless-workflows-config/charts
helm install orchestrator-workflows workflows
```

For installing the workflows from Helm repository, see further installation steps and detailed explanation for each workflow [here](https://github.com/parodos-dev/serverless-workflows-config/tree/gh-pages?tab=readme-ov-file#installation) or [here](https://www.parodos.dev/serverless-workflows-config/).
      
# Development
To generate `values.schema.json`, next to your `values.yaml` file, run: 
```
npx @socialgouv/helm-schema -f values.yaml
```

To generate `README.md`, run:
```
frigate gen <path to the chart folder> README.md
```

To bump a new chart version, use `./hack/bump_version.sh`