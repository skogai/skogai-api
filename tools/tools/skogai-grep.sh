#!/usr/bin/env bash

# @describe SkogAI Grep
# @meta version 1.0.0
# @meta dotenv
# @env LLM_OUTPUT=/dev/stdout The output path

# @option -e --* <string>                        match pattern
# @option --branch[`_choice_branch`] <string>    branch name
# @flag -c --count                               show the number of matches instead of matching lines
# @option --exclude <dir>                        skip files and directories matching pattern
# @flag -h --help                                help for skogai-grep
# @flag -i --ignore-case                         case insensitive matching
# @option --include <file>                       search only files that match pattern (default "**/*")
# @flag -n --line-number                         show line numbers
# @flag --name-only                              show only repository:filenames
# @flag -o --only-matching                       show only matching parts of a line
# @option --owner=skogai <string>                       repository owner or org
# @option --repo*[`_choice_search_repo`] <string>  repository name
# @flag --repo-only                              show only repositories
# @option --tag <string>                         tag name
# @flag --url                                    show URL
# @flag -v --version                             version for skogai-grep
# @arg pattern!
main() {
  gh grep "${argc_pattern}" --owner="${argc_owner}" --repo="${argc_repo}" --branch="${argc_branch}"
  #--tag="${argc_tag}" --include="${argc_include}" --exclude="${argc_exclude}" "${argc_count}" "${argc_name_only}" "${argc_repo_only}" "${argc_line_number}" "${argc_only_matching}" "${argc_ignore_case}" "${argc_url}" "${argc_e[@]}"
}

source "$ARGC_COMPLETIONS_ROOT/utils/_argc_utils.sh"

_choice_branch() {
  _helper_repo_query 'refs(first: 100, refPrefix: "refs/heads/") { nodes { name, target { abbreviatedOid } } }' |
    yq '.data.repository.refs.nodes[] | .name + "	" + .target.abbreviatedOid'
}

_choice_search_repo() {
  _argc_util_mode_kv /
  if [[ -z "$argc__kv_prefix" ]]; then
    _choice_owner | _argc_util_transform suffix=/ nospace
  else
    _helper_search_repo "$argc__kv_key" "$argc__kv_filter"
  fi
}

_choice_owner() {
  _argc_util_parallel _choice_search_user ::: _choice_search_org
}

_choice_search_user() {
  val=${1:-$ARGC_CWORD}
  if [[ "${#val}" -lt 2 ]]; then
    return
  fi
  gh api graphql -f query='
        query {
            search( type:USER, query: "'$val' in:login", first: 100) {
                edges { node { ... on User { login name } } } 
            }
        }' |
    yq '.data.search.edges[].node | .login + "	" + (.name // "")'
}

_choice_search_org() {
  val=${1:-$ARGC_CWORD}
  if [[ "${#val}" -lt 2 ]]; then
    return
  fi
  gh api graphql -f query='
        query {
            search( type:USER, query: "'$val' in:login", first: 100) {
                edges { node { ... on Organization  { login name } } } 
            }
        }' |
    yq '.data.search.edges[].node | .login + "	" + (.name // "")'
}

_helper_repo_query() {
  _helper_retrieve_owner_repo_vals
  if [[ -z "$owner_val" ]] || [[ -z "$repo_val" ]]; then
    return
  fi
  gh api graphql -f query='query { repository(owner: "'$owner_val'", name: "'$repo_val'") { '"$1"' } }'
}

_helper_retrieve_owner_repo_vals() {
  if [[ "$argc_repo" == *'/'* ]]; then
    owner_val="${argc_repo%/*}"
    repo_val="${argc_repo##*/}"
  else
    local raw_values="$(
      git remote -v |
        gawk '{
                if (match($0, /^origin\thttps:\/\/[^\/]+\/([^\/]+)\/([^\/]+) \(fetch\)/, arr)) {
                    gsub(".git", "", arr[2])
                    print arr[1] " " arr[2]
                } else if (match($0, /^origin\t[^:]+:([^\/]+)\/([^\/]+) \(fetch\)/, arr)) {
                    gsub(".git", "", arr[2])
                    print arr[1] " " arr[2]
                }
            }'
    )"
    local values=($raw_values)
    if [[ "${#values[@]}" -eq 2 ]]; then
      owner_val=${values[0]}
      repo_val=${values[1]}
    fi
  fi
}

_helper_search_repo() {
  gh api graphql -f query='
        query {
            search( type:REPOSITORY, query: """user:'$1' "'$2'" in:name fork:true""", first: 100) {
                edges { node { ... on Repository { name description } } } 
            }
        }' |
    yq '.data.search.edges[].node | .name + "	" + (.description // "")'
}

command eval "$(argc --argc-eval "$0" "$@")"
