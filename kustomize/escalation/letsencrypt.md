# Deploying with Let's Encrypt certificates
## Problem statement
On OpenShift clusters configured to publish a self signed certificate, when you enable the automatic route creation in Knative services you can
probably hit this error if you try to `curl` to one of the exposed `https` endpoint:
```
curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

`curl` can by-pass this problem using the `-k` option to "Allow insecure server connections", but 
> Jira Cloud's built-in webhooks can handle sending requests over SSL to hosts using publicly signed certificates
so we need a workaround to have a publicly signed certificate instead.

The first step is to disable the automatic Route using the following annotation in the `jira-listener` service:
```yaml
  annotations:
    serving.knative.openshift.io/disableRoute: "true"
```

Then, we can use the [Let's Encrypt](https://letsencrypt.org/) service to leverage its free publicly-signed certificates, following this
discussion on [Securing Jira Webhooks](https://community.atlassian.com/t5/Jira-questions/Securing-Jira-Webhooks/qaq-p/1850259).

## Installing the Let's Encrypt operator
To install the operator, execute the following procedure that is not integrated with the provided deployment and comes from this [article](https://developer.ibm.com/tutorials/secure-red-hat-openshift-routes-with-lets-encrypt/):
```bash
oc new-project acme-operator
oc create -n acme-operator \
  -fhttps://raw.githubusercontent.com/tnozicka/openshift-acme/master/deploy/cluster-wide/{clusterrole,serviceaccount,issuer-letsencrypt-live,deployment}.yaml
oc create clusterrolebinding openshift-acme --clusterrole=openshift-acme --serviceaccount="$( oc project -q ):openshift-acme" --dry-run=client -o yaml | oc create -f -
```

Run the following to uninstall the Let's Encrypt operator:
```bash
oc delete clusterrolebinding openshift-acme
oc delete -n acme-operator \
  -fhttps://raw.githubusercontent.com/tnozicka/openshift-acme/master/deploy/cluster-wide/{clusterrole,serviceaccount,issuer-letsencrypt-live,deployment}.yaml
oc delete project acme-operator
```

## The letsencrypt overlay
The `letsencrypt` overlay of the kustomize project generates a Route in `knative-serving-ingress` namespace with the proper annotation to expose the publicly-signed certificate, e.g.:
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    haproxy.router.openshift.io/timeout: 600s 
    kubernetes.io/tls-acme: "true"
  name: jira-listener 
  namespace: knative-serving-ingress 
...
```

Please note that:
* The Route must be in the `knative-serving-ingress` namespace
* The `host` must expose the `jira-listener` Service and it's made of:
```
{{ jira-listener service name }}-{{ namespace }}.{{ cluster domain }}
```
* The configuration is provided by the `host` property defined [here](./overlays/letsencrypt/route.properties). **You must update this configuration before the deployment**.

## Troubleshooting hints
### Duplicate Certificate Limit error
`Let's Encrypt` allows 5 certificate requests per week for each unique set of hostnames requested for the certificate.

The issue is detected when the `jira-listener` service is not receiving any webhook event, and the Route uses an `http`
protocol instead of the expected `https`.

To overcome this issue, you can define a different name for the `jira-listener` service (all references must be updated).

**Note**: you can easily hit this error if the OpenShift cluster is running in a VPN environment. The workaround in this case is to install a self signed certificate. 

### SAN short enough to fit in CN issue
The generated hostname cannot exceed the 64 characters as described in: [Let's Encrypt (NewOrder request did not include a SAN short enough to fit in CN)](https://support.cpanel.net/hc/en-us/articles/4405807056023-Let-s-Encrypt-NewOrder-request-did-not-include-a-SAN-short-enough-to-fit-in-CN-)
>This error occurs when attempting to request an SSL certificate from Let's Encrypt for a domain name longer than 64 characters