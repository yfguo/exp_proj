#!/bin/zsh -e

VARIANT=baseline

git clean -xdf
git submodule update --init --recursive

cd ..
./build.sh ${VARIANT}

cd ../osu
./build.sh ${VARIANT}

./run.sh ${VARIANT} osu_bw | tee output

cat output | awk '$1 == 131072 {if ($2 > 30000) {print "true"; exit 0} else {print "false"; exit 1}}'

rm -rf ../install/mpich/baseline

