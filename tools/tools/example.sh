#!/usr/bin/env bash
set -e

# @describe Generate argc-annotated bash tool from description
# @option --name!        Tool filename (e.g., my_tool.sh)
# @option --desc!        What the tool does
# @option --params       Params in format: "name! type[choices] name2*"
# @describe Generate argc tool skeleton
# @option --type[sh|py|js]       Language type
# @flag --required               Has required params
# @flag --multi                  Has multi-value params
# @flag --choices                Has choice params

main() {
  (
    set -o posix
    set
  ) | grep ^argc_
}

eval "$(argc --argc-eval "$0" "$@")"
