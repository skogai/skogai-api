#!/usr/bin/env bash

# @describe SkogAI context generation
# @meta version 1.0.0
# @meta dotenv
# @env LLM_OUTPUT=/dev/stdout The output path

ROOT_DIR="${LLM_ROOT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# @cmd All parameter types in one command
# @flag -v --verbose              Enable verbose output
# @flag -q --quiet                Suppress output
# @flag -f --force*               Can be used multiple times
# @option -o --output <FILE>      Output file path
# @option -c --config <PATH>      Config file path
# @option -t --type[json|yaml|xml] Output format with choices
# @option -e --env $ENV_VAR       Bind to environment variable
# @option --tags*,                Multi-value comma-separated tags
# @arg input!                     Required input file
# @arg output                     Optional output file
# @arg extras*                    Additional files (multi-value)
main() {
  echo "=== ALL PARAMETER TYPES ==="

  # Flags (boolean values)
  echo "verbose: $argc_verbose"
  echo "quiet: $argc_quiet"
  echo "force count: $argc_force"

  # Options with values
  echo "output: $argc_output"
  echo "config: $argc_config"
  echo "type: $argc_type"
  echo "env: $argc_env"
  echo "tags: ${argc_tags[*]}"

  # Arguments
  echo "input (required): $argc_input"
  echo "output (optional): $argc_output"
  echo "extras: ${argc_extras[*]}"

  # Built-in variables
  echo "function: $argc__fn"
  echo "all args: ${argc__args[*]}"
  echo "positionals: ${argc__positionals[*]}"
}

# See more details at https://github.com/sigoden/argc
eval "$(argc --argc-eval "$0" "$@")"
