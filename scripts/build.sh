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
    docker build --tag contained:local .
)