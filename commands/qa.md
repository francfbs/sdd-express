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
from evidence, not from the fact that a task was marked done — but do not
re-gather evidence that already exists:

- **Full check.** If the last `checkpoint` line in the decision log says `full
  check pass` and its fingerprint equals the current one (computed as the
  protocol describes), cite it — the code has not moved since. Otherwise run it
  once, output reduced to failures and the summary.
- **Map criteria to tests from `verification.md`.** Open a named test only to
  confirm it asserts the criterion. Search the code only for a criterion
  `verification.md` does not cover — a criterion with no coverage is
  unverified, regardless of how the code looks. No `verification.md` at all (a
  feature built before it existed) → find the covering test per criterion.
- **The `manual` lines, once.** If you can drive the app here (a browser tool,
  the CLI), start it once and walk all the `manual` lines in a single pass —
  the primary flow and what each line names, no exploratory testing. If you
  cannot, trace each through the code and say exactly what a human should
  click to confirm it.

Also check the non-functional requirements. They are the ones that quietly go
unimplemented, because no task felt like it owned them.

## 3. Panel validation

Read `panel.md` for the validation seats: the spec panel minus the disciplines
that already reviewed this code at build checkpoints (the decision log's
`checkpoint` lines and `reviews/*-checkpoint-*` say which). QA is covered by your
criterion-by-criterion pass above and never sits here. Say in one line who sits
and who was dropped as already covered. No seat left → skip this step and say so.

Give each seat the diff command for the whole feature limited to its paths, the
full-check result in one line, and `verification.md`. Useful questions per seat:

- **Security** (only if it saw no checkpoint) — what is reachable now that it is
  real rather than described?
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
