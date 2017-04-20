#!/bin/bash

tmpfile=$(mktemp)

# Fetch data
(
for i in $(travis show --skip-completion-check --no-interactive | grep '^#' | awk '{print $1}' | tr "#" " ");
do
    travis logs --skip-completion-check --no-interactive "$i" | grep '^\[ACCOUNTING\]=====\[' | cut -d' ' -f2-5
done
) > $tmpfile

# generate travis-ci data
(
cat /gitdata/.travis.yml.header
/gitdata/bin/travis-ci-status/make_binpacked_travis_ci_conf.py $tmpfile
cat /gitdata/.travis.yml.footer
) > /gitdata/.travis.yml

# generate build status data
/gitdata/bin/travis-ci-status/make_build_status_md.py $tmpfile > /gitdata/_buildstatus/index.md

rm -f $tmpfile
