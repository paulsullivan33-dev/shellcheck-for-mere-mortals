# Recipes

**Scope:** whole jobs, end to end — the
first pass over an inherited folder, scripts
with no `.sh` in their names, fragments and
stdin, sourced files, and leaving a report
on the record.

## First pass over a folder you inherited

**Job:** a directory of scripts that have
run for years, and a report a hundred
findings long. Do not start at the top of
it.

Run the ladder (chapter 9) and fix from the
top rung down:

```
$ shellcheck -S error scripts/*.sh
```

Check: the run finishes at all — a handful
of findings, not a hundred. Fix those, gate
that rung (chapter 11), then repeat at
`-S warning`. Each rung you clear becomes a
property of the folder rather than a mood.

## Scripts without .sh in the name

**Job:** the real scripts on a system live
in `bin/` with names like `backup-run` —
no extension to glob for.

ShellCheck does not need the extension. It
reads the **shebang**, and judges any file
you name by the shell declared there:

```
$ ls shellcheck-lab/fixtures/bin
check-things
folder-summary
$ shellcheck shellcheck-lab/fixtures/bin/folder-summary
[exit 0]
$ shellcheck -f gcc shellcheck-lab/fixtures/bin/check-things
shellcheck-lab/fixtures/bin/check-things:5:9: error: -n doesn't work with unquoted arguments. Quote or use [[ ]]. [SC2070]
shellcheck-lab/fixtures/bin/check-things:11:14: error: > is for string comparisons. Use -gt instead. [SC2071]
[exit 1]
```

(The second script is `tests.sh` under a
working name; two of its findings are cut.)
To sweep a folder, name the files
explicitly, or find them by content — a
first line that starts `#!` and mentions a
shell. A file with neither extension nor
shebang earns SC2148, which is the tool
asking a fair question.

## A fragment, or a script on stdin

**Job:** check three lines before you paste
them into a real script.

ShellCheck reads standard input when the
file is named `-` — and a fragment has no
shebang, so say which shell to judge by:

```
$ printf 'cd $1\n' | shellcheck -
In - line 1:
cd $1
^-- SC2148 (error): Tips depend on target shell and yours is unknown. Add a shebang or a 'shell' directive.
^---^ SC2164 (warning): Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
   ^-- SC2086 (info): Double quote to prevent globbing and word splitting.
$ printf 'cd $1\n' | shellcheck -s bash -
In - line 1:
cd $1
^---^ SC2164 (warning): Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
   ^-- SC2086 (info): Double quote to prevent globbing and word splitting.
```

Check: with `-s bash`, the SC2148 line is
gone and the two substantive findings
remain — the dialect was the only thing
missing. (Both runs are in transcript
t17.)

## Following a script's sourced files

**Job:** a script reads its settings from
another file, and you want that file
checked as part of the run.

Add `-x`. Without it you get SC1091 —
*not following* — and the fragment is
judged only when named itself. With it,
ShellCheck follows the `source` line and
reports on both files in one run:

```
$ shellcheck -x uses-config.sh
[exit 0]
```

(Run from `examples/`; the plain run and
its SC1091 are in chapter 10.) If the
sourced file lives somewhere the checker
cannot guess, a `# shellcheck source=`
directive above the `source` line names
the path — a directive to use when the
layout is real and permanent, and to record
like any other.

## Leaving the report on the record

**Job:** a codebase's first audit, kept for
comparison after the fixes land.

Use the gcc format — one finding per line,
greppable, diffable, and free of the
terminal's colour codes:

```
$ shellcheck -f gcc scripts/*.sh > audit-before.txt
```

Check: `audit-before.txt` ends with the
findings, and a later `audit-after.txt`
diffs against it cleanly, line for line —
which is more than can be said for the tty
format's carets and colour once a terminal
is out of the picture.

## Looking up a code you have never seen

**Job:** a finding whose message is not
self-explanatory.

Every code has a permanent address:
`https://www.shellcheck.net/wiki/SC` plus
the number — SC2071's page is
`.../wiki/SC2071`. The page gives the faulty
pattern, the corrected pattern, and the
cases where the pattern is actually fine.
Read it before you fix, and especially
before you silence: half of chapter 10's
paper trail is just "the wiki's exception
applies here, because…", written where the
next reader will find it.
