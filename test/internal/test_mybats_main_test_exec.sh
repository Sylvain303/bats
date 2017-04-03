#!/bin/bash
# test for mybats_main_test_exec
#
# NOTE: as BATS_ are rewritten MYBATS_ we rewrite official bats too.
#
# need to be run in the same directory
# Usage: 
#   cd test/internal
#   ./test_mybats_main_test_exec.sh TEST_FILENAME
#
# TEST_FILENAME  a normal bats input file


source mybats-exec-test
source test_helper.sh

rename_function \
       mybats_preprocess_source \
  orig_mybats_preprocess_source

mybats_preprocess_source() {
  orig_mybats_preprocess_source 
  #local tmp=$(mktemp)
  #cp $MYBATS_TEST_SOURCE $tmp
  #echo "our: $? saved MYBATS_TEST_SOURCE $tmp"
  # inplace
  ./rewrite_bats_to_mybats.sh -i $MYBATS_TEST_SOURCE
  #rm $tmp
}

test_main() {
  PATH=../../libexec/:$PATH
  echo "I'm running: $FUNCNAME $$"
  mybats_main_test_exec "$@"
  exit $?
}

# call our function
test_main "$@"
