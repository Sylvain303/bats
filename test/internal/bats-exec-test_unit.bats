#!/bin/bash

# already sourced we are excuting ourself
# fake resourcing a transcripted code See Makefile: make mybats-exec-test

source mybats-exec-test
mysetup_call=NONE

setup() {
  mysetup_call=NONE
}

mysetup() {
  mysetup_call=OK
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

@test "bats_frame_function" {
}

@test "bats_debug_trap" {
}

@test "bats_error_trap" {
}

@test "bats_teardown_trap" {
}

@test "bats_exit_trap" {
}

@test "bats_perform_tests" {
}

@test "bats_perform_test" {
}

@test "bats_preprocess_source" {
}

@test "bats_cleanup_preprocessed_source" {
}

@test "bats_evaluate_preprocessed_source" {
}

