## Prerequisites
* The manifests are generated without the `namespace` configuration
* Manifest names reflect the `resources` section of [kustomization.yaml](./base/kustomization.yaml)

A brief explanation of the system architecture is provided in the related [document](./escalation.md).

## Kustomization options
### Image update
Run the following to update the default image to a custom configuration
```
cd overlays/prod && kustomize edit set image serverless-workflow-escalation=quay.io/orchestrator/serverless-workflow-escalation:1234
```

## Configure properties
Edit configuration in [config.properties](./overlays/prod/config.properties) and [secret.properties](./overlays/prod/secret.properties)
to match your environment configuration.

## Deploy to the cluster
### Deploy the production environment
This environment applies the generated manifests with minimal customizations to:
* Use the latest application images
* Force the `prod` profile for the SonataFlow instance
* Deploy by default on the `sonataflow-infra` namespace
* Mount the configurations defined in [Configure properties](#configure-properties) as environment variables

The default namespace can be customized with:
```bash
TARGET_NS=YOUR-NS
cd base && kustomize edit set namespace=$TARGET_NS && cd ..
```

Once the configuration is set, apply the deployment to the configured namespace with:
```bash
kustomize build overlays/prod | oc apply -f -
```
### Deploy the letsencrypt environment
See [Deploying with Let's Encrypt certificates](./letsencrypt.md) for a detailed description of this use case. 

Apply the deployment to the configured namespace with:
```bash
kustomize build overlays/letsencrypt | oc apply -f -
```

## Configuring the Jira server
### API token
To interact with Jira server using the [REST APIs])https://developer.atlassian.com/server/jira/platform/rest-apis/, you need an API Token.
Follow these instructions to generate one and use it as the `JIRA_API_TOKEN` in [secret.properties](./overlays/prod/secret.properties):
* [API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
* [Basic auth for REST APIs](https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/)

### Webhook
First, initialize the `JIRA_WEBHOOK_URL` variable according to the selected environment.

In case of `production` environment:
```bash
JIRA_LISTENER_URL=$(oc get ksvc -n sonataflow-infra jira-listener -oyaml | yq '.status.address.url')
JIRA_WEBHOOK_URL="https://${JIRA_LISTENER_URL//\"/}/webhook/jira"
```

Otherwise, in case of `letsencrypt` environment:
```bash
JIRA_LISTENER_URL=$(oc get route -n knative-serving-ingress jira-listener -oyaml | yq '.status.ingress[0].host')
JIRA_WEBHOOK_URL="https://${JIRA_LISTENER_URL//\"/}/webhook/jira"
```

If you use Jira Cloud, you can create the webhook at https://_YOUR_JIRA_/plugins/servlet/webhooks, then:
* Configure `Issue related event` of type `update`
* Use the value of `JIRA_WEBHOOK_URL` calculated before as the URL

[Jira webhook](../doc/webhook.png)

The webhook event format is exaplained in [Issue: Get issue](https://docs.atlassian.com/software/jira/docs/api/REST/9.11.0/#api/2/issue-getIssue),
see an [Example](https://jira.atlassian.com/rest/api/2/issue/JRA-2000)

In case of issues receiving the events, you can troubleshoot using [RequestBin](https://requestbin.com/), see [How to collect data to troubleshoot WebHook failure in Jira](https://confluence.atlassian.com/jirakb/how-to-collect-data-to-troubleshoot-webhook-failure-in-jira-397083035.html)
