---
description: Turn the approved spec into ordered tasks with verifiable acceptance criteria
---

Read the `sdd-protocol` skill first. Follow it exactly.

## 1. Gate

Read `.sdd/ACTIVE` and `progress.md`.

- No active feature → `/sddx:new`. Stop.
- `spec.md` is not `approved` → say so, tell them to run `/sddx:spec`. Stop.
  Do not plan against a draft spec; that is how the plan and the contract drift.
- Already in `building` → say so and point at `/sddx:build` or `/sddx:status`. Stop.

## 2. Understand the ground before you plan

Start from `context.md` — the spec phase wrote it precisely so this phase does
not repeat that reading. Then fill only what planning needs and the briefing
lacks: how the project tests and builds, and the existing patterns for this kind
of work. A plan that ignores the codebase produces tasks that dissolve on
contact with it.

**Append what you learn back into `context.md`.** It is the briefing for every
later phase, and build will need exactly this.

Note what already exists that this feature should reuse. That shapes the tasks
more than anything else.

## 3. Write the tasks

Write `tasks.md` from the protocol template.

- **Every task maps to at least one acceptance criterion.** A task satisfying
  none is either scope creep or evidence of a criterion missing from the spec —
  resolve which, out loud.
- **Every criterion is covered by at least one task.** List any that are not;
  that is a hole in the plan, not something to paper over.
- **One sitting per task.** More than ~5 files, or spanning layers without a
  reason, means split it.
- **Order by dependency**, and prefer an order where something demonstrable
  works early. A vertical slice that runs beats three horizontal layers that
  only work once all three land.
- **Acceptance criteria are verifiable**: a test that fails before and passes
  after, a command whose output changes, a behaviour that can be driven. Not
  "code is clean".
- Include the unglamorous tasks — migration, rollback, telemetry, docs — when
  the spec's non-functional requirements imply them. They are where plans
  usually lie by omission.

## 4. Panel review of the plan

The plan panel is smaller than the spec panel — the contract is already settled,
and what is under review is coverage and order.

- `express` — **no panel.** Check the two invariants yourself: every task maps to
  a criterion, every criterion is covered by a task. Say you skipped the panel
  and why.
- `standard` — `sddx:sdd-qa-engineer` alone: criteria coverage, untestable tasks,
  missing edge cases.
- `deep` — add `sddx:sdd-code-designer` (task boundaries, reuse, order,
  abstractions that should not exist), and `sddx:sdd-systems-architect` only if
  the feature touches infrastructure, data migration, or a service boundary.

Dispatch **in parallel, in one message**. Give each the spec, the draft
`tasks.md`, the path to `context.md` in place of the codebase, their review file
path (`reviews/<persona>-plan.md`), and the protocol's budget verbatim.

Consolidate as the protocol describes. Apply what you agree with, take genuine
choices to the user as multiple choice, and log the decisions. There is no
second round at planning: a plan that needs one has a spec problem, so say that
instead.

## 5. Close planning

Mirror the task table into `progress.md`, tick the `planning` gate, set phase to
`building`, update `updated:`.

Show the user the task list — ID, title, what it satisfies — plus the total
count and which tasks are on the critical path. Ask if the order is right; they
often know a sequencing constraint you cannot see.

Then tell them to run `/sddx:build` — `/clear` first if the planning
conversation ran long, since `tasks.md` and `context.md` carry it all.
