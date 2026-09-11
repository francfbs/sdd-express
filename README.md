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

```bash
claude
> /plugin marketplace add francfbs/sdd-express
> /plugin install sdd-express@sdd-express
```

Or point it at a local clone:

```bash
git clone https://github.com/francfbs/sdd-express.git
claude
> /plugin marketplace add ./sdd-express
> /plugin install sdd-express@sdd-express
```

Nothing else to configure. The plugin brings its own commands, agents, skill and
hooks.

---

## The flow

```
/sdd:new <feature>     discovery    Claude reads your codebase, then interviews you
                                    in short rounds of multiple-choice questions.
                          │         Answers and rejected options land in questions.md.
                          ▼
/sdd:spec                 spec      Draft → the panel critiques it in parallel →
                                    gaps come back to you as concrete questions →
                          │         spec.md, with numbered acceptance criteria.
                          ▼         ⛔ gate: you must approve it explicitly.

/sdd:plan              planning     Spec becomes ordered tasks, each mapped to a
                                    criterion, each with a way to verify it.
                          │         The panel reviews the plan too.
                          ▼
/sdd:build             building     One task at a time. Implement, run the checks,
                    (repeat)        QA reviews the diff, ledger gets updated.
                          │         Scope changes go through the spec, not around it.
                          ▼
/sdd:qa               validation    Every acceptance criterion checked against real
                                    code. Failures become new tasks and it loops back.
                          │
                          ▼
/sdd:archive             done       Changelog, doc updates, and the whole paper trail
                                    moved to .sdd/archive/ for whoever comes next.
```

`/sdd:status` works at any point and tells you exactly where you are and what to
run next — written for someone who has been away for two weeks.

---

## The panel

Seven specialists, each a subagent with its own context window, its own
discipline and its own standards. They run **in parallel**, so a review round
costs the wall-clock time of its slowest member rather than the sum.

| Agent | Finds |
|---|---|
| `sdd-domain-expert` | Rules that do not match the real world; the vocabulary the domain actually uses; the unhappy paths practitioners hit daily |
| `sdd-ux-designer` | The states nobody specced — empty, loading, stale, error, offline; the cost of each interaction; error text; accessibility |
| `sdd-systems-architect` | Boundaries, failure modes, consistency, migration and rollback, operability — and over-engineering, which it is told to call out |
| `sdd-code-designer` | Abstractions that should not exist; what already exists to reuse; where behaviour belongs; names that will outlive everyone |
| `sdd-qa-engineer` | Criteria that cannot be verified; coverage holes; and at build time, the defect the author could not see |
| `sdd-security-reviewer` | Authorization per operation, object-level access, tenant isolation, where sensitive data leaks into logs and errors |
| `sdd-tech-writer` | Ambiguity that will become a bug; and at archive time, the changelog and doc deltas |

Only the relevant ones are convened. A pure-backend feature does not need the UX
designer; a feature that touches no auth and no personal data does not need the
security reviewer.

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
    progress.md              phase, gates, task status, and an append-only decision log
    questions.md             every question asked — resolved ones keep their rejected options
    spec.md                  the contract: behaviour, acceptance criteria, out of scope
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

- `/sdd:spec` will not draft around an unanswered blocking question
- `/sdd:plan` refuses to run against a spec you have not approved
- `/sdd:build` will not mark a task done on code it did not verify
- `/sdd:qa` reports **UNVERIFIED** rather than rounding up to pass

You can always override a gate. Claude will say what the risk is, do what you
asked, and write the override into the decision log.

---

## Customising it

**Bring your own domain expert.** `sdd-domain-expert` is deliberately generic,
and it is the one agent you should replace. Drop a `.claude/agents/` file in
your project with the same name and it wins over the plugin's — now the panel
has someone who knows obstetrics, or fixed income, or freight logistics:

```markdown
---
name: sdd-domain-expert
description: Domain critic for <your domain>.
tools: Read, Grep, Glob, Write, WebSearch
model: inherit
---

You are a <specific role> with N years in <domain>. You know that <the
non-obvious rules>, that practitioners actually <the real workflow>, and that
<the regulation> applies to <this data>.

[...keep the review format from the plugin's version...]
```

**Tune the models.** Agents default to `inherit` for the expensive judgement
calls (domain, architecture, security) and `sonnet` for the rest. Change the
`model:` field in any agent to trade cost against depth.

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
