#!/bin/sh -e

source ../env.sh

VARIANT=${1:-main-gnu-sockets}

parse_spec ${VARIANT} libfabric
set_compiler
REPO_DIR=${SPEC_REPO}

OPT="--without-cuda --without-rocr --without-ze"

if [ "$SPEC_OPTIONS" == "default" ]; then
    SPEC_OPTIONS="sockets"
fi

case "${SPEC_OPTIONS}" in
    sockets)
        OPT+=" --enable-only --enable-sockets"
        ;;
    verbs)
        OPT+=" --enable-only --enable-verbs"
        ;;
esac

echo "OPT: $OPT"

SPEC_NAME="${SPEC_REPO}-${SPEC_COMPILER}-${SPEC_OPTIONS}"

if [[ ! -d ${SCRIPT_PATH}/${REPO_DIR} ]]; then
    echo "Source repo ${REPO_DIR} does not exist"
    exit 1
fi

BUILD_DIR=${SCRIPT_PATH}/build/${SPEC_NAME}

if [[ ! -d ${BUILD_DIR} ]]; then
    mkdir -p ${BUILD_DIR}
fi

if [[ ! -f ${SCRIPT_PATH}/${REPO_DIR}/configure && ! -n ${FORCE_GEN} ]]; then
    (cd ${SCRIPT_PATH}/${REPO_DIR} && ./autogen.sh)
fi

pushd ${BUILD_DIR}

if [[ ! -f ${SCRIPT_PATH}/${REPO_DIR}/Makefile && ! -n ${FORCE_CONF} ]]; then
    ${SCRIPT_PATH}/${REPO_DIR}/configure \
        --prefix=${BASE_DIR}/install/libfabric/${SPEC_NAME} \
        ${OPT_COMPILER} \
        ${OPT} 2>&1 | tee c.txt
fi

make -j install 2>&1 | tee mi.txt

popd
