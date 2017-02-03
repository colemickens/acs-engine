.NOTPARALLEL:
.PHONY: prereqs build test validate-generated lint ci devenv

#IMAGE=docker.io/azurecontainers/acs-engine:latest
IMAGE=docker.io/colemickens/acs-engine:latest

all: build

prereqs:
	go get github.com/jteeuwen/go-bindata/...
	go get github.com/shurcooL/markdownfmt

build: prereqs
	go generate -v ./...
	go get -d ./...
	go build -v

fmt:
	gofmt -l -s -w ./...
	markdownfmt ./...

test:
	go test -v ./...

validate-generated: prereqs
	./scripts/validate-generated.sh

lint:
	# TODO: fix lint errors, enable linting
	# golint -set_exit_status

ci: validate-generated build test lint

publish:
	docker build -t $(IMAGE)
	docker push $(IMAGE)

devenv:
	./scripts/devenv.sh
