---
description: Close a finished feature — changelog, documentation updates, and move it to the archive
---

Read the `sdd-protocol` skill first. Follow it exactly.

## 1. Gate

Read `.sdd/ACTIVE` and `progress.md`.

- Phase is not `done` → say what is outstanding and which command finishes it.
  If the user wants to archive anyway — an abandoned feature, a change of
  direction — that is legitimate: ask them to confirm, then archive it with a
  decision-log entry saying it was closed unfinished and why. That record is
  worth more than the code was.

## 2. Write the closing documents

Dispatch `sddx:sdd-tech-writer` with `spec.md`, `progress.md`, `tasks.md`, the
feature's commits, and the paths to `README.md` / `CLAUDE.md` / any docs
directory. Ask it for:

- the **changelog entry**, in the project's existing format
- the **decision summary** — the two or three decisions a future maintainer
  must know, not all of them
- the **documentation deltas** — what is now untrue or missing, as exact edits

## 3. Apply

Add the changelog entry where the project keeps it. Show the user the proposed
documentation edits and apply the ones they approve — particularly `CLAUDE.md`,
since that is what shapes every future session in this repo.

Append the decision summary to the end of `progress.md` under a `## Closed`
heading, so the archived file explains itself without needing the log read in full.

## 4. Archive

Move `.sdd/features/<slug>/` to `.sdd/archive/<slug>/`. Clear `.sdd/ACTIVE`.

The archive is the point of the whole exercise: the next person to touch this
code — including you, in six months — gets the spec, the questions, the
rejected options and the reasoning. Do not delete it, and do not compress it
into a summary.

## 5. Report

One short paragraph: what shipped, where the archive is, what documentation
changed, and anything deliberately left undone that someone should pick up.

If the project uses git, offer a final commit. Do not commit unasked.
