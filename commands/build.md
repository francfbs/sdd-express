---
description: Implement tasks — the next one, a specific one, or continuously until something needs you
argument-hint: "[T3 | all | through T5]"
---

Read the `sdd-protocol` skill — the core only. You need its `panel.md` at a
checkpoint, not before.

**You are the orchestrator, not the implementer.** Each task goes to a fresh
`sddx:sdd-implementer` subagent, so this conversation holds only short reports
and stays small however long the run is. Implementing in this conversation
would make task eight pay again for everything tasks one to seven read.

## 1. Gate

Read `.sdd/ACTIVE` and the `progress.md` header. For task state, read only the
headings and status lines: `grep -nE '^### T|status:' tasks.md`.

- Phase is not `building` → say which phase and which command applies. Stop.
- A task is `in-progress` → resume it (dispatch with **resume**), unless the user
  named a different one.
- `context.md` is missing, or has no targeted check command → a feature planned
  before this workflow. Write or complete it once now, per `artifacts.md`, then
  continue. Every implementer depends on it.

## 2. Mode

| Argument | Mode |
|---|---|
| *(empty)* | **single** — the next ready task, then stop |
| `T3` | **single** — that task |
| `all` | **continuous** — until done or until something needs the user |
| `through T5` | **continuous** — up to and including T5 |

A named task with unfinished dependencies: say so and ask first.

Before a continuous run, say how many tasks are in scope and ask once whether to
commit per task. Honour the answer for the whole run.

## 3. The loop

Take the first `todo` task whose dependencies are all `done`.

### 3a. Claim

Set its status to `in-progress` in `tasks.md` and `updated:` in `progress.md`,
before dispatching. If the session dies, that mark is where the next one resumes.

### 3b. Dispatch

One `sddx:sdd-implementer`, in the foreground. The prompt is the slug, the task
ID, and `resume` or a finding to fix when those apply. **Nothing else** — do not
paste the task, the criteria or the briefing. It reads them itself, in slices.

### 3c. Record

From the report:

- Run `git diff --stat` and check that `changed:` matches. A report whose files
  did not move is not `done`, whatever it says.
- `done` → status `done`. `unverified` → stays `in-progress`; say what is
  unverified. `blocked` → `blocked`, with what it waits on. `needs-decision` →
  a stop condition.
- Decision log: only when something was actually decided. A task finishing is
  not a decision — its status already says so.
- Commit if the user opted in, with the task ID in the message.

**Do not read the diff yourself.** That is what the checkpoint is for, and
reading every diff here would bring back the cost this design removes.

### 3d. Checkpoint

Review is batched, not skipped. A checkpoint fires when:

- the tasks `done` since the last checkpoint reach the size cadence — `standard`
  every 3, `deep` every 2, `express` only at the end
- a report said `sensitive: yes` — checkpoint now, before building on top of it
- the run is about to stop, for any reason, with unreviewed `done` tasks
- the feature's last task is `done`

The last checkpoint is the most recent `checkpoint` line in the decision log.

At a checkpoint:

1. Read `panel.md`.
2. Run the **full** check from `context.md` once, output reduced to failures and
   the summary line.
3. Dispatch the checkpoint seats in one message, each with: the slug, the task
   IDs in the batch, the diff command — `git diff <base> -- <changed paths>`,
   where `<base>` is the commit at the last checkpoint if committing per task,
   otherwise `HEAD` — the full-check result in one line, and the review path
   `reviews/<persona>-checkpoint-<last task ID>.md`.
4. Real findings → set that task back to `in-progress` and re-dispatch the
   implementer with the finding. A finding you disagree with: say why.
5. Append one line to the decision log:
   `checkpoint T4–T6: <verdict>, <n> findings fixed`.

### 3e. Continue or stop

**Single** mode: stop and report. **Continuous**: take the next ready task,
unless a stop condition fired.

## 4. When continuous mode stops

Stopping is the feature working. **Stop and report** when:

1. **The task was wrong** — an implementer reported `needs-decision`, or the code
   contradicts the spec. Propose the amendment; the user decides.
2. **A checkpoint found something you cannot confidently fix** — a blocking
   finding, or a fix that would change behaviour the spec defines.
3. **A task is blocked**, or everything remaining depends on one that is.
4. **Checks fail for a reason that is not this feature** — a pre-existing break,
   a flaky suite, the environment.
5. **A decision only the user can make** appeared.
6. **Two tasks are `in-progress` rather than `done`.** Unverified work is
   compounding.
7. **You reached the `through` target.**

Run the pending checkpoint before stopping. Then say which condition fired, the
state of the work, and the single next action. Never carry on past one of these
because the remaining tasks look easy.

## 5. Report

**Single:** what changed, the check result, what is next.

**Continuous:** one line per task — ID, title, status, a clause on what it did —
then each checkpoint's verdict and what it fixed. The shape of the run and its
exceptions, not a narration.

End with the next command. When every task is `done` or `dropped`, tick the
`building` gate, set phase to `validation`, and point at `/sddx:qa` — after a
`/clear`, since the ledger carries it all.

## On not parallelising

Implementers run one at a time, always. A fresh context per task is not
parallelism: nothing else is editing the tree while it works, and the briefing
in `context.md` — extended by every task before it — gives it the project
context that a shared conversation used to carry at far greater cost.
