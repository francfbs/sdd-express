---
description: Validate the built feature against every acceptance criterion in the spec
---

Read the `sdd-protocol` skill first. Follow it exactly.

## 1. Gate

Read `.sdd/ACTIVE`, `progress.md`, `spec.md`, `tasks.md`.

- Phase is before `building` → there is nothing built to validate. Stop.
- Phase is `building` with tasks outstanding → this is a **mid-flight check**.
  Run it, report, but do not advance the phase. Say clearly that N tasks remain.

## 2. Validate against the contract, criterion by criterion

This is not a code review — `/code-review` does that. This asks one question:
**does the thing the spec promised actually happen?**

Go through the acceptance criteria in order. For each one, establish the answer
from evidence you gathered, not from the fact that a task was marked done:

- Run the project's full test, type check and lint suite. Report real output.
- Find the specific test or check that covers this criterion. If none exists,
  say so — a criterion with no coverage is unverified, regardless of whether
  the code looks correct.
- Where a criterion cannot be checked automatically, trace it through the code
  and say exactly what a human should click to confirm it.

Also check the non-functional requirements. They are the ones that quietly go
unimplemented, because no task felt like it owned them.

## 3. Panel validation

Dispatch **in parallel, in one message**:

- `sdd-qa-engineer` — the whole diff against the whole spec, tests run
- `sdd-domain-expert` — does the built behaviour match how the domain really
  works, now that it is real rather than described
- `sdd-security-reviewer` — if the feature touches auth, permissions, personal
  or regulated data, payments, upload, or untrusted input
- `sdd-ux-designer` — if there is a user-facing surface; ask specifically about
  the states that only became visible once it was built

Give each the spec, the full feature diff, the decision log and a review file
path (`reviews/<persona>-validation.md`).

## 4. Report

Per criterion, one line: **PASS** with the evidence, **FAIL** with what actually
happens, or **UNVERIFIED** with what is needed to check it. Do not round
UNVERIFIED up to PASS.

Then the panel's findings, consolidated — never raw.

## 5. Close or reopen

**If anything fails or is unverified**, turn each into a new task in `tasks.md`
with its own acceptance criterion, set phase back to `building`, log why, and
tell the user to run `/sdd:build`. This is a normal outcome, not a failure of
the process — it is the process working.

**If everything passes**, tick the `validation` gate, set phase to `done`,
update `updated:`, and log it. Tell the user to run `/sdd:archive`.
