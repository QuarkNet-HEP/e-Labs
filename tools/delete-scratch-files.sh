#!/bin/bash
#
# Erase files in scratch directory - differs per-server.

TMPDIR=/home/quarkcat/tmp

find $TMPDIR -maxdepth 1 -type d -mtime +14 -exec rm -rf {} \;
