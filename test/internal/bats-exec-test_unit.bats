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

@test "bats_capture_stack_trace" {
}

@test "bats_print_stack_trace" {
}

@test "bats_print_failed_command" {
}

@test "bats_frame_lineno" {
}

@test "bats_frame_function" {
}

@test "bats_frame_filename" {
}

@test "bats_extract_line" {
}

@test "bats_strip_string" {
}

@test "bats_trim_filename" {
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

