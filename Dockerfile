FROM quay.io/projectquay/golang:1.24 AS builder

ARG GOOS
ARG GOARCH

WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} \
    go build -ldflags "-s -w" -o /out/multi-platform-test-app ./...

FROM quay.io/projectquay/golang:1.24

WORKDIR /app

COPY --from=builder /out/multi-platform-test-app /app/multi-platform-test-app
RUN chmod +x /app/multi-platform-test-app

ENTRYPOINT ["/app/multi-platform-test-app"]
