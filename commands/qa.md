---
description: Validate the built feature against every acceptance criterion in the spec
---

Read the `sdd-protocol` skill first. You will need its `panel.md` reference at
step 3.

## 1. Gate

Read `.sdd/ACTIVE`, `progress.md`, `spec.md`, and the status lines of `tasks.md`
(`grep -nE '^### T|status:'`).

- Phase is before `building` → there is nothing built to validate. Stop.
- Phase is `building` with tasks outstanding → this is a **mid-flight check**.
  Run it, report, but do not advance the phase. Say clearly that N tasks remain.

## 2. Validate against the contract, criterion by criterion

This is not a code review — `/code-review` does that. This asks one question:
**does the thing the spec promised actually happen?**

Go through the acceptance criteria in order. For each one, establish the answer
from evidence you gathered, not from the fact that a task was marked done:

- Run the full check from `context.md` once, output reduced to failures and the
  summary. Report the real result.
- Find the specific test or check that covers this criterion. If none exists,
  say so — a criterion with no coverage is unverified, regardless of whether
  the code looks correct.
- Where a criterion cannot be checked automatically, trace it through the code
  and say exactly what a human should click to confirm it.

Also check the non-functional requirements. They are the ones that quietly go
unimplemented, because no task felt like it owned them.

## 3. Panel validation

Read `panel.md` and fill the validation seats within the cap for this `size:`,
dispatching as it describes. Give each the diff command for the whole feature and
the full-check result in one line. Useful questions per seat:

- **QA** — which criteria does the diff actually satisfy, and which only appear to?
- **Security** — what is reachable now that it is real rather than described?
- **UX** — which states only became visible once it was built?
- **Domain** — does the built behaviour match how the domain really works?

Review files: `reviews/<persona>-validation.md`. Validation is one round; what it
finds becomes tasks, not another review.

## 4. Report

Per criterion, one line: **PASS** with the evidence, **FAIL** with what actually
happens, or **UNVERIFIED** with what is needed to check it. Do not round
UNVERIFIED up to PASS.

Then the panel's findings, consolidated — never raw.

## 5. Close or reopen

**If anything fails or is unverified**, turn each into a new task in `tasks.md`
with its own acceptance criterion, set phase back to `building`, log why, and
tell the user to run `/sddx:build`. This is a normal outcome, not a failure of
the process — it is the process working.

**If everything passes**, tick the `validation` gate, set phase to `done`,
update `updated:`, and log it. Tell the user to run `/sddx:archive`.
