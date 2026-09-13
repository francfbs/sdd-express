# Tasks — {{FEATURE_NAME}}

Ordered. A task may only depend on tasks above it. Each is sized to one
implementer dispatch — and as few, as vertical, as that allows. This file is the
only place task status lives.

Status: `todo` · `in-progress` · `done` · `blocked` · `dropped`

---

### T1 — {{title, stated as the outcome}}
- **status:** todo
- **depends on:** —
- **touches:** {{paths you expect to change, with line ranges where files are large}}
- **satisfies:** AC-1
- **acceptance:** {{how you will know this is done — a test that fails before
  and passes after, a command whose output changes, a behaviour you can drive}}

### T2 — {{title}}
- **status:** todo
- **depends on:** T1
- **touches:** {{paths}}
- **satisfies:** AC-2, AC-3
- **acceptance:** {{verifiable outcome}}
