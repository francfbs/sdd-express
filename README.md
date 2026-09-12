# sdd-express

**Spec-driven feature development for [Claude Code](https://claude.com/claude-code).**

Most AI-assisted features start with a prompt and end with a diff nobody can
explain a month later. `sdd-express` puts a workflow in between: an interview
that produces a real specification, a panel of expert critics that finds its
holes before any code exists, tasks with acceptance criteria you can actually
check, and a ledger on disk that survives compaction, a closed terminal, and a
two-week gap.

It is deliberately close to spec-driven tools like OpenSpec, with two things
added: **a phased flow with gates**, and **expert personas that argue with the
spec before you build it.**

---

## Install

From your shell, not inside Claude Code:

```bash
claude plugin marketplace add francfbs/sdd-express   # register the catalogue
claude plugin install sddx@sdd-express               # install from it
```

Both are needed on a new machine: the second command looks the plugin up in a
local copy of the catalogue that the first one creates.

Then, in a Claude Code session that is already open:

```
/reload-plugins
```

`claude plugin install` runs outside the session, so the plugin loads on your
next launch or when you reload. Confirm with `/plugin list` — you should see
`sddx`, and `/sddx:new` in the command autocomplete.

It installs to **user scope** by default, which means every project. Use
`--scope project` to install it for everyone who clones one repository (this
writes `.claude/settings.json` there, which you then commit), or `--scope local`
for just yourself in just that repository.

<details>
<summary>Installing from the <code>/plugin</code> panel instead</summary>

`/plugin install sddx@sdd-express` inside a session does **not** install on its
own — it opens the plugin's detail view, and the install only happens once you
pick an installation scope there and confirm. Leaving that panel early looks
like the command worked when nothing was written. The full path is:

1. `/plugin` → **Discover** tab
2. Select `sddx`, press **Enter**
3. Choose a scope — **User**, **Project**, or **Local**
4. Confirm
5. **Esc** to close the panel; the reload runs for you

The shell commands above avoid the interactive step entirely, which is why they
are the recommended path.
</details>

Nothing else to configure. The plugin brings its own commands, agents, skill and
hooks.

### What it writes where

**Installing writes nothing to your project.** The plugin is cloned to
`~/.claude/plugins/marketplaces/sdd-express/` and registered in your user
settings. The one exception is installing at `project` scope, which records the
plugin in `.claude/settings.json` so everyone who clones the repo gets it.

**Using it creates two things in your project**, both meant to be committed:

```
.sdd/                                ← on /sddx:new — the ledger, spec, tasks, reviews
.claude/agents/sdd-domain-expert.md  ← the domain expert distilled from your interview
```

The second one is worth knowing about: the plugin writes a subagent into your
repo's own `.claude/agents/`. That is how this project gets a domain expert that
knows your business instead of the plugin's generic one — and it is yours to
edit or delete.

### Updating

```bash
> /plugin marketplace update sdd-express   # refresh the catalogue
> /plugin update sddx                      # update the plugin
> /reload-plugins                          # apply it to the running session
```

**Auto-update is off by default for third-party marketplaces like this one**, so
nothing arrives on its own. To have it keep itself current, run `/plugin`, go to
the **Marketplaces** tab, select `sdd-express`, and choose **Enable auto-update**.
Claude Code then refreshes shortly after each session starts and tells you when
to reload.

Updates are gated on the plugin's `version`, so you only receive a release when
that field is bumped — pushing commits alone changes nothing for anyone already
installed.

---

## The flow

```
/sddx:new <feature>     discovery   Claude sizes the feature, then interviews you
                                    in short rounds of multiple-choice questions.
                         │          Answers and rejected options land in questions.md,
                         │          and the domain expert is distilled from what you said.
                         ▼
/sddx:spec                   spec   Draft → the panel critiques it in parallel →
                                    gaps come back to you as concrete questions →
                         │          spec.md, with numbered acceptance criteria.
                         ▼          ⛔ gate: you must approve it explicitly.

/sddx:plan               planning   Spec becomes ordered tasks, each mapped to a
                                    criterion, each with a way to verify it.
                         │          The panel reviews the plan too.
                         ▼
/sddx:build              building   One task at a time: implement, run the checks,
                                    QA reviews the diff, ledger gets updated.
                         │          `/sddx:build all` runs straight through and stops
                         │          when something actually needs you.
                         ▼
/sddx:qa               validation   Every acceptance criterion checked against real
                                    code. Failures become new tasks and it loops back.
                         │
                         ▼
/sddx:archive                done   Changelog, doc updates, and the whole paper trail
                                    moved to .sdd/archive/ for whoever comes next.
```

`/sddx:status` works at any point and tells you exactly where you are and what to
run next — written for someone who has been away for two weeks.

**Run each phase in a fresh session.** The ledger exists so a phase does not need
the previous phase's transcript — `/clear` between commands and the discovery
interview stops riding along through every panel dispatch that follows. Each
command tells you when it is safe, which is: always.

---

## Not every feature gets the full treatment

A workflow that costs the same for a documented integration as for a new
business rule gets abandoned, and an abandoned workflow finds no holes at all.
So `/sddx:new` **sizes the feature first** and the size governs everything after:

| Size | The feature is… | Interview | Panel | Rounds |
|---|---|---|---|---|
| `express` | a known shape with known answers — a documented integration, CRUD over an existing model, an obvious implementation | 1 round | 2 members | 1 |
| `standard` | ordinary product work in a domain the project already models | 2–3 rounds | 3 members | 1, plus 2 on trigger |
| `deep` | genuinely uncertain — a new business rule, a redesign, something regulated or irreversible | until it settles | up to 6 | 2 |

What moves a feature up is risk — money, personal data, an irreversible
migration, a user who is not yet sure what they want. Not the size of the diff,
and not how new the library is to you.

Claude says which class it picked and why, and you override it with
`/sddx:new <name> --deep` or `--express`. It can upgrade mid-flight when the
interview turns up a real unknown; it never downgrades.

```
/sddx:new supabase-login              → express: 1 round, QA + security, done before lunch
/sddx:new consultation-billing        → deep:    the rules are the feature
```

---

## The panel

Seven specialists, each a subagent with its own context window, its own
discipline and its own standards. They run **in parallel**, so a review round
costs the wall-clock time of its slowest member rather than the sum.

| Agent | Finds |
|---|---|
| `sdd-domain-expert` | Rules that do not match the real world; the vocabulary the domain actually uses; the unhappy paths practitioners hit daily. **Rewrites itself per project** — see below |
| `sddx:sdd-ux-designer` | The states nobody specced — empty, loading, stale, error, offline; the cost of each interaction; error text; accessibility |
| `sddx:sdd-systems-architect` | Boundaries, failure modes, consistency, migration and rollback, operability — and over-engineering, which it is told to call out |
| `sddx:sdd-code-designer` | Abstractions that should not exist; what already exists to reuse; where behaviour belongs; names that will outlive everyone |
| `sddx:sdd-qa-engineer` | Criteria that cannot be verified; coverage holes; and at build time, the defect the author could not see |
| `sddx:sdd-security-reviewer` | Authorization per operation, object-level access, tenant isolation, where sensitive data leaks into logs and errors |
| `sddx:sdd-tech-writer` | Ambiguity that will become a bug; and at archive time, the changelog and doc deltas |

**Seats are capped, and they are filled in order.** QA takes the first seat
always — a spec whose criteria cannot be checked fails at every later phase. The
second goes to whichever discipline carries this feature's largest risk, not
every discipline that technically applies. The domain expert takes the third
when the feature has business rules that could be wrong in a way code review
would not catch. Claude says who it convened *and who it left out*, so you can
add a seat back when you know something it does not.

Each member works to a **briefing pack** — `context.md`, written once by the main
thread with the stack, the configuration, the files that matter and the decisions
already settled — rather than exploring your repo itself. Six critics each
grepping for the same auth configuration is the same reading paid six times, and
it was by far the largest cost in this workflow.

They also work to a budget: 8 tool calls, at most three blocking findings, 400
words. Finding nothing blocking is a real outcome, and a cheap one.

**Round 2 is the exception, not the default.** It runs only when resolving round 1
changed an acceptance criterion, the scope boundary, or a decision the spec rests
on — and then only the members whose findings drove the change. Copy-edits and
added detail do not qualify.

**They critique; they never decide.** Panel members run in isolation and cannot
talk to you. Claude consolidates their findings, fixes what it can, and brings
the genuine choices back to you as a small set of concrete questions. You never
see raw panel output.

---

## Where the state lives

On disk, in your repo, in plain Markdown:

```
.sdd/
  ACTIVE                     the slug of the feature in progress
  features/<slug>/
    progress.md              phase, size, gates, task status, and an append-only decision log
    questions.md             every question asked — resolved ones keep their rejected options
    spec.md                  the contract: behaviour, acceptance criteria, out of scope
    context.md               the briefing pack the panel reads instead of your codebase
    tasks.md                 ordered tasks, dependencies, acceptance criteria
    reviews/                 every panel review, by persona and round
  archive/<slug>/            finished features, kept whole
```

This is the whole point. Context gets compacted and sessions end; the files do
not. Commit `.sdd/` and your team gets the reasoning behind the code, not just
the code — including the options that were considered and rejected, which is
usually the part nobody writes down.

Two hooks keep it honest:

- **SessionStart** puts the active feature's ledger header into context, so a
  fresh session knows where things stand before you type anything.
- **Stop** blocks the turn from ending if code moved while the ledger did not.

---

## The gates

Each phase has a gate, and they are not decorative:

- `/sddx:spec` will not draft around an unanswered blocking question
- `/sddx:plan` refuses to run against a spec you have not approved
- `/sddx:build` will not mark a task done on code it did not verify
- `/sddx:qa` reports **UNVERIFIED** rather than rounding up to pass

You can always override a gate. Claude will say what the risk is, do what you
asked, and write the override into the decision log.

---

## Running the build

```bash
/sddx:build              # the next ready task, then stop
/sddx:build T7           # that specific task
/sddx:build all          # straight through, stopping when something needs you
/sddx:build through T5   # up to T5, then stop
```

Tasks always run **one at a time**, in dependency order, even in continuous
mode. Each is implemented, checked against the project's own test and lint
commands, reviewed by QA on its diff, and written into the ledger before the
next begins. Continuous mode asks once whether to commit per task, then honours
that for the whole run.

Continuous mode is not "run unattended until it breaks". It stops the moment it
reaches something a person should see:

- the task turned out to contradict the spec — that becomes an amendment you
  approve, never a silent change of plan
- QA or the security reviewer found something it cannot confidently fix
- a task is blocked, or everything remaining depends on one that is
- the project's checks fail for a reason that is not this task
- a real decision appeared — a trade-off, an ambiguity, two defensible designs
- two tasks ended unverified rather than done, so uncertainty is compounding

It tells you which condition fired and what the single next action is. Stopping
is the feature working, not failing.

**Implementation is deliberately not parallelised.** Parallel implementers
collide on the same files, arrive without the context this session has built up,
and produce a combined diff nobody can review. The parallelism goes where
isolation helps instead: the review panel.

---

## The domain expert builds itself

A generic domain expert produces generic findings, which are worthless. So the
one on the panel is not the generic one for long.

At the end of the discovery interview, `/sddx:new` **distils a domain expert from
what you just said** and writes it to `.claude/agents/sdd-domain-expert.md`.
From then on the panel convenes that one instead of the generic
`sddx:sdd-domain-expert` — nothing to register, nothing to configure, no second
interview.

It captures the things that are true about your business rather than about this
feature: the rules a newcomer gets wrong, the vocabulary the business uses
precisely, what practitioners actually do that the happy path ignores, the
regulation that applies.

**And it accumulates.** Every later `/sddx:new` enriches the same file with
whatever that interview taught, without rewriting what already works. After four
or five features it holds the domain knowledge of five interviews — which
reviews considerably better than anything you would write up front in one
sitting, because nobody knows all of it up front.

```
/sddx:new patient-timeline    → writes the expert: booking rules, no-show handling
/sddx:new bulk-export         → adds: LGPD retention, who may export identified data
/sddx:new shift-handover      → adds: who is accountable when cover staff act
```

You are shown the knowledge sections each time and asked what is wrong — a
distilled expert always gets one thing subtly wrong, and it is always there.

`express` features skip this step. They are the ones whose answers were already
known, so they have nothing durable to teach — and a padded persona is worse than
the generic one, because nobody re-reads it.

`/sddx:expert` is the manual door onto the same file: inspect what it knows,
correct it, build one up front, or add a second expert for a distinct domain
(`sdd-domain-expert-billing` alongside `sdd-domain-expert-clinical`).

---

## Customising it

**Tune the models.** Every agent defaults to `sonnet` — a critic reading a
two-page spec against a briefing pack does not need more. Set `model: inherit`
on the domain expert, architect or security reviewer to spend your session's
model on the judgement calls you care most about.

**Tune the budget.** The tool-call and finding limits live in each agent's *Your
budget* section, and the seat caps live in the protocol's size table. Raise them
for a project where a missed finding costs more than a long morning.

**Adjust the protocol.** Everything the workflow believes about phases, gates
and artifact formats lives in one file: `skills/sdd-protocol/SKILL.md`. Commands
and agents both defer to it, so that is where to make changes stick.

---

## Language

Artifacts are written in whatever language you speak to Claude in — the spec for
a Brazilian clinic comes out in Portuguese. Code, identifiers and commit
messages stay in English.

---

## Requirements

Claude Code with plugin support. The hooks use `bash`, `git`, `sed` and `grep` —
no `jq`, no Python, nothing to install. They degrade silently outside a git repo
or a project with no `.sdd/` directory.

## Contributing

Issues and pull requests welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). The
most useful contributions are new domain-expert personas and sharper review
criteria for the existing ones.

## Licence

MIT — see [LICENSE](LICENSE).
