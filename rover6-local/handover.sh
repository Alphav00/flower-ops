#!/bin/bash
# ROVER6 handover.sh — run at end of every session
# Prompts for what happened, writes HANDOVER file to GitHub + D1

source .env 2>/dev/null || { echo "❌ No .env"; exit 1; }
REPO="Alphav00/flower-ops"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE=$(date -u +"%Y-%m-%d")
AGENT="ROVER6"

echo "#ROVER6 — SESSION HANDOVER"
echo "================================================="

echo -n "TO (Q/Chi/ALL): "; read -r TO
echo -n "STATUS (NOMINAL/BLOCKED/NEEDS_REVIEW/URGENT): "; read -r STATUS
echo "COMPLETED (one per line, blank line to finish):"
COMPLETED=""
while IFS= read -r line && [ -n "$line" ]; do
  COMPLETED="${COMPLETED}- ${line}\n"
done
echo "BLOCKED (one per line, blank line to finish, or press enter for NONE):"
BLOCKED=""
while IFS= read -r line && [ -n "$line" ]; do
  BLOCKED="${BLOCKED}- ${line}\n"
done
[ -z "$BLOCKED" ] && BLOCKED="- NONE\n"
echo "NEXT actions (one per line, blank line to finish):"
NEXT=""
while IFS= read -r line && [ -n "$line" ]; do
  NEXT="${NEXT}- ${line}\n"
done
echo -n "CONTEXT (one line): "; read -r CONTEXT

FILE="handoffs/HANDOVER_${AGENT}_${DATE}.md"

BODY="AGENT:     $AGENT
DATE:      $TS
TO:        $TO
STATUS:    $STATUS

COMPLETED:
$(echo -e "$COMPLETED")
BLOCKED:
$(echo -e "$BLOCKED")
NEXT:
$(echo -e "$NEXT")
CONTEXT:
$CONTEXT"

# Push to GitHub
python3 - << PYEOF2
import urllib.request, json, base64, os

token = os.environ.get("GITHUB_TOKEN", "")
repo = "$REPO"
path = "$FILE"
body = """$BODY"""

try:
    r = urllib.request.urlopen(urllib.request.Request(
        f"https://api.github.com/repos/{repo}/contents/{path}",
        headers={"Authorization": f"token {token}"}
    ))
    sha = json.load(r).get("sha", "")
except:
    sha = ""

payload = json.dumps({
    "message": f"handover: {path}",
    "content": base64.b64encode(body.encode()).decode(),
    **({"sha": sha} if sha else {})
}).encode()

req = urllib.request.Request(
    f"https://api.github.com/repos/{repo}/contents/{path}",
    method="PUT",
    headers={"Authorization": f"token {token}", "Content-Type": "application/json"},
    data=payload
)
with urllib.request.urlopen(req) as r:
    d = json.load(r)
    print("GitHub: ✅ " + path if "content" in d else "❌ " + str(d))
PYEOF2

# Notify Discord
curl -s -o /dev/null -X POST -H "Content-Type: application/json" \
  -d "{\"content\":\"📋 **#ROVER6 HANDOVER → $TO** | Status: $STATUS | $TS\"}" \
  "$DISCORD_WEBHOOK"
echo "Discord: ✅"

echo "================================================="
echo "Handover complete. tmux detach or close session."
