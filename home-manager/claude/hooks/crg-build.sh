#!/usr/bin/env bash
# SessionStart (async): make the code-review-graph exist and stay fresh for
# the repo this session starts in. The one-time initial `build` nobody
# remembered to run is the whole reason the graph tools sat unused.
#
# `git rev-parse` is repo detection, not agent VCS usage - it succeeds in
# colocated jj repos, which all of these are. flock serializes against the
# PostToolUse update hook; -n skips if another build/update holds the lock.
cat >/dev/null 2>&1 || true
command -v code-review-graph >/dev/null 2>&1 || exit 0
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$ROOT" || exit 0
mkdir -p .code-review-graph
if code-review-graph status 2>/dev/null | grep -q 'Last updated: never'; then
  exec flock -n .code-review-graph/.hook.lock code-review-graph build -q
else
  exec flock -n .code-review-graph/.hook.lock code-review-graph update -q --skip-flows
fi
