##
# CERT CONTAINER
##

FROM alpine:3.18 as certs

RUN \
apk add --no-cache ca-certificates

##
# BUILD CONTAINER
##
FROM golang:1.20.5-alpine3.17 as builder
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN apk add make
RUN make build 


##
# RELEASE CONTAINER
##

FROM busybox:1.36-musl

WORKDIR /

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/gitlab-ci-pipelines-exporter /usr/local/bin/

# Run as nobody user
USER 65534

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/gitlab-ci-pipelines-exporter"]
CMD ["run"]
