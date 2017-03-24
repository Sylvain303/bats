#!/bin/bash
# test for mybats_teardown_trap
#
# need to be run in the same directory
# Usage: 
#   cd test/internal
#   test_mybats_teardown_trap.sh NUM DESC EXIT_STATUS EXIT_STATUS_TEARDOWN

source mybats-exec-test
source test_helper.sh

EXIT_STATUS_TEARDOWN=0
myteardown() {
  echo "myteardown $EXIT_STATUS_TEARDOWN"
  return $EXIT_STATUS_TEARDOWN
}

test_main() {
  #set -x
  init_test_env "$@"
  create_MYBATS_OUT

  # exit trap
  trap "mybats_teardown_trap" exit

  # simulate test finished
  MYBATS_ERROR_STATUS=$3
  if [[ "$MYBATS_ERROR_STATUS" -eq 0 ]]
  then
    MYBATS_TEST_COMPLETED=1
  else
    MYBATS_TEST_COMPLETED=""
  fi
  # not yet
  MYBATS_TEARDOWN_COMPLETED=""

  EXIT_STATUS_TEARDOWN=$4

  # collect a fake stacktrace
  if [[ $MYBATS_ERROR_STATUS -ne 0 || $EXIT_STATUS_TEARDOWN -ne 0 ]]
  then
    mybats_capture_stack_trace
    MYBATS_ERROR_STACK_TRACE=( "${MYBATS_CURRENT_STACK_TRACE[@]}" )
  fi

  # mybats_teardown_trap is called on exit trap
  # it chains with mybats_exit_trap
  # we exit to go to our trap.
  exit $3
}

# call our function
test_main "$@"
# never reached
exit 234
