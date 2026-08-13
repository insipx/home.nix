#!/usr/bin/env bash
# PostToolUse Write|Edit|Bash (async): incremental graph refresh so the
# review tools see current code. Skips repos whose graph was never built -
# the SessionStart hook (crg-build.sh) owns the initial build.
cat >/dev/null 2>&1 || true
command -v code-review-graph >/dev/null 2>&1 || exit 0
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$ROOT/.code-review-graph/graph.db" ] || exit 0
cd "$ROOT" || exit 0
exec flock -n .code-review-graph/.hook.lock code-review-graph update -q --skip-flows
