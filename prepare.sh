#!/bin/sh -e

source ./env.sh

if [[ ! -d ${BASE_DIR}/ucx ]]; then
    mkdir -p ${BASE_DIR}/ucx
    cp build-ucx.sh ${BASE_DIR}/ucx/build.sh
fi

if [[ ! -d ${BASE_DIR}/libfabric ]]; then
    mkdir -p ${BASE_DIR}/libfabric
    cp build-libfabric.sh ${BASE_DIR}/libfabric/build.sh
fi

if [[ ! -d ${BASE_DIR}/mpich ]]; then
    mkdir -p ${BASE_DIR}/mpich
    cp build-mpich.sh ${BASE_DIR}/mpich/build.sh
fi

if [[ ! -d ${BASE_DIR}/ucx/main ]]; then
    git clone https://github.com/openucx/ucx --recursive ${BASE_DIR}/ucx/main
fi

if [[ ! -d ${BASE_DIR}/libfabric/main ]]; then
    git clone https://github.com/ofiwg/libfabric --recursive ${BASE_DIR}/libfabric/main
fi

if [[ ! -d ${BASE_DIR}/mpich/main ]]; then
    git clone https://github.com/pmodels/mpich --recursive ${BASE_DIR}/mpich/main
fi

if [[ ! -d ${BASE_DIR}/osu ]]; then
    mkdir -p ${BASE_DIR}/osu
    (cd ${BASE_DIR}/osu && wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.4.tar.gz -O osu.tar.gz)
    mkdir -p ${BASE_DIR}/osu/osu && tar zxvf ${BASE_DIR}/osu/osu.tar.gz --strip-components 1 -C ${BASE_DIR}/osu/osu

fi

if [[ ! -d ${INSTALL_DIR} ]]; then
    mkdir -p ${INSTALL_DIR}
fi

if [[ ! -d ${BASE_DIR}/hydra ]]; then
    mkdir -p ${BASE_DIR}/hydra
    curl -o ${BASE_DIR}/hydra/hydra-stable.tar.gz https://www.mpich.org/static/downloads/4.2.2/hydra-4.2.2.tar.gz
    mkdir -p ${BASE_DIR}/hydra/stable && tar zxvf ${BASE_DIR}/hydra/hydra-stable.tar.gz --strip-components 1 -C ${BASE_DIR}/hydra/stable
    pushd ${BASE_DIR}/hydra/stable
    ./configure --prefix=${INSTALL_DIR}/hydra/stable 2>&1 | tee c.txt
    make -j32 install 2>&1 | tee mi.txt
    popd
fi


