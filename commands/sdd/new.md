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

## 3. Interview the user

This is the real work of this command. Your goal is a problem you understand
well enough to spec — not a solution.

**Read the codebase first.** Before asking anything, look at `CLAUDE.md` and
enough of the project to know what exists. Every question you can answer by
reading is a question you must not ask. Nothing burns a user's patience faster
than being asked what their stack is.

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

## 4. Close discovery

When only non-blocking questions remain:

- Write a summary paragraph into `progress.md`
- Record the decisions taken so far in the decision log
- Update `updated:` to today

Then show the user a **short** recap: the problem in one paragraph, the three
to five decisions that shape the feature, and anything still open. Ask them to
correct it.

Do not write `spec.md` and do not advance the phase. Tell them to run
`/sdd:spec` when the recap looks right.
