#!/usr/bin/env bash

# This requires a successful fetch-icu. build-icu is not required because
#  to run tests we need a full data package, not a filtered one
# You can enable threading by passing -jN to test-icu.sh

set -u
set -e
set -x

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOPDIR="$SCRIPTDIR/../../../"
ICU4C="$SCRIPTDIR/icu-git/icu4c/source"

pushd $SCRIPTDIR

mkdir -p $ICU4C/test-build
cd $ICU4C/test-build
# note: without --disable-extras, make check will run the uconv tests and they may fail
../configure --disable-renaming --disable-samples --with-data-packaging=library --disable-extras
make ${1-}

# the -w flag turns errors into warnings so we get a full test run
INTLTEST_OPTS=-w CINTLTST_OPTS=-w make check ${1-}

popd