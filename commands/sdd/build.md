---
description: Implement the next task (or a specific one), get it reviewed, and record the result
argument-hint: "[task id, e.g. T3]"
---

Read the `sdd-protocol` skill first. Follow it exactly.

## 1. Gate

Read `.sdd/ACTIVE`, `progress.md`, `spec.md`, `tasks.md`.

- Phase is not `building` → say what phase it is in and which command applies. Stop.
- A task is already `in-progress` → report it and finish that one first, unless
  the user names a different task in `$ARGUMENTS`.

## 2. Pick the task

If `$ARGUMENTS` names a task ID, use it — but if its dependencies are not `done`,
say so and ask before proceeding.

Otherwise take the first `todo` task whose dependencies are all `done`.

If none is available, say why (all done, or everything is blocked) and stop.

Mark it `in-progress` in `tasks.md` and `progress.md` **before you start**. If
the session dies mid-task, that mark is what tells the next session where it was.

## 3. Implement

Read the task, its acceptance criterion, and the spec sections it satisfies.
Read the code around where it lands, and follow the conventions in force there —
`CLAUDE.md` first, then the neighbouring code.

Then implement it. Rules:

- **Stay inside the task.** Something else you notice that needs doing becomes a
  new task in `tasks.md`, not a drive-by fix. Drive-by fixes make the diff
  unreviewable and the progress file a lie.
- **If the task turns out to be wrong** — the spec assumed something the code
  contradicts — stop implementing. Say what you found, propose the amendment,
  and let the user decide. Amend `spec.md` and `tasks.md` together, and log it.
  Never quietly build something other than what the spec says.
- **Verify it yourself before claiming anything.** Run the project's tests,
  type check and linter. If the criterion says a test should fail before the
  change, confirm that it would have.

## 4. Review the diff

Dispatch `sdd-qa-engineer` on the diff, with the task, its acceptance criterion,
and its review file path (`reviews/qa-<task-id>.md`).

Also dispatch `sdd-security-reviewer` **in the same message**, if the task
touches auth, permissions, personal or regulated data, payments, upload, or an
untrusted input path.

Fix what they find that is real. If you disagree with a finding, say so and say
why rather than silently ignoring it — then let the user settle it.

## 5. Record

Only now decide the status:

- **`done`** — the acceptance criterion actually passes, verified by something
  you ran. Not "the code looks right".
- **`in-progress`** — it works but you could not verify it. Say what is
  unverified and why.
- **`blocked`** — say precisely what it is waiting on.

Update `tasks.md` and the `progress.md` task table. Append a decision-log entry
for anything decided along the way. Update `updated:`.

If the project uses git, offer a commit scoped to this task, with the task ID in
the message. Do not commit without being asked.

## 6. Report

Short. What changed, what you ran and what it said, what QA found, what is next.
Then either tell them to run `/sdd:build` again, or — if every task is `done` or
`dropped` — tick the `building` gate, set phase to `validation`, and tell them
to run `/sdd:qa`.
