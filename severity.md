# Severity: Choosing Your Battles

**Scope:** the four grades — error, warning,
info, style — and the `-S` flag that turns
them into policy: which findings a run
reports, and which it lets pass for now.

## The ladder, measured

Every check has a fixed grade (chapter 2
met them). `-S` sets the *lowest grade a
run will report*, and the natural fear is
that choosing is arbitrary. It is not: here
is the renamer — twelve findings in all —
counted at each rung (transcript t10):

```
$ shellcheck -S error -f gcc examples/rename-photos.sh | wc -l
2
$ shellcheck -S warning -f gcc examples/rename-photos.sh | wc -l
3
$ shellcheck -S info -f gcc examples/rename-photos.sh | wc -l
8
$ shellcheck -S style -f gcc examples/rename-photos.sh | wc -l
12
```

Read the ladder as a series of editorial
decisions about the same script. At
**error**, only the two findings that are
simply wrong remain — the `ls` loop and the
split `$@`. At **warning**, the unguarded
`cd` joins them: three findings, each one a
named way the script breaks. **Info** adds
the five quoting findings — correct today,
fragile tomorrow. **Style** (the default
when no `-S` is given) adds the backticks
and the `expr`: housekeeping. Nothing about
the script changes between runs; what
changes is how much of the truth you asked
for.

## What a rung can hide

The flag sets a floor for the whole run,
and floors hide things unevenly. The log
trimmer's worst findings are warnings, so
at the error rung it passes outright:

```
$ shellcheck -S error examples/trim-logs.sh
[exit 0]
```

That silence is *accurate* — the trimmer has
no errors — and incomplete: the unguarded
`cd` that could trim the wrong directory is
still in it, one rung down. This is the
honest way to think about `-S`: not "how
strict is the tool" but "which class of
surprise am I choosing to live with, for
this codebase, today." A run at `-S error`
is a statement that errors are unlivable
and warnings are, for now, tolerated —
which is sometimes the right statement, as
long as it is made on purpose.

## Adopting ShellCheck on a real pile

Nobody's first run is on a tidy lab. It is
on a folder of scripts that have run for
years, and the full report is a hundred
findings long. The ladder is how you adopt
the tool without either fixing everything
this afternoon or giving up:

1. **Run at `-S error` and fix those.**
   Errors are few, they are the most likely
   to be live bugs, and the set is small
   enough to finish.
2. **Make that rung the gate.** Chapter 11
   builds gates from exit codes; a gate at
   the rung you have already reached can
   never go red behind your back.
3. **Ratchet.** When warnings are fixed,
   move the gate to `-S warning`. Each rung
   you hold becomes a property the codebase
   keeps, instead of a cleanup it remembers.

What not to do is reach for `-S` as a
volume knob to make a noisy run quiet.
The quiet it sells you is real findings,
unreported — the trimmer's `cd`, waiting.
If a *specific* finding should not be
reported, that is a different instrument
entirely — an exclusion, aimed at one code
or one line, with a reason attached. That
is chapter 10.
