# The review panel

Reference for the `sdd-protocol` skill. Read it before dispatching any reviewer.

Reviewers are subagents. They run isolated, cannot talk to the user, critique
and never decide. Each one is a cold context window, so every seat is a real
cost — convene the fewest that cover the risk.

## Who sits, where

| Where | Seats |
|---|---|
| `/sddx:spec` | by size: `express` 2, `standard` 3, `deep` up to 6 — filled in the order below |
| `/sddx:plan` | `express` none; `standard` QA; `deep` QA + code designer, + architect if infrastructure, migration or a service boundary is involved |
| build checkpoint | QA; + security reviewer if any task in the batch reported `sensitive: yes` |
| `/sddx:qa` | same cap as the spec panel, same order |

The spec and validation seats fill in this order, stopping at the cap:

1. **`sddx:sdd-qa-engineer`, always first.** A spec whose criteria cannot be
   checked fails at every later phase.
2. **The single discipline carrying the largest risk** — the row below that
   would hurt most if wrong, not every row that technically applies.
3. **The domain expert**, when the feature has business rules that could be wrong
   in a way code review would not catch. A pure integration does not need one.
4. Further seats, `deep` only, each with one line saying why.

| Candidate | When the feature… |
|---|---|
| `sddx:sdd-security-reviewer` | touches auth, permissions, personal or regulated data, payments, upload, or anything an untrusted caller can reach |
| `sddx:sdd-ux-designer` | has a user-facing surface whose states and error text are the hard part, CLI output included |
| `sddx:sdd-systems-architect` | crosses a process, service or network boundary, adds infrastructure, or changes how data is stored, migrated or deployed |
| `sddx:sdd-code-designer` | introduces a module, abstraction or public API |

`sddx:sdd-tech-writer` is never a seat; it runs at `/sddx:archive`.

Before dispatching, say in one line who you convened, which seat each fills,
and **who you left out**. The omission is the part the user can correct.

## The domain expert: project first

| Name | What it is |
|---|---|
| `sdd-domain-expert` | this project's `.claude/agents/` file — specialised, accumulates across features |
| `sddx:sdd-domain-expert` | the plugin's generic fallback |

If `.claude/agents/sdd-domain-expert.md` exists, dispatch `sdd-domain-expert`
and never the generic one as well. If it does not, dispatch the generic one and
say in one line that `/sddx:new` or `/sddx:expert` will build a real one — a user
who does not know the expert is generic will over-trust it. Unnamespaced
variants (`sdd-domain-expert-billing`) are project-level too.

When a review surfaces a durable domain fact — true in five features' time —
add it to the project expert file in one line, not only to the decision log.

## The dispatch

All seats **in one message, in parallel**. Each prompt is short, in English, and
points rather than pastes:

1. what is under review — the path to `spec.md` or `tasks.md`, or the exact
   `git diff` command for a diff
2. the path to `context.md`
3. **one question**, scoped to that discipline and this feature. A question
   narrow enough to be answered wrong is worth ten generic ones
4. the review file path: `reviews/<persona>-<round or checkpoint>.md`

Do not restate the budget or the output format. Each agent's own file carries
both, and repeating them in every dispatch is paying for them twice.

## The budget each agent enforces on itself

For reference — this lives in the agent files:

- at most 8 tool calls, not counting the project's own checks
- `context.md` plus at most five files it names; no repository sweeps
- at most 3 blocking and 3 non-blocking findings; the review file under 300 words
- returns **one line**: verdict, counts, path

## Consolidate

Read the review files. Never show the user raw panel output. Merge overlaps,
drop what the decision log already settles, and sort the rest into:

- **Gaps you can close yourself** — fix them, one line each on what changed
- **Questions only the user can answer** — as multiple choice, grouped; four
  sharp questions beat twelve
- **Disagreements between members** — both positions in a line each, your
  recommendation, the user decides

## Rounds

Round 1 always. **Round 2 only when resolving round 1 changed an acceptance
criterion, the scope boundary, or a decision the spec rests on.** Added detail,
closed assumptions and copy-edits do not qualify.

- `express` never runs round 2. If it needs one, it was misclassified: move it to
  `standard` and log that.
- Re-dispatch only the members whose findings drove the change, with the diff of
  what changed and one question: does this resolution hold?
- Never a round 3. It sharpens prose; it does not find holes.

When round 2 does not fire, say so in one line, so the user sees a decision
rather than an omission.
