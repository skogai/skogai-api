#!/usr/bin/env bash
set -e

# @describe Perform basic arithmetic operations
# @option --a! <NUM> First number
# @option --b! <NUM> Second number
# @option --operation![add|subtract|multiply|divide] The operation to perform

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local result

    case "$argc_operation" in
        add)
            result=$(echo "$argc_a + $argc_b" | bc -l)
            ;;
        subtract)
            result=$(echo "$argc_a - $argc_b" | bc -l)
            ;;
        multiply)
            result=$(echo "$argc_a * $argc_b" | bc -l)
            ;;
        divide)
            if [[ "$argc_b" == "0" ]]; then
                echo "Error: Division by zero" >> "$LLM_OUTPUT"
                exit 1
            fi
            result=$(echo "scale=2; $argc_a / $argc_b" | bc -l)
            ;;
    esac

    cat <<EOF >>"$LLM_OUTPUT"
Operation: $argc_a $argc_operation $argc_b
Result: $result
EOF
}

eval "$(argc --argc-eval "$0" "$@")"
