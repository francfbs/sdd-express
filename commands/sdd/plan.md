---
description: Turn the approved spec into ordered tasks with verifiable acceptance criteria
---

Read the `sdd-protocol` skill first. Follow it exactly.

## 1. Gate

Read `.sdd/ACTIVE` and `progress.md`.

- No active feature → `/sdd:new`. Stop.
- `spec.md` is not `approved` → say so, tell them to run `/sdd:spec`. Stop.
  Do not plan against a draft spec; that is how the plan and the contract drift.
- Already in `building` → say so and point at `/sdd:build` or `/sdd:status`. Stop.

## 2. Understand the ground before you plan

Read `CLAUDE.md`, the modules this feature touches, the existing patterns for
this kind of work, and how the project tests and builds. A plan that ignores
the codebase produces tasks that dissolve on contact with it.

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

Dispatch **in parallel, in one message**:

- `sdd-code-designer` — task boundaries, reuse, order, abstractions that should
  not exist
- `sdd-qa-engineer` — criteria coverage, untestable tasks, missing edge cases
- `sdd-systems-architect` — only if the feature touches infrastructure, data
  migration, or a service boundary

Give each the spec, the draft `tasks.md`, the decision log, and their review
file path (`reviews/<persona>-plan.md`).

Consolidate as the protocol describes. Apply what you agree with, take genuine
choices to the user as multiple choice, and log the decisions.

## 5. Close planning

Mirror the task table into `progress.md`, tick the `planning` gate, set phase to
`building`, update `updated:`.

Show the user the task list — ID, title, what it satisfies — plus the total
count and which tasks are on the critical path. Ask if the order is right; they
often know a sequencing constraint you cannot see.

Then tell them to run `/sdd:build`.
