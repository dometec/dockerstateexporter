# Immagine multi-architettura (linux/amd64, linux/arm64). Dipendenze fissate in go.mod/go.sum: le stesse del
# binario della 1.0.0 (ricavate con "go version -m"), perché senza go.mod "go mod tidy" scaricava sempre le
# ultime versioni e la build si era rotta. Go compila nativamente sulla piattaforma di build e produce il binario
# per la piattaforma di destinazione (TARGETARCH): nessuna emulazione per arm64.
FROM --platform=$BUILDPLATFORM golang:alpine AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download && go mod verify
COPY *.go ./
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -ldflags="-w -s" -o /go/bin/docker_state_exporter

FROM alpine:3
RUN apk upgrade --no-cache
COPY --from=builder /go/bin/docker_state_exporter /go/bin/docker_state_exporter
EXPOSE 8080
ENTRYPOINT ["/go/bin/docker_state_exporter"]
CMD ["-listen-address=:8080"]
