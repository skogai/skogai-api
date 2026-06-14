# Tool Development Guide

Quick reference for creating LLM tools using Bash, JavaScript, and Python with argc comment-driven schemas.

## Overview

Tools are functions callable by LLMs. Use specially formatted comments in source code to auto-generate function declarations. The `Argcfile.sh` script parses comments to create JSON schemas.

**Process:** Write code with comment tags → Argcfile.sh generates schemas → LLM calls your tools

**Essential reading:**
- `rules.md` - Critical requirements (argc validation, defaults, output to `$LLM_OUTPUT`)
- `bash-best-practices.md` - Detailed patterns, examples, and common mistakes
- This guide provides syntax reference and quick examples

## Comment Tag Reference

### @describe

Sets command description.

```sh
# @describe A demo CLI
```

### @cmd

Defines a subcommand. Use in agent tools with multiple functions.

```sh
# @cmd Upload a file
upload() {
  echo Run upload
}
```

**Note:** Standalone tools use `@describe` with single `main` function. Agent tools use `@cmd` with named functions.

### @alias

Sets command aliases.

```sh
# @cmd Run tests
# @alias t,tst
test() {
  echo Run test
}
```

### @arg

Defines positional arguments with modifiers: `!` (required), `*` (multi-value), `+` (required multi-value).

```sh
# @arg name                       optional
# @arg path!                      required
# @arg files*                     multi-value
# @arg items+                     required multi-value
# @arg file <PATH>                with notation
# @arg mode=dev                   with default
# @arg type[dev|prod]             with choices
# @arg dir[`_choice_fn`]          choices from function
# @arg remaining~                 capture all remaining
```

### @option

Defines options with same modifiers as `@arg`.

```sh
# @option --name                  optional
# @option -n --name               with short flag
# @option --path!                 required
# @option --files*                multi-occurs
# @option --items+                required multi-occurs
# @option --file <PATH>           with notation
# @option --mode=dev              with default
# @option --type[dev|prod]        with choices
# @option --dir[`_choice_fn`]     choices from function
```

### @flag

Boolean flags (no value accepted).

```sh
# @flag --verbose                 simple flag
# @flag -v --verbose              with short flag
# @flag --debug*                  multi-occurs
```

### @env

Defines environment variables.

```sh
# @env API_KEY                    optional
# @env API_KEY!                   required
# @env MODE=dev                   with default
# @env ENV[dev|prod]              with choices
# @env LLM_OUTPUT=/dev/stdout     framework variable
```

### @meta

Adds metadata.

```sh
# @meta version 1.0.0
# @meta dotenv .env.local
# @meta require-tools git,yq
```

**Common meta directives:**
- `version <value>` - Set command version
- `dotenv [<path>]` - Load environment file
- `default-subcommand` - Set default subcommand
- `require-tools <tool>,...` - Require system tools

## Language Examples

### Bash

```sh
#!/usr/bin/env bash
set -e

# @describe Demo tool showing all parameter types
# @option --string!                  Required string
# @option --string-enum![foo|bar]    Required enum
# @flag --boolean                    Boolean flag
# @option --integer! <INT>           Required integer
# @option --array+ <VALUE>           Required array

# @env LLM_OUTPUT=/dev/stdout

main() {
    # Access via $argc_<name> (kebab→snake case)
    echo "string: $argc_string" >> "$LLM_OUTPUT"
    echo "array: ${argc_array[@]}" >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
```

**Key points:**
- Use `# @describe` for single-function tools
- Use `# @cmd` for multi-function agent tools
- Parameters: `$argc_<name>` (kebab-case → snake_case)
- Output: Always write to `$LLM_OUTPUT`
- Eval line required at end

### JavaScript

```js
/**
 * Demo tool showing JSDoc parameter definitions
 *
 * @typedef {Object} Args
 * @property {string} string - Required string
 * @property {"foo"|"bar"} string_enum - Required enum
 * @property {boolean} boolean - Required boolean
 * @property {string[]} array - Required array
 * @property {string} [optional] - Optional parameter
 */

/**
 * @param {Args} args
 */
export default function main(args) {
    console.log("string:", args.string);
    console.log("array:", args.array);
}
```

**Key points:**
- `@typedef {Object} Args` defines argument object
- `@property {type} name description` for each parameter
- `[name]` indicates optional
- `{type1|type2}` for enums

### Python

Python uses similar JSDoc-style docstrings (see framework docs for complete examples).

## Agent Tools

Agent tools (`agents/<name>/tools.{sh,js,py}`) contain multiple functions. Each function becomes a separate tool.

```sh
# @cmd Show working tree status
git_status() {
    git status >> "$LLM_OUTPUT"
}

# @cmd Show differences
# @option --target!   Target to compare
git_diff() {
    git diff "$argc_target" >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
```

See `agent.md` for complete agent structure.

## Quick Tool Creation

### Using argc

```sh
argc create@tool my_tool.sh param1 param2! param3* param4+
```

**Suffixes:** `!` (required), `*` (optional array), `+` (required array)

### Using aichat

```sh
# Standalone tool
aichat -f docs/tool-development-guide.md <<-'EOF'
create tools/get_youtube_transcript.py

description: Extract YouTube transcripts
parameters:
   url (required): YouTube URL or video ID
   lang (default: "en"): Language code
EOF

# Agent with tools
aichat -f docs/agent.md -f docs/tool-development-guide.md <<-'EOF'
create a spotify agent

index.yaml:
    name: spotify
    description: Spotify integration agent

tools.py:
  search: Search Spotify
    query (required): Search term
    limit (default: 10): Max results
EOF
```

## Syntax Reference

### Modifiers

- `!` - Required parameter
- `*` - Multi-value/multi-occurs (optional)
- `+` - Required multi-value/multi-occurs

### Value Specifications

- `=value` - Default value
- `=\`fn\`` - Default from function
- `[a|b]` - Choices
- `[=a|b]` - Choices with default
- `[\`fn\`]` - Choices from function
- `[?\`fn\`]` - Choices from function, no validation

### Notations

- `<FILE>`, `<PATH>` - File/path completion
- `<DIR>` - Directory completion
- `<VALUE*>` - Zero or more values
- `<VALUE+>` - One or more values
- `<VALUE?>` - Zero or one value

### Environment Binding

- `$$` - Auto-bind to param name
- `$NAME` - Bind to specific env var

### Valid Characters

**Short flags:** A-Z a-z 0-9 and `! # $ % * + , . / : = ? @ [ ] ^ _ { } ~`

**Separators (multi-value):** `, : @ | /`

## See Also

- **rules.md** - Critical tool development rules
- **bash-best-practices.md** - Bash patterns and common mistakes
- **environment-variables.md** - LLM framework variables
- **agent.md** - Agent structure and configuration
- **variables.md** - Argc variable system
- **argcfile.md** - Build system and MCP
- **command-runner.md** - Using argc as command runner
