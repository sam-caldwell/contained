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
FROM alpine:latest AS base_image

# ToDo: setup base image

# --- --- --- --- --- --- --- --- --- --- --- ---
# build_image adds golang compilers and such to the
# base_image.  Here as well we setup our tools just
# to save time.
# --- --- --- --- --- --- --- --- --- --- --- ---
FROM base_image AS build_image

# ToDo: setup build image (building go stuffs)

# --- --- --- --- --- --- --- --- --- --- --- ---
# bootstrap_builder tests and compiles the bootstrap.go
# source into a compressed and stripped binary before
# performing a final post-compression test to ensure
# upx didn't lobatimize the binary.
# --- --- --- --- --- --- --- --- --- --- --- ---
FROM build_image AS bootstrap_builder

COPY contained-bootstrap/* /opt/
WORKDIR /opt/
RUN ./build/build.sh && \
    cd / && \
    rm -rf /opt/* && \
    echo "Build completed."

# --- --- --- --- --- --- --- --- --- --- --- ---
# runtime stage is where the metal meets the meat and things
# get real.  This is the actual image that we are here for.
# We will run bootstrap as a non-root user to spawn our
# child containers and healthcheck.
# --- --- --- --- --- --- --- --- --- --- --- ---
FROM base_image AS runtime
#
# ToDo: copy the /usr/local/bin/bootstrap binary in from bootstrap_builder stage.
# ToDo: Create non-root user uid=1337, gid=1337, user:group='contained:contained'
# ToDo: Ensure bootstrap user (contained) has docker privileges.
#
USER contained
WORKDIR /opt/
ENTRYPOINT[ "/usr/local/bin/bootstrap" ]
CMD[ "/usr/local/bin/bootstrap" ]