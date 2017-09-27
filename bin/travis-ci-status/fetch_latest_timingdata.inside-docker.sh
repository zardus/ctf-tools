#!/bin/bash -ex

tmpfile=/logs/travis.log

# Fetch data
(
for i in $(travis show --skip-completion-check --no-interactive | grep '^#' | awk '{print $1}' | tr "#" " ");
do
    travis logs --skip-completion-check --no-interactive "$i" | grep '^\[ACCOUNTING\]=====\[' | cut -d' ' -f2-5
done
) > $tmpfile
