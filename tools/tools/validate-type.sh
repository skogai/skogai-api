#!/usr/bin/env bash
set -e

# @describe Validate input against skogparse type system
# @option --type![`_choice_type`] The expected type
# @option --value! The value to validate

main() {
    local result=$(skogparse "$argc_value")
    local actual_type=$(echo "$result" | jq -r '.type')

    if [[ "$actual_type" == "$argc_type" ]]; then
        echo "Valid: $argc_value is $argc_type"
        echo "$result"
    else
        echo "Invalid: expected $argc_type but got $actual_type" >&2
        exit 1
    fi
}

_choice_type() {
    echo "string"
    echo "number"
    echo "bool"
    echo "null"
    echo "array"
    echo "object"
    echo "ref"
    echo "action"
}

eval "$(argc --argc-eval "$0" "$@")"
