#!/bin/sh

mkdir .scripts
mv * .scripts
mv .git .scripts

ln -sf ./scripts/env.sh ./env.sh
ln -sf ./scripts/prepare.sh ./prepare.sh
ln -sf ./scripts/opt.sh ./opt.sh
ln -sf ./scripts/bisect_script.sh ./bisect_script.sh

mkdir mpich
ln -sf ./scripts/mpich/build.sh ./mpich/build.sh
ln -sf ./scripts/mpich/jbuild.sh ./mpich/jbuild.sh

mkdir ompi
ln -sf ./scripts/ompi/build.sh ./ompi/build.sh

mkdir ucx
ln -sf ./scripts/ucx/build.sh ./ucx/build.sh

mkdir libfabric
ln -sf ./scripts/libfabric/build.sh ./libfabric/build.sh

mkdir osu
ln -sf ./scripts/osu/build.sh ./osu/build.sh
ln -sf ./scripts/osu/run.sh ./osu/run.sh
