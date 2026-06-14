#!/usr/bin/env bash
set -e

# @describe Get statistics for one or more files
# @option --files+ <FILE> List of files to analyze
# @option --format[text|json] Output format
# @flag --show-hidden Include hidden file details

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local total_size=0
    local file_count=0

    for file in "${argc_files[@]}"; do
        if [[ -f "$file" ]]; then
            local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
            total_size=$((total_size + size))
            file_count=$((file_count + 1))

            if [[ "$argc_format" == "json" ]]; then
                echo "{\"file\": \"$file\", \"size\": $size}" >> "$LLM_OUTPUT"
            else
                echo "File: $file - Size: $size bytes" >> "$LLM_OUTPUT"
            fi
        else
            echo "Warning: $file not found" >> "$LLM_OUTPUT"
        fi
    done

    if [[ "$argc_format" == "json" ]]; then
        echo "{\"total_files\": $file_count, \"total_size\": $total_size}" >> "$LLM_OUTPUT"
    else
        echo "---" >> "$LLM_OUTPUT"
        echo "Total: $file_count files, $total_size bytes" >> "$LLM_OUTPUT"
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
