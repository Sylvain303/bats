#!/bin/bash
# test for our tools

in='
run something
$BATS_SOME_VAR
setup() 
teardown()
bats_func_call pipo
'

@test "rewrite_bats_to_mybats forward" {
  run $BATS_TEST_DIRNAME/rewrite_bats_to_mybats.sh <(echo "$in")
  echo "$output" | grep -E "(my|MY)"
}
