# ShellCheck for Mere Mortals

Every shell script carries the same small
family of faults: the variable that splits
the day a filename grows a space, the test
that compares strings while believing it
compares numbers, the `cd` that fails and
lets the script work bravely on in the
wrong directory. They rarely stop a run —
they wait, and surface as the wrong file
renamed, the alert that cried wolf, the
backup of the wrong folder. **ShellCheck**
is the tool that reads a script without
running it and names those faults in
advance, each with a permanent code and a
wiki page. This guide teaches it the slow
way: one lab of everyday scripts, their
faults planted, their reports read in
full, and their corrections run side by
side with the originals.

The lab is a family of scripts in
`examples/` — a photo renamer, a dated
backup, a log trimmer, a disk-space
alerter — each written with its faults in,
each with a corrected twin that passes
clean. Two of the specimens are run for
real mid-guide: the buggy renamer, meeting
filenames with spaces, and the disk
alerter, whose lying test leaves evidence
in the directory. Nothing in the lab is
modelled on anyone's real machines or
organisations; the names, folders, and
files are invented, and the transcripts
are kept in `shellcheck-lab/transcripts/`.

A note on how this guide was verified.
ShellCheck **0.10.0**, the official static
binary, was run against every specimen,
and the reports quoted are captures, not
reconstructions — including the severities,
the exit codes, and the two runtime
demonstrations. Where a neighbour could
not be run on the build machine, the
chapter says so and `criteria.md` keeps
the ledger of what is documented-only.

## What this guide covers

- [**What ShellCheck is**](what-shellcheck-is.md) —
  static analysis in plain words; what it
  can prove and what it cannot; silence as
  the pass mark; the lab
- [**Reading the report**](reading-the-report.md) —
  the five parts of a finding, "Did you
  mean," the wiki footer, and the
  check–fix–check rhythm
- [**Quoting and splitting**](quoting-and-splitting.md) —
  SC2086 and SC2046, word splitting and
  globbing, the renamer's runtime wreckage,
  and where quotes do not belong
- [**Star and at**](star-and-at.md) — `$*`
  and `$@` in their four forms; SC2048 and
  SC2068; the forwarding habit
- [**Old habits**](old-habits.md) —
  backticks (SC2006), `expr` (SC2003), the
  useless `cat` (SC2002) and when it stays
  silent, looping over `ls` (SC2045)
- [**Guards and leftovers**](guards-and-leftovers.md) —
  the unguarded `cd` (SC2164), `read`
  without `-r` (SC2162), and the variable
  nothing uses (SC2034)
- [**Tests that lie**](tests-that-lie.md) —
  `[ -n $x ]` (SC2070), the `>` that is a
  redirection (SC2071) with its stray file
  as evidence, string versus number, and
  choosing `[` or `[[`
- [**Dialects**](dialects.md) — the shebang
  as a contract; `portable.sh` judged as
  `sh` and as bash; `-s`; SC2148; the four
  dialects placed
- [**Severity**](severity.md) — the four
  grades, the ladder counted on one script,
  what a rung hides, and adopting the tool
  on a real pile of scripts
- [**Silencing, with a paper trail**](silencing.md) —
  `-e` exclusions, in-file directives,
  SC1091 and `-x`, `.shellcheckrc` — and
  the rule that every silence carries its
  reason
- [**Formats and gates**](formats-and-gates.md) —
  tty, gcc, json, and diff output; the gate
  as an exit-code contract; a pre-commit
  hook run for real in both directions
- [**Recipes**](recipes.md) — a first pass
  over an inherited folder, extension-less
  scripts, stdin and fragments, sourced
  files, leaving a report on the record
- [**The neighbours**](the-neighbours.md) —
  `bash -n` and grammar's limits, shfmt
  the formatter, editor integration and
  the web checker, placed honestly
- [**Troubleshooting**](troubleshooting.md) —
  silence that means pass, dialects that
  differ by machine, directives that do
  nothing, and gates that are red while
  "the script works"
- [**Glossary**](glossary.md) — the terms,
  collected in one place

## What it doesn't cover

Writing shell scripts in the first place —
the sibling *Bash for Mere Mortals* owns
the language; this guide assumes you can
read a script and teaches you to review
one. ShellCheck's full catalogue: the lab
springs the checks everyday scripts meet,
and the wiki — linked from every report —
is the reference for the rest. Making a
script *safe* in the security sense: a
linter pass is not an audit, and chapter 1
is blunt about the difference. Editor and
hosting-platform setup in detail: those
live in chapter 13 as placements,
documented from their own manuals, because
a build sandbox cannot capture them
honestly.

## How to use this guide

Read chapter 1, copy the lab from
`examples/`, and keep a terminal open from
chapter 2 on. Every buggy specimen has a
fixed twin, so the natural exercise is to
fix the buggy one yourself before reading
the twin — the checker will grade your
attempt instantly, which is most of the
pleasure. Keep the lab afterward: a folder
of scripts with known faults is a standing
rehearsal for the day a real script needs
reviewing, and the gate from chapter 11
drops onto any project you own.
