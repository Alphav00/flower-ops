#!/bin/bash
# ROVER6 — Issue #1: Environment Audit
# Runs audit, posts results as GitHub comment, notifies Discord
# Usage: bash issue1_audit.sh

source .env 2>/dev/null || { echo "❌ No .env"; exit 1; }
REPO="Alphav00/flower-ops"
ISSUE=1
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "#ROVER6 — Issue #1 Environment Audit — $TS"
echo "================================================="

REPORT=""
add() { REPORT="${REPORT}\n$1"; echo -e "$1"; }

add "## #ROVER6 Environment Audit"
add "**Timestamp:** $TS"
add ""
add "### System"
add '```'
add "OS: $(uname -s) $(uname -m)"
add "Shell: $SHELL | User: $(whoami)"
add "Disk: $(df -h / | awk 'NR==2{print $3"/"$2" used ("$5")"}')"
add "RAM: $(free -h | awk '/^Mem/{print $3"/"$2" used"}')"
add '```'

add "### Tools"
add '```'
for cmd in git curl python3 python docker node npm pip3 claude; do
  if command -v $cmd &>/dev/null; then
    add "✅ $cmd: $(${cmd} --version 2>&1 | head -1)"
  else
    add "⚠️  $cmd: not found"
  fi
done
add '```'

add "### Docker"
add '```'
if command -v docker &>/dev/null; then
  add "$(docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null | head -10)"
  add ""
  add "Images:"
  add "$(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | head -10)"
else
  add "Docker not found"
fi
add '```'

add "### Network"
add '```'
add "Tailscale: $(tailscale status 2>/dev/null | head -1 || echo 'not found')"
add "External IP: $(curl -s --max-time 3 ifconfig.me || echo 'timeout')"
add '```'

add "### GitHub Access"
add '```'
GH=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO")
add "flower-ops: HTTP $GH $([ "$GH" = "200" ] && echo "✅" || echo "❌")"
add '```'

# Post to GitHub Issue as comment
COMMENT=$(echo -e "$REPORT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"body\":$COMMENT}" \
  "https://api.github.com/repos/$REPO/issues/$ISSUE/comments" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print('GitHub comment: ✅' if 'id' in d else '❌')"

# Update label to review
curl -s -X DELETE \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/issues/$ISSUE/labels/status:backlog" > /dev/null
curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"labels":["status:review"]}' \
  "https://api.github.com/repos/$REPO/issues/$ISSUE/labels" > /dev/null
echo "Label → status:review ✅"

# Ping Discord
if [ -n "$DISCORD_WEBHOOK" ]; then
  curl -s -o /dev/null -X POST -H "Content-Type: application/json" \
    -d "{\"content\":\"📋 **#ROVER6** Issue #1 complete — Environment Audit posted for Q review. $TS\"}" \
    "$DISCORD_WEBHOOK"
  echo "Discord notified ✅"
fi

echo "================================================="
echo "Issue #1 done. Q will review and close."
