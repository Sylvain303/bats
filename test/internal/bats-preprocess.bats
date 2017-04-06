#!/bin/bash
#
# run make before, if this code has changed
#

BPP=../../libexec/bats-preprocess
cd $BATS_TEST_DIRNAME

@test "preprocess myself" {
  diff -u <( $BPP < $BATS_TEST_FILENAME ) out
}

@test "dummy test" {
  echo ok
}
