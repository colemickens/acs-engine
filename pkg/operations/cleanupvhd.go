package operations

import (
	"fmt"

	"github.com/Azure/acs-engine/pkg/api"
	"github.com/Azure/acs-engine/pkg/armhelpers"
	"github.com/Azure/azure-sdk-for-go/arm/resources/resources"
	log "github.com/Sirupsen/logrus"
	"regexp"
)

// StorageAccountNameFormat defines the string template for storage account names
const StorageAccountNameFormat = "%s%s%sagnt0"
const osDiskBlobFormat = "k8s-%s-%s-%d-osdisk.vhd"

var (
	osDiskBlobRegex *regexp.Regexp
)

func init() {
	osDiskBlobRegex = regexp.MustCompile("k8s-([a-zA-Z0-9]+)-([0-9]+)-%d-osdisk.vhd")
}

// CleanUpOrphanedDisks deletes any OS disks in this cluster's storage accounts that do not have a corresponding
// VirtualMachine using it.
func CleanUpOrphanedDisks(az armhelpers.ACSEngineClient, goalState *api.ContainerService, logger *log.Entry) error {
	// enumerate all storage accounts possible for this cluster <- how?
	// look in each storage account
	// check for a disk name present in a map

	suffix := "123" // get from model

	// build up list of expected VHD blob names
	expectedOSDiskBlobs := []string{}
	for _, v := range goalState.Properties.AgentPoolProfiles {
		for i := 0; i < v.Count; i++ {
			diskBlobName := fmt.Sprintf(osDiskBlobFormat, v.Name, suffix, i)
			expectedOSDiskBlobs = append(expectedOSDiskBlobs, diskBlobName)
		}
	}

	// Look through all possible storage accounts
	// Look for any VHD blob that matches our regex
	// If not expected, add to list of VHDs to purge

	// METHOD 1
	// loop through storage accounts
	// consider any disk that matches the regex for our cluster
	// check to see if we STILL want that disk image or not

	return nil
}

// StorageAccountNamesFromParts forms a list of all possible storage account names based on the parts provided.
// Note: unlike code in the old RP, we always return all possible storage accounts for the inputs.
// Thus, it is expected that 'count' always be the full count of VMs, not just the count we're scaling by.
func StorageAccountNamesFromParts(count int, prefixes []string, suffix string) []string {
	accounts := []string{}
	for idx := 0; idx < count; idx++ {
		prefix1 := prefixes[idx%len(prefixes)]
		prefix2 := prefixes[idx/len(prefixes)]
		accounts = append(accounts, getStorageAccountName(prefix1, prefix2, suffix))
	}
	return accounts
}

func getStorageAccountName(prefix1, prefix2, suffix string) string {
	return fmt.Sprintf(StorageAccountNameFormat, prefix1, prefix2, suffix)
}

func enumerateStorageAccounts(deployment resources.DeploymentExtended) []string {

	return []string{"1", "2"}
}
