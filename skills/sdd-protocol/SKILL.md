---
name: sdd-protocol
description: The shared contract for the sdd-express spec-driven feature workflow — where feature state lives on disk, the phase gates that govern progress, the format of every artifact (spec, questions, tasks, progress), and how to convene the expert panel. Load this before running any /sdd: command, before writing or reading any file under .sdd/features/, and whenever you need to know what phase a feature is in or what is allowed to happen next.
---

# The sdd-express protocol

This file is the single source of truth for the feature workflow. Commands and
agents both read it. If a command's instructions and this protocol disagree,
this protocol wins.

## Core principle: state lives on disk, not in context

Every fact the workflow depends on is written to a file before the turn ends.
Context gets compacted, sessions end, days pass. The files are what survive.

Never hold a decision, an open question, or a completed task only in your head.
If it matters, it is in a file.

## Language

Write every artifact in the language the user is speaking. If the user writes in
Portuguese, `spec.md` is in Portuguese. Code, identifiers, file paths and commit
messages stay in English regardless. Never announce this rule — just follow it.

## Where a feature lives

```
.sdd/
  features/
    <slug>/
      progress.md      the ledger — phase, gates, task status, decision log
      questions.md     open questions and resolved decisions with rationale
      spec.md          the contract: what gets built and how you know it works
      tasks.md         ordered, dependency-aware, each with acceptance criteria
      reviews/         one file per panel member, per round
        <persona>-r<n>.md
  archive/
    <slug>/            completed features, moved here by /sdd:archive
```

`<slug>` is kebab-case, derived from the feature name: `pix-payment`,
`patient-timeline`, `bulk-export`.

The **active feature** is whichever slug is named in `.sdd/ACTIVE`. That file
holds one line: the slug. `/sdd:new` writes it, `/sdd:archive` clears it.
If `.sdd/ACTIVE` is missing or empty, there is no active feature.

## The phases and their gates

A feature moves through five phases. Each transition has a gate. **Never skip a
gate, and never advance a phase on your own initiative** — the user runs the
command that advances it.

| Phase | Command | Gate to leave it |
|---|---|---|
| `discovery` | `/sdd:new` | Every blocking question in `questions.md` is resolved |
| `spec` | `/sdd:spec` | The user has explicitly approved `spec.md` |
| `planning` | `/sdd:plan` | Every task has a verifiable acceptance criterion and a resolved dependency order |
| `building` | `/sdd:build` | Every task is `done` or explicitly `dropped` |
| `validation` | `/sdd:qa` | Every acceptance criterion in the spec is verified against real code |

When a command is invoked for a phase the feature is not in, say so and stop.
Do not "helpfully" run the earlier phase. Tell the user which command to run.

The one exception: `/sdd:qa` may be run at any time after `planning` as a
mid-flight check. It reports; it does not advance the phase.

## Writing the artifacts

### progress.md — the ledger

The first thing you read, the last thing you write. It must be readable by a
person who has never seen this feature, in under a minute. Keep the header
block exactly in this shape so it can be parsed:

```markdown
# <Feature name>

- **slug:** <slug>
- **phase:** discovery | spec | planning | building | validation | done
- **updated:** YYYY-MM-DD
```

Then: a one-paragraph summary of what this feature is, a task table mirroring
`tasks.md` status, and a **decision log** — append-only, newest last, each entry
dated, one line each, recording what was decided and why. The decision log is
the highest-value part of the file. It is how a future session understands why
the code looks the way it does.

Never rewrite history in the decision log. Append.

### questions.md — the interview record

Two sections: **Open** and **Resolved**.

An open question carries why it blocks (which downstream choice depends on it).
A resolved question carries the answer, the date, and the reasoning — including
options that were considered and rejected. Move questions from Open to Resolved;
do not delete them. The rejected options are often the most useful thing in the
file six months later.

Mark each open question `blocking` or `non-blocking`. Only blocking questions
gate the discovery phase. A non-blocking question is a real question you can
proceed without — record it and move on.

### spec.md — the contract

The spec answers: what is being built, for whom, how we know it works, and what
is explicitly out of scope. It is not a design document and it is not an
implementation plan. Required sections:

- **Problem** — what is broken or missing today, in the user's terms
- **Users and context** — who does this, when, under what pressure
- **Behaviour** — what the system does, as observable statements
- **Acceptance criteria** — numbered, each independently verifiable. This is the
  part `/sdd:qa` checks against. A criterion nobody can test is not a criterion
- **Non-functional requirements** — performance, security, accessibility, data
  retention, whatever actually applies. Omit the heading if nothing applies
- **Out of scope** — the boundary. Be specific; this is what stops scope creep
- **Open risks** — what could make this wrong

Write acceptance criteria as observable outcomes, not implementation steps.
"A receptionist can cancel an appointment up to 2 hours before it starts, and
the patient receives a WhatsApp notification within 60 seconds" — not "add a
cancel button".

### tasks.md — the plan

Each task has: a stable ID (`T1`, `T2`, …), a title, the files it is expected to
touch, its dependencies by ID, a status, and an acceptance criterion that maps
back to the spec. Format:

```markdown
### T3 — Cancel endpoint enforces the 2-hour window
- **status:** todo | in-progress | done | blocked | dropped
- **depends on:** T1, T2
- **touches:** src/api/appointments.ts, src/domain/cancellation.ts
- **satisfies:** AC-4, AC-5
- **acceptance:** Cancelling inside the window returns 422 with code
  `CANCEL_WINDOW_CLOSED`; outside it returns 200 and emits `appointment.cancelled`.
  Covered by a test that fails before the change.
```

Tasks are sized to be completable and reviewable in one sitting. If a task
touches more than roughly five files or spans more than one architectural layer
without a clear reason, split it.

Order matters: a task may only depend on tasks that come before it.

## The expert panel

The panel exists to find the holes you cannot see from inside the conversation.
Panel members are subagents. **They run in isolation and cannot talk to the
user.** They critique; they do not interview and they do not decide.

### Choosing who sits on the panel

Do not convene all seven every time — it is noise and it is slow. Pick by what
the feature actually touches:

| Convene | When the feature… |
|---|---|
| `sdd-domain-expert` | always — every feature has a business domain |
| `sdd-ux-designer` | has any user-facing surface, including CLI output and error text |
| `sdd-systems-architect` | crosses a process/service/network boundary, adds infrastructure, or changes how data is stored or deployed |
| `sdd-code-designer` | introduces a new module, abstraction, or public API within the codebase |
| `sdd-qa-engineer` | always — every feature needs to be verifiable |
| `sdd-security-reviewer` | touches auth, permissions, personal or regulated data, payments, file upload, or anything reachable by an untrusted caller |
| `sdd-tech-writer` | only at `/sdd:archive`, to write the changelog |

State which members you convened and why, in one line, before dispatching.

### How to run a round

Dispatch every chosen member **in one message, in parallel** — a round costs the
wall-clock time of its slowest member, not the sum. Give each the same payload:

1. The full current draft of `spec.md` (or the diff under review, for build/QA)
2. The relevant part of `progress.md` decision log, so they do not re-litigate
   what is already settled
3. The project's `CLAUDE.md` path, if one exists, so they respect local rules
4. One question, scoped to their discipline

Each member writes its findings to `.sdd/features/<slug>/reviews/<persona>-r<n>.md`
and returns a short summary. You then **consolidate**: merge overlapping findings,
drop anything already settled in the decision log, and sort what remains into:

- **Gaps you can close yourself** — fix them in the draft, note it
- **Questions only the user can answer** — take these to the user as a small
  set of concrete multiple-choice questions, never a wall of open prose
- **Disagreements between members** — surface both positions and your
  recommendation; let the user break the tie

Never dump raw panel output at the user. Consolidation is your job.

### Rounds

Round 1 on the first draft. If round 1 produced substantive changes, run round 2
on the revised draft with the same members. Stop at round 2 unless the user asks
for more — a third round on a spec is almost always sharpening prose, not
finding holes.

## Rules that keep this from degrading

1. **Read `progress.md` before doing anything.** Every command starts there.
2. **Write `progress.md` before the turn ends.** Every command ends there.
3. **One task at a time in `building`.** Mark it `in-progress` before you start,
   `done` only after its acceptance criterion actually passes.
4. **Never mark a task done on the strength of code you wrote but did not run.**
   If you could not verify it, say so and leave it `in-progress`.
5. **A gate is not a formality.** If the user asks to skip one, say what the
   risk is, then do what they say and record it in the decision log.
6. **Scope changes go through the spec.** A new requirement discovered during
   `building` gets added to `spec.md` and `tasks.md`, with a decision-log entry.
   It does not get quietly implemented.
7. **The spec is the contract, not the code.** If the code has to diverge from
   the spec, update the spec in the same change.
