#!/bin/bash

dockerimage=ctf-tools-travisbuildcheck
gitdir=$(git rev-parse --show-toplevel)

if ! docker history $dockerimage &> /dev/null;
then
    echo "Docker image \"$dockerimage\" does not exist. Run"
    echo
    echo "    docker build -t $dockerimage ."
    echo
    echo "first, then retry this command."
    exit 1
fi

docker run --rm -v $gitdir:/gitdata -ti $dockerimage /gitdata/bin/travis-ci-status/fetch_latest_timingdata.inside-docker.sh

