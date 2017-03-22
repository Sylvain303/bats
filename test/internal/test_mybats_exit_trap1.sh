#!/bin/bash
# test for mybats_exit_trap

source mybats-exec-test

MYBATS_TEST_SKIPPED=1

test_main() {
  #set -x
  mybats_init $0
  trap "mybats_exit_trap" exit
  exec 3<&1
  MYBATS_ERROR_STATUS=0
  MYBATS_TEARDOWN_COMPLETED=1
	MYBATS_TEST_NUMBER=$1
  MYBATS_TEST_DESCRIPTION="$2"
  touch $MYBATS_OUT
  # myskip will exit 0, we will never return
  # mybats_exit_trap will be called by the trap
  myskip
}

# call our function
test_main "$@"
exit
