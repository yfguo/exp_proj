#!/bin/bash -e

source ../env.sh

usage() {
    echo "Usage: $0 [-a] [-b <arg>] [-c] <file>"
    echo "  -a        : Force autogen (and configure) step"
    echo "  -c        : Force configure step"
    echo "  -m        : Set MPI type: mpich (default), ompi, cray"
    echo "  -s <spec> : Specify a spec name"
    echo "  <file1> [<file2> ...] : Specify one or more files to process"
    exit 1
}

option_autogen=false
option_configure=false
option_mpitype="mpich"
option_spec=""
while getopts ":acm:s:" opt; do
    case ${opt} in
        a)
            option_autogen=true
            option_configure=true
            ;;
        c)
            option_configure=true
            ;;
        m)
            option_mpitype=$OPTARG
            ;;
        s)
            option_spec=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done
# Remove the options from the positional parameters
shift $((OPTIND -1))

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
        polaris)
            OPT+=" --with-pmi=pmix --with-pmix=$CRAY_PMI_PREFIX --with-pm=no"
            ;;
        cuda)
            OPT+=" --with-cuda=$CRAY_NVIDIA_PREFIX"
            _gpu=1
            ;;
        hip)
            _gpu=1
            ;;
        ze)
            OPT+=" --with-ze=/usr"
            _gpu=1
            ;;
        config)
            FORCE_GEN=1
            FORCE_CONF=1
            NO_MAKE=1
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

if [[ ! -f ${SCRIPT_PATH}/${REPO_DIR}/configure || ${option_autogen} = "true" ]]; then
    (cd ${SCRIPT_PATH}/${REPO_DIR} && ./autogen.sh -yaksa-depth=1 2>&1 | tee a.txt)
fi

pushd ${BUILD_DIR}

if [[ ! -f ${BUILD_DIR}/Makefile || ${option_configure} = "true" ]]; then
    ${SCRIPT_PATH}/${REPO_DIR}/configure \
        --prefix=${BASE_DIR}/install/mpich/${SPEC_NAME} \
        ${OPT_DEVICE} ${OPT_DEVICE_PATH} \
        ${OPT_COMPILER} \
        ${OPT} 2>&1 | tee c.txt
fi

if [[ -z ${NO_MAKE+x} ]]; then
    make -j 64 install 2>&1 | tee mi.txt
fi

popd
