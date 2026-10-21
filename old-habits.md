# Old Habits

**Scope:** four findings that are not about
bugs waiting to happen but about idioms the
shell has outgrown — backticks (**SC2006**),
`expr` (**SC2003**), the useless `cat`
(**SC2002**), and looping over `ls`
(**SC2045**) — and why each replacement is
better, not just newer.

## Backticks: SC2006

The oldest specimens in the lab were dated
with backticks, and ShellCheck answered
every single one the same way:

```
stamp=`date +%F`
      ^--------^ SC2006 (style): Use $(...) notation instead of legacy backticks `...`.
```

Graded **style**, and worth fixing anyway,
for three reasons that are practical rather
than aesthetic. `$(...)` **nests** — a
substitution inside a substitution is just
more of the same syntax, where nested
backticks need backslash escapes that rot
quickly. `$(...)` is **readable at a
glance**: the opening `$(` and closing `)`
bracket the command like parentheses, where
a closing backtick is one small slanted
mark that tired eyes slide off. And inside
`$(...)`, quoting behaves the way chapter 3
taught you to expect — inside backticks,
quotes and backslashes follow older, stranger
rules. The repair is always mechanical:

```
stamp=$(date +%F)
```

## expr: SC2003

The renamer counted with `expr`, a program
from the era before shells could do their
own arithmetic:

```
  n=`expr $n + 1`
    ^-----------^ SC2006 (style): Use $(...) notation instead of legacy backticks `...`.
     ^--^ SC2003 (style): expr is antiquated. Consider rewriting this using $((..)), ${} or [[ ]].
```

The shell's own arithmetic expansion is
clearer, needs no separate process, and
keeps the variables bare — inside `$((...))`
names need no `$` and no quotes:

```
  n=$((n + 1))
```

## The useless cat: SC2002

The backup script counted the lines of its
packing list like this:

```
cat "$dst/$stamp/documents/list.txt" | wc -l
    ^-- SC2002 (style): Useless cat. Consider 'cmd < file | ..' or 'cmd file | ..' instead.
```

`cat`'s job here is to hand a file to
another program's standard input — a job
the shell's redirection does without
starting a process at all. Either form is
the correction; the lab's fixed twin uses
the first:

```
wc -l < "$dst/$stamp/documents/list.txt"
```

One honest subtlety, found while building
this lab: SC2002 speaks only when it is
**sure**. Fed the same pipeline with the
filename *unquoted* — `cat $dst/$stamp/...`
— ShellCheck reported the quoting problem
(SC2086) but stayed silent about the cat,
because an unquoted expansion can split
into several words, and `cat` with several
files is doing real work. A check that
declines to guess is a feature; it is also
a reminder that silence on one line is not
a verdict on the line.

## Looping over ls: SC2045

The renamer's loop is the chapter's one
**error**:

```
for f in `ls *.JPG`
         ^--------^ SC2045 (error): Iterating over ls output is fragile. Use globs.
```

`ls` output is a *display* — names with
spaces, newlines, or pattern characters
come back ambiguous, and the loop then
splits them further still (chapter 3's
runtime wreckage started exactly here).
The shell already has the tool for
enumerating files, and it hands each name
over intact: the glob itself.

```
for f in ./*.JPG
```

The `./` prefix earns its place: a file
named `-rf.JPG` would otherwise reach `mv`
looking like a bundle of options. (That is
its own check, **SC2035**, which the same
line of the original drew.) One honest
limit of the glob form: if nothing matches,
bash leaves the pattern itself as the word,
and the loop runs once on a name that does
not exist. Scripts that must handle the
empty case say so explicitly — `shopt -s
nullglob` in bash turns an unmatched glob
into no words at all — and the fixed twin
in the lab keeps to folders the caller has
already named, which is the simpler half of
that bargain.
