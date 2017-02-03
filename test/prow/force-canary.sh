#!/usr/bin/env bash

# temporary hack to force us to canary for sake of testing

az cloud register -n CanaryBrazilUS \
	--endpoint-active-directory https://login.microsoftonline.com \
	--endpoint-active-directory-graph-resource-id https://graph.windows.net/ \
	--endpoint-active-directory-resource-id https://management.core.windows.net/ \
	--endpoint-gallery https://gallery.azure.com/ \
	--endpoint-management https://management.core.windows.net/ \
	--endpoint-resource-manager https://brazilus.management.azure.com \
	--suffix-storage-endpoint core.windows.net

az context create --cloud CanaryBrazilUS -n CanaryBrazilUS
