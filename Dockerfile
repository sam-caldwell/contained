# contained
# (c) 2019 Sam Caldwell.  See LICENSE.txt.
#
# This dockerfile is the wrapper container at the heart of contained.
# See README.md for usage.
#
# --- --- --- --- --- --- --- --- --- --- --- ---
# base_image is used twice: builder and runtime.
# This is a very generic stage that can save us
# a lot of time.
# --- --- --- --- --- --- --- --- --- --- --- ---
FROM alpine:3.10 AS base_image

# Make sure we are setting up name resolution properly.
RUN [[ ! -e /etc/nsswitch.conf ]] && \
        echo 'hosts: files dns' > /etc/nsswitch.conf

RUN apk update && \
    apk add --no-cache \
        ca-certificates \
        docker && \
    echo "base image ready."

# --- --- --- --- --- --- --- --- --- --- --- ---
# build_image adds golang compilers and such to the
# base_image.  Here as well we setup our tools just
# to save time.
# --- --- --- --- --- --- --- --- --- --- --- ---
FROM base_image AS build_image
#
# See https://golang.org/doc/install/source#environment
# for documentation on how this thing works...in theory.
#
RUN set -eux
ENV GOLANG_VERSION=1.12.9
#Warning: Enabling cgo could create a whole set of security risks.
ENV CGO_ENABLED=0
ENV GOPATH /opt/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
ENV GOHASH='ab0e56ed9c4732a653ed22e232652709afbf573e710f56a07f7fdeca578d62fc *go.tgz'

RUN apk add --no-cache --virtual .build-deps \
	    bash \
		gcc \
		go \
        musl-dev \
		openssl

RUN export \
		GOARCH="$(go env GOARCH)" \
		GOHOSTARCH="$(go env GOHOSTARCH)" \
		GOHOSTOS="$(go env GOHOSTOS)" \
		GOOS="$(go env GOOS)" \
		GOROOT_BOOTSTRAP="$(go env GOROOT)"; \
	wget -O go.tgz "https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz"; \
	echo "${GOHASH}" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	cd /usr/local/go/src; \
	./make.bash; \
	rm -rf \
		/usr/local/go/pkg/bootstrap \
		/usr/local/go/pkg/obj; \
	apk del .build-deps; \
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
    chmod -R 777 "$GOPATH"

WORKDIR $GOPATH

# --- --- --- --- --- --- --- --- --- --- --- ---
# bootstrap_builder tests and compiles the bootstrap.go
# source into a compressed and stripped binary before
# performing a final post-compression test to ensure
# upx didn't lobatimize the binary.
# --- --- --- --- --- --- --- --- --- --- --- ---
FROM build_image AS bootstrap_builder

COPY bootstrap/* /usr/local/src/
WORKDIR /usr/local/src/
RUN ls /usr/local/src && \
    /usr/local/src/build.sh && \
    cd / && \
    echo "Build completed."

# --- --- --- --- --- --- --- --- --- --- --- ---
# runtime stage is where the metal meets the meat and things
# get real.  This is the actual image that we are here for.
# We will run bootstrap as a non-root user to spawn our
# child containers and healthcheck.
# --- --- --- --- --- --- --- --- --- --- --- ---
FROM base_image AS runtime

COPY --from=bootstrap_builder /usr/local/src/build/bootstrap /usr/local/bin/

RUN adduser -s /bin/false -S -D -H -u 1337 -G docker contained

USER contained

WORKDIR /opt/

#ENTRYPOINT [ "/usr/local/bin/bootstrap" ]
#CMD [ "/usr/local/bin/bootstrap" ]