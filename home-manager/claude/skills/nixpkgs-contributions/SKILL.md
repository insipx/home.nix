---
name: nixpkgs-contributions
description: Use when modifying nixpkgs derivations, writing patches for upstream Nix or non-Nix projects, debugging cross-compile failures (especially Darwin/iOS), or preparing PRs to nixpkgs. Covers commit-message style, minimal-diff philosophy, overlay-based downstream fixes, sed portability, jj+colocated git pitfalls, screen-detached builds, and the upstream contribution dossier pattern.
---

# Nixpkgs Contributions & Working With Nix

This skill captures the working style for landing changes in nixpkgs (and
upstream projects via nixpkgs) discovered while building libxmtp's iOS
cross-compile stack. It is **opinionated** — the rules below are derived
from real reviewer feedback and real failure modes, not theoretical
best-practice.

## Core Principle: Minimum Viable Diff

**Less lines changed = less lines reviewed = better merge odds.**

Before adding code, exhaust the cheaper options:

| Tempting | Better |
|----------|--------|
| Add new function argument | Reuse a sibling already in scope (`stdenvNoCC.hostPlatform.isiOS` instead of pulling in `stdenv`) |
| Write a custom patch file | Use an upstream configure/cmake flag (`--with-ospeed=int` instead of `substituteInPlace` on a `defined(__APPLE__)` guard) |
| Create a new `++ lib.optionals` list | Extend the existing one |
| Two-file fix | One-file fix |
| Three hunks | One hunk |
| Multi-paragraph comment | 1-2 lines unless genuinely non-obvious |

Before sending: count the lines and ask *"is any of this rearrangement, not load-bearing?"* If rearrangement, drop it.

This matters extra for upstream contributions (gnulib, libsigsegv, autoconf, etc.) — reviewers there have higher bars and less context.

## Patches vs Flags vs Overlays

When you need a Nix derivation to behave differently for some platform / use case, pick in this order:

1. **Upstream configure / cmake / make flag**: e.g. `--without-tests`, `-DSQLITE_NOHAVE_SYSTEM`, `--with-ospeed=int`. No file edits, no rot, reviewer-trivial.
2. **`substituteInPlace --replace-fail`**: single-line surgical edits. Safe on Darwin builders (no BSD sed pitfalls).
3. **`postPatch` script editing**: when you must inject blocks. Watch out for sed portability (next section).
4. **`.patch` file applied via `patches = [ ... ]`**: when the change is large or touches multiple sites. Cost: rot on every upstream bump.
5. **Custom overlay in your flake**: when the fix shouldn't go upstream, or you need it before upstream merges. Pattern in libxmtp at `nix/lib/default.nix` (see "Overlay-based downstream fixes" below).

Always start with (1) and stop at the first option that works.

## Darwin sed Portability — Critical

Patches that run on Darwin builders use **BSD sed**, which does NOT interpret `\n` inside `i\` / `a\` / `c\` text — it inserts a literal `\n` character. The same script appears to work on Linux (GNU sed) and silently corrupt files on Darwin.

**Symptom**: `#ifndef FOO\n#define FOO 0\n#endif` becomes a single line, causing a `-Werror=undef-prefix` failure 700 lines later because the `#define` never registered.

**Rules**:

- To prepend content to a file: `{ printf '...\n...\n'; cat "$f"; } > "$f.new" && mv "$f.new" "$f"`
- To append: `printf '...\n' >> "$f"`
- Single-line replace: `sed -i 's/old/new/g'` is fine — the issue is only multi-line `i\`/`a\`/`c\` inserts.
- `substituteInPlace --replace-fail` is safe (single-line substitution).

Applies whenever writing `postPatch` / `buildCommand` / `preConfigure` for any derivation that may build on Darwin (apple-sdk packages, anything cross-compiled to iOS).

## Commit Messages — nixpkgs Style

Format:

```
<pkgname>: <imperative summary, ≤72 chars, no trailing period>

<blank line>

<body — explain WHY this change exists, not WHAT the diff does.
Reviewers can read the diff. They want the constraint, the symptom,
the trade-off, the upstream issue link.>
```

Multi-bullet bodies are fine for changes that touch several aspects of a single derivation (e.g. `configureFlags + buildInputs + postInstall` for the same platform). Keep bullets parallel — start each with a verb or a noun phrase.

**Worked example** (one of the stack commits):

```
ncurses: cross-compilation fixes for iOS

Three iOS-gated changes so apple-sdk can propagate ncurses on iOS:

* enableStatic defaults to true on iOS. ncurses' configure doesn't
  recognize *-apple-ios / *-apple-ios-simulator hosts for shared-library
  builds and aborts with "Shared libraries are not supported in this
  version". iOS apps ship static ncurses in practice.

* --with-ospeed=int on iOS. The default `short` activates
  NCURSES_OSPEED_COMPAT, whose __APPLE__ arm includes <sys/ttydev.h> —
  a macOS-only header absent from the iOS SDK. Setting ospeed's type
  to `int` short-circuits the whole block via the existing upstream
  knob, no source patching needed.

* --without-progs --without-tests on iOS. The tic / reset / filter
  binaries call system(3), which iOS's SDK marks unavailable;
  apple-sdk only needs libncurses.a so the utility binaries are
  unnecessary anyway.
```

Notice: states the *constraint* (configure can't recognize triple, header missing on iOS, system() unavailable) and the *resolution* (default to static, use upstream knob, drop unused binaries). Avoids restating what the diff already says.

## Commit Stacking Order

For multi-commit work touching layered subsystems (e.g. iOS cross stack), order commits **bottom-up by dependency**. nixpkgs reviewers expect each commit to compile in isolation on top of master.

In the libxmtp iOS stack, this meant:

```
gnu-config bump          ← needed by autotools packages
lib/systems iOS platform ← needed by everything cross-compiled
apple-sdk iOS support    ← needed by every Darwin lib
copyfile / libresolv / ncurses / libutil  (libs apple-sdk propagates)
compiler-rt iOS          ← needed by cross toolchain
darwin-sdk-setup / cc-wrapper / bintools-wrapper
bash / pcre2 / gnugrep / sqlcipher  ← consumers
```

When you discover a fix mid-stack that belongs further down, use jj to insert it at the right depth rather than appending to the tip.

## jj + Colocated Git: HEAD Lag

`~/code/nixpkgs` (and similar) is often a jj+git colocated repo. Flake inputs of the form `git+file:///path/to/nixpkgs` read from **git HEAD**, NOT jj `@`. After `jj describe`, `jj squash`, or similar mutations, git HEAD may still point at the old parent.

**Symptom**: `jj diff @` shows your fix, but the flake builds the *unfixed* derivation — same drv hash as before.

**Procedure after any jj mutation intended to reach a flake build**:

```bash
git log --oneline -3                                           # check git HEAD
jj log -r @ --no-graph -T 'commit_id'                          # check jj @
# if they diverge:
git stash && git checkout <jj-@-commit-id> && git stash drop   # advance git HEAD
```

`jj git export` alone is NOT enough — it updates bookmarks but not HEAD when `@` is not on a named branch.

**Then update the flake lock**:

```bash
nix flake update nixpkgs   # otherwise flake.lock pins the prior rev
```

Verify: lock file rev matches `git log --oneline -1` in nixpkgs. Skip this and the rebuild produces the *exact same drv hash* that failed before — fix never takes effect.

## Long Builds — Always Use Screen

Nix/nom builds expected to run > 30 min must run inside a **detached `screen` session**. Background launches via the Bash tool's `run_in_background` die silently after ~30-90 minutes (session leader teardown → SIGHUP). The status flag reads "running" because the tail-monitor keeps the output file fresh, but the build process has already exited.

**Pattern**:

```sh
screen -dmS libxmtp-ios bash -c \
  "cd /path/to/flake && \
   exec nom build --keep-going --max-jobs 0 --max-silent-time 3600 \
     .#packages.aarch64-darwin.ios-bindings-iphone64 \
     -L > /tmp/build.log 2>&1"
```

Then `tail -f /tmp/build.log`; `screen -r libxmtp-ios` to attach; Ctrl-A d to detach.

`nohup`, `--max-silent-time`, `--timeout` do NOT fix the harness teardown — only a true session leader (screen) survives.

## Remote Darwin Builders

When building Darwin derivations from a Linux workstation, use `--max-jobs 0` to force all work to the remote `ssh-ng://nixbuilder@<host>` builders. Eval still has to happen on a Darwin system → target `.#packages.aarch64-darwin.<attr>` explicitly:

```bash
nix build .#packages.aarch64-darwin.ios-bindings-iphone64 --max-jobs 0
```

Eval-side iOS derivations (e.g. `arm64-apple-ios-cctools`) have `meta.platforms = [ "*-darwin" ]` and refuse to evaluate on Linux. The `.#packages.aarch64-darwin.<attr>` invocation ships eval to the Darwin builder.

**Known builder flakes**:

- `perl-5.42` OOM on parallel doc-generation (`Killed: 9`). Retry usually succeeds; the cache retains everything up to the failure. Don't introduce Nix-side patches for this — it's the builder host.
- `ld64` installCheck phase has been observed hanging then dying. Diagnose by fetching `nix log /nix/store/...drv` — that's a derivation issue, not infra.
- If personal `ssh <host>` fails but nix-store works fine, the host is up — personal user just lacks an authorized key. Test via `sudo nix store info --store ssh-ng://nixbuilder@<host>`.

## Overlay-Based Downstream Fixes

When upstream nixpkgs has a real bug that you can't (or won't) push upstream quickly — e.g. a test regression in a vendored toolchain — fix it in your flake's overlay rather than carrying a nixpkgs patch.

**Pattern** (from `nix/lib/default.nix`, for LLVM 21.1.8 BPF BTF test drift):

```nix
(
  final: prev:
  prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
    llvmPackages_21 = prev.llvmPackages_21 // {
      libllvm = prev.llvmPackages_21.libllvm.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          rm test/CodeGen/BPF/BTF/func-func-ptr.ll
          rm test/CodeGen/BPF/BTF/func-typedef.ll
        '';
      });
    };
  }
)
```

Always include a comment explaining:
- The upstream issue / commit reference
- Why it doesn't block your specific use case (BPF backend irrelevant to iOS)
- What invalidates the workaround (LLVM 21 test regeneration or Darwin stdenv bumping to 22)

## Upstream Contribution Dossier

When a fix belongs upstream (and not just in nixpkgs as a local patch), prepare a contribution dossier *before* sending. This is what made the gnulib stackvma upstream pitch defensible.

Directory layout (`docs/upstream-contributions/<project>-<topic>/`):

```
README.md                   ← contribution plan
<patch-name>.patch          ← the minimal patch itself
cover-letter.txt            ← the email body / PR description
```

README structure:

1. **What** — one paragraph describing the change.
2. **Why (audit)** — symbol-by-symbol justification that the change is correct. For include removals: grep the file for usages of each header's symbols, prove they don't exist.
3. **The patch** — show the diff inline.
4. **Upstream procedure** — exact commands for the project's contribution workflow (email-based, GitHub PR, mailing list, etc.).
5. **Why this is better than the earlier approach** — if you considered a more invasive alternative, justify the minimal one. Reviewers will ask.
6. **Historical provenance** — `git blame` / `git log` traces showing when and why the code was introduced. "Dead since birth" arguments are gold.
7. **Copyright assignment** — for FSF projects, note the threshold (~15 lines) and whether your patch crosses it.
8. **Timeline + local patch tracking** — where the nixpkgs-side patch lives, when it can retire.

Cover letter structure:

1. Subject: `[PATCH] <pkg>: <imperative summary>`
2. One paragraph: what's broken + the symptom.
3. One paragraph: why upstream didn't notice (e.g. macOS ships the dead headers; the test wasn't run on iOS).
4. Confirmation that the unchanged code path on the unaffected platforms works.
5. Field-test note: confirm the patch has been exercised in nixpkgs.
6. Signed-off-by line.

## Cross-Compile Diagnostic Patterns

When a Nix cross-compile fails on iOS / Darwin specifically:

1. **"Header X not found"**: check whether the header is macOS-only. iOS SDK lacks `<libc.h>`, `<nlist.h>`, `<sys/ttydev.h>`, `<sys/disk.h>`, `<tzfile.h>`, `<sys/kdebug.h>`, `<sys/vnode.h>`. Common fix: `cc.has_header(...)` gates in meson, `lib.optionals stdenv.hostPlatform.isiOS` skips in nix, or a `TARGET_OS_IPHONE` guard injection if the upstream source structure permits.
2. **"X function unavailable"**: check Apple availability annotations. `system(3)`, `getentropy`, `nlist()` are marked unavailable on iOS even though the symbols exist in the library. Either compile-out the call site (configure flag, define) or pre-seed the autoconf cache var to "no".
3. **Cross-compile autoconf check default**: `AC_RUN_IFELSE` defaults to "no" when cross. `AC_LINK_IFELSE` checks for symbol presence — may falsely succeed on iOS for unavailable-marked symbols. Workaround: pre-seed `ac_cv_func_<name>=no`.
4. **"Invalid target triple"**: gnu-config older than 2025-01 doesn't know `*-apple-ios-simulator`. Bump `gnu-config` or `updateAutotoolsGnuConfigScriptsHook` the package.
5. **"Shared libraries not supported"**: ncurses-style — flip `enableStatic = true` on iOS, since iOS apps don't ship `.dylib` system libs anyway.
6. **W^X violations / JIT failure**: pcre2-style — `--enable-jit=no`. iOS sandbox forbids executable-writable memory.

## Quick Reference

| Need | Mechanism |
|------|-----------|
| Skip macOS-only code on iOS | upstream `TargetConditionals.h` gate + `TARGET_OS_IPHONE` |
| Disable autoconf feature detection | `ac_cv_func_<name>=no` cache pre-seed |
| Static-only on iOS | `enableStatic = true; enableShared = false;` |
| Drop unused binaries | `--without-progs` / `--without-tests` |
| Drop JIT (W^X) | `--enable-jit=no` |
| Disable system() calls | `-DSQLITE_NOHAVE_SYSTEM` or equivalent |
| Force remote build from Linux | `--max-jobs 0` + `.#packages.aarch64-darwin.<attr>` |
| Long build survives | wrap in `screen -dmS <name> bash -c "..."` |
| Sync git HEAD to jj @ | `git checkout $(jj log -r @ --no-graph -T 'commit_id')` |
| Pick up nixpkgs change | `nix flake update nixpkgs` after git HEAD sync |
