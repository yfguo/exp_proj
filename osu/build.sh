#!/bin/sh -e

source ../env.sh

VARIANT=${1:-cpu}
OPTION=${2:-osu}

parse_spec ${VARIANT} mpich
set_compiler

SPEC_NAME="${SPEC_REPO}-${SPEC_COMPILER}-${SPEC_DEVICE}-${SPEC_OPTIONS}"

MPICH_HOME=${BASE_DIR}/install/mpich/${SPEC_NAME}

if [[ ! -d ${MPICH_HOME} ]]; then
    echo "Cannot find MPICH at ${MPICH_HOME}"
    exit
fi

BUILD_DIR=${BASE_DIR}/osu/${SPEC_NAME}

echo "SPEC_NAME: ${SPEC_NAME}"
echo "MPICH_HOME: ${MPICH_HOME}"
echo "BUILD_DIR: ${BUILD_DIR}"

if [[ -d ${BUILD_DIR} ]]; then
    rm -rf ${BUILD_DIR}
fi

mkdir -p ${BUILD_DIR}

pushd ${BUILD_DIR}
${BASE_DIR}/osu/${OPTION}/configure CC=$MPICH_HOME/bin/mpicc CXX=$MPICH_HOME/bin/mpic++
make -j -C c/mpi/pt2pt/standard
make -j -C c/mpi/collective/blocking
# make -j -C c/mpi/collective/non_blocking
popd
