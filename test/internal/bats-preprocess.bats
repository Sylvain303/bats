#!/bin/bash
#
# run make before is this code has changed

tmp=tmp-bats-preprocess
BPP=../../libexec/bats-preprocess

@test "preprocess myself" {
  cat $BATS_TEST_FILENAME | $BPP > $tmp
  echo $tmp
  diff -q $tmp out
}

@test "dummy test" {
  echo ok
}
