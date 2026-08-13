# Subagent Brief Rules

Paste the relevant block into every subagent brief. Cut what does not apply.

## Version control — jj repos

State the repo fact first — it is the part that changes behaviour. An agent
told the repo is jj reaches for `jj` unprompted; an agent not told reaches for
`git rebase` and `git push --force-with-lease` every time.

```
- This is a colocated jj repo. Use `jj` for all version control; `gh` only for
  GitHub operations. Never `git` — it corrupts the colocated state.
- Work in a NEW isolated workspace:
    jj workspace add --name <name> <path> -r main
  Do NOT touch other agents' workspaces.
- Push to `origin`, never a fork:
    jj git push --remote origin --bookmark <branch> --allow-new
  If a push is denied by the permission classifier, STOP and report it.
- Rebase in jj only:
    jj git fetch --remote origin
    jj rebase -b <bookmark> -d main
  jj materialises conflicts in the files. Resolve, then check `jj status`.
  Never `git rebase`, never `git merge`.
```

## Stacked PRs in a jj repo

```
- Use `gh stack link` ONLY. `init`/`add`/`push`/`submit`/`sync`/`rebase` all
  drive git underneath. `link` is the documented external-tool path.
- From a secondary jj workspace, `gh stack link` exits 4 (`not a git
  repository`). Set the repo and pass PR URLs:
    GH_REPO=<owner>/<repo> gh stack link <pr1-url> <pr2-url>
- `gh stack view` cannot run from a secondary jj workspace at all. It needs a
  real `.git`, and `GH_REPO` does not help it the way it helps `link`. Verify
  the stack with the idempotent `gh stack link` instead.
- Once the bottom PR merges, do NOT re-run `gh stack link` with both URLs. It
  tries to retarget the upper PR's base to the deleted branch. GitHub rejects
  that with HTTP 422 — but `link` still exits 0, so the exit code hides the
  failed mutation. Check the base independently after any `link` call.
- Review bots cache analysis by code content, not commit id. A no-op push
  skips re-analysis and carries the old verdict forward. A dismissed approval
  only returns if the code actually changed.
- Any change to the lower PR requires rebasing the upper one onto the new tip,
  or the upper PR's diff shows the lower PR's changes as its own.
- When the lower PR merges, GitHub retargets the upper PR but does NOT rebase
  the branch. Rebase it, then confirm the diff shows only its own changes.
- Merging stacked PRs from the CLI is not supported. A human merges in the
  browser, bottom first.
```

## Code style

```
- Code comments: 3 lines maximum in general, 6 maximum for genuinely subtle
  points. Keep only the non-obvious *why*; delete anything the code states.
- Spend the 6-line budget only where a future reader would otherwise
  "simplify" the code and reintroduce the bug. A guard that looks redundant
  but closes a hole earns it; a restatement of the symptom does not.
- In a 6-line comment, write short active sentences — one fact each, under 25
  words. Six lines is enough rope for a single 55-word sentence, and that is
  the shape to avoid. Keep every consequence; drop the metaphors.
    before: one sentence — "the guard is load-bearing, do not simplify to a
            bare match, that would let a commit choose the 0, and each
            receiver would resolve it against its own tip, so two receivers
            straddling a revocation fork the group"
    after:  four — "Keep the guard. Without it a commit can choose the 0.
            Each receiver then resolves at its own tip. Two receivers can
            disagree and fork the group."
- Narrative belongs in the PR body and the issue, not in the code.
```

## Tests

```
- Follow the repo's test skill if one exists.
- Run every profile CI runs, not just the default one. Verifying one profile
  locally when CI runs two is how a green local run still breaks the build.
- Never shorten a production constant for test convenience. Have the test
  write the state it needs instead. A short interval leaks into every code
  path that reads it.
- Every new test must be verified to FAIL without its fix. State that
  verification in your report.
- Expect flaky tests when several agents share one test backend. Retry rather
  than chase. Verify a suspected flake passes in isolation before dismissing it.
- Do NOT restart shared test infrastructure. Other agents depend on it.
```

## Review

```
- Follow `superpowers:receiving-code-review`. Reply on the thread either way,
  saying what you did or why you disagree.
- Review bots re-run on every push. Batch changes so one CI cycle covers them.
```

## Merging

Do not soften "needs a human approving review" — agents read that as a
precondition they can check off, then merge once the approval exists.

```
- Do NOT merge, ever. A human runs the merge. An approval on the PR is not
  that human doing it, and neither is an approver saying "ship it, don't wait
  on me" — approving the code and performing the merge are separate acts, and
  only the second one is reserved. `gh pr merge` being available is capability,
  not authorisation.
- Do not rebase without cause. If the ruleset has
  `strict_required_status_checks_policy: false`, being behind the base does NOT
  block a merge. Rebase for a real conflict, a reviewer request, or an actual
  staleness block.
- Watch `mergeStateStatus`: `DIRTY` is a real conflict; `BEHIND` alone is fine.
```

## Shipping

```
- Commit message ends with the repo's mandated co-author trailer.
- PR body ends with the repo's mandated generation trailer.
- Never put real user identifiers — inbox ids, installation ids, account
  addresses — or raw log excerpts containing them into a public PR or issue.
  Describe the shape of the problem and use placeholders.
```

## Stopping

```
- If you need a human decision, an approving review, or you disagree with a
  reviewer, PAUSE. Say plainly that you are pausing and exactly what you need.
  You will be resumed, so you keep your context.
- If the same failure survives two fix attempts, stop and report rather than
  thrashing.
- Never improvise around a blocked permission. Report which command was denied.
```

## Report contract

```
Your final message must contain:
- what you changed and why, including design decisions and rejected options
- your technical assessment of any review finding: agree or disagree, with
  reasoning
- test and lint results, with actual numbers
- the PR URL and current CI status
- anything still blocking, and who can unblock it
```

## Project-specific facts worth stating

These change per repo. Verify before pasting.

```
- Which CI jobs are excluded from the required gate (check the aggregate job's
  `needs:` list — commented-out entries do not block).
- Which lint recipes are already red on the base branch.
- Which tests are known-flaky by name.
- Whether bot approvals satisfy the review gate.
- Any AI-generated-contributions policy in CONTRIBUTING.
```
