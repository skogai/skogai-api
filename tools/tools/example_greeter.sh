#!/usr/bin/env bash
set -e

# @describe Greet a user with a customizable message
# @option --name! The name of the person to greet
# @option --greeting=Hello The greeting word to use
# @flag --uppercase Convert output to uppercase

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local message="$argc_greeting, $argc_name!"

    if [[ "$argc_uppercase" == "1" ]]; then
        message=$(echo "$message" | tr '[:lower:]' '[:upper:]')
    fi

    echo "$message" >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
