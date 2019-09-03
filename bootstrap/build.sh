#!/bin/sh -e
#
# build.sh
#
# ToDo: Strip debugging symbols out of bootstrap binary.
# ToDo: Run upx compression on bootstrap binary.
# ToDo: Run bootstrap binary with 'noop' mode to ensure upx didn't leave us a dud. Expect OK.

binary_file=build/bootstrap

rm -rf build/*
go test && \
echo "tests pass...building artifact..." && \
go build -o "${binary_file}" bootstrap.go && \
echo "build complete.  Setting executable permissions." && \
\
chmod +x "${binary_file}" && \
\
echo "Running noop mode to test health of the executable before compression." && \
${binary_file} noop && \
\
echo "Compressing the binary ${binary_file}" && \
upx ${binary_file} && \
\
echo "Running noop mode to test health of the compressed executable." && \
${binary_file} noop && \
echo "done." && \
exit 0

echo "An error occurred."