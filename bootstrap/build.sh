#!/bin/sh
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
chmod +x "${binary_file}" && \
echo "done." && \
exit 0

echo "An error occurred."