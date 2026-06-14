# Rules for Writing argc Tools

## Input Validation

- **Use argc choice functions** for all file/path parameters
- **Create `_choice_*` helpers** that return valid options
- **Use `[`\`_choice_fn\``]`** syntax to enforce validation at parse time
- **No bash validation** - if argc accepts it, the tool runs

## Defaults

- **Use argc defaults** with `=value` syntax: `--count=10 <INT>`
- **Never use bash fallbacks** like `${var:-default}`
- **Enum defaults** use `[=default|opt1|opt2]` syntax

## Output

- **Data only** - no headers, banners, or decorative formatting
- **Tab-separated** for structured data
- **No echo "Error:"** messages - let `set -e` fail naturally
- **No "No matches found"** fallbacks - empty output is valid

## Code Style

- **Trust argc** - don't re-validate what argc already validated
- **Minimal bash** - let argc handle defaults, choices, types
- **No wrapper functions** for simple operations
- **Direct commands** - `cat`, `grep`, `find` output straight to `$LLM_OUTPUT`

## Examples

Good:
```bash
# @option --doc-path=README.md[`_choice_doc`] Path to document
read_doc() {
  cat -- "$DOCS_DIR/$argc_doc_path" >>"$LLM_OUTPUT"
}
```

Bad:
```bash
# @option --doc-path Path to document (default: README.md)
read_doc() {
  local doc="${argc_doc_path:-README.md}"
  if [[ ! -f "$DOCS_DIR/$doc" ]]; then
    echo "Error: File not found" >>"$LLM_OUTPUT"
    return 1
  fi
  echo "=== Reading $doc ===" >>"$LLM_OUTPUT"
  cat "$DOCS_DIR/$doc" >>"$LLM_OUTPUT"
}
```
