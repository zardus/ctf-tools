#!/bin/bash -e

sample=$1

[ -e ../toolchains/$sample ] && echo "Already built: $sample" && exit
HOME=$(dirname $PWD) CT_PREFIX=$(dirname $PWD)/toolchains ./ct-ng $sample
yes '' | HOME=$(dirname $PWD) CT_PREFIX=$(dirname $PWD)/toolchains ./ct-ng build.$(nproc)
rm -rf .build/$sample
