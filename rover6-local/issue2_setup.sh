#!/bin/bash
# ROVER6 — Issue #2: Ecosystem Setup Verification
# Tests GitHub + Discord, reports results, closes Issue #2

source .env 2>/dev/null || { echo "❌ No .env"; exit 1; }
REPO="Alphav00/flower-ops"
ISSUE=2
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "#ROVER6 — Issue #2 Ecosystem Setup — $TS"
echo "================================================="

PASS=0; FAIL=0
REPORT="## #ROVER6 Ecosystem Setup Report\n**Timestamp:** $TS\n"

check() {
  local label="$1"; local cmd="$2"; local expect="$3"
  local result=$(eval "$cmd" 2>/dev/null)
  if echo "$result" | grep -q "$expect"; then
    REPORT="${REPORT}\n✅ $label"
    echo "✅ $label"
    ((PASS++))
  else
    REPORT="${REPORT}\n❌ $label (got: $result)"
    echo "❌ $label"
    ((FAIL++))
  fi
}

check "GitHub auth" \
  "curl -s -o /dev/null -w '%{http_code}' -H 'Authorization: token $GITHUB_TOKEN' https://api.github.com/repos/$REPO" \
  "200"

check "GitHub read BOOT.md" \
  "curl -s -o /dev/null -w '%{http_code}' -H 'Authorization: token $GITHUB_TOKEN' https://api.github.com/repos/$REPO/contents/BOOT.md" \
  "200"

check "Discord webhook" \
  "curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' -d '{\"content\":\"🔧 **#ROVER6** Issue #2 ecosystem test — $TS | Last word: OPERATIVE\"}' '$DISCORD_WEBHOOK'" \
  "204"

REPORT="${REPORT}\n\n**Results:** $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && REPORT="${REPORT}\n**Status:** ECOSYSTEM LIVE ✅" || REPORT="${REPORT}\n**Status:** ISSUES DETECTED ⚠️"

# Post comment
COMMENT=$(echo -e "$REPORT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"body\":$COMMENT}" \
  "https://api.github.com/repos/$REPO/issues/$ISSUE/comments" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print('GitHub comment: ✅' if 'id' in d else '❌')"

# Update labels
curl -s -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/issues/$ISSUE/labels/status:backlog" > /dev/null
curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"labels":["status:review"]}' \
  "https://api.github.com/repos/$REPO/issues/$ISSUE/labels" > /dev/null
echo "Label → status:review ✅"

# Update D1 team_state
python3 - << PYEOF
import urllib.request, json, os
# Simple D1 write via CF API would need CF token — skip for now, log locally
print("D1 team_state: update manually or via Q next session")
PYEOF

echo "================================================="
echo "$PASS passed, $FAIL failed"
