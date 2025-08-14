APP ?= multi-platform-test-app
REGISTRY ?= ghcr.io/dionisz
HOST_GOOS := $(shell go env GOOS)
HOST_GOARCH := $(shell go env GOARCH)
VERSION ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")-$(shell git rev-parse --short HEAD 2>/dev/null || echo "dev")
IMAGE := $(REGISTRY)/$(APP):$(VERSION)-$(HOST_GOOS)-$(HOST_GOARCH)

all: build image

format:
	gofmt -s -w ./

get:
	go get

# Build a local binary
build: format get
	CGO_ENABLED=0 GOOS=$(HOST_GOOS) GOARCH=$(HOST_GOARCH) go build -v -o bin/$(APP)-$(HOST_GOOS)-$(HOST_GOARCH) ./...

#Image built for host platform
image:
	docker build --pull \
		--build-arg GOOS=$(HOST_GOOS) \
		--build-arg GOARCH=$(HOST_GOARCH) \
		-t $(IMAGE) .

# Targets for different platforms
linux:
	docker build --pull --build-arg GOOS=linux --build-arg GOARCH=amd64 -t $(REGISTRY)/$(APP):$(VERSION)-linux-amd64 .

arm:
	docker build --pull --build-arg GOOS=linux --build-arg GOARCH=arm64 -t $(REGISTRY)/$(APP):$(VERSION)-linux-arm64 .

macos:
	docker build --pull --build-arg GOOS=darwin --build-arg GOARCH=arm64 -t $(REGISTRY)/$(APP):$(VERSION)-darwin-arm64 .

windows:
	docker build --pull --build-arg GOOS=windows --build-arg GOARCH=amd64 -t $(REGISTRY)/$(APP):$(VERSION)-windows-amd64 .

# Run the image built for the host (only works if image matches host kernel/arch)
run:
	docker run --rm $(IMAGE)

# Remove images build by this Makefile (requirement: use docker rmi <IMAGE_TAG>)
clean:
	@echo "Removing image $(IMAGE)"
	-docker rmi $(IMAGE) || true
	@echo "Removing local bins"
	-rm -rf bin || true
