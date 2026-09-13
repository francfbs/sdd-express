# Artifact formats

Reference for the `sdd-protocol` skill. Read it when writing or restructuring a
feature's artifacts. Starting templates for `progress.md`, `questions.md`,
`spec.md` and `tasks.md` are in `templates/` beside this file; `progress.md` is
described in the core protocol.

## questions.md — the interview record

Two sections: **Open** and **Resolved**.

An open question says why it blocks — which downstream choice depends on it —
and is marked `blocking` or `non-blocking`. Only blocking questions gate
discovery; a non-blocking one is recorded and proceeded without.

A resolved question carries the answer, the date and the reasoning, including
the options considered and rejected. Move questions from Open to Resolved;
never delete them. The rejected options are often the most useful thing in the
file six months later.

## spec.md — the contract

What is being built, for whom, how we know it works, and what is out of scope.
Not a design document and not a plan — no file names, no library choices.
Required sections:

- **Problem** — what is broken or missing today, in the user's terms
- **Users and context** — who does this, when, under what pressure
- **Behaviour** — what the system does, as observable statements
- **Acceptance criteria** — numbered `AC-1`, `AC-2`…, each independently
  verifiable. This is what `/sddx:qa` checks. A criterion nobody can test is not
  a criterion
- **Non-functional requirements** — performance, security, accessibility,
  retention; only what applies. Omit the heading otherwise
- **Out of scope** — specific. This is what stops scope creep
- **Open risks** — what could make this wrong

Write criteria as outcomes, not steps: "a receptionist can cancel an appointment
up to 2 hours before it starts, and the patient receives a WhatsApp notification
within 60 seconds" — not "add a cancel button". Undecided but non-blocking calls
are written in and marked `[assumption]`.

## tasks.md — the plan

```markdown
### T3 — Cancel endpoint enforces the 2-hour window
- **status:** todo | in-progress | done | blocked | dropped
- **depends on:** T1, T2
- **touches:** src/api/appointments.ts:40-95, src/domain/cancellation.ts
- **satisfies:** AC-4, AC-5
- **acceptance:** Cancelling inside the window returns 422 with code
  `CANCEL_WINDOW_CLOSED`; outside it returns 200 and emits `appointment.cancelled`.
  Covered by a test that fails before the change.
```

This file is the only place task status lives.

**A task is sized to one implementer dispatch.** A fresh subagent holding only
`context.md`, this block and the criteria it satisfies must be able to finish it
and verify it. That is the limit — not a file count.

**Within that limit, prefer fewer, larger, vertical tasks.** Every task pays a
fixed overhead — claim, dispatch, record — whatever its size, so five thin
horizontal tasks cost far more than two slices that each run end to end, and
the slices demonstrate something working earlier. The size table in the core
protocol gives the target count. Split a task only when one criterion cannot
verify it, or when it mixes two things that could fail for unrelated reasons.

**`touches` is what the implementer reads**, and nothing else by default. Give
line ranges where a file is large and only part of it matters.

A task may only depend on tasks above it.

## context.md — the briefing

Written by `/sddx:spec` before the first panel dispatch, from the reading that
drafting the spec already required. Every subagent in every later phase reads it
instead of the codebase — so anything missing from it, every one of them pays to
rediscover.

In English. **Extended, never rewritten**: `/sddx:plan` adds the check commands
and patterns, implementers append what they learn. Keep it under ~1,500 words.
Past that it is turning into a copy of the codebase; cut back to what bears on
this feature.

```markdown
# Briefing — <feature>

## Stack and conventions
Versions, frameworks and the local rules that constrain this feature. Quote the
relevant CLAUDE.md lines rather than pointing at the file.

## How this project is checked
- targeted: the command that tests one file or area, with quiet output
  (e.g. `npx vitest run <path> --reporter=dot`)
- full: the whole suite, lint and type check, output reduced to failures
- how to confirm a test fails before a change, if the project has a convention

## What already exists
Files this feature touches or reuses: path, the line range that matters, one
line on what it does.

## Configuration that bears on this feature
The actual auth setup, policies, schema, env contract — pasted, not referenced.

## Decisions already settled
The decision-log entries that close questions, so nobody re-opens them.

## What we deliberately do not know yet
Open non-blocking questions, so nobody reports them as findings.

## Learned during build
One line each, appended by implementers: a gotcha, a helper that exists, a
command form that works. Only what the next task would otherwise rediscover.
```
