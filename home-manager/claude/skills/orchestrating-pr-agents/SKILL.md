---
name: orchestrating-pr-agents
description: Use when running several subagents in parallel on separate PRs, when handing a PR to an agent to own through review and merge, or when the same setup rules keep getting repeated in every subagent brief.
---

# Orchestrating PR Agents

## Overview

One orchestrator holds the context and makes no code changes. Each subagent owns
one unit of work end to end, in its own workspace, until its PR merges.

**Core principle:** the orchestrator's product is decisions and briefs, not diffs.

## When to Use

- Two or more independent pieces of work can run at once
- A PR needs someone to sit on it through CI, review rounds, and rebases
- You are about to paste the same rules into a third subagent brief

**Do not use** for a single small change you can finish in one pass. The overhead
is real: each agent costs a full context, and parallel agents contend for shared
test infrastructure.

## The Orchestrator's Role

Do:

- write briefs, dispatch agents, relay the user's decisions
- resume paused agents instead of starting new ones
- verify a claim yourself before passing it to the user as fact
- surface only what needs a human decision

Never:

- write the code an agent was dispatched to write
- merge a PR, or let an agent merge one
- report an agent's result before its notification arrives

## Dispatch Brief Contract

Every brief contains these parts, in this order:

1. **Goal** — one sentence on what ships.
2. **Critical rules** — see `subagent-brief-rules.md`. Paste the block.
3. **Setup** — the exact isolated-workspace command.
4. **Background** — the evidence and `file:line` references you already hold.
   The agent must not re-derive what you know.
5. **What to decide, not just do** — name the design forks and tell the agent to
   report its reasoning. A brief that only lists steps gets steps back.
6. **Verification bar** — the exact commands, and which failures are pre-existing.
7. **Shipping** — branch, base, trailers, and what must not appear in public text.
8. **Report contract** — what the final message must contain.

State your own assumptions as assumptions. Agents that verify a brief and find it
wrong are working correctly; say so explicitly, and they will.

## Babysit to Merge

Green CI is not the finish line. An agent that owns a PR stays open until
`state` is `MERGED`, and each round it:

- reads every new comment and review thread, because review bots re-run per push
- verifies feedback technically before acting, and replies either way
- keeps the branch mergeable, rebasing only when there is real cause
- checks `gh pr view <n> --json state,mergeStateStatus,reviewDecision,mergedAt`

## Resume, Do Not Restart

A paused or failed agent still holds its transcript. Send it a message to resume.
Restarting throws away everything it learned.

When an agent dies on an API error, restate the brief in the resume message. It
costs little and removes any doubt about what it was doing.

## Quick Reference

| Situation | Action |
|---|---|
| Agent pauses needing a human decision | Relay to the user, then resume with the answer |
| Agent dies mid-response | Resume with the brief restated |
| Agent's PR needs approval | Only a human can give it — say so plainly |
| Two agents touch the same files | Warn both; whichever merges second rebases |
| A shared test backend is loaded | Expect flakes; tell agents to retry, not chase |

## Common Mistakes

**Briefing steps instead of decisions.** An agent given a checklist returns a
checklist. Name the forks and it returns reasoning.

**Letting agents rebase on every push.** Being behind the base usually does not
block a merge. Each rebase costs a full CI matrix.

**Accepting an agent's finding without checking.** Verify anything you are about
to state to the user as fact, especially claims about which checks block a merge.
"Job X is failing" is not "the PR is blocked" — those are the same claim only if
X is in the required gate. Check the aggregate job's `needs:` list before you
repeat an agent's "blocked" to anyone. Without that check an orchestrator will
pass the claim straight through, caveated but uncorrected.

**Letting an approval read as merge authority.** The failure is not an agent
deciding to defy the rule; it is an agent concluding the rule is satisfied.
Given an approved, green, `CLEAN` PR and a deadline, agents merge and explain
that the approver "already made the decision" and that waiting "isn't caution,
it's just risking the miss." Brief the merge rule as a reserved act, not as a
precondition — see `subagent-brief-rules.md`.

**Stripping attribution quietly.** If a repo policy touches AI-authored work,
surface it. That is the user's call, not an agent's.
