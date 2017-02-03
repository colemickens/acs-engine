# Contributing

## Contents

* [Usage](#usage)
* [Building](#building)
  * [Building (Docker)](#building-docker)
  * [Building (Linux)](#building-linux)
  * [Building (Windows)](#buiding-windows)
* [Deployment](#deployment)
  * [Deployment (Azure CLI)](#deployment-azure-cli)
  * [Deployment (PowerShell)](#deployment-powershell)
  * [Deployment (azure-xplat-cli)](#deployment-azure-xplat-cli)

## Usage

## Building

The recommended way of building and using `acs-engine`, *on all platforms*,
is to use Docker. It's the best way to ensure that all developers
and users are using the same tooling and environment.

### Building (Docker)

1. Enter the development environment:

  **Linux/Mac:** `./scripts/devenv.sh`
  **Windows:**  `.\scripts\devenv.ps1`

2. Run make:
  ```
  make
  ```

That's it.

### Building (Linux)

1. Ensure the `GOPATH` and `PATH` are configured. If you're unsure,
   then simply use:





## General Workflow

1. Clone repository.

2. Make changes to `parts/` directory, or `pkg/acsengine/...` as appropriate

3. Run `make` in the root of the repository.

The resulting binary will have updated template parts, as they are baked into
the binary.
