#!/bin/bash
# test for mybats_exit_trap
#
# need to be run in the same directory
# Usage: 
#   cd test/internal
#   test_mybats_exit_trap2.sh NUM DESC [SKIP_MESG]

source mybats-exec-test
source test_helper.sh

test_main() {
  #set -x
  init_test_env "$@"
  trap "mybats_exit_trap" exit
  create_MYBATS_OUT

  # simulate skip behavior
  MYBATS_ERROR_STATUS=0
  MYBATS_TEARDOWN_COMPLETED=1

  # myskip will exit 0, we will never return, it sets:
  #  # default value 1 if no argument
  #  MYBATS_TEST_SKIPPED=${1:-1}
  #  MYBATS_TEST_COMPLETED=1
  # mybats_exit_trap will be called by the trap
  myskip "$3"
}

# call our function
test_main "$@"
# never reached
exit 234
