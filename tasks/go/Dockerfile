FROM golang:1.20 AS builder

ARG CMD

WORKDIR /usr/src/app

# Install task: https://taskfile.dev/
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Creates minimal /etc/group and /etc/passwd that will be copied to scratch
RUN echo 'app:x:55555:55555:App:/:/sbin/nologin' > /passwd.minimal && \
    echo 'app:x:55555:' > /group.minimal

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading
# them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .

RUN task go:build CMD=${CMD}


FROM scratch

ARG CMD

COPY --from=builder /passwd.minimal /etc/passwd
COPY --from=builder /group.minimal /etc/group
COPY --from=builder /usr/src/app/out/bin/${CMD} /app

ENV TZ=UTC

EXPOSE 8000
EXPOSE 9000

USER app:app

ENTRYPOINT ["/app"]
