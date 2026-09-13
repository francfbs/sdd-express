---
description: Turn the approved spec into ordered tasks with verifiable acceptance criteria
---

Read the `sdd-protocol` skill, then its `artifacts.md` reference.

## 1. Gate

Read `.sdd/ACTIVE` and `progress.md`.

- No active feature → `/sddx:new`. Stop.
- `spec.md` is not `approved` → say so, point at `/sddx:spec`. Stop. Planning
  against a draft is how the plan and the contract drift.
- Already `building` → point at `/sddx:build` or `/sddx:status`. Stop.

## 2. Ground the plan

Start from `context.md`; the spec phase wrote it so this phase does not repeat
that reading. Fill only what planning needs and the briefing lacks, and
**append it to `context.md`** — every implementer will read it:

- **the check commands** — the targeted form for one area and the full form,
  both with quiet output. Implementers cannot verify anything without these
- the existing patterns for this kind of work
- what already exists that this feature should reuse — it shapes the tasks more
  than anything else

## 3. Write the tasks

Write `tasks.md` from the template, sized as `artifacts.md` describes: **one
implementer dispatch per task, and as few, as vertical, as that allows.** The
size table in the protocol gives the target count; every task carries fixed
overhead whatever its size.

- **Every task maps to at least one criterion**, and **every criterion is covered
  by a task.** A task satisfying none is scope creep or a missing criterion —
  resolve which, out loud.
- **`touches` with line ranges** where files are large. It is what the implementer
  reads.
- **Acceptance is verifiable** — a test that fails before and passes after, a
  command whose output changes, a behaviour that can be driven.
- **Order by dependency**, with something demonstrable working early.
- Include the unglamorous work — migration, rollback, telemetry, docs — when the
  non-functional requirements imply it. Fold it into the slice it belongs to
  rather than giving it a task of its own.

## 4. Review the plan

Read `panel.md` for the plan seats. `express` has none: check the two coverage
invariants yourself and say you did. Otherwise dispatch as `panel.md` describes,
with review files `reviews/<persona>-plan.md`, and consolidate.

No second round at planning. A plan that needs one has a spec problem — say that
instead.

## 5. Close planning

Tick the `planning` gate, set phase to `building`, update `updated:`. Task status
lives in `tasks.md` only; do not copy it into `progress.md`.

Show the user the tasks — ID, title, what each satisfies — the count, and the
critical path. Ask if the order is right; they often know a sequencing
constraint you cannot see.

Then point at `/sddx:build` — after a `/clear`, since `tasks.md` and `context.md`
carry it all.
