---
description: Show where the active feature stands, and what to do next
argument-hint: "[slug — defaults to the active feature]"
allowed-tools: Read, Grep, Glob, Bash(cat:*), Bash(ls:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*)
---

Active feature: !`cat .sdd/ACTIVE 2>/dev/null || echo "(none)"`

Features on disk: !`ls -1 .sdd/features/ 2>/dev/null || echo "(none)"`

---

Read the `sdd-protocol` skill if you have not already.

Report on the feature named in `$ARGUMENTS`, or the active one if no argument.
If there is no active feature and no argument, list what is in `.sdd/features/`
and `.sdd/archive/` and stop.

Read `progress.md`, `tasks.md` and `questions.md`. Then give the user a briefing
that stands on its own — assume they have been away for two weeks:

1. **Feature and phase** — one line, plus how long since `updated:`.
2. **What it is** — the summary paragraph, as written.
3. **Gates** — which are ticked, which is next.
4. **Tasks** — counts by status, then the specific tasks that are
   `in-progress` or `blocked` and what each is waiting on. Do not print the
   whole table if it is long; print what is live.
5. **Open questions** — blocking ones first.
6. **The last three decisions** from the log, with their reasoning.
7. **Next action** — the exact command to run, and why that one.

If the repo is dirty, say which of the changed files belong to this feature's
current task and which do not — uncommitted work that nobody has recorded is
the most common way this workflow loses state.

Flag anything inconsistent rather than smoothing it over: a task marked `done`
whose files were never touched, a phase that does not match the gates, a spec
marked approved with no approval in the log. Those mean the ledger drifted from
reality, and the user needs to know before they build on it.
