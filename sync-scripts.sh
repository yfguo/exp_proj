#!/bin/sh -e

cp env.sh ./scripts
cp prepare.sh ./scripts

mkdir -p .scripts/mpich
cp mpich/*.sh .scripts/mpich

mkdir -p .scripts/libfabric
cp libfabric/*.sh .scripts/libfabric

mkdir -p .scripts/ucx
cp ucx/*.sh .scripts/ucx

mkdir -p .scripts/osu
cp osu/*.sh .scripts/osu
