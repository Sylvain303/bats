#!/bin/bash

# already sourced we are excuting ourself
# fake resourcing
sed -e 's/bats_/mybats_/g' \
    -e 's/BATS_/MYBATS_/g' \
    -e 's/\<setup\>/mysetup/g' \
    -e 's/\<skip\>/myskip/g' \
    -e 's/\<run\>/myrun/g' \
    -e 's/\<teardown\>/myteardown/g' \
      $BATS_TEST_DIRNAME/../../libexec/bats-exec-test

mysetup=NONE
setup {
  mysetup=OK
}

@test "bats_test_begin" {
  #BATS_TEST_DESCRIPTION="$1"
  #if [ -n "$BATS_EXTENDED_SYNTAX" ]; then
  #  echo "begin $BATS_TEST_NUMBER $BATS_TEST_DESCRIPTION" >&3
  #fi
}

@test "bats_test_function" {
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

