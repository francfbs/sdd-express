---
description: Inspect, refine, or hand-build this project's domain expert outside a feature flow
argument-hint: "[what to add or correct, optional]"
---

Work on this project's domain expert: **$ARGUMENTS**

Normally you do not need this command. `/sdd:new` distils the domain expert from
the discovery interview and enriches it on every later feature. Use this when
you want to work on the expert directly:

- **Inspect** what it currently knows
- **Correct** something it got wrong, or add knowledge it missed
- **Build one up front**, before the first feature
- **Add a second expert** for a distinct domain in the same system

The file is `.claude/agents/sdd-domain-expert.md`. Project agents outrank plugin
agents, so it takes effect on its own — nothing to register.

## If no argument was given

Read `.claude/agents/sdd-domain-expert.md`.

**If it exists:** summarise what it knows — the rules, the vocabulary, the
failure modes, the regulation — and say plainly where it is thin. Compare it
against the specs in `.sdd/features/` and `.sdd/archive/`: domain facts that
show up in those but not in the expert are exactly what is missing. Offer to add
them.

**If it does not exist:** say so, and offer the two paths. Running `/sdd:new`
gets you one for free as a by-product of the next feature, which is the cheaper
route. Building one now means an interview — worth it only if you are about to
start several features at once.

## If an argument was given

Apply it. `$ARGUMENTS` is usually a correction ("cancellations inside 24h still
bill the patient") or an addition ("we're subject to LGPD, records kept 20
years"). Fold it into the right section, keep the file's shape, and confirm in
one line what changed.

## Building one from scratch

Read `CLAUDE.md`, `README.md`, the data model and the core module names first,
and state what you inferred rather than asking about it — being wrong out loud
is faster than twenty questions. Then interview in **three rounds** of
multiple-choice questions, mining only for what is *not* in the code:

1. **Who and what** — the users by real job title, the one workflow the software
   exists to support, where the money or the risk sits.
2. **The non-obvious rules** — what a newcomer gets wrong; what must be true
   before an action is allowed and who may do it; what must be recorded for
   legal or professional reasons; which words the business uses precisely, and
   which ones the code currently gets wrong. This is the round that matters.
3. **Where it hurts** — the frequent real-world failures, the expensive mistake,
   the regulation and its jurisdiction, and what practitioners do that the happy
   path ignores: corrections after the fact, duplicates, covering a shift.

Then write the file exactly as `/sdd:new` step 4 describes: the plugin's review
format carried across unchanged, a specific role with standing, and the four
knowledge sections — what you know that the author may not, the vocabulary,
where this domain goes wrong, regulatory constraints. Close with a
worthless-versus-real contrast drawn from this domain.

## Adding a second expert

Large systems hold more than one domain — billing is not clinical care. Write
`.claude/agents/sdd-domain-expert-<area>.md` with a matching `name:`, and record
in `.sdd/README.md` which expert covers which area, so future sessions convene
the right one.

## Always

Show the user the "What you know" section and the vocabulary after any change.
Those are the parts they can judge, and the parts a distilled expert gets subtly
wrong.
