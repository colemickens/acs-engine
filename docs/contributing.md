# Contributing

## Contents

* [Building](#building)
  * [Building (Docker)](#building-docker)
  * [Building (Linux/macOS)](#building-linux-macos)
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

### Building (Linux/macOS)

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

