#!/bin/sh -e

source ../env.sh

VARIANT=${1:-cpu}
BIN=${2:-osu_allgather}
PARMS=${3:--m 1:4096}

parse_spec ${VARIANT} mpich

SPEC_NAME="${SPEC_REPO}-${SPEC_COMPILER}-${SPEC_DEVICE}-${SPEC_OPTIONS}"
MPICH_HOME=${BASE_DIR}/install/mpich/${SPEC_NAME}
BENCH_DIR=${BASE_DIR}/osu/${SPEC_NAME}

echo "SPEC_NAME: ${SPEC_NAME}"
echo "MPICH_HOME: ${MPICH_HOME}"
echo "BENCH_DIR: ${BENCH_DIR}"

export UCX_TLS=sm
# export FI_PROVIDER=verbs
# export MPIR_CVAR_ENABLE_GPU=0
# export MPIR_CVAR_CH4_SHM_POSIX_TOPO_ENABLE=1
# export MPIR_CVAR_DEBUG_SUMMARY=10
# export MPIR_CVAR_NOLOCAL=1
# export MPIR_CVAR_CH4_CMA_ENABLE=1
# export MPIR_CVAR_CH4_IPC_CMA_P2P_THRESHOLD=1
# export MPIR_CVAR_CH4_SHM_POSIX_IQUEUE_CELL_SIZE=17408
# export MPIR_CVAR_CH4_SHM_POSIX_IQUEUE_NUM_CELLS=128

# ldd ${BENCH_DIR}/c/mpi/pt2pt/standard/${BIN}
# export LD_PRELOAD=/usr/lib64/libasan.so.4.0.0

# export LD_PRELOAD=/soft/compilers/gcc/x86_64-suse-linux/14.1.0/lib64/libasan.so.8

pushd ${BENCH_DIR}
rm -f core.*
ulimit -c unlimited
$MPICH_HOME/bin/mpiexec -bind-to hwthread:1 -map-by core -n 28 ./c/mpi/collective/blocking/${BIN} ${PARMS}
ulimit -c 0
popd
