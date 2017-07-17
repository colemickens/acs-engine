package cmd

import (
	"testing"

	"github.com/Azure/acs-engine/pkg/api"
	log "github.com/Sirupsen/logrus"
)

const ExampleAPIModel = `{
  "apiVersion": "vlabs",
  "properties": {
    "orchestratorProfile": { "orchestratorType": "Kubernetes" },
    "masterProfile": { "count": 1, "dnsPrefix": "", "vmSize": "Standard_D2_v2" },
    "agentPoolProfiles": [ { "name": "linuxpool1", "count": 2, "vmSize": "Standard_D2_v2", "availabilityProfile": "AvailabilitySet" } ],
    "windowsProfile": { "adminUsername": "azureuser", "adminPassword": "replacepassword1234$" },
    "linuxProfile": { "adminUsername": "azureuser", "ssh": { "publicKeys": [ { "keyData": "" } ] }
    },
    "servicePrincipalProfile": { "servicePrincipalClientID": "", "servicePrincipalClientSecret": "" }
  }
}
`

func TestAutofillApimodel(t *testing.T) {
	// reuse the sparsely populated apimodel file in 'api' pkg
	cs, ver, err := api.DeserializeContainerService([]byte(ExampleAPIModel), false)
	if err != nil {
		t.Fatalf("unexpected error deserializing the example apimodel: %s", err)
	}

	// deserialization happens in validate(), but we are testing just the default
	// setting that occurs in autofillApimodel (which is called from validate)
	// Thus, it assumes that containerService/apiVersion are already populated
	deployCmd := &deployCmd{
		apimodelPath:    "./this/is/unused.json",
		dnsPrefix:       "dnsPrefix1",
		outputDirectory: "dummy/path/",
		location:        "westus",
	}

	autofillApimodel(deployCmd)

	// again, inelegant, but will suffice for now
	rawVersionedAPIModel, err := api.SerializeContainerService(cs, ver)
	if err != nil {
		log.Fatalf("Failed to serialize the apimodel to validate it after populating values: %s", err)
	}
	_, _, err = api.DeserializeContainerService(rawVersionedAPIModel, true)
	if err != nil {
		log.Fatalf("error validating the api model: %s", err)
	}
}
