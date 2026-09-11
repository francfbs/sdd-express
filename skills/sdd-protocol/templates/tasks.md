# Tasks — {{FEATURE_NAME}}

Ordered. A task may only depend on tasks above it. Sized so one task is one
reviewable sitting — if it touches more than ~5 files or spans layers without a
reason, split it.

Status: `todo` · `in-progress` · `done` · `blocked` · `dropped`

---

### T1 — {{title, stated as the outcome}}
- **status:** todo
- **depends on:** —
- **touches:** {{paths you expect to change}}
- **satisfies:** AC-1
- **acceptance:** {{how you will know this is done — a test that fails before
  and passes after, a command whose output changes, a behaviour you can drive}}

### T2 — {{title}}
- **status:** todo
- **depends on:** T1
- **touches:** {{paths}}
- **satisfies:** AC-2, AC-3
- **acceptance:** {{verifiable outcome}}
