#!/bin/bash
#
# contained :: initialize.sh
# (c) 2019 Sam Caldwell.  See LICENSE.txt.
#
# This script will initialize a local project-specific copy of the
# contained repository.  See README.md "Getting Started" for details.
#

prompt_to_setup_remote_repo(){
    #
    # ToDo: prompt the user y/n "Do you want to connect to a remote git repo?"
    # If 'y' then get the repo address and update `git remote origin`
    # If 'n' then remind the user that the repo will be local only and that
    # any changes will not be pushed off the local machine until `git remote add` is
    # run.
    echo "Not implemented."
    exit 1 # Remove when implemented.
}



#
# main:
#
}(
    cd """$(dirname "$0")"""
    git clone git@github.com:sam-caldwell/contained-bootstrap.git
    prompt_to_setup_remote_repo
)
