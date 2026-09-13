---
description: Draft the spec, put it through the expert panel, and close the gaps until you approve it
---

Read the `sdd-protocol` skill, then its `artifacts.md` reference. You will need
`panel.md` at step 4.

## 1. Gate

Read `.sdd/ACTIVE`, then `.sdd/features/<slug>/progress.md`.

- No active feature → tell the user to run `/sddx:new`. Stop.
- Phase is not `discovery` or `spec` → say which phase and which command
  applies. Stop.
- Blocking questions still open in `questions.md` → ask them now, as multiple
  choice. Do not draft around an unanswered blocking question.

## 2. Draft

Read `questions.md`, the decision log, `CLAUDE.md`, and the parts of the codebase
this will touch. Write `spec.md` from the template, in the format `artifacts.md`
gives.

A contract, not a design: no implementation, no file names, no library choices.
The acceptance criteria are the load-bearing part — if you cannot say how one
would be checked, it is not ready to be one. Undecided but non-blocking calls go
in marked `[assumption]`; the panel will test them.

Set phase to `spec` in `progress.md`.

## 3. Write the briefing

You have just read the codebase to draft the spec. **Write it into `context.md`**
now, in the shape `artifacts.md` gives, before dispatching anybody — in English.

It is the difference between reading the auth configuration once and once per
reviewer. Paste the configuration, quote the conventions, name files with line
ranges. Whatever you leave out, every subagent in every later phase pays to
rediscover.

## 4. Panel — round 1

Read `panel.md`. Fill the spec seats within the cap for this `size:`, say in one
line who sits, which seat, and who you left out, then dispatch them all in one
message as `panel.md` describes. Review files: `reviews/<persona>-r1.md`.

## 5. Consolidate

Read the review files and consolidate as `panel.md` describes — never raw output.
Fix what you can in `spec.md`, take the user's questions as `AskUserQuestion`,
and surface disagreements with your recommendation.

Apply the answers. Log each decision with its reasoning, and the round in the
Panel section of `progress.md`.

## 6. Round 2 — only on the trigger

Apply `panel.md`'s round-2 trigger. If it fires, re-dispatch only the members
whose findings drove the change (`-r2`). If it does not, say so in one line and
go to approval.

Run `sddx:sdd-tech-writer` only if the spec has grown long and vague enough that
the ambiguity is itself a risk — and treat every ambiguity it flags as a
question for the user.

## 7. Ask for approval

Show the user:

- the acceptance criteria in full — this is the contract, they must read it
- what is out of scope
- what the panel changed, in three or four lines
- anything still marked `[assumption]`

Then ask explicitly. **Approval is a gate — a real answer, never inferred from
silence or from "ok".**

On approval: set `status: approved` and the date in `spec.md`, tick the `spec`
gate, log the approval, update `updated:`. Tell them to run `/sddx:plan` — after
a `/clear`, since `spec.md` and `context.md` carry everything planning needs.

If they want changes: apply them, log them, ask again.
