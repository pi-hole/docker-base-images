#!/bin/bash

# exit when any command fails
set -e

# Walk subdirectories
for dir in ./*/
do
        pushd "$dir"
        docker build .
        popd
done
