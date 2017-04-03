#!/bin/bash

sed -e 's/bats_/mybats_/g' \
    -e 's/BATS_/MYBATS_/g' \
    -e 's/\<setup\>/mysetup/g' \
    -e 's/\<skip\>/myskip/g' \
    -e 's/\<run\>/myrun/g' \
    -e 's/\<teardown\>/myteardown/g' \
    -e 's/\<load\>/myload/g' \
    "$@"
