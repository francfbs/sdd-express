---
name: sdd-protocol
description: The shared contract for the sdd-express spec-driven feature workflow — where feature state lives on disk, the phase gates that govern progress, the format of every artifact (spec, questions, tasks, progress), and how to convene the expert panel. Load this before running any /sddx: command, before writing or reading any file under .sdd/features/, and whenever you need to know what phase a feature is in or what is allowed to happen next.
---

# The sdd-express protocol

This file is the single source of truth for the feature workflow. Commands and
agents both read it. If a command's instructions and this protocol disagree,
this protocol wins.

## Core principle: state lives on disk, not in context

Every fact the workflow depends on is written to a file before the turn ends.
Context gets compacted, sessions end, days pass. The files are what survive.

Never hold a decision, an open question, or a completed task only in your head.
If it matters, it is in a file.

## Language

Write every artifact in the language the user is speaking. If the user writes in
Portuguese, `spec.md` is in Portuguese. Code, identifiers, file paths and commit
messages stay in English regardless. Never announce this rule — just follow it.

## Where a feature lives

```
.sdd/
  features/
    <slug>/
      progress.md      the ledger — phase, gates, task status, decision log
      questions.md     open questions and resolved decisions with rationale
      spec.md          the contract: what gets built and how you know it works
      context.md       the briefing pack the panel reads instead of the codebase
      tasks.md         ordered, dependency-aware, each with acceptance criteria
      reviews/         one file per panel member, per round
        <persona>-r<n>.md
  archive/
    <slug>/            completed features, moved here by /sddx:archive
```

`<slug>` is kebab-case, derived from the feature name: `pix-payment`,
`patient-timeline`, `bulk-export`.

The **active feature** is whichever slug is named in `.sdd/ACTIVE`. That file
holds one line: the slug. `/sddx:new` writes it, `/sddx:archive` clears it.
If `.sdd/ACTIVE` is missing or empty, there is no active feature.

## Size: the triage that decides how much workflow to spend

Not every feature deserves the same machinery. A spec-driven workflow that costs
the same for a known integration as for a new business rule gets abandoned —
which is the real failure mode, worse than a thin spec.

So every feature is classified **once, at `/sddx:new`, before the interview**,
and the class is written into `progress.md` as `size:`. Classify by asking what
could go wrong, not by counting files:

| Size | The feature is… | Interview | Panel | Rounds | Domain expert |
|---|---|---|---|---|---|
| `express` | a known shape with known answers — a documented integration, a CRUD surface over an existing model, a version bump, a change with an obvious correct implementation | 1 round | 2 members | 1 | not distilled |
| `standard` | ordinary product work — new behaviour in a domain the project already models | 2–3 rounds | 3 members | 1, plus 2 on trigger | enriched |
| `deep` | genuinely uncertain — a new business rule nobody has stated, a redesign, something regulated, something irreversible, or a problem the user cannot yet describe in one paragraph | until it stops changing the design | up to 6 | 2 | distilled or enriched, always shown |

**What moves a feature up:** money, personal or regulated data, an irreversible
migration, a boundary between teams, or a user who is unsure what they want.
**What does not:** the number of files, the size of the diff, or how new the
library is to you. A Supabase login integration is `express` on the domain and
`standard` at most — the questions are about *this project's* choices (which
identity providers, what happens to existing users, where the session lives),
not about how Supabase works.

**Say the class out loud and let the user override it.** One line: what you
picked, why, and that `/sddx:new <name> --deep` (or `--express`) overrides it.
Record the class and its reason in the decision log. A misclassification is
cheap to fix at discovery and expensive to fix at build.

**Upgrading mid-flight is allowed and expected.** If the interview or round 1 of
the panel turns up a real unknown, say that the feature just became `standard`
or `deep`, update `size:`, log why, and spend the extra rounds. Downgrading is
not: once a feature has shown you it is uncertain, it stays that way.

## The phases and their gates

A feature moves through five phases. Each transition has a gate. **Never skip a
gate, and never advance a phase on your own initiative** — the user runs the
command that advances it.

| Phase | Command | Gate to leave it |
|---|---|---|
| `discovery` | `/sddx:new` | Every blocking question in `questions.md` is resolved |
| `spec` | `/sddx:spec` | The user has explicitly approved `spec.md` |
| `planning` | `/sddx:plan` | Every task has a verifiable acceptance criterion and a resolved dependency order |
| `building` | `/sddx:build` | Every task is `done` or explicitly `dropped` |
| `validation` | `/sddx:qa` | Every acceptance criterion in the spec is verified against real code |

When a command is invoked for a phase the feature is not in, say so and stop.
Do not "helpfully" run the earlier phase. Tell the user which command to run.

The one exception: `/sddx:qa` may be run at any time after `planning` as a
mid-flight check. It reports; it does not advance the phase.

## Writing the artifacts

### progress.md — the ledger

The first thing you read, the last thing you write. It must be readable by a
person who has never seen this feature, in under a minute. Keep the header
block exactly in this shape so it can be parsed:

```markdown
# <Feature name>

- **slug:** <slug>
- **phase:** discovery | spec | planning | building | validation | done
- **size:** express | standard | deep
- **updated:** YYYY-MM-DD
```

Then: a one-paragraph summary of what this feature is, a task table mirroring
`tasks.md` status, and a **decision log** — append-only, newest last, each entry
dated, one line each, recording what was decided and why. The decision log is
the highest-value part of the file. It is how a future session understands why
the code looks the way it does.

Never rewrite history in the decision log. Append.

### questions.md — the interview record

Two sections: **Open** and **Resolved**.

An open question carries why it blocks (which downstream choice depends on it).
A resolved question carries the answer, the date, and the reasoning — including
options that were considered and rejected. Move questions from Open to Resolved;
do not delete them. The rejected options are often the most useful thing in the
file six months later.

Mark each open question `blocking` or `non-blocking`. Only blocking questions
gate the discovery phase. A non-blocking question is a real question you can
proceed without — record it and move on.

### spec.md — the contract

The spec answers: what is being built, for whom, how we know it works, and what
is explicitly out of scope. It is not a design document and it is not an
implementation plan. Required sections:

- **Problem** — what is broken or missing today, in the user's terms
- **Users and context** — who does this, when, under what pressure
- **Behaviour** — what the system does, as observable statements
- **Acceptance criteria** — numbered, each independently verifiable. This is the
  part `/sddx:qa` checks against. A criterion nobody can test is not a criterion
- **Non-functional requirements** — performance, security, accessibility, data
  retention, whatever actually applies. Omit the heading if nothing applies
- **Out of scope** — the boundary. Be specific; this is what stops scope creep
- **Open risks** — what could make this wrong

Write acceptance criteria as observable outcomes, not implementation steps.
"A receptionist can cancel an appointment up to 2 hours before it starts, and
the patient receives a WhatsApp notification within 60 seconds" — not "add a
cancel button".

### tasks.md — the plan

Each task has: a stable ID (`T1`, `T2`, …), a title, the files it is expected to
touch, its dependencies by ID, a status, and an acceptance criterion that maps
back to the spec. Format:

```markdown
### T3 — Cancel endpoint enforces the 2-hour window
- **status:** todo | in-progress | done | blocked | dropped
- **depends on:** T1, T2
- **touches:** src/api/appointments.ts, src/domain/cancellation.ts
- **satisfies:** AC-4, AC-5
- **acceptance:** Cancelling inside the window returns 422 with code
  `CANCEL_WINDOW_CLOSED`; outside it returns 200 and emits `appointment.cancelled`.
  Covered by a test that fails before the change.
```

Tasks are sized to be completable and reviewable in one sitting. If a task
touches more than roughly five files or spans more than one architectural layer
without a clear reason, split it.

Order matters: a task may only depend on tasks that come before it.

## The expert panel

The panel exists to find the holes you cannot see from inside the conversation.
Panel members are subagents. **They run in isolation and cannot talk to the
user.** They critique; they do not interview and they do not decide.

### Choosing who sits on the panel

A panel member is a cold subagent: it costs a full context window to tell it
what you already know. So the panel is **capped by the feature's size**, and the
cap is a real limit, not a suggestion:

| Size | Members | Exceeding the cap |
|---|---|---|
| `express` | 2 | not allowed — if you need a third, the feature is `standard` |
| `standard` | 3 | a 4th requires one line saying what it sees that the other three cannot |
| `deep` | up to 6 | say why each one is there |

Fill the seats in this order, stopping when the cap is reached:

1. **`sddx:sdd-qa-engineer` — always the first seat.** A spec whose criteria
   cannot be checked fails at every later phase, so this is the one review no
   feature can skip.
2. **The discipline carrying this feature's largest risk** — whichever single row
   below fits hardest. Not all the rows that technically apply: the one that
   would hurt most if it were wrong.
3. **`sdd-domain-expert`**, when the feature has business rules that could be
   wrong in a way code review would not catch. A pure integration with no rules
   of its own does not need it, and a generic domain review of one is noise.

| Seat 2 candidate | When the feature… |
|---|---|
| `sddx:sdd-security-reviewer` | touches auth, permissions, personal or regulated data, payments, file upload, or anything reachable by an untrusted caller |
| `sddx:sdd-ux-designer` | has a user-facing surface whose states and error text are the hard part, including CLI output |
| `sddx:sdd-systems-architect` | crosses a process/service/network boundary, adds infrastructure, or changes how data is stored, migrated or deployed |
| `sddx:sdd-code-designer` | introduces a new module, abstraction, or public API within the codebase |
| `sddx:sdd-tech-writer` | only at `/sddx:archive`, to write the changelog — never a panel seat |

State which members you convened, which seat each fills, and what you left out,
in one line, before dispatching. Naming the omission matters: it lets the user
add a seat back when they know something you do not.

### The briefing pack — write `context.md` before dispatching

**Never send a panel member to read the codebase itself.** Six members each
grepping for the same auth configuration is the same reading paid six times, and
it is the single largest cost in this workflow.

Instead, the main thread reads once and writes
`.sdd/features/<slug>/context.md` before the first dispatch:

```markdown
# Briefing — <feature>

## Stack and conventions
The versions, frameworks and local rules that constrain this feature. Quote the
relevant lines of CLAUDE.md rather than pointing at the file.

## How this project is checked
The exact test, lint, type-check and build commands. Every reviewer needs these
and every one of them would otherwise go hunting for them separately.

## What already exists
The files this feature touches or reuses, each with a path, the line range that
matters, and one line on what it does.

## Configuration that bears on this feature
The actual auth setup, policies, schema, env contract — pasted, not referenced.
Whatever the panel would otherwise go looking for.

## Decisions already settled
The decision log entries that close questions, so nobody re-opens them.

## What we deliberately do not know yet
The open non-blocking questions, so a member does not report them as findings.
```

Write it once per feature and **extend it** at `/sddx:plan` and `/sddx:build`
rather than rewriting it. It is the same briefing every later phase needs.

Panel members read: `spec.md` (or the diff), `context.md`, and **at most five
files that `context.md` names by path**. No repo-wide sweeps, no reading to
build general familiarity. If `context.md` was missing something they needed,
that is a finding to report — and a gap for you to fix in the pack, once, for
everyone.

### The budget every member works under

Include these limits verbatim in every dispatch. They are what keeps a critic
from turning its checklist into an exhaustive survey:

- **At most 8 tool calls.** Reading is not the job; judgement is.
- **At most 3 blocking findings and 3 non-blocking ones.** If there are more,
  report the 3 that matter and say the count you are withholding.
- **Review file: 400 words maximum.** Returned summary: 10 lines maximum.
- **Report nothing already settled in the decision log**, and nothing listed
  under "what we deliberately do not know yet".

A member that finds nothing blocking should say so in two lines and stop. That
is a successful review, and it costs almost nothing.

### The domain expert is per-project, and it accumulates

The plugin's domain expert is generic on purpose — a plugin cannot know whether
this project is a clinic scheduler or a freight exchange. Generic domain
findings are worthless, so the real expert is a **project-level** file at
`.claude/agents/sdd-domain-expert.md`.

**The two do not override each other; they coexist under different names.**
A plugin agent is namespaced, a project agent is not, so both are dispatchable
and you must pick deliberately:

| Agent name | Where it comes from |
|---|---|
| `sdd-domain-expert` | this project's `.claude/agents/` — the specialised one |
| `sddx:sdd-domain-expert` | the plugin — generic, the fallback |

So before convening the domain expert, check whether
`.claude/agents/sdd-domain-expert.md` exists:

- **It exists** — dispatch `sdd-domain-expert`. Never dispatch the plugin's
  generic one as well; you would get two reviews, one of them worthless.
- **It does not exist** — dispatch `sddx:sdd-domain-expert`, and say in one line
  that the panel is running without a project domain expert and that `/sddx:new`
  will distil one, or `/sddx:expert` will build one now. A user who does not know
  the expert is generic will over-trust its findings.

The same rule applies to any additional domain expert
(`sdd-domain-expert-billing` and so on): unnamespaced means project-level.

`/sddx:new` step 4 writes this file from the discovery interview the first time,
and **enriches it on every later feature**. That accretion is the design: after
four or five features the expert holds the business rules, the vocabulary and
the failure modes that were learned one interview at a time, and it reviews far
better than anything written up front in one sitting.

So when a panel review surfaces a durable domain fact — a rule, a term, a
constraint that will still be true in five features' time — it belongs in that
file, not only in this feature's decision log. Add it, in one line.

### How to run a round

Dispatch every chosen member **in one message, in parallel** — a round costs the
wall-clock time of its slowest member, not the sum. Give each the same payload:

1. The full current draft of `spec.md` (or the diff under review, for build/QA)
2. The path to `context.md`, and the instruction that it replaces exploring the
   codebase — at most five files beyond it, all named there
3. One question, scoped to their discipline and to *this* feature. A question
   narrow enough to be answered wrong is worth ten generic ones
4. The budget above, verbatim

Each member writes its findings to `.sdd/features/<slug>/reviews/<persona>-r<n>.md`
and returns a short summary. You then **consolidate**: merge overlapping findings,
drop anything already settled in the decision log, and sort what remains into:

- **Gaps you can close yourself** — fix them in the draft, note it
- **Questions only the user can answer** — take these to the user as a small
  set of concrete multiple-choice questions, never a wall of open prose
- **Disagreements between members** — surface both positions and your
  recommendation; let the user break the tie

Never dump raw panel output at the user. Consolidation is your job.

### Rounds

**Round 1 always. Round 2 is the exception, not the default.**

The old rule — "run round 2 if round 1 changed something" — means always, because
round 1 always changes something. The trigger is narrower:

> Run round 2 only when resolving round 1 **changed an acceptance criterion, the
> scope boundary, or a decision the spec rests on** — a change big enough that
> round 1's reviews were written against a different contract.

Copy-edits, added detail, closed assumptions and answered questions do not
qualify. Neither does the feeling that another pass might find more.

When round 2 does run:

- `express` never runs one. If an express feature needs a second round, say it
  was misclassified, move it to `standard`, and log that.
- Re-dispatch **only the members whose findings drove the change**, not the whole
  panel. A reviewer whose round-1 review is still accurate has nothing to add.
- Send the **diff of what changed** plus the revised spec, not just the spec.
  Ask one question: does this resolution hold?

Stop at round 2 always. A third round sharpens prose; it does not find holes.

## Rules that keep this from degrading

1. **Read `progress.md` before doing anything.** Every command starts there.
2. **Write `progress.md` before the turn ends.** Every command ends there.
3. **One task at a time in `building`** — including during a continuous run.
   Mark it `in-progress` before you start, `done` only after its acceptance
   criterion actually passes. Never implement two tasks in parallel: they
   conflict on files and produce a diff nobody can review.
4. **Never mark a task done on the strength of code you wrote but did not run.**
   If you could not verify it, say so and leave it `in-progress`.
5. **A gate is not a formality.** If the user asks to skip one, say what the
   risk is, then do what they say and record it in the decision log.
6. **Scope changes go through the spec.** A new requirement discovered during
   `building` gets added to `spec.md` and `tasks.md`, with a decision-log entry.
   It does not get quietly implemented.
7. **The spec is the contract, not the code.** If the code has to diverge from
   the spec, update the spec in the same change.
8. **Each phase is worth a fresh session.** The artifacts exist precisely so a
   phase does not need the previous phase's transcript — carrying a discovery
   interview into every panel dispatch and consolidation pays for it again on
   every turn. When a command ends and hands off to the next one, say so: "the
   ledger has everything — `/clear` before `/sddx:spec` if you like." Say it
   once, as an aside, and never nag.
9. **Spend where uncertainty is.** Every round, every seat and every question in
   this protocol is a cost the user pays. If you cannot say what a review would
   change, do not run it — an abandoned workflow finds no holes at all.
