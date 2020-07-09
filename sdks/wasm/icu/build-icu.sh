#!/usr/bin/env bash

# You will need an existing ICU checkout to perform a build. Run fetch-icu.sh to get one
# You can enable threading by passing -jN to build-icu.sh

set -u
set -e
set -x

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOPDIR="$SCRIPTDIR/../../../"
ICU4C="$SCRIPTDIR/icu-git/icu4c/source"

pushd $SCRIPTDIR

mkdir -p $ICU4C/build
cd $ICU4C/build
# note: without --disable-extras, make check will run the uconv tests and they will fail
ICU_DATA_FILTER_FILE=$SCRIPTDIR/filters.json ../configure --disable-renaming --disable-samples --with-data-packaging=library --disable-extras
make ${1-}

mkdir -p $ICU4C/wasm-build
cd $ICU4C/wasm-build

mkdir -p $ICU4C/wasm-usr
source $TOPDIR/sdks/builds/toolchains/emsdk/emsdk_env.sh

# --disable-shared: If we try to build shared libraries the wasm toolchain will choke on things like soname
DEFINES="-DU_CHARSET_IS_UTF8=1 -DUCONFIG_NO_TRANSLITERATION=1 -DUCONFIG_NO_REGULAR_EXPRESSIONS=1 -DUCONFIG_NO_FILE_IO=1 -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_FILTERED_BREAK_ITERATION=1"
# -fvisibility=hidden: set default visibility to hidden so the c++ symbols aren't exported. we'll manually export the C ones
# DEFINES="-DU_CHARSET_IS_UTF8=1 -DUCONFIG_NO_TRANSLITERATION=1 -DUCONFIG_NO_REGULAR_EXPRESSIONS=1 -DUCONFIG_NO_FILE_IO=1 -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_FILTERED_BREAK_ITERATION=1 -DU_CXX_HIDDEN=1 -fvisibility=hidden -fvisibility-inlines-hidden -fmerge-all-constants"
# would use LDFLAGS="--gc-sections" but emscripten does not support this
ICU_DATA_FILTER_FILE=$SCRIPTDIR/filters.json emconfigure ../configure --prefix=$ICU4C/wasm-usr --enable-static --disable-shared CXXFLAGS="-fno-exceptions -Wno-sign-compare $DEFINES" CFLAGS="-fno-exceptions $DEFINES" CPPFLAGS="$DEFINES" --with-cross-build=$ICU4C/build --disable-extras --disable-renaming --disable-samples --with-data-packaging=archive

# even though we set --with-cross-build and we used emconfigure, autoconf may not have decided we're cross-compiling, so forcibly set that
sed -i -e 's/cross_compiling = .*/cross_compiling = yes/g' icudefs.mk
# on some platforms the icu autoconf script helpfully turns on some optimization flags that aren't compatible with emscripten, so forcibly remove those flags.
sed -i -e 's/LDFLAGS =/#/g' icudefs.mk

make all install

popd
