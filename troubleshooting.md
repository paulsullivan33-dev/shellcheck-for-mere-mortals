# Troubleshooting

**Scope:** the confusions that actually
occur, as symptom → cause → move. If yours
is not here, the code's wiki page
(chapter 2) is the next stop.

**Symptom: ShellCheck prints nothing at
all.**
That is a pass. Silence plus exit 0 is the
clean verdict (chapter 1). Before you
celebrate, confirm the run happened:
`echo $?` straight after, and check you
named the file you meant to — a mistyped
path also produces output, but about the
error, and it is easy to scroll past.

**Symptom: exit 1, but no findings in the
output.**
Exit 1 covers "findings" *and* "could not
do the job" — a missing file, an unreadable
one. The message says which; read the words
rather than the number (chapter 2).

**Symptom: the script passes ShellCheck
and still misbehaves.**
Expected, eventually. ShellCheck proves
things about the *text*: it cannot see
runtime data, other machines, or your
intent. The lab's own example is mild — in
bash, `[ "$use" == "$limit" ]` drew no
error, because string equality is legal
there — yet the author meant numbers, and
only the neighbouring `>` line betrayed the
confusion. A clean report retires a class
of faults, not the need to test.

**Symptom: clean on my machine, findings
on the server (or the reverse).**
Two usual causes. The **dialect**: the
server runs the script under `sh` that is
dash, your machine's habits are bash —
check as the target runs it, `shellcheck
-s sh` (chapter 8). Or the **version**: the
catalogue grows between releases, so a
newer ShellCheck can name findings an
older one had no code for. Pipelines that
care pin a version, which is why this
guide's captures all record 0.10.0.

**Symptom: my `disable=` directive does
nothing.**
Placement, almost always. A directive
applies from where it stands **downward**
(chapter 10): one typed *below* the line it
means to cover, or below the file's first
command when you wanted file-wide, is inert
for everything above it. After that, check
the spelling — `disable=SC2086`, codes
comma-separated, no spaces that matter —
and that the comment begins `# shellcheck`.

**Symptom: SC1091 will not go away.**
It is not a fault and does not clear by
fixing code: ShellCheck is reporting that
it did not follow a `source`. Name the
sourced file on the command line too, add
`-x`, or record the path with a
`# shellcheck source=` directive
(chapters 10 and 12).

**Symptom: the gate is red, but "the script
works."**
Both statements can be true; the gate is
not claiming the script failed today. It
claims the script contains a named failure
mode — the unguarded `cd`, the unquoted
filename — waiting for its input. If the
team judges a specific one acceptable, the
move is a recorded exclusion or directive
(chapter 10), not turning the gate's
severity down until the noise stops
(chapter 9).

**Symptom: it flags a file I did not
write — generated, vendored, upstream.**
Then checking it as your own is the wrong
job. Exclude the *file* in the gate command
(and let the command be the record), or
check it separately at `-S error` so a
genuine fault in it still surfaces. What
not to do is paste disables into a file
that the next upstream refresh will
overwrite.

**Symptom: the "Did you mean" fix changed
behaviour.**
The suggestions are mechanical, one line
at a time (chapter 2). Quoting is the usual
case: it preserves meaning for data, and
changes it — correctly, but visibly — for
anything that was relying on being split.
Apply suggestions line by line, re-run the
checker, and where the old behaviour was
load-bearing, re-run the *script* too.
