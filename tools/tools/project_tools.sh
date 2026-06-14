#!/usr/bin/env bash
set -e

# @describe Show available tools based on project files in current directory
# @option --tool[`_choice_tool`] Run a specific detected tool
# @option --dir=. <DIR> Directory to scan for project files
# @flag --list Only list available tools without details

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local scan_dir="${argc_dir:-.}"

    if [[ -n "$argc_tool" ]]; then
        # Run the selected tool's help
        case "$argc_tool" in
            poetry) cd "$scan_dir" && poetry --help >> "$LLM_OUTPUT" ;;
            npm) cd "$scan_dir" && npm --help >> "$LLM_OUTPUT" ;;
            cargo) cd "$scan_dir" && cargo --help >> "$LLM_OUTPUT" ;;
            make) cd "$scan_dir" && make --help >> "$LLM_OUTPUT" ;;
            docker) cd "$scan_dir" && docker --help >> "$LLM_OUTPUT" ;;
            docker-compose) cd "$scan_dir" && docker-compose --help >> "$LLM_OUTPUT" ;;
            go) cd "$scan_dir" && go help >> "$LLM_OUTPUT" ;;
            gradle) cd "$scan_dir" && gradle --help >> "$LLM_OUTPUT" ;;
            maven) cd "$scan_dir" && mvn --help >> "$LLM_OUTPUT" ;;
            argc) cd "$scan_dir" && argc --help >> "$LLM_OUTPUT" ;;
            *) echo "Unknown tool: $argc_tool" >> "$LLM_OUTPUT" ;;
        esac
        return
    fi

    # List detected tools
    if [[ "$argc_list" == "1" ]]; then
        _detect_tools "$scan_dir"
    else
        _detect_tools_verbose "$scan_dir"
    fi
}

_detect_tools() {
    local dir="$1"

    [[ -f "$dir/pyproject.toml" ]] && grep -q "poetry" "$dir/pyproject.toml" 2>/dev/null && echo "poetry"
    [[ -f "$dir/pyproject.toml" ]] && grep -q "hatch" "$dir/pyproject.toml" 2>/dev/null && echo "hatch"
    [[ -f "$dir/requirements.txt" ]] && echo "pip"
    [[ -f "$dir/setup.py" ]] && echo "pip"
    [[ -f "$dir/package.json" ]] && echo "npm"
    [[ -f "$dir/yarn.lock" ]] && echo "yarn"
    [[ -f "$dir/pnpm-lock.yaml" ]] && echo "pnpm"
    [[ -f "$dir/Cargo.toml" ]] && echo "cargo"
    [[ -f "$dir/go.mod" ]] && echo "go"
    [[ -f "$dir/Makefile" ]] && echo "make"
    [[ -f "$dir/Dockerfile" ]] && echo "docker"
    [[ -f "$dir/docker-compose.yml" ]] || [[ -f "$dir/docker-compose.yaml" ]] && echo "docker-compose"
    [[ -f "$dir/build.gradle" ]] || [[ -f "$dir/build.gradle.kts" ]] && echo "gradle"
    [[ -f "$dir/pom.xml" ]] && echo "maven"
    [[ -f "$dir/Argcfile.sh" ]] && echo "argc"
    [[ -f "$dir/Gemfile" ]] && echo "bundler"
    [[ -f "$dir/mix.exs" ]] && echo "mix"
    [[ -f "$dir/deno.json" ]] || [[ -f "$dir/deno.jsonc" ]] && echo "deno"
    [[ -f "$dir/bun.lockb" ]] && echo "bun"
}

_detect_tools_verbose() {
    local dir="$1"

    echo "Project tools detected in: $dir" >> "$LLM_OUTPUT"
    echo "---" >> "$LLM_OUTPUT"

    [[ -f "$dir/pyproject.toml" ]] && grep -q "poetry" "$dir/pyproject.toml" 2>/dev/null && echo "poetry      → pyproject.toml (Poetry)" >> "$LLM_OUTPUT"
    [[ -f "$dir/pyproject.toml" ]] && grep -q "hatch" "$dir/pyproject.toml" 2>/dev/null && echo "hatch       → pyproject.toml (Hatch)" >> "$LLM_OUTPUT"
    [[ -f "$dir/requirements.txt" ]] && echo "pip         → requirements.txt" >> "$LLM_OUTPUT"
    [[ -f "$dir/setup.py" ]] && echo "pip         → setup.py" >> "$LLM_OUTPUT"
    [[ -f "$dir/package.json" ]] && echo "npm         → package.json" >> "$LLM_OUTPUT"
    [[ -f "$dir/yarn.lock" ]] && echo "yarn        → yarn.lock" >> "$LLM_OUTPUT"
    [[ -f "$dir/pnpm-lock.yaml" ]] && echo "pnpm        → pnpm-lock.yaml" >> "$LLM_OUTPUT"
    [[ -f "$dir/Cargo.toml" ]] && echo "cargo       → Cargo.toml" >> "$LLM_OUTPUT"
    [[ -f "$dir/go.mod" ]] && echo "go          → go.mod" >> "$LLM_OUTPUT"
    [[ -f "$dir/Makefile" ]] && echo "make        → Makefile" >> "$LLM_OUTPUT"
    [[ -f "$dir/Dockerfile" ]] && echo "docker      → Dockerfile" >> "$LLM_OUTPUT"
    ([[ -f "$dir/docker-compose.yml" ]] || [[ -f "$dir/docker-compose.yaml" ]]) && echo "docker-compose → docker-compose.y(a)ml" >> "$LLM_OUTPUT"
    ([[ -f "$dir/build.gradle" ]] || [[ -f "$dir/build.gradle.kts" ]]) && echo "gradle      → build.gradle(.kts)" >> "$LLM_OUTPUT"
    [[ -f "$dir/pom.xml" ]] && echo "maven       → pom.xml" >> "$LLM_OUTPUT"
    [[ -f "$dir/Argcfile.sh" ]] && echo "argc        → Argcfile.sh" >> "$LLM_OUTPUT"
    [[ -f "$dir/Gemfile" ]] && echo "bundler     → Gemfile" >> "$LLM_OUTPUT"
    [[ -f "$dir/mix.exs" ]] && echo "mix         → mix.exs" >> "$LLM_OUTPUT"
    ([[ -f "$dir/deno.json" ]] || [[ -f "$dir/deno.jsonc" ]]) && echo "deno        → deno.json(c)" >> "$LLM_OUTPUT"
    [[ -f "$dir/bun.lockb" ]] && echo "bun         → bun.lockb" >> "$LLM_OUTPUT"
}

_choice_tool() {
    local dir="${argc_dir:-.}"
    _detect_tools "$dir"
}

eval "$(argc --argc-eval "$0" "$@")"
