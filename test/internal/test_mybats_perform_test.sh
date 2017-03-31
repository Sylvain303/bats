#!/bin/bash
# test for mybats_perform_test (singular)
#
# need to be run in the same directory
# Usage: 
#   cd test/internal
#   test_mybats_perform_test.sh [TEST_FUNC] [TEST_NUM]
#
# TEST_FUNC: our_fake_* or an inexistant func

source mybats-exec-test
source test_helper.sh

rename_function mybats_teardown_trap orig_mybats_teardown_trap
rename_function mybats_exit_trap orig_mybats_exit_trap

our_exit_trap() {
  echo "our_exit_trap $?"
}

our_fake_func_true() {
  echo our_fake_func_true
  true
}

our_fake_func_false() {
  echo our_fake_func_false
  false
}

# link our own functions
mybats_teardown_trap() {
	echo our_teardown_trap
	orig_mybats_teardown_trap
}

mybats_exit_trap() {
	echo our_exit_linked_trap
	orig_mybats_exit_trap
}

test_main() {
  TEST_FUNC=$1
  TEST_NUM=$2

  init_test_env "$TEST_NUM" "some fixed test description"
  create_MYBATS_OUT save_it_with /tmp/MYBATS_OUT.$$
  trap our_exit_trap exit

  # on error argument it exits 1, so our_exit_trap will be called
  # on test error, it will call mybats_error_trap
  mybats_perform_test "$@"
  #trap -p
  #set | grep ^MYBATS

  # on succes we return here
  exit $?
}

# call our function
test_main "$@"

# never reached
exit 234
