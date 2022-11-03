#!/bin/bash

COL_NC="\x1b[0m"
COL_BOLD="\x1b[1m"
COL_GREEN="\x1b[32m"
COL_RED="\x1b[91m"

# Walk subdirectories
for dir in ./*/
do
        pushd "$dir"
        if ! docker build .; then
          echo -e "${COL_BOLD}  $dir - ${COL_RED}FAILED${COL_NC}"
          exit 1
        else
          echo -e "${COL_BOLD}  $dir - ${COL_GREEN}SUCCESS${COL_NC}"
        fi
        popd
done
echo "ALL DONE"
