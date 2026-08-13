#!/usr/bin/env bash
# Standing reminder, injected at the start of every session: semble is the
# default for code search/exploration; code-review-graph is secondary and
# only for graph-structural analysis (and needs its graph built first).
jq -n '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: "Reminder: default to semble for code search and exploration whenever possible — mcp__plugin_claude-code-home-manager_semble__search / ..._find_related MCP tools, or the `semble search` / `semble find-related` CLI (works in subagents without MCP). Use it before Grep/Glob/cold file reading when locating implementations or exploring unfamiliar code. The code-review-graph MCP tools (mcp__plugin_claude-code-home-manager_code-review-graph__*) are secondary: only for graph-structural analysis (impact radius, call graphs, affected flows). A SessionStart hook auto-builds the graph in the background; if the tools report an empty or stale graph, run build_or_update_graph_tool and retry."
  }
}'
