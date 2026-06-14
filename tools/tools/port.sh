#!/usr/bin/env bash
set -e

# @describe Takes an open/available port between 9900 and 9999
# @option --port![`_choice_port`] <NUM> An available port between 9900 and 9999
# @env LLM_OUTPUT=/dev/stdout The output path

main() {
  echo "port is ok: $argc_port" >>$LLM_OUTPUT
}

_choice_port() {
  local used_ports=$(ss -tuln 2>/dev/null | awk '{print $5}' | grep -oE '[0-9]+$' | sort -u)
  for port in $(seq 9900 9999); do
    if ! echo "$used_ports" | grep -q "^${port}$"; then
      echo "$port"
    fi
  done
}

eval "$(argc --argc-eval "$0" "$@")"
