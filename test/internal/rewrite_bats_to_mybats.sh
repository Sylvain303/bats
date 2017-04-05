#!/bin/bash

RULES="
\<setup\>
\<skip\>
\<run\>
\<teardown\>
\<load\>
"

SED_RULES=()

build_rule() {
  SED_RULES+=( "-e 's/$1/$2/g'" )
}

if [[ "$1" == '--reverse' ]]
then
  shift
  build_rule mybats_ bats_
  build_rule MYBATS_ BATS_
  for r in $RULES
  do
    lr=${r//\\</my}
    rr=${r//\\[<>]/}
    build_rule "\\<$lr" "$rr"
  done
else
  build_rule bats_ mybats_
  build_rule BATS_ MYBATS_
  for r in $RULES
  do
    rr=${r//\\[<>]/}
    build_rule "$r" "my$rr"
  done
fi

#echo sed "${SED_RULES[@]}" "$@" > log
eval sed "${SED_RULES[@]}" "$@"
