---
name: sdd-protocol
description: The shared contract for the sdd-express spec-driven feature workflow — where feature state lives on disk, feature sizing, the phase gates, and the rules every command follows. Two references beside it hold the artifact formats (artifacts.md) and how to convene reviewers (panel.md). Load this before running any /sddx: command, before writing or reading any file under .sdd/features/, and whenever you need to know what phase a feature is in or what is allowed to happen next.
---

# The sdd-express protocol

The single source of truth for the workflow. If a command and this protocol
disagree, the protocol wins.

This file is the core, and every command needs all of it. Two references sit
beside it. **Read one only when the command you are running needs it:**

| Reference | Read it when |
|---|---|
| `artifacts.md` | writing or restructuring `questions.md`, `spec.md`, `tasks.md` or `context.md` |
| `panel.md` | dispatching any reviewer — spec panel, plan review, build checkpoint, validation |

Loading all three for a command that uses one is the cost this split exists to
avoid.

## State lives on disk, not in context

Every fact the workflow depends on is written to a file before the turn ends.
Context gets compacted, sessions end, days pass; the files survive. If it
matters, it is in a file.

## Language

Two audiences, two rules:

- **What a person reads** — `spec.md`, `questions.md`, `progress.md`, and
  everything you say to the user — in the language the user speaks.
- **What only agents read** — `context.md`, `reviews/`, dispatch prompts and what
  subagents return — in English, always. It costs fewer tokens per fact, and no
  person reads it raw. Quote the spec in its own language where exact wording
  matters.

Code, identifiers, file paths and commit messages stay in English. Never
announce either rule.

## Where a feature lives

```
.sdd/
  ACTIVE               one line: the slug of the active feature
  features/
    <slug>/
      progress.md      the ledger — phase, size, gates, decision log
      questions.md     open questions, and resolved ones with their rationale
      spec.md          the contract: what gets built and how you know it works
      context.md       the briefing every subagent reads instead of the codebase
      tasks.md         ordered tasks — the only place task status lives
      reviews/         one file per reviewer, per round or checkpoint
  archive/<slug>/      completed features, moved here by /sddx:archive
```

`<slug>` is kebab-case, from the feature name. `/sddx:new` writes `ACTIVE` and
`/sddx:archive` clears it; missing or empty means no active feature.

## progress.md — the ledger

The first thing you read and the last thing you write. Keep the header exactly
in this shape — the hooks parse it:

```markdown
# <Feature name>

- **slug:** <slug>
- **phase:** discovery | spec | planning | building | validation | done
- **size:** express | standard | deep
- **updated:** YYYY-MM-DD
```

Then a one-paragraph summary, the gates checklist, the panel note, and the
**decision log**: append-only, newest last, dated, one line per decision saying
what was decided and why. It is how a future session understands why the code
looks the way it does. Never rewrite it.

**Task status is not mirrored here.** It lives in `tasks.md` alone, and
`/sddx:status` reads it from there. A mirrored table doubled every status edit,
and the copy was always the one that drifted.

## Size

Every feature is classified once, at `/sddx:new`, before the interview, and
recorded as `size:`. Classify by what could go wrong, not by counting files:

| Size | The feature is… | Interview | Spec panel | Tasks | Build checkpoint |
|---|---|---|---|---|---|
| `express` | a known shape with known answers — a documented integration, CRUD over an existing model, an obvious implementation | 1 round | 2 seats, 1 round | 2–4 | once, at the end |
| `standard` | ordinary product work in a domain the project already models | 2–3 rounds | 3 seats, round 2 on trigger | up to ~8 | every 3 tasks |
| `deep` | genuinely uncertain — a new business rule, a redesign, regulated or irreversible, or a problem the user cannot yet state in a paragraph | until it stops changing the design | up to 6 seats, 2 rounds | as needed | every 2 tasks |

**What moves a feature up:** money, personal or regulated data, an irreversible
migration, a boundary between teams, a user who is unsure what they want.
**What does not:** file count, diff size, or how new the library is to you. A
Supabase login is `express` on the domain — its questions are about this
project's choices (which providers, what happens to existing users, where the
session lives), not about how Supabase works.

Say the class in one line with the reason, and that `--deep` or `--express`
overrides it. Log it. **Upgrade mid-flight** when a real unknown appears —
update `size:` and log why. Never downgrade.

## Phases and gates

| Phase | Command | Gate to leave it |
|---|---|---|
| `discovery` | `/sddx:new` | Every blocking question in `questions.md` is resolved |
| `spec` | `/sddx:spec` | The user has explicitly approved `spec.md` |
| `planning` | `/sddx:plan` | Every task has a verifiable acceptance criterion and a resolved dependency order |
| `building` | `/sddx:build` | Every task is `done` or explicitly `dropped` |
| `validation` | `/sddx:qa` | Every acceptance criterion in the spec is verified against real code |

**Never skip a gate, and never advance a phase on your own initiative** — the
user runs the command that advances it. Invoked in the wrong phase: say so,
name the right command, stop. The one exception: `/sddx:qa` may run any time
after `planning` as a check. It reports; it does not advance.

## Rules

1. **Read `progress.md` first; write it last.** Every command.
2. **One task at a time in `building`**, continuous runs included. Each task goes
   to a fresh implementer subagent, one after another, never two at once —
   parallel implementers collide on files and produce a diff nobody can review.
3. **Never mark a task `done` on code that was not run.** Unverified stays
   `in-progress`, and says what is unverified.
4. **A gate is not a formality.** If the user asks to skip one, state the risk,
   do what they say, and log it.
5. **Scope changes go through the spec.** A requirement found during `building`
   is added to `spec.md` and `tasks.md` with a decision-log entry — never quietly
   implemented.
6. **The spec is the contract, not the code.** If the code must diverge, update
   the spec in the same change.
7. **Each phase is worth a fresh session.** The artifacts exist so no phase needs
   the previous one's transcript. When a command hands off to the next, mention
   once, as an aside, that `/clear` first costs nothing.
8. **Read slices, not files.** The task's block, not all of `tasks.md`; the
   criteria a task satisfies, not the whole spec; a line range, not a module.
   Command output the same way: failures and the summary line, never a passing
   suite in full.
9. **Spend where uncertainty is.** Every round, seat, question and task is a cost
   the user pays. If you cannot say what a review would change, do not run it —
   an abandoned workflow finds no holes at all.
