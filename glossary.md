# Glossary

**Check** — one rule in ShellCheck's
catalogue: a pattern, a message, a severity,
and a code. "A finding" is one place a
check fired.

**Code (SC number)** — a check's permanent
name: SC plus four digits, as in SC2086.
Codes are never reused for a different
problem, and each has a page on the project
wiki.

**Dialect** — the specific shell language a
script is judged as: bash, sh, dash, or
ksh. Chosen by the shebang, a `shell=`
directive, an rc file, or `-s`.

**Directive** — a comment ShellCheck reads
as an instruction to itself, beginning
`# shellcheck`: `shell=`, `disable=`,
`source=`, and others. Directives act from
where they stand, downward.

**Error / warning / info / style** — the
four severities, in descending seriousness:
wrong now; a trap under the right
conditions; right until the input changes;
the old way of writing it. `-S` picks the
lowest a run reports.

**Exit code** — ShellCheck's verdict in
number form: 0, no findings; 1, findings —
or a file it could not read. Gates are
built on it.

**Expansion** — the shell's act of replacing
a notation with a value: `$name`, `$(...)`,
`$*`. What quoting protects.

**Gate** — a command whose exit code
decides whether work proceeds: a pre-commit
hook, a CI step. For ShellCheck, the gate
is the command, its severity, and its
recorded choices.

**Globbing** — the shell replacing a
pattern containing `*`, `?`, or `[...]` with
the filenames it matches. The second half
of what unquoted expansions undergo.

**Linter** — a program that checks source
text against a catalogue of known mistakes,
without running it. ShellCheck is a linter
for shell scripts.

**.shellcheckrc** — a file of standing
settings ShellCheck reads when it runs:
`disable=`, `shell=`, and more, scoped to a
directory tree or a user's config home.

**Shebang** — the `#!` first line of a
script naming the program that should run
it. ShellCheck reads it as the script's
declared dialect.

**Sourcing** — running a file's commands
inside the current shell rather than in a
child: `. file` or `source file`. Files
that are sourced usually have no shebang of
their own.

**Static analysis** — checking a program's
text at rest rather than its behaviour
while running. The opposite trade from a
test suite, and complementary to one.

**Word splitting** — the shell breaking an
unquoted expansion's value into separate
words at spaces, tabs, and newlines. The
fault behind SC2086, and half the faults
in this guide.
