#!/bin/bash
#
# This bats file goal is to unittest functions in
# ../../libexec/bats-exec-suite
# as the file itself is exentsivly used to run this very test, we use a
# fake resourcing a transcripted code.
#
# Most of the code is renamed bats_ to mybats_ also bats tools.
#
# See Makefile for details, not fulling working yet use commited file
#    make mybats-exec-test

source $BATS_TEST_DIRNAME/mybats-exec-test
mysetup_call=NONE
myteardown_call=NONE

setup() {
  mysetup_call=NONE
  myteardown_call=NONE
}

teardown() {
  local n=$(ls "$BATS_TMPDIR" | grep -E 'bats\.[0-9]+\.out$' | wc -l)
  # rm -f $BATS_TMPDIR/bats.*.out
  [[ $n -ne 0 ]] || {
    echo "$BATS_TEST_DESCRIPTION $n"
    false
  }
}

mysetup() {
  mysetup_call=OK
}

myteardown() {
  myteardown_call=OK
  echo called myteardown
}

@test "bats_test_begin and setup" {
  [[ "$BATS_TEST_DESCRIPTION" == "bats_test_begin and setup" ]]
  MYBATS_TEST_DESCRIPTION=""
  [[ -z "$MYBATS_TEST_DESCRIPTION" ]]
  # not call by run, doesn't work to test global assignment
  mybats_test_begin "BATS_TEST_DESCRIPTION" 33
  [[ ! -z "$MYBATS_TEST_DESCRIPTION" ]]
  [[ "$MYBATS_TEST_DESCRIPTION" == "BATS_TEST_DESCRIPTION" ]]
  [[ "$mysetup_call" == "OK" ]]
}

@test "bats_test_function" {
  MYBATS_TEST_NAMES=()
  mybats_test_function "bats_test_function"
  [[ ${#MYBATS_TEST_NAMES[@]} -eq 1 ]]
  [[ ${MYBATS_TEST_NAMES[0]} ==  "bats_test_function" ]]
}

@test "bats_frame_filename" {
  MYBATS_TEST_FILENAME=me
  MYBATS_TEST_SOURCE=you
  # caller displays:
  # line number, subroutine name, and source filename
  # corresponding to that position in the current execution call stack.
  filename="/home/user/path/to/source.sh"
  run mybats_frame_filename "33 some_dummy_func $filename"

  [[ ! -z "$output" ]]
  [[ "$output" == "$filename" ]]

  # secial case filename == $MYBATS_TEST_SOURCE
  run mybats_frame_filename "33 some_dummy_func $MYBATS_TEST_SOURCE"

  [[ ! -z "$output" ]]
  [[ "$output" == "$MYBATS_TEST_FILENAME" ]]
}

@test "bats_frame_lineno" {
  lineno=33
  run mybats_frame_lineno "$lineno some_dummy_func /dummy/filename"
  [[ "$output" == "$lineno" ]]
}

@test "bats_frame_function" {
  funcname=pipo_func
  run mybats_frame_function "33 $funcname /dummy/filename"
  [[ "$output" == "$funcname" ]]
}

@test "bats_capture_stack_trace" {
  # silly test for now
  MYBATS_CURRENT_STACK_TRACE=()
  [[ -z "$MYBATS_SOURCE" ]]
  [[ -z "$MYBATS_LINENO" ]]
  mybats_capture_stack_trace
  [[ -z "$output" ]]
  echo "MYBATS_SOURCE=$MYBATS_SOURCE"
  echo "MYBATS_LINENO=$MYBATS_LINENO"
  echo "MYBATS_CURRENT_STACK_TRACE=${MYBATS_CURRENT_STACK_TRACE[@]}"
  [[ ! -z "$MYBATS_SOURCE" ]]
  [[ ! -z "$MYBATS_LINENO" ]]
  [[ ${#MYBATS_CURRENT_STACK_TRACE[@]} -gt 1 ]]
}

@test "bats_trim_filename" {
  MYBATS_CWD=$(readlink -f .)
  run mybats_trim_filename inexistant
  [[ "$output" == "inexistant" ]]
  run mybats_trim_filename "$(readlink -f $BATS_TEST_FILENAME)"
  echo "BATS_TEST_FILENAME=$BATS_TEST_FILENAME"
  echo "output=$output"
  [[ "$output" == "$(basename $BATS_TEST_FILENAME)" ]]
  batsfilename="$(readlink -f ../../libexec/bats)"
  run mybats_trim_filename "$batsfilename"
  [[ "$output" == "$batsfilename" ]]
}

@test "bats_print_stack_trace" {
  # not defined by bats-exec-test itself only in bats top wrapper
  MYBATS_CWD=$(readlink -f .)
  # get a stack trace un $MYBATS_CURRENT_STACK_TRACE
  mybats_capture_stack_trace
  [[ ${#MYBATS_CURRENT_STACK_TRACE[@]} -gt 1 ]]
  #mybats_print_stack_trace "${MYBATS_CURRENT_STACK_TRACE[@]}" > log
  run mybats_print_stack_trace "${MYBATS_CURRENT_STACK_TRACE[@]}"
  [[ ! -z "$output" ]]
}

@test "bats_extract_line" {
  run mybats_extract_line lineno.txt 10
  [[ "$output" == "line10" ]]
  run mybats_extract_line lineno.txt 3
  [[ "$output" == "line3" ]]
}

@test "bats_strip_string" {
  run mybats_strip_string $' \t some char here \t\t\t'
  [[ "$output" == "some char here" ]]
}

@test "bats_print_failed_command" {
  run mybats_print_failed_command "5 some_func lineno.txt"  2
  echo "output=$output"
  regexp="with status"
  [[ "$output" =~ $regexp ]]
  [[ "$output" =~ line5 ]]
  # without status value == 1
  run mybats_print_failed_command "4 some_func lineno.txt"  1
  [[ ! "$output" =~ $regexp ]]
  [[ "$output" =~ line4 ]]
}

@test "bats_debug_trap" {
  # in bash debug trap is called for every line of code executed by bash

  # called on trap debug with $BASH_SOURCE as argument
  # will call mybats_capture_stack_trace if we are not $BASH_SOURCE
  [[ -z "$MYBATS_LINENO" ]]

  # pass the filename where the current code leave
  mybats_debug_trap $BATS_TEST_DIRNAME/mybats-exec-test
  [[ -z "$MYBATS_LINENO" ]]

  mybats_debug_trap some_dummy_filename
  [[ -n "$MYBATS_LINENO" ]]
}

@test "bats_error_trap" {
  # collect MYBATS_ERROR_STATUS and MYBATS_ERROR_STACK_TRACE
  # it also removes trap debug
  # save current trap
  run trap -p
  debug_trap=$(echo "$output" | grep DEBUG)
  echo "debug_trap=$debug_trap"
  [[ "$output" =~ DEBUG ]]
  [[ -z "$MYBATS_ERROR_STATUS" ]]
  mybats_error_trap
  run trap -p
  [[ ! "$output" =~ DEBUG ]]
  [[ ! -z "$MYBATS_ERROR_STATUS" ]]
}

@test "bats_exit_trap" {
  # ensure we are runing in our own directory
  cd $BATS_TEST_DIRNAME

  # Some doc about globals used in mybats_exit_trap:
  #  # set by mybats_error_trap() or mybats_teardown_trap()
  #  MYBATS_ERROR_STACK_TRACE=()
	#  MYBATS_ERROR_STATUS=1
  #  # set by bats_main_test_exec()
  #  MYBATS_OUT=mybats.out
  #  # set by mybats_teardown_trap()
	#  MYBATS_TEARDOWN_COMPLETED=1
  #  # set by myskip() or mybats_perform_test() (after the test)
	#  MYBATS_TEST_COMPLETED=""
  #  # set by mybats_test_begin()
	#  MYBATS_TEST_DESCRIPTION="some description"
  #  # set by mybats_perform_test() (singular)
	#  MYBATS_TEST_NUMBER=23
  #  # set by myskip() if any
	#  MYBATS_TEST_SKIPPED=0

  # mybats_exit_trap() displays test result and do some cleanup.
  # We run outer script to ensure trap behavior isolation from bats itself.

  # #################################### ok - no error or skiped
  #
  # skip + test without explicit skip message
  # We test for this portion of code:
  #  echo "ok ${MYBATS_TEST_NUMBER}${skipped} ${MYBATS_TEST_DESCRIPTION}" >&3
  #  status=0

  # the MYBATS_OUT filename is outputed on line0
  run ./test_mybats_exit_trap1.sh 23 my_description ""
  echo "nb lines=${#lines[@]}, status=$status, '$output' '${lines[1]}'"
  [[ $status -eq 0 ]]
  [[ "${lines[1]}" == "ok 23 # myskip my_description" ]]

  # skip + with explicit skip message
  skip_message="my skip message"
  run ./test_mybats_exit_trap1.sh 55 my_description "$skip_message"
  echo "'$output'"
  [[ $status -eq 0 ]]
  [[ "${lines[1]}" == "ok 55 # myskip ($skip_message) my_description" ]]

  # ensure $MYBATS_OUT removed
  MYBATS_OUT=${lines[0]}
  echo "MYBATS_OUT=$MYBATS_OUT"
  echo $MYBATS_OUT
  [[ -n "$MYBATS_OUT" && ! -e "$MYBATS_OUT" ]]
  echo $MYBATS_OUT | grep -E 'out$'


  # #################################### not ok - some errors
  # testing code:
  #   echo "not ok $MYBATS_TEST_NUMBER $MYBATS_TEST_DESCRIPTION" >&3

  # MYBATS_OUT and saved_MYBATS_OUT are outputed on line1 and line2
  # so output starts at line3 (index 2)
  number=76
  description="some not ok description"
  run ./test_mybats_exit_trap2.sh $number "$description"
  echo "'${lines[2]}'"
  echo "${lines[2]}" | grep "^not ok $number $description"
  [[ $status -eq 1 ]]
  [[ ${#lines[@]} -gt 3 ]]

	# tests that the function output collected in MYBATS_OUT is outputed by:
  #    sed -e "s/^/# /" < "$MYBATS_OUT" >&3
  saved_MYBATS_OUT=${lines[1]}
  ext_test_fname=$(cat $saved_MYBATS_OUT)
  [[ -s "$saved_MYBATS_OUT" ]] && rm $saved_MYBATS_OUT
  echo "${lines[-1]}" | grep -E "^# $ext_test_fname"
}

@test "bats_teardown_trap" {
  cd $BATS_TEST_DIRNAME
  # check trap in place
  run trap -p
  echo "$output" | grep -E 'DEBUG|EXIT|ERR'

  # mybats_teardown_trap calls myteardown() + mybats_exit_trap
  EXIT_STATUS=0
  EXIT_STATUS_TEARDOWN=0
  number=22
  run ./test_mybats_teardown_trap.sh $number "some desc" \
    $EXIT_STATUS $EXIT_STATUS_TEARDOWN
  echo "${lines[1]}" | grep -E "^ok $number"
  [[ $status -eq $EXIT_STATUS ]]
  [[ ${#lines[@]} -eq 2 ]]

  EXIT_STATUS=1
  EXIT_STATUS_TEARDOWN=0
  run ./test_mybats_teardown_trap.sh $number "some desc" \
    $EXIT_STATUS $EXIT_STATUS_TEARDOWN
  echo "${lines[1]}" | grep -E "^not ok $number"
  [[ $status -eq $EXIT_STATUS ]]
  echo "${lines[-1]}" | grep -E "^# myteardown $EXIT_STATUS_TEARDOWN"

  EXIT_STATUS=0
  EXIT_STATUS_TEARDOWN=1
  run ./test_mybats_teardown_trap.sh $number "some desc" \
    $EXIT_STATUS $EXIT_STATUS_TEARDOWN
  echo "${lines[1]}" | grep -E "^not ok $number"
  [[ $status -eq $EXIT_STATUS_TEARDOWN ]]
  echo "${lines[-1]}" | grep -E "^# myteardown $EXIT_STATUS_TEARDOWN"

  EXIT_STATUS=2
  EXIT_STATUS_TEARDOWN=1
  run ./test_mybats_teardown_trap.sh $number "some desc" \
    $EXIT_STATUS $EXIT_STATUS_TEARDOWN
  echo "${lines[1]}" | grep -E "^not ok $number"
  [[ $status -eq $EXIT_STATUS_TEARDOWN ]]
  echo "${lines[-1]}" | grep -E "^# myteardown $EXIT_STATUS_TEARDOWN"
}

@test "bats_main_test_exec (init_only)" {
  # setup environment

  echo $BATS_TEST_FILENAME
  # no run, we affect global vars
  mybats_main_test_exec init_only "$BATS_TEST_FILENAME"

  # test env setup
  # + use TMPDIR
  vars="
  MYBATS_COUNT_ONLY
  MYBATS_EXTENDED_SYNTAX
  MYBATS_OUT
  MYBATS_PARENT_TMPNAME
  MYBATS_TEST_DIRNAME
  MYBATS_TEST_FILENAME
  MYBATS_TEST_NAMES
  MYBATS_TMPDIR
  MYBATS_TMPNAME
  "

  # example output:
  # MYBATS_COUNT_ONLY=
  # MYBATS_EXTENDED_SYNTAX=
  # MYBATS_OUT=/tmp/bats.22622.out
  # MYBATS_PARENT_TMPNAME=/tmp/bats.20962
  # MYBATS_TEST_DIRNAME=/home/sylvain/code/bats/test/internal
  # MYBATS_TEST_FILENAME=/home/sylvain/code/bats/test/internal/bats-exec-test_unit.bats
  # MYBATS_TEST_NAMES=()
  # MYBATS_TMPDIR=/tmp
  # MYBATS_TMPNAME=/tmp/bats.22622

  set | grep ^MYBATS_

  for v in $vars
  do
    set | grep -q "^$v" || { echo "$v notfound" && exit 1; }
  done

	# count
	mybats_main_test_exec init_only -c "$BATS_TEST_FILENAME"
  [[ "$MYBATS_COUNT_ONLY" -eq 1 ]]
  [[ "$MYBATS_TEST_FILENAME" == "$BATS_TEST_FILENAME" ]]

  # extended
	mybats_main_test_exec init_only -x "$BATS_TEST_FILENAME"
  [[ "$MYBATS_EXTENDED_SYNTAX" == "-x" ]]
  [[ "$MYBATS_TEST_FILENAME" == "$BATS_TEST_FILENAME" ]]

  # usage:
  run mybats_main_test_exec init_only
  [[ $status -eq 1 ]]
  [[ "$output" =~ filename ]]

  # file not found
  run mybats_main_test_exec init_only dummy
  [[ $status -eq 1 ]]
  echo "$output" | grep -E 'does not exist'

  # dirname + tmp
  mydirname=$(dirname "$BATS_TEST_FILENAME")
  mybats_main_test_exec init_only "$BATS_TEST_FILENAME"
  [[ "$MYBATS_TEST_DIRNAME" == "$BATS_TEST_DIRNAME" ]]
  [[ "$MYBATS_TEST_DIRNAME" == "$mydirname" ]]
  [[ "$MYBATS_TMPDIR" == "/tmp" ]]
  echo "$MYBATS_TMPNAME" | grep -E '^/tmp'

  export TMPDIR=/toto
  mybats_main_test_exec init_only "$BATS_TEST_FILENAME"
  [[ "$MYBATS_TEST_DIRNAME" == "$BATS_TEST_DIRNAME" ]]
  [[ "$MYBATS_TMPDIR" == "$TMPDIR" ]]
  echo "$MYBATS_TMPNAME" | grep -E "^$TMPDIR"
}

@test "bats_preprocess_source" {
  # generate preprocessed shell script in $MYBATS_TEST_SOURCE
  # install trap

  cd $BATS_TEST_DIRNAME
  run ./test_mybats_preprocess_source.sh "$BATS_LIBEXEC" "$BATS_TEST_FILENAME"

  test_source=${lines[0]}
  [[ -s "$test_source" ]]
  [[ $(wc -l < "$test_source") -gt $(wc -l < "$BATS_TEST_FILENAME") ]]

  # syntax validation, no exec
  bash -n "$test_source"

  # count traps
  n=$(echo "$output" | grep -c ^trap)
  [[ $n -eq 3 ]]

  # our trap called
  echo "${lines[-1]}" | grep -q -E '^mybats_cleanup_preprocessed_source'

  # ensure it support DOS end-of-line removal
  f=../fixtures/bats/dos_line.bats
  run ./test_mybats_preprocess_source.sh "$BATS_LIBEXEC" "$f"
  [[ $status -eq 0 ]]
  test_source=${lines[0]}

  if grep -q $'\r' $test_source
  then
    echo "some \\r in $test_source" && false
  fi

  # lint again
  bash -n $test_source
  rm $test_source
}

@test "bats_evaluate_preprocessed_source" {
  cd $BATS_TEST_DIRNAME
  # mybats_evaluate_preprocessed_source does:
  # sourcing $MYBATS_TEST_SOURCE or ${MYBATS_PARENT_TMPNAME}.src ??
  # what is the usecase for sourcing MYBATS_PARENT_TMPNAME?

  # generating a preprocessed file
  f=../fixtures/bats/loop_keep_IFS.bats
  run ./test_mybats_preprocess_source.sh "$BATS_LIBEXEC" "$f"
  test_source=${lines[0]}
  MYBATS_TMPNAME=${lines[1]}

  [[ $status -eq 0 ]]
  [[ -n "$MYBATS_TMPNAME" ]]
  [[ ! -e "$MYBATS_TMPNAME" ]]
  bash -n "$test_source"

  # prepares call for mybats_evaluate_preprocessed_source
  MYBATS_TEST_NAMES=()
  MYBATS_TEST_SOURCE="$test_source"
  # reformats output to call our mybats_ version
  sed -i -e 's/^bats_/mybats_/' "$test_source"

  # in current env (no run)
  mybats_evaluate_preprocessed_source

  echo "MYBATS_TEST_NAMES=${#MYBATS_TEST_NAMES[@]}"
  [[ ${#MYBATS_TEST_NAMES[@]} -eq 1 ]]
  [[ ${MYBATS_TEST_NAMES[0]} ==  "test_loop-2d5ffunc" ]]

  # our test code is sourced
  type -t loop_func | grep '^function'

  rm "$test_source"
}

@test "bats_cleanup_preprocessed_source" {
  cd $BATS_TEST_DIRNAME
  MYBATS_TEST_SOURCE=tmp_some.$$

  [[ $status -eq 0 ]]
  echo "mybats_cleanup_preprocessed_source" > $MYBATS_TEST_SOURCE
  [[ -s "$MYBATS_TEST_SOURCE" ]]
  run mybats_cleanup_preprocessed_source
  [[ ! -e "$MYBATS_TEST_SOURCE" ]]
  [[ $status -eq 0 ]]
  run mybats_cleanup_preprocessed_source
  [[ $status -eq 0 ]]
}

@test "bats_perform_test" {
  # non recursive call for test a single @test
  cd $BATS_TEST_DIRNAME

  run ./test_mybats_perform_test.sh
  [[ $status -eq 1 ]]

  run ./test_mybats_perform_test.sh "dummy" "0"
  echo "$output" | grep -E 'bats: unknown test name .dummy'
  echo "$output" | grep -E '^our_exit_trap'

  number=22
  run ./test_mybats_perform_test.sh our_fake_func_true "$number"
  [[ $status -eq 0 ]]
  echo "${lines[-1]}" | grep -E "^ok $number"
  echo "$output" | grep -E '^our_exit_linked_trap'

  run ./test_mybats_perform_test.sh our_fake_func_false "$number"
  [[ $status -eq 1 ]]
  echo "$output" | grep -E "^not ok $number"

  MYBATS_OUT=${lines[1]}
  grep "our_fake_func_false" $MYBATS_OUT
  rm -f /tmp/MYBATS_OUT.*
}

@test "bats_perform_tests" {
  # recursive script call with extented argument
  cd $BATS_TEST_DIRNAME

  # This is the "normal" path of calling the test. This function will call all
  # test function @test one by one in a sub-shell recursively calling $?
  # (bats-exec-test) with extra argument, so it will itself call
  # bats_perform_test (singular).
  # This way sub-shell creates an isolation level between each tests

  MYBATS_TEST_NAMES=( one two three four )
  n=${#MYBATS_TEST_NAMES[@]}
  run ./test_mybats_perform_tests.sh no-rec "${MYBATS_TEST_NAMES[@]}"
  echo "$output"
  # tap line
  echo "${lines[1]}" | grep "1..$n"
  # same recusive number of call$
  [[ $(echo "$output" | grep -c "call_id:") -eq $n ]]
  # check distinct PID
  nbids=$(echo "$output" | awk '/_id: [0-9]+/ {print $2}' | sort -n -u | wc -l)
  [[ $nbids -eq $(($n + 1)) ]]

  export MYBATS_EXTENDED_SYNTAX=-x
  run ./test_mybats_perform_tests.sh no-rec "${MYBATS_TEST_NAMES[@]}"
  echo "$output" | grep -E "\[4] \('-x'"

  unset MYBATS_EXTENDED_SYNTAX
  run ./test_mybats_perform_tests.sh no-rec "${MYBATS_TEST_NAMES[@]}"
  echo "$output" | grep -E "\[3\]"

  # test if MYBATS_TEST_FILENAME is correctly passed
  export MYBATS_TEST_FILENAME=mytest_dummy_name
  run ./test_mybats_perform_tests.sh no-rec "${MYBATS_TEST_NAMES[@]}"
  echo "$output" | grep -E "'$MYBATS_TEST_FILENAME' '${MYBATS_TEST_NAMES[0]}"
}

@test "bats_main_test_exec" {
  # full code run
  input=../fixtures/bats/loop_keep_IFS.bats
  run ./test_mybats_main_test_exec.sh "$input"
  [[ $status -eq 0 ]]
}

# heplers
# myskip - DONE in test_mybats_exit_trap1.sh

@test "helper: run" {
}

@test "helper: load" {
}
