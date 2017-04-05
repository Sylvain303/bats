#!/bin/bash
# test for mybats_preprocess_source
#
# need to be run in the same directory
# Usage: 
#   cd test/internal
#   ./test_mybats_preprocess_source.sh "$BATS_LIBEXEC" "$BATS_TEST_FILENAME"
# Output:
#  $MYBATS_TEST_SOURCE
#  $MYBATS_TMPNAME
#  trap ...
#  mybats_cleanup_preprocessed_source

source mybats-exec-test

# overwrite cleanup code
mybats_cleanup_preprocessed_source() {
  # won't remove anything, file pointed by $MYBATS_TEST_SOURCE is left for the
  # caller, see echo bellow.
  echo mybats_cleanup_preprocessed_source
}

# usage: test_main "$BATS_LIBEXEC" "$BATS_TEST_FILENAME"
test_main() {
  local me=$(basename $0 .sh)
  MYBATS_TMPNAME=tmp_${me}
  export PATH="$1:$PATH"
  MYBATS_TEST_FILENAME=$2
  #echo $PATH

  # run function (no display)
  mybats_preprocess_source

  # generated filename, echo can be catched in ${lines[0..1]}
  echo $MYBATS_TEST_SOURCE
  # a string
  echo $MYBATS_TMPNAME
  # all traps present
  trap -p

  # it chains with mybats_cleanup_preprocessed_source
  # we exit to go to our trap.
  exit $?
}

# call our function
test_main "$@"
# never reached
exit 234

