#!/bin/bash

# internal function unittest
source $BATS_TEST_DIRNAME/../../libexec/bats-preprocess

# binary must be compiled be running tests
cpp_encode_name="$BATS_TEST_DIRNAME/../../fast-bats/src/fast-bats encode_name"

tencode() {
  local cpp_out=$(eval "$cpp_encode_name \"$1\"")
  [[ "$(encode_name "$1")" == "test_$2" ]] && \
    [[ "$cpp_out" == "test_$2" ]]
  return $?
}

@test "encode_name" {
  # utf-8 é = Hexa 00e9
  tencode "é" "é"
  tencode "/" "-2f"
  tencode " " "_"
  tencode "pipo molo font du ski '- \\é" "pipo_molo_font_du_ski_-27-2d_-5cé"
}
