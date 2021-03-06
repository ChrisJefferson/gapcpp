#!/bin/bash

set -e

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized

# works on linux and windows
mytmpdir="`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`"

cat > ${mytmpdir}/source.cc

. ${MY_PATH}/gapcpp.vars

GAC=${GAPPATH}/gac

MYCFLAGS="-Wall -Wextra -g -I${MY_PATH}/gap_cpp_headers -Wno-pragmas -Wno-cast-function-type -Wno-unused-parameter -Wno-missing-field-initializers -O3 -march=native -mtune=native"

BUILDSTUFF=" -o ${mytmpdir}/source.so -d ${mytmpdir}/source.cc"

${GAC}  -p "${MYCFLAGS}"  ${BUILDSTUFF} -P "-Wl,-Bsymbolic"

echo ${mytmpdir}
