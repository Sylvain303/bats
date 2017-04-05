#!/bin/bash
# test for mybats_perform_tests (plural) (recursive)
#
# need to be run in the same directory
# Usage: 
#   cd test/internal
#
# "$0" $MYBATS_EXTENDED_SYNTAX "$MYBATS_TEST_FILENAME" "$test_name" "$test_number"
#   test_mybats_perform_tests.sh no-rec FUNC_NAMES...
#

source mybats-exec-test
source test_helper.sh

test_func_one() {
  echo ${FUNCNAME[0]}
  true
}

test_main() {
  TEST_NUM=22

  # can be set via export
  #MYBATS_TEST_FILENAME=""
  #MYBATS_EXTENDED_SYNTAX=""

  # recursive call "no-rec" striped
  echo "parent_id: $$"
  mybats_perform_tests "$@"
  exit $?
}

# call our function
if [[ "$1" == 'no-rec' ]]
then
  shift
  test_main "$@"
else
  echo -n "call_id: $$ [$#] ("
  for p in "$@"
  do
    echo -n "'$p' "
  done
  echo ")"
fi
