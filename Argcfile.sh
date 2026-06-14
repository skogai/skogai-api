#!/usr/bin/env bash

# ============================================================================
# skogai/skogapi-cloudflare: Cloudflare Workers REST API (Hono + Chanfana + D1)
# ============================================================================

# @env SKOGAPI_BASE_URL=http://localhost:8787 Base URL of the API (local dev or deployed worker)
# @meta require-tools pnpm,curl,jq

# @meta default-subcommand
main() {
  argc --help
}

# @cmd Seed the local D1 DB and start the wrangler dev server
dev() {
  pnpm dev
}

# @cmd Dry-run deploy and run the Vitest integration tests
test() {
  pnpm test
}

# @cmd Apply remote D1 migrations and deploy to Cloudflare Workers
deploy() {
  pnpm deploy
}

# @cmd Extract the OpenAPI schema locally via chanfana
schema() {
  pnpm run schema
}

# @cmd Regenerate worker-configuration.d.ts from wrangler.jsonc bindings
cf-typegen() {
  pnpm run cf-typegen
}

# @cmd Apply D1 migrations for the DB binding
# @arg target![local|remote] Migration target
migrate() {
  npx wrangler d1 migrations apply DB "--${argc_target}"
}

# @cmd Task resource operations against $SKOGAPI_BASE_URL
tasks() {
  :
}

# @cmd List tasks
# @option --page <NUM>       Page number
# @option --per-page <NUM>   Results per page
# @option --search <TEXT>    Search name, slug and description
tasks::list() {
  local query=()
  [[ -n "${argc_page:-}" ]] && query+=("page=${argc_page}")
  [[ -n "${argc_per_page:-}" ]] && query+=("per_page=${argc_per_page}")
  [[ -n "${argc_search:-}" ]] && query+=("search=${argc_search}")
  local url="${SKOGAPI_BASE_URL}/tasks"
  if [[ "${#query[@]}" -gt 0 ]]; then
    local IFS='&'
    url+="?${query[*]}"
  fi
  curl -sS "$url" | jq .
}

# @cmd Read a task by id
# @arg id! <ID> Task id
tasks::read() {
  curl -sS "${SKOGAPI_BASE_URL}/tasks/${argc_id}" | jq .
}

# @cmd Create a task
# @option --name! <NAME>         Task name
# @option --slug! <SLUG>         Task slug
# @option --description! <TEXT>  Task description
# @option --due-date! <DATETIME> Due date (ISO 8601)
# @flag --completed               Mark the task as completed
tasks::create() {
  # completed is required by the API; default to false unless a flag was given
  if [[ -z "${argc_completed:-}" && -z "${argc_incomplete:-}" ]]; then
    argc_incomplete=1
  fi
  curl -sS -X POST "${SKOGAPI_BASE_URL}/tasks" \
    -H 'Content-Type: application/json' \
    -d "$(_tasks_body)" | jq .
}

# @cmd Update a task by id
# @arg id! <ID> Task id
# @option --name <NAME>          Task name
# @option --slug <SLUG>          Task slug
# @option --description <TEXT>   Task description
# @option --due-date <DATETIME>  Due date (ISO 8601)
# @flag --completed               Mark the task as completed
# @flag --incomplete              Mark the task as not completed
tasks::update() {
  curl -sS -X PUT "${SKOGAPI_BASE_URL}/tasks/${argc_id}" \
    -H 'Content-Type: application/json' \
    -d "$(_tasks_body)" | jq .
}

# @cmd Delete a task by id
# @arg id! <ID> Task id
tasks::delete() {
  curl -sS -X DELETE "${SKOGAPI_BASE_URL}/tasks/${argc_id}" | jq .
}

# Build a JSON body from whichever tasks:: options/flags were set.
_tasks_body() {
  local pairs=() filter_parts=()
  [[ -n "${argc_name:-}" ]] && { pairs+=(--arg name "$argc_name"); filter_parts+=('name: $name'); }
  [[ -n "${argc_slug:-}" ]] && { pairs+=(--arg slug "$argc_slug"); filter_parts+=('slug: $slug'); }
  [[ -n "${argc_description:-}" ]] && { pairs+=(--arg description "$argc_description"); filter_parts+=('description: $description'); }
  [[ -n "${argc_due_date:-}" ]] && { pairs+=(--arg due_date "$argc_due_date"); filter_parts+=('due_date: $due_date'); }
  if [[ -n "${argc_completed:-}" ]]; then
    pairs+=(--argjson completed true)
    filter_parts+=('completed: $completed')
  elif [[ -n "${argc_incomplete:-}" ]]; then
    pairs+=(--argjson completed false)
    filter_parts+=('completed: $completed')
  fi
  local IFS=,
  jq -n "${pairs[@]}" "{${filter_parts[*]}}"
}

eval "$(argc --argc-eval "$0" "$@")"
