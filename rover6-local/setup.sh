#!/bin/bash
# ROVER6 ECOSYSTEM SETUP
# Run once after FTP to PC. Sets up GitHub + Discord + local env.
# All reads. No writes until Step 5 test.

set -e
BOLD="\033[1m"; GREEN="\033[0;32m"; RED="\033[0;31m"; YELLOW="\033[1;33m"; NC="\033[0m"
REPO="Alphav00/flower-ops"
D1_ID="b240d384-26a1-42bf-8c38-d055c7431043"

echo -e "${BOLD}#ROVER6 — ECOSYSTEM SETUP${NC}"
echo "================================================="

# ── STEP 1: Load .env ──
if [ ! -f .env ]; then
  cp .env.template .env
  echo -e "${YELLOW}Created .env from template. Fill in your values, then re-run.${NC}"
  exit 0
fi
source .env

echo -e "\n${BOLD}STEP 1 — Environment${NC}"
[ -z "$GITHUB_TOKEN" ] && echo -e "${RED}❌ GITHUB_TOKEN missing${NC}" && exit 1
[ -z "$DISCORD_WEBHOOK" ] && echo -e "${YELLOW}⚠️  DISCORD_WEBHOOK missing — notifications disabled${NC}"
echo -e "${GREEN}✅ .env loaded${NC}"

# ── STEP 2: System check ──
echo -e "\n${BOLD}STEP 2 — System${NC}"
echo "OS: $(uname -s) $(uname -m)"
echo "Shell: $SHELL"
echo "User: $(whoami)"
for cmd in git curl python3 docker; do
  if command -v $cmd &>/dev/null; then
    echo -e "${GREEN}✅ $cmd: $(command -v $cmd)${NC}"
  else
    echo -e "${YELLOW}⚠️  $cmd: not found${NC}"
  fi
done

# ── STEP 3: GitHub connectivity ──
echo -e "\n${BOLD}STEP 3 — GitHub${NC}"
GH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO")
if [ "$GH_STATUS" = "200" ]; then
  echo -e "${GREEN}✅ GitHub: connected to $REPO${NC}"
else
  echo -e "${RED}❌ GitHub: HTTP $GH_STATUS — check token${NC}"
  exit 1
fi

# Pull BOOT.md to confirm read access
BOOT=$(curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/contents/BOOT.md" | \
  python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d[content]).decode()[:80])" 2>/dev/null)
echo "BOOT.md preview: ${BOOT:0:60}..."

# ── STEP 4: Discord webhook ──
echo -e "\n${BOLD}STEP 4 — Discord${NC}"
if [ -n "$DISCORD_WEBHOOK" ]; then
  DC_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST -H "Content-Type: application/json" \
    -d "{\"content\":\"🟢 **#ROVER6 ONLINE** — Ecosystem setup complete. Ready for missions.\"}" \
    "$DISCORD_WEBHOOK")
  if [ "$DC_STATUS" = "204" ]; then
    echo -e "${GREEN}✅ Discord: webhook live — check your channel${NC}"
  else
    echo -e "${RED}❌ Discord: HTTP $DC_STATUS — check webhook URL${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  Discord: skipped (no webhook configured)${NC}"
fi

# ── STEP 5: Check open missions ──
echo -e "\n${BOLD}STEP 5 — Open Missions${NC}"
ISSUES=$(curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/issues?labels=agent:ROVER6,status:backlog&state=open" | \
  python3 -c "
import sys,json
issues = json.load(sys.stdin)
if not issues:
  print(No