#!/usr/bin/env bash
# sdd-express — SessionStart hook.
# If this project has an active feature, put its ledger header into context so a
# fresh session knows where the work stands without being told.
# stdout from a SessionStart hook is added to the session context.

set -u

[ -f .sdd/ACTIVE ] || exit 0

slug=$(tr -d '[:space:]' < .sdd/ACTIVE 2>/dev/null)
[ -n "$slug" ] || exit 0

prog=".sdd/features/${slug}/progress.md"
[ -f "$prog" ] || exit 0

phase=$(grep -m1 'phase:' "$prog" 2>/dev/null | sed 's/.*phase:[^ ]*[[:space:]]*//' | tr -d '*' | tr -d '[:space:]')

cat <<EOF
## Active sdd-express feature: ${slug} (phase: ${phase:-unknown})

This project has a spec-driven feature in progress. Its ledger is \`${prog}\`,
and the spec, questions and tasks sit beside it in \`.sdd/features/${slug}/\`.

Before doing any work on this feature, read that ledger and the \`sdd-protocol\`
skill. Do not advance a phase on your own initiative — the user runs the
\`/sdd:\` command that does it. \`/sdd:status\` gives the full briefing.

Ledger header:
EOF

sed -n '1,14p' "$prog" 2>/dev/null

exit 0
