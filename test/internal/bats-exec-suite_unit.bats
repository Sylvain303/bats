#!/bin/bash
#

source $BATS_TEST_DIRNAME/../../libexec/bats-exec-suite
cd $BATS_TEST_DIRNAME

# nothing realy to test here with a single function, See functional testing
@test "bats-exec-suite main exists" {
  test -n "$(declare -f bats_exec_suite_main)"
}
