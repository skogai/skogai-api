#!/usr/bin/env bash
set -e

# @describe Takes a number between 1 and 100 and echoes it
# @option --type!

main() {
  skogparse "$argc_type"
}

eval "$(argc --argc-eval "$0" "$@")"
