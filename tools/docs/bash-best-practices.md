# Bash Tool Best Practices

Essential patterns and common mistakes when writing argc-based Bash tools.

## Output to LLM_OUTPUT

**What you want to show as output should be sent to `$LLM_OUTPUT`**

```bash
# Send output to LLM_OUTPUT
echo "result" >> "$LLM_OUTPUT"

# Heredoc
cat <<EOF >>"$LLM_OUTPUT"
Multiple lines
EOF

# Command output
curl -fsSL "https://example.com" >> "$LLM_OUTPUT"
```

Use `>` to overwrite or `>>` to append - normal bash redirection.

### Testing Your Tool

When testing, set `LLM_OUTPUT` to a file to see the actual output:

```bash
LLM_OUTPUT=/tmp/output.txt ./tools/my_tool.sh --param value
cat /tmp/output.txt
```

Or use the framework's test runner:

```bash
argc run@tool my_tool.sh '{"param":"value"}'
```

## Tool Structure Template

```bash
#!/usr/bin/env bash
set -e

# @describe Brief description of what the tool does
# @option --param1!           Required parameter
# @option --param2=default    Optional with default
# @flag --verbose             Boolean flag

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Your tool logic here
    # Access params via: $argc_param1, $argc_param2, $argc_verbose

    # Output results (use >> not >)
    echo "result" >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
```

## Variable Access Patterns

### String Options
```bash
# @option --name! The user's name
main() {
    echo "Hello $argc_name" >> "$LLM_OUTPUT"
}
```

### Flags (Boolean)
```bash
# @flag --verbose Enable verbose output
main() {
    if [[ "$argc_verbose" == "1" ]]; then
        echo "Verbose mode enabled" >> "$LLM_OUTPUT"
    fi
}
```

### Arrays (Multi-value)
```bash
# @option --files* <FILE> List of files
main() {
    for file in "${argc_files[@]}"; do
        echo "Processing: $file" >> "$LLM_OUTPUT"
    done
}
```

### With Defaults
```bash
# @option --count=1 <INT> How many times
main() {
    for ((i=1; i<=argc_count; i++)); do
        echo "Iteration $i" >> "$LLM_OUTPUT"
    done
}
```

## Naming Convention

**Kebab-case in comments → Snake_case in variables**

```bash
# @option --my-param    → $argc_my_param
# @flag --is-enabled    → $argc_is_enabled
# @option --file-path   → $argc_file_path
```

## Common Patterns

### Piping Command Output
```bash
main() {
    curl -fsSL "https://api.example.com" >> "$LLM_OUTPUT"
}
```

### Building Complex Output
```bash
main() {
    cat <<EOF >>"$LLM_OUTPUT"
Name: $argc_name
Count: $argc_count
Verbose: $argc_verbose
EOF
}
```

### Using LLM Framework Variables
```bash
# Available environment variables:
# - LLM_OUTPUT: Where to write output
# - LLM_ROOT_DIR: Path to llm-functions directory
# - LLM_TOOL_NAME: Name of current tool
# - LLM_TOOL_CACHE_DIR: Tool-specific cache directory

main() {
    echo "Tool: $LLM_TOOL_NAME" >> "$LLM_OUTPUT"
    echo "Cache: $LLM_TOOL_CACHE_DIR" >> "$LLM_OUTPUT"
}
```

## Testing Your Tool

```bash
# Build the tool (generates functions.json)
argc build@tool your_tool.sh

# Test run
argc run@tool your_tool.sh '{"name":"Alice","count":3}'
```

## Common Mistakes

1. **Using `>` instead of `>>`** - Will overwrite LLM_OUTPUT
2. **Forgetting the eval line** - argc won't parse arguments
3. **Wrong variable names** - Remember kebab → snake conversion
4. **Not quoting variables** - Use `"$argc_var"` not `$argc_var`
5. **Flag checks without quotes** - Use `[[ "$argc_flag" == "1" ]]`

## Quick Reference

| Pattern | Comment Tag | Variable Access |
|---------|-------------|-----------------|
| Required string | `@option --name!` | `$argc_name` |
| Optional string | `@option --name` | `$argc_name` |
| With default | `@option --name=default` | `$argc_name` |
| Integer | `@option --count <INT>` | `$argc_count` |
| Number | `@option --price <NUM>` | `$argc_price` |
| Enum | `@option --mode[dev\|prod]` | `$argc_mode` |
| Array (optional) | `@option --files*` | `${argc_files[@]}` |
| Array (required) | `@option --files+` | `${argc_files[@]}` |
| Boolean flag | `@flag --verbose` | `$argc_verbose` (0 or 1) |

## See Also

- `tool-development-guide.md` - Complete tool creation guide with argc syntax reference
- `variables.md` - Full argc variable system
- `environment-variables.md` - LLM framework environment variables
