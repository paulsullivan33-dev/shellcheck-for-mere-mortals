# Quoting and Splitting

**Scope:** the finding you will meet more
than any other — **SC2086**, the unquoted
expansion — what word splitting actually
does, proof from a run that quoting is not
pedantry, and where quotes do *not* belong.

## The one-sentence version

When the shell expands `$dir` **unquoted**,
it takes the value and then does two more
things to it: it **splits** the value into
separate words at spaces, tabs, and
newlines, and it treats any `*`, `?`, and
`[...]` in the result as filename patterns
and replaces them with matching names. This
is **word splitting** and **globbing**, and
together they mean an unquoted variable is
not "the value" — it is "the value,
reinterpreted." Quoted — `"$dir"` — the
value passes through as exactly one word,
exactly as stored.

That is why SC2086's message is phrased the
way it is:

```
   ^--^ SC2086 (info): Double quote to prevent globbing and word splitting.
```

Note the grade: *info*, not error. Most of
the time the value has no spaces and no
pattern characters, and the unquoted form
works — ShellCheck is telling you the line
is one unusual input away from doing
something else. For a path or a filename,
that day always comes.

## Proof, not pedantry

The renamer again. Its heart is three
unquoted expansions:

```bash
cd $dir
...
  mv $f $newname
```

Here is the script run against a folder of
three photos, two of them with spaces in
their names — the fixed twin run against an
identical folder, straight after
(transcript t06):

```
$ ls photos-buggy
IMG 2041.JPG
IMG 2042.JPG
plain.JPG
$ bash rename-photos.sh photos-buggy
mv: cannot stat 'IMG': No such file or directory
mv: cannot stat '2041.JPG': No such file or directory
mv: cannot stat 'IMG': No such file or directory
mv: cannot stat '2042.JPG': No such file or directory
All done: photos-buggy
$ ls photos-buggy
IMG 2041.JPG
IMG 2042.JPG
IMG-20261021-5.jpg
$ bash rename-photos-fixed.sh photos-fixed
All done in photos-fixed
$ ls photos-fixed
IMG-20261021-1.jpg
IMG-20261021-2.jpg
IMG-20261021-3.jpg
```

Read the buggy run closely, because it is
the whole chapter in one screen. The loop
handed `mv` the name `IMG 2041.JPG`; the
unquoted `$f` split it into two words,
`IMG` and `2041.JPG`, and `mv` went looking
for both, twice over. Only `plain.JPG` —
the one name without a space — was renamed,
and it got number 5, because the counter
had already ticked past the wreckage. And
the script **exited 0 and said "All
done"**: every fault ShellCheck listed for
it was real, and not one of them stopped
the run. The fixed twin — same script,
quotes added and the other findings
repaired — renames all three, in order.

## Its sibling, SC2046

The same trap exists for command
substitution. An unquoted `$(...)` splits
and globs its output the same way, and
ShellCheck reports it as **SC2046**:

```
echo Backup finished at `date +%T`
                        ^--------^ SC2046 (warning): Quote this to prevent word splitting.
```

The repair is the same shape — quotes
around the expansion: `"$(date +%T)"`. (The
backticks themselves are a separate,
older-fashioned problem; chapter 5 takes
them.) SC2086 and SC2046 together account
for a large share of everything ShellCheck
will ever say to you, and the habit that
retires both is one line long: **expansions
that carry data get quotes.**

## Where quotes do not belong

Quoting is not "more is better," and three
unquoted forms are correct as they stand:

- **Assignments.** `count=$n + 1` never
  splits — the right-hand side of `=` is
  taken whole. (ShellCheck will not flag
  it, and neither should you.)
- **Numbers you control.** `tail -n $keep`
  in the log trimmer was *not* flagged:
  ShellCheck can see `keep=500` was assigned
  a plain number earlier in the same file,
  so there is nothing to split. It flags
  what it cannot prove safe, which is why
  the same script's `$log` — a filename from
  a glob, contents unknown — was flagged
  every time.
- **Splitting on purpose.** Occasionally a
  script *wants* a string broken into words
  — a list of options stored in one
  variable. That is a real technique with
  real sharp edges; if you use it, the
  honest way to keep the line is a directive
  with a reason, which is chapter 10's
  subject, not a habit to pick up from this
  paragraph.

And one warning in the other direction:
quotes change what a pattern means.
`"$dir"/*.JPG` quotes the directory and
leaves the glob outside, where it still
works. `"$dir/*.JPG"` quotes the star too,
and now nothing expands — the script goes
looking for a file literally named with an
asterisk in it. Quote the data; leave the
machinery outside.
