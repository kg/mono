#!/usr/bin/env bash

set -u
set -e
set -x

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOPDIR="$SCRIPTDIR/../../../"
ICU4C="$SCRIPTDIR/icu-git/icu4c/source"

pushd $SCRIPTDIR

if [ ! -d "$SCRIPTDIR/icu-git" ] ; then
    git clone https://github.com/unicode-org/icu.git icu-git
fi
cd icu-git
git clean -xffd
git checkout -f master
git fetch origin
git reset --hard origin/master

mkdir -p $ICU4C/build
cd $ICU4C/build
ICU_DATA_FILTER_FILE=$SCRIPTDIR/filters.json ../configure --disable-renaming --disable-samples --with-data-packaging=library
make

# exit 1

mkdir -p $ICU4C/wasm-build
cd $ICU4C/wasm-build

mkdir -p $ICU4C/wasm-usr
source $TOPDIR/sdks/builds/toolchains/emsdk/emsdk_env.sh

# --disable-shared: If we try to build shared libraries the wasm toolchain will choke on things like soname
ICU_DATA_FILTER_FILE=$SCRIPTDIR/filters.json emconfigure ../configure --prefix=$ICU4C/wasm-usr --enable-static --disable-shared CXXFLAGS=-Wno-sign-compare --with-cross-build=$ICU4C/build --disable-extras --disable-renaming --disable-samples --with-data-packaging=archive

# even though we set --with-cross-build and we used emconfigure, autoconf may not have decided we're cross-compiling, so forcibly set that
sed -i -e 's/cross_compiling = .*/cross_compiling = yes/g' icudefs.mk
# on some platforms the icu autoconf script helpfully turns on some optimization flags that aren't compatible with emscripten, so forcibly remove those flags.
sed -i -e 's/LDFLAGS =/#/g' icudefs.mk

make all install

popd