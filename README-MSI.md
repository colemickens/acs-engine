# MSI-enabled ACS-Engine

## Goal

Get us the heck out of SP land finally.

## Problems with this so far

1. ARM RBAC GUID crap, weird trick, up to 9 nodes with this current hack
2. No MSI IMDS (ugh)
3. No CRP IMDS (ugh x 1000)
4. Relies on hidden, unpublished ARM schema version that is going to be reverted soon too...
5. It's sloooooow. That's extensions though. MSI should be our path AWAY from extensions.... see #2...
6. Annnnnnd we're back over ARM's string template expression limit. Booo :(.

## Cleanup to this before merge

1. Always adds MSI extension, need to have an API toggle for opting into it and it needs to then be conditionally included
2. Make ./deploy-msi.sh use a special config dir for Azure so we don't clobber ourselves

## Usage/Demo

Note: deployer must be owner, not just contributor (because it needs to be able to do ARM RBAC assignment)

```
export SERVICE_PRINCIPAL_CLIENT_ID=""
export SERVICE_PRINCIPAL_CLIENT_SECRET=""
export TENANT_ID=""
export SUBSCRIPTION_ID=""

# use this so that it retries until it hits an ARM worker that works
./scripts/deploy-msi-retry.sh
```

## Random

Wait, how is bburn's soak working? whats the deploy script?? or is it all in jenkins?? :(
