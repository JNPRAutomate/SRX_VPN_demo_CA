#!/bin/bash
binaries="openssl sed cut head grep"
for i in $binaries; do
  if ! which $i &>/dev/null ; then
    echo -e "\nMissing $i binary, exiting.\n"
    exit 1
  fi
done
exit 0
