#!/bin/bash
# ROVER6 SESSION BOOT — run at start of every Claude Code session

source .env 2>/dev/null || { echo "❌ No .env — run setup.sh first"; exit 1; }

REPO="Alphav00/flower-ops"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "#ROVER6 BOOTING — $TS"

# Pull open missions
echo ""
echo "=== OPEN MISSIONS ==="
curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/issues?labels=agent:ROVER6&state=open" | \
  python3 -c "
import sys, json
issues = json.load(sys.stdin)
if not issues:
    print('STANDBY — no missions assigned.')
else:
    for i in issues:
        labels = [l['name'] for l in i['labels']]
        print(f'#{i[\"number\"]} {i[\"title\"]}')
        print(f'  Labels: {labels}')
        print(f'  URL: {i[\"html_url\"]}')
"

# Notify Discord
if [ -n "$DISCORD_WEBHOOK" ]; then
  curl -s -o /dev/null -X POST -H "Content-Type: application/json" \
    -d "{\"content\":\"🔵 **#ROVER6** online at $TS\"}" \
    "$DISCORD_WEBHOOK"
fi
