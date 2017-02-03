.NOTPARALLEL:
.PHONY: prereqs build test validate-generated lint ci devenv

all: build

devenv:
	./scripts/devenv.sh

prereqs:
	go get github.com/jteeuwen/go-bindata/...

build: prereqs
	go generate -v ./...
	go get -d ./...
	go build -v

test:
	go test -v ./...

validate-generated: prereqs
	./scripts/validate-generated.sh

lint:
	# TODO: fix lint errors, enable linting
	# golint -set_exit_status

ci: validate-generated build test lint

devenv:
	./scripts/devenv.sh
