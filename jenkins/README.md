# Deploy Jenkins

### Overview

This will setup the testing infrastructure for ACS-Engine.

### Deploy: Kubernetes on Azure

```
export SUBSCRIPTION_ID=
export TENANT_ID=
export SUBSCRIPTION_ID=""
export TENANT_ID=""
export SERVICE_PRINCIPAL_CLIENT_ID=""
export SERVICE_PRINCIPAL_CLIENT_SECRET=""

export INSTANCE_NAME="acs-engine-jenkins"
export LOCATION="westus2"

<acs-engine>/scripts/deploy-msi.sh
```

### Deploy: Jenkins on Kubernetes

```shell
export JENKINS_GITHUB_PERSONAL_ACCESS_TOKEN=""
export JENKINS_SERVICE_PRINCIPAL_CLIENT_ID=""
export JENKINS_SERVICE_PRINCIPAL_CLIENT_SECRET=""
export JENKINS_SUBSCRIPTION_ID=""
export JENKINS_TENANT_ID=""

<acs-engine>/test/jenkins/deploy/deploy-jenkins.sh
```

### Authentication

1. Put the kubeconfig/etc assets in KeyVault.

2. People access the cluster via portforwarding? Don't have to worry about SSH or configuring GitHub auth
