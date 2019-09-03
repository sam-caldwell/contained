#!/bin/sh -e
#
# build.sh
# (c) 2019 Sam Caldwell.  See LICENSE.txt.
# ---
# This script builds the bootstrap binary, strips out debugging symbols and
# compresses the artifact.
#

binary_file=build/bootstrap

echo "Starting bootstrap build process."
rm -rf build/*

go test && \
echo "tests pass...building artifact..." && \
\
go build -a -ldflags '-s -w -extldflags "-static"' -o "${binary_file}" bootstrap.go && \
echo "build complete.  Setting executable permissions." && \
\
chmod +x "${binary_file}" && \
\
echo "Running noop mode to test health of the executable before compression." && \
echo "TEST: $(${binary_file} noop)" && \
echo "Binary size: $(ls -lah ${binary_file} | awk '{print $5}')" && \
\
echo "Compressing the binary ${binary_file}" && \
/usr/bin/upx -9 ${binary_file} && \
echo "Binary size: $(ls -lah ${binary_file} | awk '{print $5}')" && \
\
echo "Running noop mode to test health of the compressed executable." && \
echo "TEST: $(${binary_file} noop)" && \
echo "done.  Bootstrap has been built." && \
exit 0

echo "An error occurred."
exit 1