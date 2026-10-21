# Guards and Leftovers

**Scope:** three findings about what happens
when a step fails or a line is dead —
**SC2164**, the unguarded `cd`; **SC2162**,
`read` without `-r`; and **SC2034**, the
variable nothing uses.

## The cd that fails quietly: SC2164

Both the renamer and the log trimmer open
with the same move, and draw the same
warning:

```
cd $logdir
^--------^ SC2164 (warning): Use 'cd ... || exit' or 'cd ... || return' in case cd fails.

Did you mean: 
cd $logdir || exit
```

The failure this guards against is easy to
miss because `cd` *failing* does not look
like anything. If the folder is missing,
renamed, or unmounted, `cd` prints an error
to stderr and returns a failure code — and
then the script **keeps going, in the
directory it was already in**. The trimmer
would then trim "the logs" in whatever
directory it happened to be launched from.
The renamer would rename the *caller's*
photos. Nobody notices until the wrong
files are shorter.

The repair states the intent: if we cannot
be in the place this script works on, there
is nothing sensible left to do.

```
cd "$logdir" || exit 1
```

(Inside a function, the same shape is
`|| return` — ShellCheck's message names
both.) A related habit you will see in the
wild is starting scripts with `set -e`, so
any failing command ends the run. That is a
broader contract with its own surprises —
commands in conditions stop failing loudly,
and some failures are still ignored — and
it is a design decision for the whole
script, not a per-line repair. The `||`
guard says exactly one thing, exactly
where it matters, which is why the checker
suggests it.

## read and the backslash: SC2162

The disk alerter asks its question with
`read`, and hears about it:

```
read -p "Filesystem to check [/]: " fs
^--^ SC2162 (info): read without -r will mangle backslashes.
```

Without `-r`, `read` treats a backslash in
the input as an escape: it swallows the
backslash and, at the end of a line, reads
a trailing `\` as "the input continues."
Type the path `/mnt/back\` and the variable
receives something that is not what you
typed. Paths are exactly the kind of input
that grows backslashes (Windows shares,
escaped spaces), so the alerter's question
is precisely the wrong place to mangle
them. The repair is one word:

```
read -r -p "Filesystem to check [/]: " fs
```

Make `read -r` the reflex and plain `read`
the deliberate exception — the input where
you *want* escape processing is rare enough
to deserve a second thought when it comes.

## The variable nothing uses: SC2034

```
speed=fast
^---^ SC2034 (warning): speed appears unused. Verify use (or export if used externally).
```

The backup script set a `speed` it never
read; the trimmer set a `scratch` folder it
never used. ShellCheck grades this a
**warning**, because a dead assignment is
rarely just clutter — it is usually a
symptom. The variable was renamed elsewhere
and this is the leftover. The feature it was
meant to drive was never finished. The name
is misspelled in one of its two places, and
the script has been quietly running a
default ever since. The message's own
wording — *verify use* — is the right
response: find out which story is true,
then delete the line or finish the feature.

The honest exception is in the message too:
*(or export if used externally)*. A
variable can be dead in its own file and
alive in the system — set for a child
process, a sourced file, or a framework to
read. The lab's `config-fragment.sh` is
exactly that case, and there the correct
response is not deletion but a recorded
exception, which is chapter 10's whole
subject. Learn to tell the two apart:
leftovers get deleted, interfaces get
documented. What neither gets is ignored.
