#!/usr/bin/env bash
# sdd-express — Stop hook.
# The workflow's failure mode is code that moves while the ledger does not.
# If a feature is mid-build, the tree has real changes, and progress.md was not
# touched today, block the stop and say what to record.
#
# Exit 0 = allow stop. Exit 2 = block, stderr goes back to the model.

set -u

input=$(cat 2>/dev/null || echo '')

# Loop guard: never block a stop that was already triggered by this hook.
case "$input" in
  *'"stop_hook_active"'*'true'*) exit 0 ;;
esac

[ -f .sdd/ACTIVE ] || exit 0

slug=$(tr -d '[:space:]' < .sdd/ACTIVE 2>/dev/null)
[ -n "$slug" ] || exit 0

prog=".sdd/features/${slug}/progress.md"
[ -f "$prog" ] || exit 0

phase=$(grep -m1 'phase:' "$prog" 2>/dev/null | sed 's/.*phase:[^ ]*[[:space:]]*//' | tr -d '*' | tr -d '[:space:]')
case "$phase" in
  building|validation) ;;
  *) exit 0 ;;
esac

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Real changes = anything outside .sdd/ itself.
changed=$(git status --porcelain 2>/dev/null | grep -v '\.sdd/' | head -c 1)
[ -n "$changed" ] || exit 0

updated=$(grep -m1 'updated:' "$prog" 2>/dev/null | sed 's/.*updated:[^ ]*[[:space:]]*//' | tr -d '*' | tr -d '[:space:]')
today=$(date +%F)
[ "$updated" = "$today" ] && exit 0

cat >&2 <<EOF
sdd-express: the ledger has drifted from the code.

Feature '${slug}' is in phase '${phase}', the working tree has uncommitted
changes outside .sdd/, and ${prog} still reads "updated: ${updated}".

Before finishing: set each touched task's status in tasks.md and the progress.md
table, append a decision-log entry for anything decided this turn, and set
updated: to ${today}. If the changes are unrelated to this feature, say so
explicitly and set updated: anyway so this stops firing.
EOF

exit 2
