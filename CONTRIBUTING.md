# Contribution guide

**Want to contribute? Great!** 
We try to make it easy, and all contributions, even the smaller ones, are more than welcome.
This includes bug reports, fixes, documentation, examples... 
But first, read this page (including the small print at the end).

## Legal



## Issues

We are using [JIRA to manage and report issues](https://issues.redhat.com/projects/FLPATH).

If you believe you found a bug, please indicate a way to reproduce it, what you are seeing and what you would expect to see. Don't forget to indicate your Sonataflow, Java, Maven, Quarkus/Spring, Helm, K8s/OCP, GraalVM version. 


## Creating a Pull Request (PR)

To contribute, use GitHub Pull Requests, from your **own** fork. 

- PRs should be always related to an open JIRA issue. If there is none, you should create one.
- Try to fix only one issue per PR.
- Make sure to create a new branch. Usually branches are named after the JIRA ticket they are addressing. E.g. for ticket "FLPATH-XYZ An example issue" your branch should be at least prefixed with `FLPATH-XYZ`. E.g.:

        git checkout -b FLPATH-XYZ
        # or
        git checkout -b FLPATH-XYZ-my-fix

- When you submit your PR, make sure to include the ticket ID, and its title; e.g., "FLPATH-XYZ An example issue".
- The description of your PR should describe the code you wrote. The issue that is solved should be at least described properly in the corresponding JIRA ticket. 
- If your contribution spans across multiple repositories, 
  use the same branch name (e.g. `FLPATH-XYZ`) in each PR 
- If your contribution spans across multiple repositories, make sure to list all the related PRs.


## Setup

If you have not done so on this machine, you need to:
 
* Install Helm
* Be logged in to an OCP cluster (to test)


## Requirements

* The newly created Helm chart shall be located in its own folder: `charts/<workflow name>`
* The workflow for which you want to create a new Helm chart shall be in the [production repository](https://github.com/parodos-dev/serverless-workflows) and be througfully tested.
* Values in `values.yaml` shall have a description
* Each Helm chart shall have a `README.md` and `values.schema`.json files generated
* Each Helm chart shall have the orchestrator icon:
`icon: https://raw.githubusercontent.com/parodos-dev/parodos-dev.github.io/main/assets/images/WO_black.svg
`


## The small print

This project is an open source project, please act responsibly, be nice, polite and enjoy!

