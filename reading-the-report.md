# Reading the Report

**Scope:** the anatomy of a ShellCheck
report — where it points, what the numbers
mean, how it grades what it finds — and the
working rhythm of check, fix, check again.

## One finding, taken apart

Here is the first specimen, a photo renamer
written in a hurry (`examples/rename-photos.sh`):

```bash
#!/bin/bash
# Rename every .JPG photo in a folder to IMG-<date>-<number>.jpg
# Written in a hurry. It works — on filenames without spaces.
dir=$1
cd $dir
n=1
for f in `ls *.JPG`
do
  newname=IMG-`date +%Y%m%d`-$n.jpg
  mv $f $newname
  n=`expr $n + 1`
done
echo All done: $@
```

And here is the top of its report:

```
$ shellcheck examples/rename-photos.sh

In examples/rename-photos.sh line 5:
cd $dir
^-----^ SC2164 (warning): Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
   ^--^ SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean: 
cd "$dir" || exit
```

Every finding has the same five parts:

1. **Where.** The file and the line number,
   then the line itself, quoted verbatim.
2. **The carets.** `^-----^` underlines the
   exact span ShellCheck is talking about —
   the whole command for one finding, just
   the variable for the next. Two findings
   on one line is normal; they are separate
   complaints with separate spans.
3. **The code.** **SC2164**, **SC2086**. The
   number is the finding's permanent name.
   It never gets reused for a different
   problem, so a code you learn today means
   the same thing in every future script.
4. **The severity**, in brackets after the
   code — here *warning* and *info*.
   ShellCheck grades every check as
   **error**, **warning**, **info**, or
   **style**. Errors are things that are
   wrong or very likely to break; warnings
   are traps that bite under the right
   conditions; info is "this works, until
   the input changes"; style is housekeeping
   — not wrong, but the old way of writing
   it. Chapter 9 is about acting on the
   grades.
5. **The message**, one sentence saying what
   it found and usually what to do instead.

Then, often, a sixth part: **Did you mean** —
ShellCheck's own suggested rewrite of the
line. It is genuinely useful, and it is
mechanical. It fixes the line it is looking
at, in the way it prefers; whether that fix
is the whole repair is your judgement to
make. Chapter 3 watches a case where the
suggested quote is right but only half the
story.

## The footer is a reading list

After the last finding, ShellCheck prints
links for the codes it used:

```
For more information:
  https://www.shellcheck.net/wiki/SC2045 -- Iterating over ls output is fragi...
  https://www.shellcheck.net/wiki/SC2068 -- Double quote array expansions to ...
  https://www.shellcheck.net/wiki/SC2164 -- Use 'cd ... || exit' or 'cd ... |...
```

The wiki page behind each code is the
check's full documentation: what the pattern
is, why it breaks, an example of the problem
and of the correction, and — worth knowing
— the cases the page calls *correct*, where
the pattern is fine and the warning can be
set aside with understanding. This guide
teaches the checks the lab springs; the
wiki is the reference for the other several
hundred, and every chapter leans on it
rather than paraphrasing it wholesale.

## The whole report, and the rhythm

The renamer's full report runs to twelve
findings across six lines of code (the full
capture is transcript t02 in
`shellcheck-lab/transcripts/`). Read top to
bottom, they are a fair review of the
script: an unguarded `cd`, a loop over `ls`
output, unquoted variables throughout,
backticks three times, and a split `$@` at
the end. Nothing in it is a syntax error —
the script *runs*. That is the point of the
tool: these are the faults a run would only
reveal on the wrong day, with the wrong
filename.

The working rhythm is a loop:

1. Run ShellCheck on the file.
2. Fix the findings you understand; look up
   the ones you don't, in the wiki, by code.
3. Run it again. Silence — and exit 0 — is
   the finish line.

```
$ shellcheck examples/rename-photos.sh
[exit 1]
$ shellcheck examples/rename-photos-fixed.sh
[exit 0]
```

You can also check several files in one
command — ShellCheck works through them in
order and the exit code is 1 if *any* of
them has findings. Chapter 11 uses that to
build a gate. And a small thing that will
save you a confused minute someday: if you
name a file that does not exist, ShellCheck
says so and exits 1, the same code as for
findings. Read the words, not just the
number.
