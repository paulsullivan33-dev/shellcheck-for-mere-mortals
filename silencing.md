# Silencing, With a Paper Trail

**Scope:** the three ways to tell ShellCheck
"not that one" — `-e` on the command line,
`# shellcheck` directives in the file, and
`.shellcheckrc` beside the project — and
the discipline that keeps them honest:
every silence is scoped as narrowly as
possible, and carries its reason.

## Excluding by code: -e

```
$ shellcheck -e SC2086 -f gcc examples/rename-photos.sh
examples/rename-photos.sh:5:1: warning: Use 'cd ... || exit' or 'cd ... || return' in case cd fails. [SC2164]
examples/rename-photos.sh:7:10: error: Iterating over ls output is fragile. Use globs. [SC2045]
examples/rename-photos.sh:13:16: error: Double quote array expansions to avoid re-splitting elements. [SC2068]
```

(Style findings from the same run are cut
here for length; the full capture is
transcript t11.) The five SC2086 findings
are gone; everything else still speaks.
Exclusions take lists — `-e SC2086,SC2006`
removes the backticks too — and the run
still exits 1, because findings remain.
`-e` is a property of the *invocation*, not
of the code: it lives in your command, your
CI file, your Makefile. The next person to
run ShellCheck on the file by hand will see
the findings you excluded and wonder. Used
in a gate script (chapter 11), where the
command itself is the recorded decision,
that is fine. Typed at a prompt to make a
report shorter, it is amnesia.

## Directives: the decision moves into the file

A directive is a comment ShellCheck reads.
It can name the dialect for a file with no
shebang, and it can disable named checks
for the code that follows it. The lab's
settings fragment shows both. *Without*
directives, the same three lines draw an
error and two warnings (transcript t12):

```
$ cat shellcheck-lab/fixtures/frag.sh
# Settings, no directives.
BACKUP_ROOT=/mnt/backupdrive
RETENTION_DAYS=14
$ shellcheck shellcheck-lab/fixtures/frag.sh
^-- SC2148 (error): Tips depend on target shell and yours is unknown. Add a shebang or a 'shell' directive.
^---------^ SC2034 (warning): BACKUP_ROOT appears unused. Verify use (or export if used externally).
^------------^ SC2034 (warning): RETENTION_DAYS appears unused. Verify use (or export if used externally).
```

The SC2034s are false alarms: the settings
are unused *in this file* because other
scripts source it precisely to read them.
The shipped fragment (`examples/config-fragment.sh`)
says exactly that, in comments a human
reads, with the directives doing the work:

```bash
# Settings for the backup scripts, sourced by them, never run
# directly — which is why there is no shebang. The directive below
# tells ShellCheck which shell to judge it by.
# shellcheck shell=bash
#
# The two settings are used by the scripts that source this file,
# not by anything in it, so the unused-variable warning is a false
# alarm here. It is disabled for this file only, and this comment
# is the record of why.
# shellcheck disable=SC2034
BACKUP_ROOT=/mnt/backupdrive
RETENTION_DAYS=14
```

```
$ shellcheck examples/config-fragment.sh
[exit 0]
```

Three placement rules, all visible in that
example. A directive applies from where it
stands **downward** — the `shell=` line
must come before the code it describes. A
directive placed before the first command
in the file covers the **whole file**; one
placed directly above a single line covers
that line, which is the narrowest scope of
all:

```
$ cat shellcheck-lab/fixtures/dir.sh
#!/bin/bash
# shellcheck disable=SC2164
cd $1
$ shellcheck shellcheck-lab/fixtures/dir.sh
   ^-- SC2086 (info): Double quote to prevent globbing and word splitting.
```

The `cd` warning is silenced; the quoting
finding on the same line still speaks.
(That specimen disables SC2164 to prove the
mechanism — in a real script, record *why*
the unguarded `cd` is acceptable, as the
fragment records its reason, or a reader a
year from now inherits a silence and a
mystery in equal measure.)

## One more directive-shaped fact: SC1091

A script that sources another file draws
an informational note, because by default
ShellCheck checks only the files you name:

```
$ shellcheck examples/uses-config.sh
       ^------------------^ SC1091 (info): Not following: ./config-fragment.sh was not specified as input (see shellcheck -x).
```

`-x` tells it to follow `source` lines and
check what it finds there too:

```
$ shellcheck -x uses-config.sh
[exit 0]
```

Neither is a "silencing" — SC1091 is the
tool showing its working boundary. It
matters to gates: chapter 11's gate runs
without `-x` at warning severity, where
this info finding passes quietly, which is
a decision a gate author should make
knowingly rather than discover later.

## Project-wide: .shellcheckrc

For decisions that belong to a whole
folder of scripts, ShellCheck reads a file
named `.shellcheckrc` — in the directory
you run it from, the script's own directory,
or your user's config home. The lab ran
both kinds (transcript t13). With
`disable=SC2086` in the rc file, the tests
specimen's quoting findings vanished while
its errors remained; with `shell=sh`, the
same file was rejudged as POSIX and SC3014
and SC3010 appeared — the rc's `shell=`
works exactly like `-s`, for every run in
the tree.

An rc file is the broadest of the three
instruments, and the easiest to abuse:
`disable=` in an rc is a standing order
nobody reviewing a single script will ever
see. Reserve it for decisions that truly
are project-shaped — the dialect every
script in the folder targets, a check that
misfires on a framework the whole project
uses — and put the reason in the rc as a
comment, where the next reader's confusion
will actually happen.

The hierarchy, narrowest first: **a
directive above one line, a directive for
one file, an rc for one project, `-e` in
one recorded gate command.** Choose the
narrowest scope the decision honestly has,
and write the reason where the silence
will be found.
