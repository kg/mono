#!/usr/bin/env bash

# run build-icu.sh successfully first

set -u
set -e
set -x

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOPDIR="$SCRIPTDIR/../../../"
ICU4C="$SCRIPTDIR/icu-git/icu4c/source"
ICUOUT="$ICU4C/build/data-out"
ICUTMP="$ICU4C/build/data-tmp"

pushd $ICU4C

LD_LIBRARY_PATH=build/lib:$PATH PYTHONPATH=./python:${PYTHONPATH:-} python3 -m icutools.databuilder --mode=unix-exec --out_dir $ICUOUT --tmp_dir $ICUTMP --src_dir ./data --tool_dir ./build/bin

popd