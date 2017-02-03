#!/usr/bin/env bash

set -eu -o pipefail
set -x

docker build --pull -t acs-engine .

docker run -it \
	--volume="$(pwd):/gopath/src/github.com/Azure/acs-engine" \
	--env=TERM=xterm \
		acs-engine /bin/bash -l

