---
description: Draft the spec, put it through the expert panel, and close the gaps until you approve it
---

Read the `sdd-protocol` skill first. Follow it exactly.

## 1. Gate

Read `.sdd/ACTIVE`, then `.sdd/features/<slug>/progress.md`.

- No active feature → tell the user to run `/sddx:new`. Stop.
- Phase is not `discovery` or `spec` → say what phase it is in and which command
  applies. Stop.
- Blocking questions still open in `questions.md` → list them and ask them now,
  as multiple choice. Do not draft around an unanswered blocking question.

## 2. Draft

Read `questions.md`, the decision log, `CLAUDE.md`, and the parts of the
codebase this will touch. Write `spec.md` from the protocol template.

Write it as a contract, not a design document. No implementation, no file
names, no library choices — those belong to `/sddx:plan`. The acceptance
criteria are the load-bearing part: numbered, observable, each one something a
person could check. If you cannot say how a criterion would be checked, it is
not ready to be one.

Where discovery left something genuinely undecided but non-blocking, write your
best call into the spec and mark it `[assumption]`. The panel will test it.

Set phase to `spec` in `progress.md`.

## 3. Write the briefing pack

You have just read the codebase to draft the spec. **Write what you learned into
`.sdd/features/<slug>/context.md`** in the protocol's shape, before dispatching
anybody.

This is not documentation for its own sake — it is the difference between one
member reading the auth configuration and six. Paste the configuration, quote
the conventions, name the files with their line ranges. Anything you leave out,
every member pays to rediscover.

## 4. Convene the panel — round 1

Fill the seats by the protocol's order, **within the cap for this feature's
`size:`**. Say in one line who you convened, which seat each fills, and who you
left out — the omission is the part the user can correct.

Dispatch them **all in a single message so they run in parallel**. Give each:

- the full `spec.md`
- the path to `context.md`, and that it replaces exploring the codebase: at most
  five further files, all named there
- their review file path: `.sdd/features/<slug>/reviews/<persona>-r1.md`
- one question scoped to their discipline and to this feature
- the protocol's budget, verbatim: 8 tool calls, 3 blocking findings, 3
  non-blocking, 400 words in the file, 10 lines back

## 5. Consolidate

Never show the user raw panel output. Read the review files and produce:

- **Gaps you can close yourself** — fix them in `spec.md` directly. List what
  you changed, one line each.
- **Questions only the user can answer** — as `AskUserQuestion`, with real
  options. Group them; four sharp questions beat twelve.
- **Disagreements between members** — state both positions in one line each,
  give your recommendation, let the user decide.

Apply the answers to `spec.md`. Record each decision in the decision log with
its reasoning. Note the panel round in the Panel section of `progress.md`.

## 6. Round 2 — only on the protocol's trigger

Round 2 is not the default. Run it **only** if resolving round 1 changed an
acceptance criterion, the scope boundary, or a decision the spec rests on. Added
detail, closed assumptions and copy-edits do not qualify.

If it does fire:

- `express` features do not run one — say the feature was misclassified, move it
  to `standard`, log that, and then run it
- re-dispatch **only the members whose findings drove the change**
- send the diff of what changed alongside the revised spec, review files `-r2`,
  and one question: does this resolution hold?

If it does not fire, say so in one line — "round 1 found nothing that changed the
contract, so no second round" — so the user sees a decision rather than an
omission. Then go to approval.

Skip `sddx:sdd-tech-writer` unless the spec is genuinely long and vague enough
that the ambiguity is itself a risk. When you do run it, treat every ambiguity it
flags as a question for the user, not something to resolve yourself.

## 7. Ask for approval

Show the user:

- the acceptance criteria in full — this is the contract, they must read it
- what is out of scope
- what the panel changed, in three or four lines
- anything still marked `[assumption]`

Then ask explicitly whether to approve. **Approval is a gate — it must be a
real answer, not inferred from silence or from "ok".**

On approval: set `status: approved` and the date in `spec.md`, tick the `spec`
gate in `progress.md`, log the approval, update `updated:`. Tell them to run
`/sddx:plan` — after a `/clear`, since `spec.md` and `context.md` now carry
everything the planning phase needs.

If they want changes: apply them, log them, and ask again.
