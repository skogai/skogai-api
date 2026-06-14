#!/usr/bin/env bash
set -e

# @describe Get formatted date/time in various formats
# Provides date/time utilities including current time, unix timestamp, and custom formats

# @option --format="default" The date format to use (now|unix|iso|date|custom)
# @option --custom-format A custom date format string (e.g., "+%Y-%m-%d %H:%M:%S")
# @option --timezone="local" Timezone to use (local|utc)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local format="${argc_format:-default}"
    local tz_prefix=""

    # Handle timezone
    if [[ "$argc_timezone" == "utc" ]]; then
        tz_prefix="TZ=UTC "
    fi

    case "$format" in
        "now")
            # Full datetime with time
            eval "${tz_prefix}date '+%Y-%m-%d %H:%M:%S'" >> "$LLM_OUTPUT"
            ;;
        "unix")
            # Unix timestamp (seconds since epoch)
            eval "${tz_prefix}date +%s" >> "$LLM_OUTPUT"
            ;;
        "iso")
            # ISO 8601 format
            eval "${tz_prefix}date --iso-8601=seconds" >> "$LLM_OUTPUT"
            ;;
        "date")
            # Date only (no time)
            eval "${tz_prefix}date '+%Y-%m-%d'" >> "$LLM_OUTPUT"
            ;;
        "custom")
            # Custom format provided by user
            if [[ -n "$argc_custom_format" ]]; then
                eval "${tz_prefix}date '$argc_custom_format'" >> "$LLM_OUTPUT"
            else
                echo "Error: --custom-format required when using format=custom" >&2
                exit 1
            fi
            ;;
        "default"|*)
            # Default format (date only)
            eval "${tz_prefix}date '+%Y-%m-%d'" >> "$LLM_OUTPUT"
            ;;
    esac
}

eval "$(argc --argc-eval "$0" "$@")"