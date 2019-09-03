#!/bin/bash -e
#
# contained :: build.sh
(
    cd """$(dirname "$0")"""
    cd ..
    [[ ! -f Dockerfile ]] && {
        echo "Missing Dockerfile"
        exit 1
    }
    docker build --compress --tag contained:local . || {
        echo "contained:local build failed."
        exit 2
    }
    [[ "$(docker run -i contained:local /bin/sh -c 'bootstrap noop')" == 'OK' ]] || {
        echo "contained:local post build noop test failed."
        exit 3
    }
    echo "contained:local build successful."
    exit 0
)