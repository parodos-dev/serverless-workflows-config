# System Architecture
As described by the following architectural diagram, the system is made of the following services:
1. `ticketescalation` the escalation workflow application, modelled as a SonataFlow instance (and related deployments and resources managed by the operator)
2. `jira-listener` a Quarkus service deployed as a serverless Knative Service to monitor webhook events from the configured Jira Server and transform them into [Cloud Events](https://cloudevents.io/) to trigger the `ticketescalation` workflow
3. `event-display` another serverless Service whose purpose is to connect to the event broker and print the Cloud Events sent to the broker
4. `newsletter-postgres` is a regular OpensShift Deployment which implements the subscription data store with a PosgreSQL database

## System architecture: application layer
``mermaid
graph LR
    ticketescalation-sf(<b>SonataFlow</b><br/>ticketescalation-flow)
    ticketescalation(<b>Deployment</b><br/>ticketescalation-flow)
    01-ticketescalation-resources(<b>ConfigMap</b><br/>01-ticketescalation-resources)
    ticketescalation-props(<b>ConfigMap</b><br/>ticketescalation-props)
    escalation-config(<b>ConfigMap</b><br/>escalation-config)
    escalation-secret(<b>Secret</b><br/>escalation-secret)
    
    ticketescalation-sf --create--> ticketescalation
    01-ticketescalation-resources --mount specs--> ticketescalation
    ticketescalation-props --mount props--> ticketescalation
    escalation-config --mount env--> ticketescalation
    escalation-secret --mount env--> ticketescalation
```

## System architecture: eventing layer
```mermaid
graph LR
    jira-server(Jira Server)
    jira-listener(<b>serving.knative.dev.Service</b><br/>jira-listener)
    event-display(<b>serving.knative.dev.Service</b><br/>event-display)
    ticketescalation(<b>Deployment</b><br/>ticketescalation-flow)

    ticket-events[<b>eventing.knative.dev.Broker</b><br/>ticket-events]
    ticket-closed(<b>Trigger</b><br/>ticket-closed)
    event-display-trigger(<b>Trigger</b><br/>event-display-trigger)
    ticket-source(<b>SinkBinding</b><br/>ticket-source)

    jira-server --webhook event--> jira-listener

    ticket-closed --broker--> ticket-events
    ticket-closed --subscriber--> ticketescalation
    event-display-trigger --broker--> ticket-events
    event-display-trigger --subscriber--> event-display
    ticket-source --subject<br/>env.K_SINK--> jira-listener
    ticket-source --sink--> ticket-events
```

## System architecture: data flow
```mermaid
graph LR
    jira-server(Jira Server)
    jira-listener(<b>serving.knative.dev.Service</b><br/>jira-listener)
    event-display(<b>serving.knative.dev.Service</b><br/>event-display)
    ticketescalation(<b>Deployment</b><br/>ticketescalation-flow)

    ticket-events[<b>eventing.knative.dev.Broker</b><br/>ticket-events]

    jira-server --webhook event--> jira-listener

    jira-listener --transform and</br> forward--> ticket-events
    ticket-events --forwards--> ticketescalation
    ticket-events --forwards--> event-display
```