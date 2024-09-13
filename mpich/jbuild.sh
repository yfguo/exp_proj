#!/bin/bash -e

source ../env.sh

VARIANT=${1:-cpu}
QUEUE=${2:-skylake_8180}
WALLTIME=${3:-20}

parse_spec ${VARIANT} mpich
SPEC_NAME="${SPEC_REPO}-${SPEC_COMPILER}-${SPEC_DEVICE}-${SPEC_OPTIONS}"

if [[ ! -d job_out ]]; then
    mkdir -p job_out
fi

rm -f job_out/${SPEC_NAME}.cobaltlog
rm -f job_out/${SPEC_NAME}.erro
rm -f job_out/${SPEC_NAME}.output

jobid=$(qsub -q ${QUEUE} -t ${WALLTIME} -n 1 \
    --jobname=build_${SPEC_NAME} \
    -O job_out/${SPEC_NAME} \
    ./build.sh ${@})

watch -n 1 tail job_out/${SPEC_NAME}.cobaltlog job_out/${SPEC_NAME}.error job_out/${SPEC_NAME}.output
