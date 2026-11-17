#!/bin/bash
#
# Verify that no directive has been silently dropped from .claude/agent-notes.md.
#
# Why this exists: the file carries `merge=union` in .gitattributes, which Git applies
# to merges but NOT to rebase replays — so a rebase can drop the base branch's newer
# notes while keeping yours, with no conflict and no warning.
#
# A plain `git diff | grep '^-'` cannot answer the question, because superseding an
# entry in place (the documented convention) also shows up as a deleted line. This
# script separates the two: an entry may leave the file only by being rewritten in
# place under its own date stamp with a `(SUPERSEDED ...)` marker. Anything else is
# a real loss.
#
# Usage: Scripts/check-agent-notes.sh [base-ref]        (base-ref defaults to origin/main)

set -e

NOTES=".claude/agent-notes.md"
BASE="${1:-origin/main}"

if [ ! -f "$NOTES" ]; then
	echo "error: $NOTES not found (run from the repository root)" >&2
	exit 2
fi

if ! git rev-parse --verify --quiet "$BASE" > /dev/null; then
	echo "error: base ref '$BASE' not found — fetch it first" >&2
	exit 2
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Entry lines only (YYYY-MM-DD — ...); ignore the header and rules block.
git show "$BASE:$NOTES" | grep '^20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] — ' > "$TMP/base.txt" || true
grep '^20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] — ' "$NOTES" > "$TMP/current.txt" || true

LOST=0
MARKED=0

# Every base entry must still be present verbatim, or survive as a superseded rewrite.
while IFS= read -r entry; do
	[ -z "$entry" ] && continue
	if grep -Fxq "$entry" "$TMP/current.txt"; then
		continue
	fi

	date_stamp="${entry:0:10}"
	if grep -qE "^$date_stamp — \((SUPERSEDED|REVISED) " "$TMP/current.txt"; then
		MARKED=$((MARKED + 1))
		echo "marked      $date_stamp — $(printf %.80s "${entry#*— }")..."
		continue
	fi

	LOST=$((LOST + 1))
	echo "LOST        $date_stamp — $(printf %.80s "${entry#*— }")..." >&2
done < "$TMP/base.txt"

echo
echo "base $BASE: $(wc -l < "$TMP/base.txt" | tr -d ' ') entries; current: $(wc -l < "$TMP/current.txt" | tr -d ' ') entries"

if [ "$LOST" -gt 0 ]; then
	cat >&2 <<-MSG

		$LOST directive(s) dropped without a marker.

		Repair by rebuilding from the base and re-appending only your own lines:
		    git show $BASE:$NOTES > $NOTES
		Never reconstruct from an older commit — that deletes every note added
		between it and the base.

		If the change WAS intentional, rewrite the entry in place instead: keep its
		date stamp and prefix it with "(SUPERSEDED <date> — ...)" if its substance no
		longer applies, or "(REVISED <date> — ...)" if you corrected it and it stands.
	MSG
	exit 1
fi

echo "OK — no directives dropped ($MARKED rewritten in place)."
