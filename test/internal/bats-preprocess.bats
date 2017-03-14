#!/bin/bash

tmp=tmp-bats-preprocess
BPP=../../libexec/bats-preprocess

@test "preprocess single" {
  cat $BATS_TEST_FILENAME | $BPP > $tmp
  diff -q $tmp out
}
