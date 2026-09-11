---
description: Draft the spec, put it through the expert panel, and close the gaps until you approve it
---

Read the `sdd-protocol` skill first. Follow it exactly.

## 1. Gate

Read `.sdd/ACTIVE`, then `.sdd/features/<slug>/progress.md`.

- No active feature → tell the user to run `/sdd:new`. Stop.
- Phase is not `discovery` or `spec` → say what phase it is in and which command
  applies. Stop.
- Blocking questions still open in `questions.md` → list them and ask them now,
  as multiple choice. Do not draft around an unanswered blocking question.

## 2. Draft

Read `questions.md`, the decision log, `CLAUDE.md`, and the parts of the
codebase this will touch. Write `spec.md` from the protocol template.

Write it as a contract, not a design document. No implementation, no file
names, no library choices — those belong to `/sdd:plan`. The acceptance
criteria are the load-bearing part: numbered, observable, each one something a
person could check. If you cannot say how a criterion would be checked, it is
not ready to be one.

Where discovery left something genuinely undecided but non-blocking, write your
best call into the spec and mark it `[assumption]`. The panel will test it.

Set phase to `spec` in `progress.md`.

## 3. Convene the panel — round 1

Choose members by the protocol's table, based on what this feature actually
touches. Say in one line who you convened and why.

Dispatch them **all in a single message so they run in parallel**. Give each:

- the full `spec.md`
- the decision log, so they do not re-open settled questions
- the path to `CLAUDE.md`, if it exists
- their review file path: `.sdd/features/<slug>/reviews/<persona>-r1.md`
- one question scoped to their discipline

## 4. Consolidate

Never show the user raw panel output. Read the review files and produce:

- **Gaps you can close yourself** — fix them in `spec.md` directly. List what
  you changed, one line each.
- **Questions only the user can answer** — as `AskUserQuestion`, with real
  options. Group them; four sharp questions beat twelve.
- **Disagreements between members** — state both positions in one line each,
  give your recommendation, let the user decide.

Apply the answers to `spec.md`. Record each decision in the decision log with
its reasoning. Note the panel round in the Panel section of `progress.md`.

## 5. Round 2, if round 1 changed something substantive

Same members, revised spec, review files `-r2`. Consolidate the same way.

Stop after round 2 unless the user asks for more. A third round sharpens prose;
it does not find holes.

If the spec got long or vague, run `sdd-tech-writer` over it now — but treat
every ambiguity it flags as a question for the user, not something to resolve
yourself.

## 6. Ask for approval

Show the user:

- the acceptance criteria in full — this is the contract, they must read it
- what is out of scope
- what the panel changed, in three or four lines
- anything still marked `[assumption]`

Then ask explicitly whether to approve. **Approval is a gate — it must be a
real answer, not inferred from silence or from "ok".**

On approval: set `status: approved` and the date in `spec.md`, tick the `spec`
gate in `progress.md`, log the approval, update `updated:`. Tell them to run
`/sdd:plan`.

If they want changes: apply them, log them, and ask again.
