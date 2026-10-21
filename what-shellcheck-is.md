# What ShellCheck Is

**Scope:** the mental model — a program that
reads shell scripts without running them, and
reports the mistakes it can prove from the
text alone — plus what it cannot do, your
version, and the lab.

## A reader, not a runner

Most tools that deal with a shell script
*run* it: the shell itself, a test suite, the
cron daemon at 3 a.m. **ShellCheck** does
the opposite. It reads a script the way a
careful proofreader reads a letter — top to
bottom, checking every line against a large
catalogue of known mistakes — and it never
executes a single command. The trade this
kind of tool makes has a name: **static
analysis**, checking the text at rest rather
than the behaviour in motion.

What it can prove from text alone turns out
to be a great deal, because shell scripts
fail in a small number of well-worn ways.
A variable used without quotes splits into
several words the day a filename grows a
space. A `>` inside a test is not a
comparison at all — it is a redirection
wearing a disguise. A `cd` that fails does
not stop the script; the script carries on
in the wrong directory, doing its work in
the wrong place. ShellCheck knows several
hundred of these patterns, and every one it
reports carries a number — **SC2086**,
**SC2164** — that names it in every script,
on every machine, and links to a wiki page
that explains it.

What it cannot do matters just as much, and
this guide will keep saying it: **a clean
ShellCheck report is not proof that a script
is correct, and it is not proof that a
script is safe.** ShellCheck cannot know
what you *meant*. It cannot see the data the
script will meet at runtime — the empty
variable, the missing file, the filesystem
that is a network share today and was not
yesterday. It checks the shape of the code,
not the rightness of the plan. Treat a clean
report the way you treat a spell-checker's
silence: the letter is free of typos. It
might still say the wrong thing.

Check: the tool, on the build machine. This
guide's ShellCheck is the official static
binary, one self-contained file:

```
$ shellcheck --version
ShellCheck - shell script analysis tool
version: 0.10.0
license: GNU General Public License, version 3
website: https://www.shellcheck.net
```

Version numbers matter with a linter: the
catalogue grows, and a check that is silent
in one release may speak in the next. Every
capture in this guide is from **0.10.0**;
`criteria.md` keeps the ledger.

ShellCheck speaks four dialects — **bash**,
**sh** (the portable POSIX subset), **dash**,
and **ksh** — and which one it judges by is
not a detail. The same file can be clean in
one dialect and wrong in another, and
chapter 8 is built on exactly that. It runs
on Linux, macOS, and Windows (natively and
under WSL); the binary is the same tool
everywhere, though the scripts you feed it
may lean on tools your other systems spell
differently, and the chapters flag the
differences that bite.

## Silence is the pass mark

Run ShellCheck on a sound script and it
prints *nothing at all* — no "OK", no
summary, just a quiet exit. The verdict
lives in the **exit code**: 0 means no
findings, 1 means findings (or a file it
could not read). That silence-plus-exit-code
shape is deliberate: it makes ShellCheck a
natural gate in scripts and CI pipelines,
which chapter 11 builds for real.

```
$ shellcheck examples/clean.sh
[exit 0]
```

The lab's `clean.sh` is six lines long and
says nothing back. Every other specimen in
the lab has something to say.

## The lab

Everything in this guide happens to one
small family of scripts in `examples/`,
written for the guide — everyday jobs of
the kind that live on every machine:

- `rename-photos.sh` — a photo renamer, and
  its corrected twin `rename-photos-fixed.sh`
- `backup.sh` / `backup-fixed.sh` — a dated
  folder backup
- `trim-logs.sh` / `trim-logs-fixed.sh` — a
  log trimmer that promises to be portable
  `sh`
- `disk-alert.sh` / `disk-alert-fixed.sh` —
  an interactive disk-space alerter with two
  genuine traps in it
- `args.sh` / `args-fixed.sh` — a tiny
  script about the script's own arguments
- `tests.sh` / `tests-fixed.sh` — a
  pocketful of test idioms, some sound
- `portable.sh` — bash habits wearing an
  `sh` shebang
- `config-fragment.sh` and `uses-config.sh`
  — a settings file and the script that
  sources it
- `clean.sh` — the quiet one above

Each buggy script was written with its
faults planted, and each fixed twin is the
same script with every fault repaired —
ShellCheck passes all of the twins, and the
chapters show the repairs side by side with
the findings that demanded them. Working
transcripts are kept in
`shellcheck-lab/transcripts/`.

One habit to form now: **the specimens are
the syllabus.** Run the commands yourself,
on your copies. A linter is learned the way
proofreading is learned — by seeing your own
sentences come back marked.
