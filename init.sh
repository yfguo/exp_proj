#!/bin/sh

mkdir .scripts
mv * .scripts
mv .git .scripts

ln -sf $PWD/.scripts/env.sh ./env.sh
ln -sf $PWD/.scripts/prepare.sh ./prepare.sh
ln -sf $PWD/.scripts/opt.sh ./opt.sh
ln -sf $PWD/.scripts/bisect_script.sh ./bisect_script.sh

mkdir mpich
ln -sf $PWD/.scripts/mpich/build.sh ./mpich/build.sh
ln -sf $PWD/.scripts/mpich/jbuild.sh ./mpich/jbuild.sh

mkdir ompi
ln -sf $PWD/.scripts/ompi/build.sh ./ompi/build.sh

mkdir ucx
ln -sf $PWD/.scripts/ucx/build.sh ./ucx/build.sh

mkdir libfabric
ln -sf $PWD/.scripts/libfabric/build.sh ./libfabric/build.sh

mkdir osu
ln -sf $PWD/.scripts/osu/build.sh ./osu/build.sh
ln -sf $PWD/.scripts/osu/run.sh ./osu/run.sh
