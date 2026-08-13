#!/usr/bin/env python3
import json, shlex, sys

cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "")
lex = shlex.shlex(cmd, posix=True, punctuation_chars=True)
lex.whitespace_split = True
SEPS = {";", "&", "|", "&&", "||", "(", ")", "\n"}
WRAPPERS = {"env", "command", "exec", "xargs", "sudo", "time", "nice", "timeout"}

expect_cmd = True
try:
    for tok in lex:
        if tok in SEPS:
            expect_cmd = True
            continue
        if expect_cmd:
            if "=" in tok and not tok.startswith("-"):  # VAR=val prefix
                continue
            name = tok.rsplit("/", 1)[-1]
            if name == "git":
                print("git is disabled here — use jj", file=sys.stderr)
                sys.exit(2)
            expect_cmd = name in WRAPPERS  # env/xargs etc. forward to another cmd
except ValueError:
    pass  # unbalanced quotes etc. — fail open
sys.exit(0)
