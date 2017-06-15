package operations

import (
	"fmt"

	"github.com/Azure/acs-engine/pkg/armhelpers"
	"github.com/Azure/azure-sdk-for-go/arm/resources/resources"
	log "github.com/Sirupsen/logrus"
)

// StorageAccountNameFormat defines the string template for storage account names
const StorageAccountNameFormat = "%s%s%sagnt0"

// OSDiskRegex is a regex that can be used to match VHD URIs from Azure storage accounts
// If there is a match, the parts returned are [PREFIX], [SUFFIX], etc.
const OSDiskRegex = "https://something/%s/%s.%s.vhd"

// DeleteOrphanedOSDisks deletes any OS disks in this cluster's storage accounts that do not have a corresponding
// VirtualMachine using it.
func DeleteOrphanedOSDisks(az armhelpers.ACSEngineClient, count int, suffix string, logger *log.Entry) error {
	// enumerate all storage accounts possible for this cluster <- how?
	// look in each storage account
	// check for a disk name present in a map

	// build up list of expected OS Disks

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

// CleanDeleteVirtualMachine deletes a VM and any associated OS disk
func CleanDeleteVirtualMachine(az armhelpers.ACSEngineClient, logger *log.Entry, resourceGroup, name string) error {
	logger.Infof("fetching VM: %s/%s", resourceGroup, name)
	vm, err := az.GetVirtualMachine(resourceGroup, name)
	if err != nil {
		logger.Errorf("failed to get VM: %s/%s: %s", resourceGroup, name, err.Error())
		return err
	}

	// NOTE: This code assumes a non-managed disk!
	vhd := vm.VirtualMachineProperties.StorageProfile.OsDisk.Vhd
	if vhd == nil {
		logger.Warnf("found an OS Disk with no VHD URI. This is probably a VM with a managed disk")
		return fmt.Errorf("os disk does not have a VHD URI")
	}
	accountName, vhdContainer, vhdBlob, err := armhelpers.SplitBlobURI(*vhd.URI)
	if err != nil {
		return err
	}

	nicID := (*vm.VirtualMachineProperties.NetworkProfile.NetworkInterfaces)[0].ID
	nicName, err := armhelpers.ResourceName(*nicID)
	if err != nil {
		return err
	}

	logger.Infof("found os disk storage reference: %s %s %s", accountName, vhdContainer, vhdBlob)
	logger.Infof("found nic name for VM (%s/%s): %s", resourceGroup, name, nicName)

	logger.Infof("deleting VM: %s/%s", resourceGroup, name)
	_, deleteErrChan := az.DeleteVirtualMachine(resourceGroup, name, nil)

	as, err := az.GetStorageClient(resourceGroup, accountName)
	if err != nil {
		return err
	}

	logger.Infof("waiting for vm deletion: %s/%s", resourceGroup, name)
	if err := <-deleteErrChan; err != nil {
		return err
	}

	logger.Infof("deleting nic: %s/%s", resourceGroup, nicName)
	_, nicErrChan := az.DeleteNetworkInterface(resourceGroup, nicName, nil)
	if err != nil {
		return err
	}

	logger.Infof("deleting blob: %s/%s", vhdContainer, vhdBlob)
	if err = as.DeleteBlob(vhdContainer, vhdBlob); err != nil {
		return err
	}

	logger.Infof("waiting for nic deletion: %s/%s", resourceGroup, nicName)
	if nicErr := <-nicErrChan; nicErr != nil {
		return nicErr
	}

	return nil
}
