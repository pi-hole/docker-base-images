#!/bin/bash

# Walk subdirectories
for dir in ./*/
do
        pushd "$dir"
        if ! docker build .; then
          echo "$dir - FAILED"
          exit 1
        else
          echo "$dir - SUCCESS"
        fi
        popd
done
echo "ALL DONE"
