#!/bin/bash -e

tmpfile=/logs/travis.log

# generate travis-ci data
(
cat /gitdata/.travis.yml.header
/gitdata/bin/travis-ci-status/make_binpacked_travis_ci_conf.py $tmpfile
cat /gitdata/.travis.yml.footer
) > /gitdata/.travis.yml
