#!/usr/bin/env bash
set -euo pipefail

# update frontmatter across all markdown files under the provided root by
# opening each file in Neovim headlessly and writing it back out so the
# BufWritePre automation runs. uses fd + xargs to parallelise the work.

ROOT_DIRECTORY="${1:-$HOME/workspace/garden/content}"
APPNAME="${NVIM_APPNAME:-nvim}"

if ! command -v fd >/dev/null 2>&1; then
  printf 'error: fd is required but not found in PATH\n' >&2
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
  printf 'error: nvim is required but not found in PATH\n' >&2
  exit 1
fi

if [ ! -d "$ROOT_DIRECTORY" ]; then
  printf 'error: directory not found: %s\n' "$ROOT_DIRECTORY" >&2
  exit 1
fi

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

JOBS_RAW="${JOBS:-}"
if [ -n "$JOBS_RAW" ]; then
  JOBS_COUNT="$JOBS_RAW"
else
  JOBS_COUNT="$(detect_cpus)"
fi

if ! printf '%s' "$JOBS_COUNT" | grep -Eq '^[0-9]+$'; then
  printf 'error: JOBS must be a positive integer (got %s)\n' "$JOBS_COUNT" >&2
  exit 1
fi

if [ "$JOBS_COUNT" -lt 1 ]; then JOBS_COUNT=1; fi

export NVIM_APPNAME="$APPNAME"

if ! fd --extension md --type f . "$ROOT_DIRECTORY" --print0 \
  | xargs -0 -n1 -P "$JOBS_COUNT" bash -c '
    file="$1"
    printf "Updating frontmatter: %s\n" "$file"
    if ! nvim --headless "$file" \
      +"setlocal modifiable" \
      +"setlocal noreadonly" \
      +"silent keepalt write!" \
      +qa >/dev/null; then
      printf "warning: failed to update frontmatter for %s\n" "$file" >&2
      exit 1
    fi
  ' _; then
  exit 1
fi
