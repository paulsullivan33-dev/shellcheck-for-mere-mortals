# Star and At

**Scope:** the two expansions that carry a
script's arguments — `$*` and `$@` — and why
ShellCheck treats the unquoted forms as two
different mistakes, **SC2048** and **SC2068**.

## Four forms, three behaviours

A script's arguments arrive as a list.
Shell notation gives you two ways to reach
for the list, each quotable or not, and the
four combinations behave three ways:

| Form | What it becomes |
|---|---|
| `"$@"` | Each argument, as its own word, exactly as passed |
| `"$*"` | One single word: all arguments joined by spaces |
| `$@`, `$*` unquoted | Each argument, **split again** on its spaces and globbed |

The first row is the one you want almost
every time you forward or loop over
arguments: nothing merged, nothing split,
a name with a space in it survives the
trip. The second row is a deliberate act —
joining the list into one string for
display, or for building a single message.
The third row is the trap: it *looks* like
the first, right up until an argument
contains a space, when it quietly becomes
more arguments than the caller passed.

## Two codes, because the intent differs

The lab's `examples/args.sh` holds both
arguments wrong on purpose:

```
$ shellcheck examples/args.sh

In examples/args.sh line 5:
for a in $*
         ^-- SC2048 (warning): Use "$@" (with quotes) to prevent whitespace problems.


In examples/args.sh line 9:
for a in $@
         ^-- SC2068 (error): Double quote array expansions to avoid re-splitting elements.
```

Why two codes for what looks like one sin?
Because the repairs differ in kind. For
`$*`, ShellCheck can guess your intent
exactly — you were looping over the
arguments, and `"$@"` is the form that does
that — so SC2048 says so outright. For
unquoted `$@`, the same guess applies, but
the code is graded **error** rather than
warning: `$@` unquoted is never the right
tool for any job, where `$*` at least has
the honest joined-string use when quoted.

The runtime proof is one command (from
transcript t05). The same two arguments —
one of them a filename with a space — go
through both scripts:

```
$ bash examples/args.sh "my photo.jpg" notes.txt
As one string: my photo.jpg notes.txt
split by star: [my]
split by star: [photo.jpg]
split by star: [notes.txt]
split by at: [my]
split by at: [photo.jpg]
split by at: [notes.txt]
$ bash examples/args-fixed.sh "my photo.jpg" notes.txt
intact: [my photo.jpg]
intact: [notes.txt]
As one string: my photo.jpg notes.txt
```

Both unquoted loops saw three items where
the caller passed two — the split is not a
warning about style, it is a different list.
Only the fixed script's `for a in "$@"`
loop saw the arguments as they were given.
And note the last line of the fixed run:
`"$*"` quoted, joining on purpose for
display, is left entirely alone by
ShellCheck. Quoted, the star is a tool;
unquoted, it is a leak.

## The forwarding habit

The place this bites hardest is the wrapper
script — the little script whose whole job
is to call another command with some fixed
options and pass everything else through:

```bash
#!/bin/bash
# Run the photo renamer against the imports folder.
exec /opt/tools/rename-photos.sh /srv/imports "$@"
```

That final `"$@"` is the whole craft of the
wrapper. Write `$@` bare and the wrapper
works for months — until the first caller
passes a path with a space, when it hands
the inner command a quietly different set
of arguments and the failure surfaces one
script away from its cause. If you take one
line from this chapter into muscle memory,
make it this: **arguments are forwarded
with `"$@"`, displayed with `"$*"`, and
never, ever split on purpose by accident.**
