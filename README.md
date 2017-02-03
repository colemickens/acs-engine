# Azure Container Service Engine - Container Freedom

## Overview

The Azure Container Service Engine (`acs-engine`) generates ARM (Azure Resource Manager) templates which deploy a container orchestrator on Microsoft Azure. This tool consumes an "apimodel" which is very similar to (and in many cases, the same as) the ARM template object used to deploy an Azure Container Service cluster.

The cluster definition file enables the following customizations to your Docker enabled cluster:
* choice of DC/OS, Kubernetes, or Swarm orchestrators
* multiple agent pools where each agent pool can specify:
 * standard or premium VM Sizes,
 * node count, 
 * Virtual Machine ScaleSets or Availability Sets,
 * Storage Account Disks or Managed Disks (under private preview),
* Docker cluster sizes of 1200
* Custom VNET

## Azure Container Service vs ACS-Engine

[Azure Container Service] (ACS) is Microsoft Azure's container orchestration solution.
It offers installations of Kubernetes, DCOS, Swarm and Swarm Mode.

[ACS-Engine] is the open-source core of the [Azure Container Service].
This project is used to enable new features in the ACS, as well as host
experimental modifications that may never make their way to the hosted Service,
due to licensing, supportability, or other reasons.

[Other Frequently Asked Questions]()

## Documentation

* [Frequently Asked Questions](faq.md) - FAQs about `acs-engine` each orchestrator
* [Development](docs/development.md) - how to build `acs-engine`, how to add features to the apimodel
    (possibly to contribute back)
* [Customization](docs/customization.md) - how to customize your cluster deployments (custom
    virtual network, managed disks, etc) by enabling features in your apimodel
* [Usage](docs/usage.md) - how to use `acs-engine` to create an ARM template for a container orchestrator
    cluster from an apimodel
    (possibly to contribute back)
* [Development](docs/development.md) - how to build `acs-engine`, how to add features to the apimodel
    (possibly to contribute back)

* [Walkthrough: Kubernetes](docs/walkthroughs/kubernetes.md)
* [Walkthrough: Swarm](docs/walkthroughs/swarm.md)
* [Walkthrough: Swarm Mode](docs/walkthroughs/swarmmode.md)
* [Walkthrough: DCOS](docs/walkthroughs/dcos.md)

## Simple Usage

This is the normal manual way of using ACS-Engine, you may be interested
in [the quick advanced usage](usage.md#usage-quick).

1. Clone the repo and enter the directory
  ```
  git clone https://github.com/Azure/acs-engine
  cd acs-engine
  ```

2. Enter the development environment:

  This assumes usage of `docker` (or Docker for Windows/Mac).
  (Alternatives: [building under Windows](), [building under Mac]()).

  **Linux/Mac:** `./scripts/devenv.sh`
  **Windows:**  `.\scripts\devenv.ps1`

3. Create a cluster defintion from an example:
  1. Copy a cluster definition from `examples/`.
  2. Name it `clusterdefinition.json`.
  3. Edit it:
    * Add your SSH Key
    * Edit the FQDNs as appropriate
    * Edit the ServicePrincipalProfile section (Kubernetes only)

4. Generate the ARM Template and Parameters
  **Linux/Mac:** `./acs-engine clusterdefinition.json`
  **Windows:**  `.\acs-engine.exe clusterdefinition.json`

5. Checkout the Generated Assets
  ```
  cd _output/<instance>
  ```

  In this directory, you will find the generated assets, such as
  ARM template, parameters file, and in the case of Kubernetes,
  the generated PKI assets and the kubeconfig(s).


4. Create a Resource Group and Deployment

  This step assumes usage of the [Azure CLI](https://github.com/Azure/azure-cli).
  (Alternatives: [deploy with PowerShell](), [deploy with legacy azure-xplat-cli]())

  ```
  az resource group create --name "somename" --location "westus2"

  az group deployment create --name "somename-deployment1"
    --template-file "azuredeploy.json" \
    --parameters "@azuredeploy.parameters.json"
  ```

5. You're done. You can now use your SSH credentials with the appropriate domain
   name for your cluster. With Kubernetes, you probably want to just use the
   kubeconfig file, such as `kubeconfig.westus2.json`.

## Further Reading

Please follow these instructions before submitting a PR:

1. Execute `make ci` to run the checkin validation tests.

2. Manually test deployments if you are making modifications to the templates.
   For example, if you have to change the expected resulting templates then you
   should deploy the relevant example cluster definitions to ensure you're not
   introducing any sort of regression.

### Developer Guide

* [Quick Usage](docs/development.md): shows you how to build and use the ACS engine to generate custom Docker enabled container clusters

* [Cluster Definition](docs/clusterdefinition.md) - describes the components of the cluster definition file
* [DC/OS Walkthrough](docs/dcos.md) - shows how to create a DC/OS enabled Docker cluster on Azure
* [Kubernetes Walkthrough](docs/kubernetes.md) - shows how to create a Kubernetes enabled Docker cluster on Azure
* [Swarm Walkthrough](docs/swarm.md) - shows how to create a Swarm enabled Docker cluster on Azure
* [DockerCE Walkthrough](docs/swarmmode.md) - shows how to create a DockerCE cluster on Azure
* [Custom VNET](examples/vnet) - shows how to use a custom VNET 
* [Attached Disks](examples/disks-storageaccount) - shows how to attach up to 4 disks per node
* [Managed Disks](examples/disks-managed) (under private preview) - shows how to use managed disks 
* [Large Clusters](examples/largeclusters) - shows how to create cluster sizes of up to 1200 nodes

## Code of conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


# Contributing

## Contents

* [Building](#building)
  * [Building (Docker)](#building-docker)
  * [Building (Linux)](#building-linux)
  * [Building (Windows)](#buiding-windows)
* [Deployment](#deployment)
  * [Deployment (Azure CLI)](#deployment-azure-cli)
  * [Deployment (PowerShell)](#deployment-powershell)
  * [Deployment (azure-xplat-cli)](#deployment-azure-xplat-cli)
* [Usage](#usage)

## Building

The recommended way of building and using `acs-engine`, *on all platforms*,
is to use Docker. It's the best way to ensure that all developers
and users are using the same tooling and environment.

### Building (Docker) (recommended!)

This will allow you to edit source code on your normal
machine, while building and executing `acs-engine` in a
Docker container where everything is configured. The output
files created in the container will still be available
after you exit.

1. Enter the development environment:

  **Linux/Mac:** `./scripts/devenv.sh`
  **Windows:**  `.\scripts\devenv.ps1`

2. Run make:
  ```
  make
  ```

### Building (Linux)

1. Ensure Go is installed.
2. Ensure the `GOPATH` and `PATH` are configured.
3. Run `make`.

### Building (Windows)

1. Ensure Go is installed.
2. Ensure the 

## Usage

```
# acs-engine
Usage of acs-engine:
  -artifacts string
    	directory where artifacts will be written
  -caCertificatePath string
    	the path to the CA Certificate file
  -caKeyPath string
    	the path to the CA key file
  -classicMode
    	enable classic parameters and outputs
  -noPrettyPrint
    	do not pretty print output
  -parametersOnly
    	only output the parameters
```

