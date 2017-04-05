#!/bin/bash
#
# run make before if this code has changed
#

tmp=tmp-bats-preprocess
BPP=../../libexec/bats-preprocess

@test "preprocess myself" {
  cat $BATS_TEST_FILENAME | $BPP > $tmp
  diff -q $tmp out
  rm $tmp
}

@test "dummy test" {
  echo ok
}
