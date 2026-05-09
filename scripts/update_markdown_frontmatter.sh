#!/usr/bin/env bash
set -euo pipefail

ROOT_DIRECTORY="${1:-$HOME/workspace/garden/content}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
FRONTMATTER_LUA="$SCRIPT_DIR/markdown_frontmatter.lua"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'error: %s is required but not found in PATH\n' "$1" >&2
    exit 1
  fi
}

require_command fd
require_command nvim
require_command yq

if [ ! -f "$FRONTMATTER_LUA" ]; then
  printf 'error: helper not found: %s\n' "$FRONTMATTER_LUA" >&2
  exit 1
fi

if [ ! -d "$ROOT_DIRECTORY" ]; then
  printf 'error: directory not found: %s\n' "$ROOT_DIRECTORY" >&2
  exit 1
fi

ROOT_DIRECTORY="$(cd -- "$ROOT_DIRECTORY" && pwd -P)"

detect_cpus() {
  if command -v nproc >/dev/null 2>&1; then
    nproc
  elif command -v getconf >/dev/null 2>&1; then
    getconf _NPROCESSORS_ONLN
  elif command -v sysctl >/dev/null 2>&1; then
    sysctl -n hw.ncpu
  else
    printf '1\n'
  fi
}

JOBS_COUNT="${JOBS:-$(detect_cpus)}"

if ! printf '%s' "$JOBS_COUNT" | grep -Eq '^[0-9]+$'; then
  printf 'error: JOBS must be a positive integer (got %s)\n' "$JOBS_COUNT" >&2
  exit 1
fi

if [ "$JOBS_COUNT" -lt 1 ]; then JOBS_COUNT=1; fi

export MARKDOWN_FRONTMATTER_ROOT="$ROOT_DIRECTORY"
export MARKDOWN_FRONTMATTER_LUA="$FRONTMATTER_LUA"

fd --extension md --type f . "$ROOT_DIRECTORY" --print0 \
  | xargs -0 -n1 -P "$JOBS_COUNT" bash -c '
    file="$1"
    printf "Updating frontmatter: %s\n" "$file"
    nvim --clean --headless "$file" \
      +"lua dofile(vim.env.MARKDOWN_FRONTMATTER_LUA)" \
      +"silent keepalt write!" \
      +qa >/dev/null
  ' _
