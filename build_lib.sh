#!/bin/bash

set -e

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized

# works on linux and windows
mytmpdir="`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`"

cat > ${mytmpdir}/source.cc

. ${MY_PATH}/gapcpp.vars

GAC=${GAPPATH}/gac

MYCFLAGS="-Wall -Wextra -g -I${MY_PATH}/gap_cpp_headers -Wno-missing-field-initializers -O"

BUILDSTUFF="-L ${CPPLIB} -o ${mytmpdir}/source.so -d ${mytmpdir}/source.cc"

${GAC}  -p "${MYCFLAGS}"  ${BUILDSTUFF}

echo ${mytmpdir}
