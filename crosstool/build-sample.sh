#!/bin/bash -e

sample=$1

[ -e ../x-tools/$sample ] && echo "Already built: $sample" && exit
HOME=$(dirname $PWD) CT_PREFIX=$(dirname $PWD)/toolchains ./ct-ng $sample
yes '' | HOME=$(dirname $PWD) CT_PREFIX=$(dirname $PWD)/toolchains ./ct-ng build.$(nproc)
rm -rf .build/$sample
