package operations

import (
	"github.com/Azure/acs-engine/pkg/armhelpers"
	log "github.com/Sirupsen/logrus"
)

// PowerOffVirtualMachine powers off a VM.
func PowerOffVirtualMachine(az armhelpers.ACSEngineClient, logger *log.Entry, resourceGroup, name string) error {
	logger.Infof("powering off VM start: %s/%s", resourceGroup, name)

	_, errChan := az.PowerOffVirtualMachine(resourceGroup, name, nil)
	if err := <-errChan; err != nil {
		logger.Errorf("failed to poweroff VM: %s/%s: %s", resourceGroup, name, err.Error())
		return err
	}

	logger.Infof("powering off VM complete: %s/%s", resourceGroup, name)
	return nil
}
