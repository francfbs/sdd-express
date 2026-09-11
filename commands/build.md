---
description: Implement tasks — the next one, a specific one, or continuously until something needs you
argument-hint: "[T3 | all | through T5]"
---

Read the `sdd-protocol` skill first. Follow it exactly.

## 1. Gate

Read `.sdd/ACTIVE`, `progress.md`, `spec.md`, `tasks.md`.

- Phase is not `building` → say what phase it is in and which command applies. Stop.
- A task is already `in-progress` → report it and finish that one first, unless
  the user names a different task.

## 2. Read the mode from `$ARGUMENTS`

| Argument | Mode |
|---|---|
| *(empty)* | **single** — the next ready task, then stop |
| `T3` | **single** — that specific task |
| `all` | **continuous** — keep going until done or until something needs the user |
| `through T5` | **continuous** — up to and including T5, then stop |

For a specific task ID whose dependencies are not all `done`, say so and ask
before proceeding.

**Before starting continuous mode**, tell the user how many tasks are in scope
and ask once whether to commit after each task — then honour that answer for the
whole run without asking again. Per-task commits are what make a long run
reviewable afterwards.

## 3. The task loop

For each task, in dependency order, take the first `todo` whose dependencies are
all `done`:

### 3a. Claim it

Mark it `in-progress` in `tasks.md` and `progress.md` **before starting**. If the
session dies mid-task, that mark is what tells the next session where it was.

### 3b. Implement

Read the task, its acceptance criterion, and the spec sections it satisfies.
Read the code around where it lands and follow the conventions in force —
`CLAUDE.md` first, then the neighbouring code.

- **Stay inside the task.** Anything else you notice becomes a new task in
  `tasks.md`, not a drive-by fix. Drive-by fixes make the diff unreviewable and
  the ledger a lie.
- **Verify before claiming anything.** Run the project's tests, type check and
  linter. If the criterion says a test should fail before the change, confirm
  that it would have.

### 3c. Review the diff

Dispatch `sddx:sdd-qa-engineer` on the diff with the task, its acceptance criterion,
and its review file path (`reviews/qa-<task-id>.md`).

Dispatch `sddx:sdd-security-reviewer` **in the same message** if the task touches
auth, permissions, personal or regulated data, payments, upload, or an untrusted
input path.

Fix what they find that is real. If you disagree with a finding, say why rather
than silently ignoring it.

### 3d. Record

Decide the status honestly:

- **`done`** — the acceptance criterion passes, verified by something you ran.
  Not "the code looks right".
- **`in-progress`** — works but unverified. Say what is unverified and why.
- **`blocked`** — say precisely what it is waiting on.

Update `tasks.md`, the `progress.md` table, and the decision log. Set `updated:`.
Commit if the user opted into per-task commits, with the task ID in the message.

### 3e. Continue or stop

In **single** mode, stop here and report.

In **continuous** mode, go to the next ready task — unless one of the stop
conditions below has fired.

## 4. When continuous mode stops

Continuous mode is not "run unattended until it breaks". It runs until it
reaches something a person should see, and stopping is a success, not a failure.
**Stop and report** on any of these:

1. **The task was wrong.** What you found in the code contradicts the spec. Do
   not implement something other than what the spec says — propose the amendment
   and let the user decide.
2. **QA or security found something you cannot confidently fix.** A blocking
   finding, or a fix that would change behaviour the spec defines.
3. **A task is blocked**, or every remaining task depends on one that is.
4. **The project's checks fail for a reason that is not this task** — a
   pre-existing break, a flaky suite, an environment problem.
5. **A decision only the user can make** appeared — a trade-off, an ambiguity,
   a choice between two defensible designs.
6. **You have marked two tasks `in-progress` rather than `done`.** Unverified
   work is compounding; a person should look before it goes further.
7. **You reached the `through` target.**

When you stop, say which condition fired, what state the work is in, and the
single next action. Never carry on past one of these because the remaining
tasks look easy.

## 5. Report

**Single mode:** what changed, what you ran and what it said, what QA found,
what is next.

**Continuous mode:** keep it tight — a per-task line (ID, title, status, one
clause on what it did), then the checks you ran at the end, then anything QA or
security raised that you acted on. Do not narrate each task at length; the user
wants the shape of the run and the exceptions.

Either way, end with the next command. If every task is `done` or `dropped`,
tick the `building` gate, set phase to `validation`, and point at `/sddx:qa`.

## On not parallelising

Tasks run one at a time even when their dependencies would allow otherwise.
This is deliberate: parallel implementers conflict on the same files, arrive
without the project context this session has built up, and produce a combined
diff nobody can review. Reviews are parallelised instead, where the isolation
helps rather than hurts.
