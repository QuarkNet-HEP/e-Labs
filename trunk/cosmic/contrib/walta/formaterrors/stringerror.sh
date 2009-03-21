#!/bin/bash
# stringerror.exe will count for an entire file list.
# to identify strange files, I want to run this on single files
# over and over again.

for file in $*
do
  ./stringerror.exe ${file}
done
