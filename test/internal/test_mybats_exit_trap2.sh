#!/bin/bash
# test for mybats_exit_trap
# need to be run in the same directory
# Usage: 
#   cd test/internal
#   test_mybats_exit_trap2.sh BATS_TEST_NUMBER BATS_TEST_DESCRIPTION

source mybats-exec-test
source test_helper.sh

test_main() {
  #set -x
  init_test_env "$@"
  trap "mybats_exit_trap" exit

  # it outputs 2 more line for the caller
  create_MYBATS_OUT save_it_with $MYBATS_TMPDIR/MYBATS_OUT.$$

  # define an erronous test
  MYBATS_ERROR_STATUS=0
  MYBATS_TEARDOWN_COMPLETED=1

  # simulate a failing test
	MYBATS_TEST_COMPLETED=""
  mybats_capture_stack_trace
  MYBATS_ERROR_STACK_TRACE=( "${MYBATS_CURRENT_STACK_TRACE[@]}" )
  exit 1
}

# call our function
test_main "$@"
# never reached
exit 234
