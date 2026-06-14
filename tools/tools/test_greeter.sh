#!/usr/bin/env bash
set -e

# @describe A comprehensive greeting tool demonstrating argc capabilities
#
# This tool showcases best practices for argc-based bash tools including:
# - Required and optional parameters
# - Default values and enums
# - Multi-value arrays
# - Flags (boolean)
# - Dynamic choice functions
# - Environment variable binding
# - Proper output handling
# - Input validation

# @option --name!                            The person's name to greet (required)
# @option --title[Mr|Mrs|Ms|Dr|Prof]         Formal title to use (optional)
# @option --language[=en|es|fr|de|sv]      Language for greeting
# @option --times=1 <INT>                    How many times to repeat the greeting
# @option --style[=casual|formal|friendly]  Greeting style
# @option --topics* <TOPIC>                  Topics to mention (optional array)
# @option --colors+[`_choice_colors`] <COLOR>  Favorite colors (required array with dynamic choices)
# @option --mood[`_choice_moods`]            Current mood (dynamic choices)
# @flag --enthusiastic                       Add extra enthusiasm
# @flag --verbose                            Enable verbose output
# @option --output-format[=text|json|yaml]  Output format
# @option --time-of-day[morning|afternoon|evening|night]  Time-specific greeting
# @option --signature                        Add custom signature at the end
# @option --max-length <INT>                 Maximum length of greeting message

# @env LLM_OUTPUT=/dev/stdout The output path
# @env LLM_TOOL_NAME=test_greeter Tool name
# @env LLM_TOOL_CACHE_DIR Cache directory for tool

main() {
    # Initialize variables with defaults
    local name="${argc_name}"
    local title="${argc_title}"
    local language="${argc_language}"
    local times="${argc_times}"
    local style="${argc_style}"
    local enthusiastic="${argc_enthusiastic}"
    local verbose="${argc_verbose}"
    local output_format="${argc_output_format}"
    local time_of_day="${argc_time_of_day}"
    local signature="${argc_signature}"
    local max_length="${argc_max_length}"
    local mood="${argc_mood}"

    # Verbose logging
    if [[ "$verbose" == "1" ]]; then
        echo "=== Verbose Mode Enabled ===" >> "$LLM_OUTPUT"
        echo "Tool: $LLM_TOOL_NAME" >> "$LLM_OUTPUT"
        echo "Cache Dir: $LLM_TOOL_CACHE_DIR" >> "$LLM_OUTPUT"
        echo "Parameters received:" >> "$LLM_OUTPUT"
        echo "  Name: $name" >> "$LLM_OUTPUT"
        echo "  Language: $language" >> "$LLM_OUTPUT"
        echo "  Style: $style" >> "$LLM_OUTPUT"
        echo "  Times: $times" >> "$LLM_OUTPUT"
        echo "  Enthusiastic: $enthusiastic" >> "$LLM_OUTPUT"
        echo "  Output Format: $output_format" >> "$LLM_OUTPUT"
        echo "" >> "$LLM_OUTPUT"
    fi

    # Build the greeting based on parameters
    local greeting=""

    # Time-specific greeting
    if [[ -n "$time_of_day" ]]; then
        case "$time_of_day" in
            morning) greeting="Good morning" ;;
            afternoon) greeting="Good afternoon" ;;
            evening) greeting="Good evening" ;;
            night) greeting="Good night" ;;
        esac
    else
        # Language-specific greeting
        case "$language" in
            en) greeting="Hello" ;;
            es) greeting="Hola" ;;
            fr) greeting="Bonjour" ;;
            de) greeting="Guten Tag" ;;
            sv) greeting="Hej" ;;
        esac
    fi

    # Style modification
    case "$style" in
        formal)
            greeting="$greeting"
            ;;
        casual)
            greeting="Hey there"
            ;;
        friendly)
            greeting="Hi friend"
            ;;
    esac

    # Add title if provided
    if [[ -n "$title" ]]; then
        greeting="$greeting, $title $name"
    else
        greeting="$greeting, $name"
    fi

    # Add enthusiasm
    if [[ "$enthusiastic" == "1" ]]; then
        greeting="$greeting!!"
    else
        greeting="$greeting!"
    fi

    # Add mood if provided
    if [[ -n "$mood" ]]; then
        greeting="$greeting I hope you're feeling $mood today."
    fi

    # Build additional context
    local context=""

    # Add colors if provided
    if [[ ${#argc_colors[@]} -gt 0 ]]; then
        context+="Your favorite colors are: ${argc_colors[*]}. "
    fi

    # Add topics if provided
    if [[ ${#argc_topics[@]} -gt 0 ]]; then
        context+="Let's talk about: ${argc_topics[*]}. "
    fi

    # Apply max length if specified
    if [[ -n "$max_length" ]]; then
        greeting="${greeting:0:$max_length}"
        context="${context:0:$max_length}"
    fi

    # Output based on format
    case "$output_format" in
        json)
            _output_json "$greeting" "$context" "$signature"
            ;;
        yaml)
            _output_yaml "$greeting" "$context" "$signature"
            ;;
        text|*)
            _output_text "$greeting" "$context" "$signature" "$times"
            ;;
    esac
}

# Helper function: Output as text
_output_text() {
    local greeting="$1"
    local context="$2"
    local signature="$3"
    local times="$4"

    for ((i = 1; i <= times; i++)); do
        if [[ $times -gt 1 ]]; then
            echo "=== Greeting #$i ===" >> "$LLM_OUTPUT"
        fi

        echo "$greeting" >> "$LLM_OUTPUT"

        if [[ -n "$context" ]]; then
            echo "" >> "$LLM_OUTPUT"
            echo "$context" >> "$LLM_OUTPUT"
        fi

        if [[ -n "$signature" ]]; then
            echo "" >> "$LLM_OUTPUT"
            echo "-- $signature" >> "$LLM_OUTPUT"
        fi

        if [[ $i -lt $times ]]; then
            echo "" >> "$LLM_OUTPUT"
        fi
    done
}

# Helper function: Output as JSON
_output_json() {
    local greeting="$1"
    local context="$2"
    local signature="$3"
    local enthusiastic_val="${argc_enthusiastic:-0}"

    # Build colors array
    local colors_json=""
    if [[ ${#argc_colors[@]} -gt 0 ]]; then
        colors_json=$(printf '"%s",' "${argc_colors[@]}" | sed 's/,$//')
    fi

    # Build topics array
    local topics_json=""
    if [[ ${#argc_topics[@]} -gt 0 ]]; then
        topics_json=$(printf '"%s",' "${argc_topics[@]}" | sed 's/,$//')
    fi

    cat <<EOF >> "$LLM_OUTPUT"
{
  "greeting": "$greeting",
  "context": "$context",
  "signature": "$signature",
  "metadata": {
    "language": "$argc_language",
    "style": "$argc_style",
    "enthusiastic": $enthusiastic_val,
    "colors": [$colors_json],
    "topics": [$topics_json]
  }
}
EOF
}

# Helper function: Output as YAML
_output_yaml() {
    local greeting="$1"
    local context="$2"
    local signature="$3"
    local enthusiastic_val="${argc_enthusiastic:-0}"

    cat <<EOF >> "$LLM_OUTPUT"
greeting: "$greeting"
context: "$context"
signature: "$signature"
metadata:
  language: $argc_language
  style: $argc_style
  enthusiastic: $enthusiastic_val
  colors:
EOF
    if [[ ${#argc_colors[@]} -gt 0 ]]; then
        for color in "${argc_colors[@]}"; do
            echo "    - $color" >> "$LLM_OUTPUT"
        done
    else
        echo "    []" >> "$LLM_OUTPUT"
    fi

    if [[ ${#argc_topics[@]} -gt 0 ]]; then
        echo "  topics:" >> "$LLM_OUTPUT"
        for topic in "${argc_topics[@]}"; do
            echo "    - $topic" >> "$LLM_OUTPUT"
        done
    fi
}

# Choice function: Provide color options
_choice_colors() {
    cat <<EOF
red
blue
green
yellow
purple
orange
pink
black
white
cyan
magenta
EOF
}

# Choice function: Provide mood options
_choice_moods() {
    cat <<EOF
happy
excited
calm
energetic
peaceful
cheerful
content
motivated
inspired
EOF
}

eval "$(argc --argc-eval "$0" "$@")"
