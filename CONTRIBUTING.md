# Contributing to sdd-express

Contributions are welcome. This project is mostly prompts, so "code quality"
here means: is the instruction specific enough that a model does the right thing
without being told twice?

## What helps most

**New domain-expert personas.** `sdd-domain-expert` is generic by design. A
version that genuinely knows healthcare scheduling, fintech compliance, or
logistics is worth more than any refactor. Put them in `agents/domains/` and
document what they assume.

**Sharper review criteria.** If a persona missed something in real use, that is
a bug. Add the criterion that would have caught it — with the concrete example,
not a general principle.

**Bug reports from real features.** Where the flow fell apart: a gate that
blocked something it should not have, a hook that fired wrongly, a phase that
got stuck. Include what you ran and what happened.

## The one rule for prompts

**Be specific enough to act on.** Every persona file ends with a contrast
between a worthless finding and a real one, because that contrast does more work
than paragraphs of instruction. If you add criteria, add them in that register:

> "Consider edge cases" is worthless.
> "`canCancel` compares `startsAt - now > 2h` in local time, so a booking across
> the DST boundary is cancellable an hour late" is the review.

Related conventions, all deliberate:

- Personas **critique and never edit code.** They write one file: their review.
  The only exception is `sdd-tech-writer`, which may edit prose in `spec.md`.
- Personas **return at most 10 lines.** Detail goes in the review file; the
  orchestrator reads that if it needs to. This keeps the main context usable.
- Personas **stay in their lane.** Overlapping findings waste the user's
  attention more than a missed finding costs.
- Artifacts follow **the user's language**; code and commits stay English.

## Changing the workflow itself

Phases, gates and artifact formats live in `skills/sdd-protocol/SKILL.md`, and
it is authoritative — commands defer to it. Change the protocol first, then any
command that references what you changed. A command that contradicts the
protocol is a bug in the command.

## Testing a change

There is no test suite; it is prompts. Before opening a PR:

1. Install your branch locally: `/plugin marketplace add ./sdd-express`
2. Run a real feature end to end — `/sdd:new` through `/sdd:archive` — on a
   throwaway project. Small is fine; it needs to be real, not hypothetical.
3. If you touched a hook, run `bash hooks/<script>.sh` directly against a
   synthetic `.sdd/` directory and check both the firing and the silent paths.
4. Say in the PR what you ran and what it did.

## Pull requests

One concern per PR. Say what problem you hit and why this fixes it. If you
changed a persona, include a before/after of a finding it now catches — that is
the clearest possible evidence.

## Branching and releases

Plain GitHub Flow. There is no `develop` branch and no release branches — this
is a prompt repository with no build step, and that machinery would only add
ceremony.

```
main ──●────────●────────●──────────●──  always installable
        \      /          \        /
         ●────●            ●──────●       feat/… or fix/…
```

- **`main` is always installable.** It is the repository's default branch, so it
  is what every new `/plugin install` fetches. A broken `main` is broken for
  everyone who installs that day.
- **One branch per change**, named `feat/<thing>` or `fix/<thing>`. Open a PR
  even for small changes — a prose diff is far easier to judge in a PR view than
  in an editor, and on a public repo the PR is where the reasoning is recorded.
- **Squash on merge.** The branch's working commits are noise; the PR title and
  body are the history worth keeping.

### Releasing: bump the version, or nobody gets it

This is the part that is easy to get wrong. `version` in
`.claude-plugin/plugin.json` gates updates: Claude Code compares the installed
version string against the manifest, and **if it has not changed, existing users
keep their cached copy no matter how many commits you push.** New installs get
the newest `main`; everyone already on the plugin gets nothing.

So a release is two things, together:

1. Bump `version` in `.claude-plugin/plugin.json`
2. Tag the merge commit: `git tag -a v0.2.0 -m "..." && git push --tags`

The tag is not what distributes the plugin — `main` does that — but it gives
anyone who wants stability something to pin with `ref` in their own marketplace
entry.

Set `version` in `plugin.json` only. The docs are explicit that `plugin.json`
silently wins over a version in the marketplace entry, so having both means one
of them is a lie waiting to confuse someone.

### What counts as major, minor, patch

Semver on prompts needs a sharper rule than "breaking change". The one that
matters here is **whether it breaks a feature someone has in flight**:

| Bump | Means |
|---|---|
| **patch** | Sharper review criteria, clearer instructions, fixed wording. Behaviour is the same shape, just better. |
| **minor** | A new command, a new persona, a new optional field in an artifact. Existing `.sdd/` directories keep working untouched. |
| **major** | The `.sdd/` layout changes, a command is renamed or removed, or an artifact's required format changes — anything that strands someone mid-feature. |

A major bump needs a migration note in the release body saying what to do with
an open feature. Someone will be in `building` when they update.

### Dogfooding

The plugin is developed with itself: `.sdd/` in this repository is committed and
public. That is deliberate — it is both the best test of the workflow and the
clearest documentation of what its output actually looks like. A change to how a
phase behaves should be visible in this repo's own `.sdd/` directory.

## Licence

Contributions are accepted under the MIT licence.
