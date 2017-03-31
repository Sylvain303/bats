#!/bin/bash
#
# heplers for test_* wrapper

# Creates MYBATS_OUT pointed file name with a value.
# It echos 1 or 2 more line with filename to MYBATS_OUT and FILENAME
# It fakes the following call in mybats_perform_tests()
#   "$MYBATS_TEST_NAME" >>"$MYBATS_OUT" 2>&1
# Usage: create_MYBATS_OUT [save_it_with FILENAME]
create_MYBATS_OUT() {
  # create and pass MYBATS_OUT to caller via ${lines[0]}
  basename "$0" > $MYBATS_OUT && echo $MYBATS_OUT

  # if param is passed we hardlink it, so it would be kept on removal
  # name of the link is outputed to be catch by the caller on ${lines[]}
  if [[ "$1" == "save_it_with" ]]
  then
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

# from http://stackoverflow.com/questions/1203583/how-do-i-rename-a-bash-function
copy_function() {
  test -n "$(declare -f $1)" || return
  eval "${_/$1/$2}"
}

rename_function() {
  copy_function $@ || return
  unset -f $1
}
