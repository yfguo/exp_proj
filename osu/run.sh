#!/bin/sh -e

source ../env.sh

VARIANT=${1:-cpu}
BIN=${2:-osu_latency}
PARMS=${3:--m 1:4096}
# PARMS=${3}

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

pushd ${BENCH_DIR}
touch output
rm -f core.*
rm -f collected_data.json
ulimit -c unlimited
echo "Intra-NUMA"
$MPICH_HOME/bin/mpiexec -bind-to user:0,1 -n 2 ./c/mpi/pt2pt/standard/${BIN} ${PARMS} | ../data_collector.py -k "Inter-NUMA"

echo "Inter-NUMA"
$MPICH_HOME/bin/mpiexec -bind-to user:0,28 -n 2 ./c/mpi/pt2pt/standard/${BIN} ${PARMS} | ../data_collector.py -k "Intra-NUMA"
ulimit -c 0
../data_collector.py -p
popd

