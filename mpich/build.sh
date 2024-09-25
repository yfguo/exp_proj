#!/bin/sh -e

source ../env.sh

VARIANT=${1:-cpu}

parse_spec ${VARIANT} mpich
set_compiler

OPT="--disable-fortran --disable-romio"

case "${SPEC_REPO}" in
    quicq)
        OPT+=" --with-ch4-shmmods=posix --with-ch4-posix-eager-modules=quicq"
        ;;
    fbox)
        OPT+=" --with-ch4-shmmods=posix --with-ch4-posix-eager-modules=fbox"
        ;;
    *)
        ;;
esac

case "${SPEC_DEVICE}" in
    ofi)
        set_device "sockets"
        ;;
    ucx)
        OPT+=" --with-ch4-shmmods=none"
        set_device "default"
        ;;
    *)
        ;;
esac

# OPT+=" --enable-fast=O2 --enable-avx --enable-g=dbg,asan"
# OPT+=" --enable-fast=O2,avx"
OPT+=" --enable-fast=ndebug,O3,avx"
IFS=+ read -r -a _arr <<< "${SPEC_OPTIONS}"
unset IFS

for _item in ${_arr[@]}; do
    case "${_item}" in
        default)
            ;;
        debug)
            OPT+=" --enable-g=all"
            ;;
        opt)
            OPT+=" --enable-fast=ndebug,O3,avx,avx512f"
            ;;
        probe)
            OPT+=" --disable-visibility"
            ;;
        vci)
            OPT+=" --with-ch4-max-vcis=64 --enable-ch4-mt=runtime --enable-thread-cs=per-vci"
            ;;
        am)
            OPT+=" --enable-ch4-am-only"
            ;;
        asan)
            OPT+=" --enable-g=dbg,asan --disable-visibility"
            ;;
        sunspot)
            OPT+=" --with-pmi=pmix --with-pmix=/usr --with-pm=no"
            ;;
        cuda)
            _gpu=1
            ;;
        hip)
            _gpu=1
            ;;
        ze)
            OPT+=" --with-ze=/usr"
            _gpu=1
            ;;
        *)
            exit -1
            ;;
    esac
done

if [[ -z ${_gpu} ]]; then
    OPT+=" --without-cuda --without-hip --without-ze"
fi

echo "OPT: $OPT"

SPEC_NAME="${SPEC_REPO}-${SPEC_COMPILER}-${SPEC_DEVICE}-${SPEC_OPTIONS}"

echo "SPEC NAME: ${SPEC_NAME}"

REPO_DIR=${SPEC_REPO}

if [[ ! -d ${SCRIPT_PATH}/${REPO_DIR} ]]; then
    echo "Source repo ${REPO_DIR} does not exist"
    exit 1
fi

BUILD_DIR=${SCRIPT_PATH}/build/${SPEC_NAME}

if [[ ! -d ${BUILD_DIR} ]]; then
    mkdir -p ${BUILD_DIR}
fi

if [[ ! -f ${SCRIPT_PATH}/${REPO_DIR}/configure || ! -z ${FORCE_GEN+x} ]]; then
    (cd ${SCRIPT_PATH}/${REPO_DIR} && ./autogen.sh -yaksa-depth=1 2>&1 | tee a.txt)
fi

pushd ${BUILD_DIR}

if [[ ! -f ${BUILD_DIR}/Makefile || ! -z ${FORCE_GEN+x} || ! -z ${FORCE_CONF+x} ]]; then
    ${SCRIPT_PATH}/${REPO_DIR}/configure \
        --prefix=${BASE_DIR}/install/mpich/${SPEC_NAME} \
        ${OPT_DEVICE} ${OPT_DEVICE_PATH} \
        ${OPT_COMPILER} \
        ${OPT} 2>&1 | tee c.txt
fi

make -j 64 install 2>&1 | tee mi.txt

popd

