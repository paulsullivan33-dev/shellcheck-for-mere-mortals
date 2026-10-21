# Writing Criteria

Every guide in this repo is written to the same
standard. If you're adding or editing a guide —
human or AI — hold it to these.

1. **Plain words, real ideas.** Simple language,
   never dumbed-down concepts. Explain jargon on
   first use; collect terms in the glossary.
2. **No hype.** No marketing adjectives, no
   "revolutionary," no promises about what
   something will do for the reader.
3. **Honest about limits.** Say what the thing
   *can't* do. State uncertainty instead of
   smoothing it over. Validation notes include
   what remains unverified.
4. **No invented numbers.** Benchmarks, defaults,
   and specs are either measured or qualified with
   "depends on your setup." If it wasn't tested,
   say so.
5. **Checkable.** Commands are meant to be run,
   with "Check:" blocks showing what success looks
   like. Sources are linked, not asserted.
6. **Respect the reader's setup.** Call out
   Windows/Mac/Linux differences. Don't assume a
   GPU, a budget, or prior experience.
7. **Safety isn't skipped.** Real risks get
   stated plainly, not buried.
8. **Scoped.** Each guide says what it covers and
   points elsewhere for the rest. No guide
   pretends to be the whole subject.
9. **Structure over prose.** Tables, before/after
   examples, symptom → fix. Scannable beats essay.

## Verification notes for this guide

Standard 3 and 4 applied to this guide,
specifically. The build machine ran Ubuntu
with **ShellCheck 0.10.0** — the official
static binary from the project's GitHub
releases (koalaman/shellcheck,
linux.x86_64) — under GNU bash 5.2.21,
which was used only to *run* specimens,
never to judge them. Every quoted report
in the chapters is a capture from that
binary, run against the lab in
`examples/`. Working transcripts are kept
with the build
(`shellcheck-lab/transcripts/`, t01–t17).

**The lab.** Fourteen scripts in
`examples/`, described in
`examples/lab-notes.txt`: six scripts with
planted faults (a photo renamer, a backup,
a log trimmer, a disk alerter, an argument
demonstrator, a set of test idioms), their
six corrected twins, one script of bash
habits under an `sh` shebang
(`portable.sh`), a sourced settings
fragment with its directives, the script
that sources it, and one six-line clean
script. Every fixed twin and the clean
script pass ShellCheck with exit 0 at
default severity; that was re-verified as
a set in the gate run (transcript t15).
Three further fixtures live in
`shellcheck-lab/fixtures/` because the
chapters make them: a directive-less
fragment, a three-line directive specimen,
and an `if` with no `fi`. Two specimens
also appear under working names with no
`.sh` extension in
`shellcheck-lab/fixtures/bin/`.

**Verified by running, per chapter:**

- *Ch. 1:* `--version` (0.10.0, quoted
  verbatim); silence and exit 0 on
  `clean.sh` and on `backup-fixed.sh`
  (t01).
- *Ch. 2:* the full report on
  `rename-photos.sh` — twelve findings,
  six lines, exit 1 (t02); the anatomy
  quoted in the chapter is its first two
  findings, untrimmed.
- *Ch. 3:* SC2086 and SC2046 in place (t02,
  t03); the runtime proof in full (t06):
  the buggy renamer run against
  `IMG 2041.JPG`, `IMG 2042.JPG`, and
  `plain.JPG` split both spaced names,
  renamed one file in three (as
  `IMG-20261021-5.jpg` — the date is the
  build machine's clock), reported "All
  done", and exited 0; the fixed twin
  renamed all three in order. The claim
  that an assignment's right-hand side and
  a provably numeric variable draw no
  SC2086 is read off the captures:
  `count=$n + 1`-style lines and
  `tail -n $keep` (with `keep=500` above
  it) appear in specimens and in no
  finding.
- *Ch. 4:* SC2048 and SC2068 on
  `args.sh` (t05), and the runtime proof:
  both scripts given `"my photo.jpg"` as
  one argument — the buggy loops see three
  items, the `"$@"` loop sees two.
- *Ch. 5:* SC2006 on every backticked
  specimen (t02–t04); SC2003 on the
  renamer's `expr`; SC2045 on the `ls`
  loop; SC2002 on the backup's `cat`
  pipeline. The nuance that SC2002 stays
  silent for an *unquoted* filename was
  measured in probes before it was
  written: a matrix of `cat` argument
  shapes (literal, `"$1"`, `"$report"`,
  `$report`, `$dir/file`, `${list}`, two
  variables) was run, and the check fired
  only where its argument was a literal or
  a quoted expansion. One probe result is
  quoted nowhere in the chapters: with the
  filename unquoted, SC2086 fires and
  SC2002 does not, on the same line.
- *Ch. 6:* SC2164 on both unguarded `cd`s
  (t02, t04); SC2162 on the alerter's
  `read` (t07); SC2034 on `speed` (t03)
  and `scratch` (t04).
- *Ch. 7:* SC2070 on `[ -n $name ]` and
  SC2071 on both `>` tests (t07, t08);
  the runtime evidence in full: the buggy
  alerter, fed `/` on a filesystem the
  capture's own output reports at 11%,
  printed "Over the limit: 11 percent used
  on /" and created an empty file named
  `90` in its working directory (t07).
  And `tests.sh bob 10` prints no "More
  than two" while `tests-fixed.sh bob 10`
  does (t08) — the string comparison,
  caught in the act.
- *Ch. 8:* `portable.sh` judged as written
  (shebang `sh`): SC3010, SC3030, SC3054,
  SC3028 (t09); the same file under
  `-s bash`: silence, exit 0 (t09).
  `tests.sh` under `-s sh`: SC3014 and
  SC3010 join its bash findings (t08).
  SC2148 on a shebang-less file (t12) and
  on stdin (t17).
- *Ch. 9:* the severity ladder on the
  renamer, counted in gcc format: error 2,
  warning 3, info 8, style 12 (t10); and
  `-S error` on `trim-logs.sh` exiting 0,
  its worst findings being warnings (t10).
- *Ch. 10:* `-e SC2086` and
  `-e SC2086,SC2006` on the renamer, gcc
  format, exit still 1 (t11); the fragment
  without directives — SC2148 and two
  SC2034s — against the shipped fragment's
  silence (t12); a one-line `disable=`
  silencing SC2164 while SC2086 on the
  same line still speaks (t12); SC1091 on
  `uses-config.sh` and its absence under
  `-x` (t12); `.shellcheckrc` in a scratch
  directory changing verdicts twice —
  `disable=SC2086` removing the quoting
  findings, `shell=sh` rejudging the file
  into SC3014/SC3010 territory (t13).
- *Ch. 11:* gcc format on `backup.sh`,
  json on `trim-logs.sh` (the `fix`
  objects are the tool's own; the chapter
  quotes one finding, declared), diff
  format on `disk-alert.sh` (t14); the
  gate at `-S warning` over the seven
  buggy specimens — seventeen findings,
  exit 1 — and over the nine sound files —
  silence, exit 0 (t15); the pre-commit
  hook in a scratch git repository
  refusing `trim-logs.sh` (exit 1, the
  hook's own captured output) and
  accepting `trim-logs-fixed.sh`
  (root-commit 857c022 in the demo repo,
  t15). The demo's first attempt is also
  recorded here, because the chapter
  teaches from it: a refused file stays
  staged and joins the next commit's
  check, which is why the captured
  sequence includes `git reset -q`.
- *Ch. 12:* extension-less specimens
  judged by their shebangs (t17); a
  one-line fragment checked on stdin, with
  and without `-s bash` (t17, the second
  run captured, not inferred).
- *Ch. 13:* `bash -n` passing
  `disk-alert.sh` (exit 0) and failing the
  unparseable fixture (exit 2), with
  ShellCheck's parse errors on the same
  fixture (SC1046, SC1047, SC1072, SC1073)
  (t16).

**Capture hygiene (declared trims):**
chapter 2 quotes the first two findings of
a twelve-finding report and says so; the
full report is t02. Chapter 10 quotes the
renamer's `-e` run with its style findings
cut and says so (full run, t11). Chapter
11 quotes five of the gate's seventeen
findings and five of the gcc run's eight,
saying so in place (full runs, t14, t15);
its json extract is one of eight findings,
line-broken for print and declared.
Transcript command lines render an
argument containing a space with its
quotes restored (`"my photo.jpg"`), so a
reader retyping a command gets the run
that was captured; no output line in any
transcript was altered.

**Build-machine weather, stated once:** the
runtime captures ran on the build
machine's own filesystem: the 11% figure
in chapter 7 and the 2026-10-21 date in
chapter 3's filenames are that machine on
that day, quoted as captured. The overlay
filesystem's group and permission habits,
noted in sibling guides, affect nothing
here — ShellCheck reads file contents,
not metadata.

**Documented-only (not run), and why:**

- *Editor integration and shellcheck.net:*
  an editor session and a browser cannot
  be captured from this build; chapter 13
  names them, places them, and quotes no
  output from either.
- *shfmt:* not installed on the build
  machine — its absence is captured
  (`command -v shfmt`, exit 1, t16) and
  chapter 13 describes its role from its
  documentation. Nothing about its output
  is quoted.
- *Windows and macOS as hosts:* the binary
  is one static program and the verdicts
  in the captures are its, but no Windows
  or macOS machine was available to the
  build. Chapter 1's platform remarks are
  the project's documented position;
  WSL is named, not exercised.
- *Installation* on a reader's machine is
  described, not performed, beyond the
  build's own use of the official release
  binary. Package-manager routes (apt,
  brew, and friends) are the project's
  documented ones.
- *ksh and dash as judged dialects:*
  named and placed in chapter 8 from the
  documentation. Every dialect verdict
  actually captured is bash or sh; no
  capture claims a dash or ksh run.
- *The `source=` directive and `--enable`
  optional checks:* named in chapters 10
  and 12 as instruments; the captures
  exercise `disable=`, `shell=`, `-x`, and
  the rc file, and no optional check is
  quoted.

Specimen discipline, for the record: every
script in the lab is invented for this
guide; the folders, drives, and thresholds
in them (`/mnt/backupdrive`, a 90% limit,
a documents folder) are nobody's real
configuration. The buggy specimens were
run for real only inside scratch
directories in the build area, against
invented files; the one side effect that
escaped a specimen — the empty file named
`90` — was created inside its scratch
directory, is the subject of its own
transcript, and was removed with the
scratch. No command in the guide was aimed
at a real system file except the read-only
examples stated as audits, which are shown
as commands to adapt, not transcripts.
