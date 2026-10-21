# Tests That Lie

**Scope:** the `[ ... ]` family — three
findings where a test does not test what it
says: **SC2070**, the unquoted `-n`;
**SC2071**, the `>` that is not a
comparison; and the string-versus-number
trap that joins them.

## -n with nothing to hold: SC2070

```
if [ -n $name ]; then
        ^---^ SC2070 (error): -n doesn't work with unquoted arguments. Quote or use [[ ]].
```

`-n` asks "is this string non-empty?" Hand
it an unquoted variable and the question
changes with the value. If `name` is empty,
the expansion vanishes and the test becomes
`[ -n ]` — a one-argument test, which asks
"is the string `-n` non-empty?" It is. The
test is **always true** exactly when it was
written to sometimes be false. If `name`
holds two words, the test becomes three
arguments and `test` complains or guesses.
This one is graded **error**, and quoting
repairs it completely: `[ -n "$name" ]`
asks the intended question at every value,
including the empty one. (Its twin `-z`,
"is empty", has the mirror-image failure
and the same fix.)

## The comparison that is a redirection: SC2071

The disk alerter's second test is the
single most dangerous line in the lab:

```
if [ $use > $limit ]; then
          ^-- SC2071 (error): > is for string comparisons. Use -gt instead.
```

Inside `[ ... ]`, `>` is not an operator at
all — the **shell** gets it first, before
`test` runs, and treats it as output
redirection. The line becomes "run the test
`[ $use ]`, sending any output to a file
named by `$limit`." A one-argument test is
true whenever the value is non-empty — so
the branch fires unconditionally, and it
leaves litter. Both halves are in the
capture (transcript t07), run against a
filesystem that was 11% full:

```
$ printf '/\n' | bash disk-alert.sh
Over the limit: 11 percent used on /
$ ls
90
disk-alert.sh
```

"Over the limit: 11 percent" — and a new,
empty file named `90`, the limit's value,
sitting in the directory as the
redirection's receipt. Every run of the
script did this. Nobody noticed, because
nothing crashed; the test just lied,
politely, forever. Numbers inside
`[ ... ]` are compared with the arithmetic
operators the `test` command provides:
`-eq`, `-ne`, `-gt`, `-ge`, `-lt`, `-le`.
The fixed twin uses them:

```
if [ "$use" -gt "$limit" ]; then
```

## ==, and strings wearing numbers

The alerter's first test, `[ $use == $limit ]`,
drew only quoting complaints in bash — `==`
inside `[ ... ]` *is* legal there, as a
**string** comparison. That is the trap in
its mildest form: `"11" == "90"` is false
and `"90" == "90"` is true, so an equality
check *seems* to work while comparing text,
not quantities. (Judged as POSIX `sh`, the
same line also draws **SC3014** — in
portable shell, `=` is the only spelling;
chapter 8 returns to that.)

The string trap has teeth in `[[ ... ]]`,
where `>` really is a comparison — of
strings. The lab's `tests.sh` asks whether
the count is more than two, and here are
both versions answering for a count of 10
(transcript t08):

```
$ bash examples/tests.sh bob 10
Name given
$ bash examples/tests-fixed.sh bob 10
Name given
More than two
```

`[[ 10 > 2 ]]` compares character by
character, and `1` sorts before `2`, so the
test says 10 is *not* more than 2 — no
error, no warning at runtime, just the
wrong answer. Inside `[[ ... ]]`, numbers
still want the arithmetic operators
(`-gt`, as the fixed twin uses), or the
arithmetic test itself: `(( count > 2 ))`.

## Choosing between [ and [[

Both are legitimate; they are not
interchangeable.

| | `[ ... ]` | `[[ ... ]]` |
|---|---|---|
| Shells | Everywhere, incl. POSIX `sh` | bash, ksh, zsh — not portable `sh` |
| Word splitting | Happens — quote everything | Does not happen inside |
| Comparisons | `-eq`/`-gt` for numbers, `=` for strings | Same operators for numbers; `<`/`>` compare strings; `==` also matches *patterns* |
| Combining | `-a`, `-o` (best avoided) | `&&`, `||`, readable and safe |

The working rule the lab lands on: write
`[ ... ]` when the script promises to be
portable, quote every expansion inside it,
and use the `-` operators for numbers.
Write `[[ ... ]]` when the script is
honestly bash — the quoting traps relax,
but the string-versus-number trap does not,
because it was never about quoting. It was
about saying which kind of comparison you
mean.
