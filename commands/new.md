---
description: Start a new feature — opens the workspace and interviews you until the problem is actually understood
argument-hint: <feature name>
---

Start a new feature: **$ARGUMENTS**

First, read the `sdd-protocol` skill. It defines the file layout, the phase
gates and the artifact formats. Follow it exactly.

## 1. Check for an active feature

Read `.sdd/ACTIVE`. If it names a feature that is not in `done` phase, stop and
tell the user which feature is open and what phase it is in. Ask whether to
park it or archive it first. Do not open a second feature silently.

## 2. Open the workspace

Derive a kebab-case `<slug>` from the feature name. Create
`.sdd/features/<slug>/` with `progress.md` and `questions.md` from the protocol
templates, filled in with the name, slug and today's date. Write the slug to
`.sdd/ACTIVE`. Set phase to `discovery`.

If this is the first feature in the project, also create `.sdd/README.md` with
two sentences explaining what the directory is, so a teammate who finds it in a
diff understands it.

## 3. Triage the size — before asking anything

Read the protocol's size table and classify this feature `express`, `standard`
or `deep`. Write it into `progress.md` as `size:` and log the reason in one line.

`$ARGUMENTS` may end with `--express` or `--deep`; that is the user's call and it
overrides yours. Log it as an override.

Tell the user in one line what you picked, why, and what it buys them — "express:
integration with a documented product, so one round of questions and a two-member
panel; say `--deep` if you want the full treatment." Then go.

Getting this wrong in the cheap direction is recoverable: you can upgrade at any
point in the interview, and the protocol expects you to. Getting it wrong in the
expensive direction burns a morning the user does not get back.

## 4. Interview the user

This is the real work of this command. Your goal is a problem you understand
well enough to spec — not a solution.

**Read the codebase first.** Before asking anything, look at `CLAUDE.md` and
enough of the project to know what exists. Every question you can answer by
reading is a question you must not ask. Nothing burns a user's patience faster
than being asked what their stack is.

**Let the size govern the depth.** `express` gets one round of three or four
questions. `standard` gets two or three. `deep` runs until the marginal question
stops changing the design. Do not run a `deep` interview on an `express`
feature because the topic is interesting.

**For a feature built on a product you already know**, the questions are about
*this project's* choices, never about the product. Which providers, what happens
to the users who already exist, where the session lives, who gets locked out
when it fails — not how the library works. You can read that.

**Ask in rounds of three or four questions, as multiple choice**, using
`AskUserQuestion`. Offer real options with real trade-offs — your best
recommendation first, marked as such. Users answer concrete options far better
than open prose, and an option list that shows you understood the domain is
itself a signal they can correct.

**Order matters. Start here and only move on when each is solid:**

1. **The problem.** What happens today, who it hurts, how they work around it.
   If the user opens with a solution, walk them back to the problem it solves —
   politely, once. The most common failure of this whole workflow is speccing a
   solution nobody checked against a real problem.
2. **Who and when.** The person doing this, the moment they do it, what else is
   happening around them. Volume: is this 3 times a week or 300 times a day?
3. **Done.** How they will know it worked. Push until you get something
   observable. "It's faster" becomes "the receptionist stops keeping the paper
   list".
4. **The boundary.** What is explicitly not part of this. Name the adjacent
   things you can imagine and ask which are out.
5. **Constraints that are already fixed** — deadlines, systems that cannot
   change, decisions already made elsewhere, people who must approve.

**Follow the thread.** When an answer opens something up, ask about it in the
next round rather than marching through a checklist. Three sharp rounds beat
six generic ones.

**Stop when the marginal question stops changing the design.** Typically three
to five rounds. Do not pad. When you notice you are asking things you could
decide yourself, you are done — decide them, and record them as decisions.

**Write as you go.** After each round, append the answers to `questions.md`
under Resolved, with the reasoning. Anything still unknown goes under Open,
marked `blocking` or `non-blocking`. If the session dies mid-interview, the
file is what survives.

**Notice durable domain knowledge as it goes past.** Some answers are about
this feature; others are facts about the business that will still be true in
five features' time — a rule about who may do what, a word the business uses
precisely, a regulation, a workflow practitioners actually follow. Mark those
mentally as you hear them. Step 4 turns them into the project's domain expert.

If an answer is one short follow-up away from being a durable domain fact, ask
the follow-up. It is the cheapest knowledge you will ever capture.

## 5. Distil the domain expert

**Skip this step entirely when the feature is `express`.** An express feature is
one whose answers were already known — it has, by definition, taught you nothing
durable about the business. Say in one line that you skipped it and why. This
step is 40 lines of work and a whole file of output; spending it on a login
integration produces a padded persona nobody will ever re-read, and a padded
persona is worse than the generic one.

For `standard` and `deep`: the panel's `sdd-domain-expert` ships generic, and
generic domain findings are worthless. You have just spent an interview learning
this business — turn that into the project's own expert. A project agent is
dispatchable under its bare name, so the file takes effect with nothing to
register.

Read `.claude/agents/sdd-domain-expert.md`.

**If it does not exist**, write it now, from what you learned in the interview
plus what you read in the codebase. Read the plugin's generic
`sddx:sdd-domain-expert` first and carry its review format across unchanged —
you are specialising the knowledge, not redesigning the output. Keep
`name: sdd-domain-expert` exactly: the protocol dispatches that bare name when
this file exists, and falls back to the plugin's namespaced one when it does not.

Replace the generic opening with a specific role that has standing — "a clinic
operations manager with twelve years running front-desk scheduling", not "a
domain expert" — and add the sections that carry the knowledge:

- **What you know that the spec's author may not** — the non-obvious rules,
  stated as facts concrete enough to test a spec against. This section is the
  entire value of the file.
- **The vocabulary** — each term, what it means here, and the wrong word people
  reach for instead.
- **Where this domain goes wrong** — the frequent real-world failures and their
  consequences, not error messages.
- **Regulatory and professional constraints** — what applies and where. Flag
  what you are unsure of rather than asserting it.

Rewrite the closing worthless-versus-real contrast with an example from *this*
domain. It calibrates the agent more than any instruction.

**If it already exists**, enrich it instead. Read it, then add only what this
interview taught that is not already there, and correct anything it got wrong.
Note the additions in one line each. Do not rewrite what is working — this file
is meant to accumulate across features, and its value comes from that accretion.

**Then show the user** the "What you know" and vocabulary sections — those are
the parts they can judge — and ask what is wrong or missing. A distilled expert
always gets one thing subtly wrong on the first pass, and it is always here. On
a `standard` feature that only added a line or two, show the additions alone.

If the interview did not yield enough durable domain knowledge to be worth a
file — a small internal tool, a purely technical change — say so and skip this
step rather than writing a padded persona. An expert full of filler is worse
than the generic one, because nobody re-reads it.

Log what you did in the decision log, one line.

## 6. Close discovery

When only non-blocking questions remain:

- Write a summary paragraph into `progress.md`
- Record the decisions taken so far in the decision log
- Confirm `size:` still reflects what the interview revealed; if it does not,
  upgrade it and log why
- Update `updated:` to today

Then show the user a **short** recap: the problem in one paragraph, the three
to five decisions that shape the feature, and anything still open. Ask them to
correct it.

Do not write `spec.md` and do not advance the phase. Tell them to run
`/sddx:spec` when the recap looks right — and mention once, as an aside, that
the ledger holds everything, so `/clear` first costs them nothing and keeps the
whole interview from riding along through the spec phase.
