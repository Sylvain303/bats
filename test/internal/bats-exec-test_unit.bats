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

source mybats-exec-test
mysetup_call=NONE
myteardown_call=NONE

setup() {
  mysetup_call=NONE
  myteardown_call=NONE
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
  run mybats_frame_filename "33 some_dumy_func $filename"

  [[ ! -z "$output" ]]
  [[ "$output" == "$filename" ]]

  # secial case filename == $MYBATS_TEST_SOURCE
  run mybats_frame_filename "33 some_dumy_func $MYBATS_TEST_SOURCE"

  [[ ! -z "$output" ]]
  [[ "$output" == "$MYBATS_TEST_FILENAME" ]]
}

@test "bats_frame_lineno" {
  lineno=33
  run mybats_frame_lineno "$lineno some_dumy_func /dumy/filename"
  [[ "$output" == "$lineno" ]]
}

@test "bats_frame_function" {
  funcname=pipo_func
  run mybats_frame_function "33 $funcname /dumy/filename"
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
  mybats_debug_trap mybats-exec-test
  [[ -z "$MYBATS_LINENO" ]]
  mybats_debug_trap some_dummy_filename
  [[ ! -z "$MYBATS_LINENO" ]]
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
  # Some doc about globals:
  #  # set by mybats_error_trap() or mybats_teardown_trap()
  #  MYBATS_ERROR_STACK_TRACE=()
	#  MYBATS_ERROR_STATUS=1
  #  # set by mybats_init()
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

  # skip + test without explicit skip message
  # We test for this portion of code:
  #  echo "ok ${MYBATS_TEST_NUMBER}${skipped} ${MYBATS_TEST_DESCRIPTION}" >&3
  #  status=0
  run ./test_mybats_exit_trap1.sh 23 my_description ""
  echo "n lines=${#lines[@]}, status=$status, '$output' '${lines[1]}'"
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
}

@test "bats_teardown_trap" {
  skip "not working yet"
  # check trap still in place for new test
  run trap -p
  debug_trap=$(echo "$output" | grep DEBUG)
  echo "debug_trap=$debug_trap"
  [[ "$output" =~ DEBUG ]]
  # call myteardown() + mybats_exit_trap
  # need to write myteardown output to MYBATS_OUT
  MYBATS_OUT=mybats.out
  [[ "$myteardown_call" == "NONE" ]]
  mybats_teardown_trap
  [[ "$myteardown_call" == "OK" ]]
  [[ -s "$MYBATS_OUT" ]]
}

@test "bats_perform_test" {
  # non recursive call for test a single @test
}

@test "bats_perform_tests" {
  # recursive script call with extented argument
}


@test "bats_preprocess_source" {
}

@test "bats_cleanup_preprocessed_source" {
}

@test "bats_evaluate_preprocessed_source" {
}
