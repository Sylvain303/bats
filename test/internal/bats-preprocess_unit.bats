#!/bin/bash

# internal function unittest
source $BATS_TEST_DIRNAME/../../libexec/bats-preprocess

#ENCODER_ALT=encorder_test.sh
if [[ -e "$ENCODER_ALT" ]] ; then
  source $ENCODER_ALT
fi

source $BATS_TEST_DIRNAME/../../libexec/bats-preprocess

tencode() {
  if [[ -n "$CPP_ENCODE_NAME" ]] ; then
    local cpp_out=$(eval "$cpp_encode_name \"$1\"")
    [[ "$(encode_name "$1")" == "test_$2" ]] && \
      [[ "$cpp_out" == "test_$2" ]]
  else
    [[ "$(encode_name "$1")" == "test_$2" ]]
  fi

  return $?
}

@test "encode_name" {
  # utf-8 é = Hexa 00e9
  tencode "é" "é"
  tencode "/" "-2f"
  tencode " " "_"
  tencode "pipo molo font du ski '- \\é" "pipo_molo_font_du_ski_-27-2d_-5cé"
}
