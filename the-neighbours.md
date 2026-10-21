# The Neighbours

**Scope:** the tools that live beside
ShellCheck in a script-writer's kit —
`bash -n`, the grammar-only check; **shfmt**,
the formatter; editor integration; and the
web checker — and what each trades away
and gives back.

## bash -n: grammar, and only grammar

Your shell can check a script's syntax
without running it:

```
$ bash -n examples/disk-alert.sh
[exit 0]
```

Sit with that result for a moment.
`disk-alert.sh` contains the lab's worst
line — the `>` test that lies and litters
(transcript t07) — and `bash -n` passes it
without a murmur, because *grammatically*
there is nothing wrong with it. The line is
a well-formed command with a redirection;
only its meaning is broken. That is the
neighbour's whole character: `-n` proves a
script **parses**, full stop.

Where parsing is the question, it is the
right tool — instant, and already
installed. The genuinely unparseable
fixture (an `if` with no `fi`) fails under
both tools, each in its own voice:

```
$ bash -n shellcheck-lab/fixtures/broken.sh
shellcheck-lab/fixtures/broken.sh: line 4: syntax error: unexpected end of file
[exit 2]
$ shellcheck shellcheck-lab/fixtures/broken.sh
^-- SC1046 (error): Couldn't find 'fi' for this 'if'.
^-- SC1073 (error): Couldn't parse this if expression. Fix to allow more checks.
```

ShellCheck, when it cannot parse, says so
in the SC104x/SC107x family and stops —
it will not guess at the rest of the file.
So the division of labour is: `-n` for
"is this even a script", ShellCheck for
"is this script saying what it thinks it
is saying", and neither for "is the plan
right", which remains stubbornly yours.

## shfmt: the formatter

**shfmt** does not check meaning at all —
it rewrites shell scripts in one canonical
layout: indentation, spacing, line breaks.
Teams like it because it ends formatting
arguments the way a linter ends quoting
arguments. It was not installed on this
guide's build machine —

```
$ command -v shfmt
[exit 1]
```

— so nothing in this guide quotes its
output, and its behaviour here is
documented-only (see `criteria.md`).
Placed honestly: shfmt answers "does it
*look* uniform", ShellCheck answers "is it
sound", and a project can sensibly run
both, the formatter first so the linter's
line numbers are stable. It cannot rescue
a lying test, and ShellCheck cannot rescue
an unreadable script; the resemblance
between them ends at the file extension.

## In the editor, and on the web

Two more neighbours are named here and
deliberately not demonstrated, because a
sandbox build cannot capture them honestly.

Most serious editors can run ShellCheck as
you type — directly, or through a language
server — and underline findings in place,
with the code and wiki link a keystroke
away. It is the same binary and the same
verdicts this guide captured, delivered at
the moment of writing instead of after;
the setup belongs to your editor's
documentation, and the habits transfer
unchanged. If your editor offers it, it is
the single most effective way to absorb
this guide's lessons — SC2086 underlined
the third time teaches quoting faster than
any chapter.

And **shellcheck.net**, the project's own
site, will check a script pasted into a
browser with no install at all. It is a
fine way to meet the tool, or to check one
script on a machine where you cannot
install anything. Its limits are the
pasting itself: nothing about your files,
your dialect defaults, or your gates
travels with the snippet, and a script you
would not paste into a stranger's website
should not be checked there. Everything
the site does, the local binary does
without the script leaving the machine.
