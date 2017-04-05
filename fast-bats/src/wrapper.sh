#!/bin/bash
# fast-bats shell wrapper
# send command to fast-bats
# cat <(echo preprocess) \
#   ../../test/internal/bats-exec-test_unit.bats \
#   <(echo -e "\004") \
#   > pipe

FAST_BATS_PIPE=pipe
FAST_BATS_DESCRIPTOR=7

fast_bats_start() {
	# Create pipe and start reader.
  if [[ ! -p "$FAST_BATS_PIPE" && -e "$FAST_BATS_PIPE" ]]
  then
    echo "error $FAST_BATS_PIPE is in the way"
    return 1
  fi

  if [[ ! -e "$FAST_BATS_PIPE" ]]
  then
    mkfifo $FAST_BATS_PIPE
  fi
  if [[ -p "$FAST_BATS_PIPE" ]]
  then
    ./fast-bats < $FAST_BATS_PIPE &
    # Open pipe for writing.
    eval "exec $FAST_BATS_DESCRIPTOR>$FAST_BATS_PIPE"
  else
    echo "error no pipe found: $FAST_BATS_PIPE"
    return 1
  fi
}

fast_bats_stop() {
  pkill fast-bats
	# Close pipe.
	eval "exec $FAST_BATS_DESCRIPTOR>&-"
}
