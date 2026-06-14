#!/usr/bin/env bash
set -e

# @describe Classic FizzBuzz implementation - prints numbers 1 to max, replacing multiples of 3 with 'Fizz', multiples of 5 with 'Buzz', and multiples of both with 'FizzBuzz'
# @env LLM_OUTPUT=/dev/stdout The output path
# @option --int![`_choice_int`] The amounts of numbers to print

main() {
  local max=${argc_int:-15}

  for ((i = 1; i <= max; i++)); do
    if ((i % 15 == 0)); then
      echo "FizzBuzz" >>"$LLM_OUTPUT"
    elif ((i % 3 == 0)); then
      echo "Fizz" >>"$LLM_OUTPUT"
    elif ((i % 5 == 0)); then
      echo "Buzz" >>"$LLM_OUTPUT"
    else
      echo "$i" >>"$LLM_OUTPUT"
    fi
  done
}

_choice_int() {
  seq 1 100
}

eval "$(argc --argc-eval "$0" "$@")"
