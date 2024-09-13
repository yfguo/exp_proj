#!/bin/sh -e

source ../env.sh

VARIANT=${1:-main-gnu-default}

parse_spec ${VARIANT} ucx
set_compiler
REPO_DIR=${SPEC_REPO}

case "${SPEC_COMPILER}" in
    gnu)
        OPT_COMPILER="CFLAGS=-mavx"
        ;;
    clang)
        OPT_COMPILER="CFLAGS=-mavx"
        ;;
    amd)
        OPT_COMPILER="CFLAGS=-mavx"
        ;;
    intel)
        OPT_COMPILER="CFLAGS=-Wno-error"
        ;;
    *)
        exit -1
        ;;
esac

echo "OPT_COMPILER: $OPT_COMPILER"

OPT="--without-cuda --without-rocm --without-ze"
OPT+=" --disable-cma --enable-builtin-memcpy=yes"

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

if [[ ! -f ${SCRIPT_PATH}/${REPO_DIR}/configure && ! -n ${FORCE_AUTO} ]]; then
    (cd ${SCRIPT_PATH}/${REPO_DIR} && ./autogen.sh)
fi

pushd ${BUILD_DIR}

# if [[ ! -f ${SCRIPT_PATH}/${REPO_DIR}/Makefile && ! -n ${FORCE_CONF} ]]; then
    ${SCRIPT_PATH}/${REPO_DIR}/contrib/configure-opt \
        --prefix=${BASE_DIR}/install/ucx/${SPEC_NAME} \
        ${OPT_COMPILER} \
        ${OPT} 2>&1 | tee c.txt
# fi

make -j install 2>&1 | tee mi.txt

popd
