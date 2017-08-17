#!/bin/bash -ex

apt-get install -y python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential

if [[ $(lsb_release -rs | sed 's/\(..\)\.../\1/') -lt 16 ]]; then 
    echo "using pwntools binutils ppa for pre-xenial ubuntu"
    apt-get -y install software-properties-common
    apt-add-repository -y ppa:pwntools/binutils
    apt-get update
    apt-get -y install binutils-.*-linux-gnu 
fi
