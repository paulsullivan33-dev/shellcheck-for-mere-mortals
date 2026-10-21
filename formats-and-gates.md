# Formats and Gates

**Scope:** ShellCheck's output formats —
**tty** for humans, **gcc** for tools that
think in lines, **json** for programs,
**diff** for its own suggestions — and the
gate built on the exit code: a pre-commit
hook, run for real, that refuses a faulty
script.

## One report, four shapes

Everything so far was the default **tty**
format: carets, colours on a terminal,
prose. `-f` asks for the same findings in
other shapes. **gcc** format is one line
per finding — file, line, column, grade,
message, code:

```
$ shellcheck -f gcc examples/backup.sh
examples/backup.sh:5:7: note: Use $(...) notation instead of legacy backticks `...`. [SC2006]
examples/backup.sh:6:15: note: Double quote to prevent globbing and word splitting. [SC2086]
examples/backup.sh:8:5: note: Useless cat. Consider 'cmd < file | ..' or 'cmd file | ..' instead. [SC2002]
examples/backup.sh:9:25: warning: Quote this to prevent word splitting. [SC2046]
examples/backup.sh:10:1: warning: speed appears unused. Verify use (or export if used externally). [SC2034]
```

(The full run lists eight findings; five
are shown. In this format, info and style
findings are both labelled *note*.) This is
the shape editors and build logs have
parsed for decades, and the shape to reach
for when output feeds anything else that
thinks line-by-line — including `wc -l`,
as chapter 9's ladder did.

**json** is for programs proper: an array
of objects carrying file, line, column,
level, code, message — and, where
ShellCheck has a mechanical fix, the fix
itself as machine-applicable replacements.
One finding of the trimmer's eight, broken
across lines for print (the full array is
transcript t14):

```json
{"file": "examples/trim-logs.sh", "line": 6, "endLine": 6,
 "column": 1, "endColumn": 11, "level": "warning",
 "code": 2164,
 "message": "Use 'cd ... || exit' or 'cd ... || return' in case cd fails.",
 "fix": {"replacements": [
   {"line": 6, "column": 11, "endColumn": 11,
    "insertionPoint": "beforeStart",
    "replacement": " || exit"}]}}
```

**diff** renders those same suggested
fixes as a unified diff you can read — or
pipe to `patch`:

```
$ shellcheck -f diff examples/disk-alert.sh
--- a/examples/disk-alert.sh
+++ b/examples/disk-alert.sh
@@ -2,13 +2,13 @@
 # Ask which filesystem to check, then warn if it is at or over the limit.
 limit=90
 read -p "Filesystem to check [/]: " fs
-if [ -z $fs ]; then
+if [ -z "$fs" ]; then
   fs=/
```

Read a diff before you ever apply one. The
fixes are the mechanical "Did you mean"
suggestions in patch form: individually
sound, collectively unopinionated about
your script's design. Letting a tool
rewrite every line it dislikes, unread, is
how a codebase ends up consistent and
wrong; the chapters before this one exist
so the diff reads as proposals you judge,
not weather you endure.

## The gate

A **gate** is a promise enforced by an exit
code: run ShellCheck at an agreed severity
(chapter 9), and let the command's 0 or 1
decide whether work proceeds. Here is the
promise applied to the whole lab,
buggy half first (transcript t15, gcc
format, findings condensed to their
headlines by the format itself):

```
$ shellcheck -S warning -f gcc examples/rename-photos.sh examples/backup.sh examples/trim-logs.sh examples/disk-alert.sh examples/tests.sh examples/args.sh examples/portable.sh
examples/rename-photos.sh:5:1: warning: Use 'cd ... || exit' or 'cd ... || return' in case cd fails. [SC2164]
examples/rename-photos.sh:7:10: error: Iterating over ls output is fragile. Use globs. [SC2045]
examples/disk-alert.sh:12:11: error: > is for string comparisons. Use -gt instead. [SC2071]
examples/tests.sh:5:9: error: -n doesn't work with unquoted arguments. Quote or use [[ ]]. [SC2070]
examples/portable.sh:5:4: warning: In POSIX sh, [[ ]] is undefined. [SC3010]
[exit 1]
```

Seventeen findings at warning-and-above
across the seven scripts; five are shown.
And the fixed half of the lab, same gate:

```
$ shellcheck -S warning examples/clean.sh examples/rename-photos-fixed.sh examples/backup-fixed.sh examples/trim-logs-fixed.sh examples/disk-alert-fixed.sh examples/args-fixed.sh examples/tests-fixed.sh examples/config-fragment.sh examples/uses-config.sh
[exit 0]
```

Note who is in that passing list:
`uses-config.sh`, which draws SC1091 — an
*info* finding, below the gate's floor, so
the gate passes it without `-x`. That is
chapter 9's lesson in production: the rung
you choose is a decision about which
classes of finding may pass, and it should
be made the way it is made here — named,
in the command, where a reader can see it.

## The pre-commit hook, for real

A CI gate discovers faults after the push;
a **pre-commit hook** discovers them before
the commit exists. Git runs any executable
in `.git/hooks/pre-commit` and cancels the
commit if it exits non-zero. This one
checks every shell script being committed,
at the lab's warning gate:

```bash
#!/bin/bash
# Refuse the commit if ShellCheck (warning and above) objects
# to any shell script being committed.
files=$(git diff --cached --name-only --diff-filter=ACM | grep -e '\.sh$' || true)
[ -z "$files" ] && exit 0
# shellcheck disable=SC2086
shellcheck -S warning $files
```

(Even the hook has a line ShellCheck would
discuss: `$files` is split on purpose —
the hook wants each staged name as its own
argument — and the disable directive says
so, per chapter 10's discipline.) Installed
in a scratch repository and exercised with
both trimmers, it did its job in both
directions (transcript t15):

```
$ git add trim-logs.sh && git commit -m 'add the log trimmer'
^-----^ SC2034 (warning): scratch appears unused. Verify use (or export if used externally).
^--------^ SC2164 (warning): Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
[exit 1]
$ git reset -q && git add trim-logs-fixed.sh && git commit -m 'add the fixed trimmer'
[main (root-commit) 857c022] add the fixed trimmer
 1 file changed, 11 insertions(+)
 create mode 100644 trim-logs-fixed.sh
[exit 0]
```

Two lessons ride along. First, the refusal
leaves the faulty file **staged**: it would
have ridden into the *next* commit and
been refused again there, which is why the
second command above begins with
`git reset` to unstage it. A refused commit
is not a cleaned slate. Second, the same
command that gates a commit gates a CI
job unchanged — the gate is the command
and its severity, and the hook, the CI
file, and your own prompt are just three
places to stand it. Whichever place you
choose, write the choice down there: the
severity, any `-e` exclusions, any `-x`,
so the next reader inherits the decision
and not just the silence.
