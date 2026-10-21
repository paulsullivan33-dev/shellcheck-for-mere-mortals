# Dialects

**Scope:** the fact that ShellCheck does not
judge "shell" in the abstract — it judges a
specific dialect, chosen by the shebang or
by you — and the same file can pass in one
and fail in another.

## The portable.sh experiment

`examples/portable.sh` was written and
tested on a bash machine, then promised to
the world as portable `sh` — its first line
says so:

```sh
#!/bin/sh
# Greet the user by name. Written and tested on a bash machine,
# then promised to the world as portable sh.
name=$1
if [[ $name == admin* ]]; then
```

ShellCheck believes the shebang, and judges
it as POSIX `sh`. Four warnings, all the
same shape — *in POSIX sh, this is
undefined*:

```
In examples/portable.sh line 5:
if [[ $name == admin* ]]; then
   ^-------------------^ SC3010 (warning): In POSIX sh, [[ ]] is undefined.

In examples/portable.sh line 10:
days=(mon tue wed thu fri)
     ^-------------------^ SC3030 (warning): In POSIX sh, arrays are undefined.

In examples/portable.sh line 11:
echo "Today is ${days[0]}"
               ^--------^ SC3054 (warning): In POSIX sh, array references are undefined.

In examples/portable.sh line 12:
lucky=$((RANDOM % 10))
         ^----^ SC3028 (warning): In POSIX sh, RANDOM is undefined.
```

"Undefined" is the standard's careful word:
a real `sh` may reject the construct, may
ignore it, or may happen to support it —
and since `/bin/sh` is a different program
on different systems (dash on Debian and
Ubuntu, bash in disguise in some places,
something stricter elsewhere), a script
that leans on undefined behaviour is a
script whose behaviour depends on which
machine runs it. The author tested it where
`sh`-labelled bash habits happened to work,
and shipped the assumption.

Now the same file, judged as what it
actually is:

```
$ shellcheck -s bash examples/portable.sh
[exit 0]
```

Silence. Not one finding. Neither verdict
is ShellCheck changing its mind — it
answered two different questions. Judged as
`sh`, the file is full of constructs its
declared shell does not have. Judged as
bash, it is an ordinary, sound script whose
only fault is the lie in its first line.
The repairs are equally two: change the
**shebang** to `#!/bin/bash` and keep the
code, or keep the promise and rewrite the
four constructs portably. What you may not
do is keep both the promise and the code.

## Choosing the dialect yourself

`-s` (long form `--shell=`) overrides the
shebang, which is how the experiment above
was run, and it cuts both ways. Here is
`tests.sh` — an honest bash script — judged
as `sh` (transcript t08):

```
$ shellcheck -s sh examples/tests.sh
            ^-- SC3014 (warning): In POSIX sh, == in place of = is undefined.
   ^--------------^ SC3010 (warning): In POSIX sh, [[ ]] is undefined.
```

Two new warnings appear that the bash
verdict never raised, because in POSIX land
`==` is not a spelling and `[[ ]]` does not
exist. This is the tool for a real job:
before promising a script to a system whose
`sh` is not your shell — an init system, a
container base image, a NAS box — check it
as that system will run it:

```
$ shellcheck -s sh my-script.sh
```

And when a script has no shebang at all,
ShellCheck refuses to guess:

```
^-- SC2148 (error): Tips depend on target shell and yours is unknown. Add a shebang or a 'shell' directive.
```

That is **SC2148**, and it is an error for
a sound reason: without a declared dialect,
every other verdict would be a coin flip.
Chapter 10 shows the directive that answers
it for files that are sourced rather than
run, and so have no shebang of their own.

## The four dialects, placed

ShellCheck knows **bash**, **sh**, **dash**,
and **ksh**. In practice: bash is the
interactive Linux default and the richest;
`sh` is not a program but the portable
subset defined by POSIX, the dialect you
promise when portability is the point; dash
is a specific small shell — Debian and
Ubuntu's actual `/bin/sh` — judged as itself
with `-s dash` when that is the target;
ksh is the Korn shell, still holding
ground in older commercial Unix. The
practical rule costs one sentence: **the
shebang is a contract, ShellCheck holds
you to the one you signed, and `-s` lets
you read a different contract before you
sign it.**
