#!/usr/bin/env bash

# @describe Parse input text using skogparse and return the output
# @option --input! The text to parse with skogparse

# @env LLM_OUTPUT=/dev/stdout The output path
# @env SKOGAI_SCRIPTS=/skogai/scripts

main() {
  echo "$argc_input" >/tmp/skogparse_input.tmp
  export SKOGAI_SCRIPTS="/skogai/scripts"
  /mnt/sda2/WORKING_SKOGPARSE/bin/Release/net9.0/linux-x64/SkogParse --execute /tmp/skogparse_input.tmp >$LLM_OUTPUT
  # /home/skogix/.local/bin/skogparse "$argc_input" >/tmp/llm_output.txt
  # cat /tmp/llm_output.txt  # cat /tmp/llm_output.txt >$LLM_OUTPUT
}

eval "$(argc --argc-eval "$0" "$@")"
