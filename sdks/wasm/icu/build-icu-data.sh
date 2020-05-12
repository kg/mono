#!/usr/bin/env bash

# run build-icu.sh successfully first
# data will be stored in $SCRIPTDIR/data

set -u
set -e
set -x

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOPDIR="$SCRIPTDIR/../../../"
ICU4C="$SCRIPTDIR/icu-git/icu4c/source"
ICUOUT_COMPONENT="$SCRIPTDIR/data/components"
ICUOUT_PACKAGE="$SCRIPTDIR/data"
ICUTMP="$SCRIPTDIR/data/temp"

pushd $ICU4C

# this generates the individual data and resource files that will be combined into the package
LD_LIBRARY_PATH=build/lib:$PATH PYTHONPATH=./python:${PYTHONPATH:-} python3 -m icutools.databuilder --mode=unix-exec --out_dir $ICUOUT_COMPONENT --tmp_dir $ICUTMP --src_dir ./data --tool_dir ./build/bin

#  options:
# [REQ] -p or --name        Set the data name
#       -O or --bldopt      The directory where the ICU is located (e.g. <ICUROOT> which contains the bin directory)
#       -m or --mode        Specify the mode of building (see below; default: common)
#       -h or --help        This usage text
#       -? or --help        This usage text
#       -v or --verbose     Make the output verbose
#       -c or --copyright   Use the standard ICU copyright
#       -C or --comment     Use a custom comment (instead of the copyright)
#       -d or --destdir     Specify the destination directory for files
#       -F or --rebuild     Force rebuilding of all data
#       -T or --tempdir     Specify temporary dir (default: output dir)
#       -I or --install     Install the data (specify target)
#       -s or --sourcedir   Specify a custom source directory
#       -e or --entrypoint  Specify a custom entrypoint name (default: short name)
#       -r or --revision    Specify a version when packaging in dll or static mode
#       -f or --force-prefix  Add package to all file names if not present
#       -L or --libname     Library name to build (if different than package name)
#       -q or --quiet       Quiet mode. (e.g. Do not output a readme file for static libraries)
#       -w or --without-assembly  Build the data without assembly code
#       -z or --zos-pds-build  Build PDS dataset (zOS build only)
#       -u or --windows-uwp-build  Build for Universal Windows Platform (Windows build only)
#       -a or --windows-DLL-arch  Specify the DLL machine architecture for LINK.exe (Windows build only)
#       -b or --windows-dynamicbase  Ignored. Enable DYNAMICBASE on the DLL. This is now the default. (Windows build only)
# modes: (-m option)
#    files                  Uses raw data files (no effect). Installation copies all files to the target location.
#    dll       / library    Generates one shared library, <package>.so
#    common    / archive    Generates one common data file, <package>.dat
#    static    / static     Generates one statically linked library, lib<package>.a

# now combine all the generated data into a .dat file
LD_LIBRARY_PATH=build/lib:$PATH ./build/bin/pkgdata --mode common --name icudtl -c --bldopt $ICU4C/build --sourcedir $ICUOUT_COMPONENT --tempdir $ICUTMP --destdir $ICUOUT_PACKAGE $ICUTMP/icudata.lst

popd