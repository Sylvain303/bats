#!/bin/bash
# test for mybats_exit_trap
# need to be run in the same directory
# Usage: 
#   cd test/internal
#   source test_helper.sh

# create MYBATS_OUT pointed file name with a value
# it echos 1 or 2 more line with filename to MYBATS_OUT and FILENAME
# it replaces the following call in mybats_perform_tests()
#   "$MYBATS_TEST_NAME" >>"$MYBATS_OUT" 2>&1
# Usage: create_MYBATS_OUT [save_it_with FILENAME]
create_MYBATS_OUT() {
  # create and pass MYBATS_OUT to caller via ${lines[0]}
  basename "$0" > $MYBATS_OUT && echo $MYBATS_OUT
  if [[ "$1" == "save_it_with" ]]
  then
    # make a hardlink on it so we can read it after it has been removed
    ln $MYBATS_OUT $2 && echo $2
  fi
}

# Usage: init_test_env "$@"
# you have to setup your own trap if any, none set by default
init_test_env() {
  mybats_init $0
  exec 3<&1
	MYBATS_TEST_NUMBER=$1
  MYBATS_TEST_DESCRIPTION="$2"
}
