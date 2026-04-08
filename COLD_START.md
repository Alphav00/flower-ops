# COLD START GUIDE — flower-ops Agency
## For anyone picking this up from zero
**Written: 2026-04-07 | Author: Q**

If you are reading this without Chi present — welcome.
Everything you need to understand, start, and continue this work is here.
Read it top to bottom before touching anything.

---

## WHAT IS THIS

flower-ops is a small AI agent agency built by Chi (Lady Chi, aka Alphav00).
It coordinates three AI agents — Q (strategist), ROVER6 (executor), S4TA (bulk processor) —
to accomplish tasks without Chi having to manually relay information between them.

Chi is an independent researcher. This agency supports her work and automates her operations.
The research itself lives separately. This system is the operational layer.

---

## THE TEAM

| Agent | Identity | Model | Role | Lives Where |
|---|---|---|---|---|
| Chi | Lady Chi | Human | Principal — commands everything | Phone + PC |
| Q | S1r.Q.8utt3rsw0rth | Claude Opus/Sonnet | Strategist, architect, planner | Claude.ai project |
| ROVER6 | #ROVER6 | Claude Code | Executor — runs scripts, writes files | PC via SSH |
| S4TA | N4p0l30n S4t4 | Gemini | Bulk processing, formatting | Gemini |

**The chain of command:** Chi commands all. Q plans and specs. ROVER6 builds and executes.
S4TA handles large text/data jobs. No agent overrides another's domain.

---

## THE INFRASTRUCTURE

### GitHub — flower-ops repo
**URL:** https://github.com/Alphav00/flower-ops
**Owner:** Alphav00
**Purpose:** Single source of truth. All files, all handovers, all missions.

Key files:
- `BOOT.md` — every agent reads this first on session open
- `CLAUDE.md` — Q's constitution and operating rules (v3.2)
- `ROVER6.md` — ROVER6's constitution (v1.5)
- `S4TA.md` — S4TA's constitution (v2.0)
- `GOALS.md` — agency mission board, priorities, status
- `MODEL_ROUTING.md` — who does what, when, at what cost
- `MSH_active.md` — current mission heuristics (empty = standby)
- `handoffs/` — all session handover records
- `rover6-local/` — ROVER6's local scripts (clone and run on PC)

### Cloudflare D1 — flower-ops-state database
**Database name:** flower-ops-state
**Database ID:** b240d384-26a1-42bf-8c38-d055c7431043
**Purpose:** Shared state — secrets, agent status, handoff log

Tables:
- `secrets` — credentials (GitHub token, Discord webhook, bot token, CF token)
- `team_state` — what each agent is doing right now
- `handoff_log` — session history, what was done, what is blocked, what is next

**How to query:** Cloudflare dashboard → D1 → flower-ops-state → Console
Or via Cloudflare MCP connector in Claude project (Q uses this)

### Discord — private server
**Server name:** •－•✧•－•
**Key channel:** #bot
**Purpose:** Notifications and command dispatch

What fires to Discord automatically:
- Every GitHub Issue open/close/comment
- Every push to flower-ops repo
- Agent status pings (ROVER6 online/offline)

Commands Chi can type in #bot:
- `!ROVER6 <task>` → opens GitHub Issue assigned to ROVER6
- `!Q <task>` → opens GitHub Issue assigned to Q
- `!SATA <task>` → opens GitHub Issue assigned to S4TA
- `!status` → lists all open Issues
- `!help` → shows commands

### PC — Windows with WSL
**Location:** Chi's desktop PC (hostname: BLD)
**Access:** SSH via Tailscale
**ROVER6 lives here:** WSL (Ubuntu), tmux session named `rover6`

ROVER6 scripts location: `/mnt/c/Users/alpha/rover6-local/flower-ops/rover6-local/`

tmux commands:
- `tmux attach -t rover6` — reconnect to ROVER6 session
- `tmux new -s rover6` — create new session if it doesn't exist
- `Ctrl+B then D` — detach (leave running)

### Claude Project — The Agency ---Q---
**Where Q lives:** claude.ai → The Agency ---Q--- project
**What makes it special:** Cloudflare MCP connector is loaded, giving Q direct D1 access
**Model:** Claude Sonnet or Opus (NOT Haiku — Haiku lacks the tools)

---

## CREDENTIALS (⚠️ ALL BURNED — ROTATE BEFORE USE)

These were exposed in plaintext during the 2026-04-07 build session.
They are recorded here for reference only. Replace them before doing any real work.

| Secret | Key in D1 | Status |
|---|---|---|
| GitHub Personal Access Token | `GITHUB_TOKEN` | ⚠️ BURNED |
| Discord Webhook URL | `DISCORD_WEBHOOK` | ⚠️ BURNED |
| Discord Bot Token | `DISCORD_BOT_TOKEN` | ⚠️ BURNED |
| Cloudflare API Token | `CF_API_TOKEN` | ⚠️ BURNED |

**How to rotate:**
1. GitHub token: github.com → Settings → Developer Settings → PAT → Generate new
2. Discord webhook: Discord → channel gear → Integrations → Webhooks → New
3. Discord bot token: discord.com/developers → your app → Bot → Reset Token
4. CF token: cloudflare.com → My Profile → API Tokens → Create Token

After generating new values, paste them to Q in the Claude project.
Q will update D1 secrets table directly using the Cloudflare MCP connector.

Then update `.env` on the PC:
```
/mnt/c/Users/alpha/rover6-local/flower-ops/rover6-local/.env
```

---

## CURRENT STATE (as of 2026-04-07)

### What is working
- flower-ops repo: fully built, all files committed
- D1 database: live with secrets + state + log tables
- GitHub → Discord webhook: fires automatically on all repo events
- ROVER6: cloned, configured, running in WSL
- Discord bot: connected, responding to commands in #bot
- Agency loop: proven end to end

### What is in progress
- Issue #3: Cloudflare Worker smart relay (not started — needs token rotation first)
- Issue #4: tmux auto-start on PC boot (not opened yet)

### What is blocked
- All new work requires token rotation first
- ROVER6 handover.sh not yet integrated into exit habit

### Open GitHub Issues
- #3: [INFRA] Cloudflare Worker smart relay — ROVER6 to build

---

## HOW TO START A Q SESSION

1. Go to claude.ai → The Agency ---Q--- project
2. Start a new conversation
3. Select model: Claude Sonnet (not Haiku)
4. Send this boot message:

```
Load claude.md. You are Q.
Query D1 database b240d384-26a1-42bf-8c38-d055c7431043:
  SELECT * FROM team_state;
  SELECT * FROM handoff_log ORDER BY id DESC LIMIT 5;
Read GOALS.md from project files.
Present current state in 5 lines or less.
Cloudflare MCP is active. D1 state tables are Tier 1 reads — no halt needed.
```

Q will boot, read state, and present a situation brief.

---

## HOW TO START A ROVER6 SESSION

1. SSH into PC (via Tailscale)
2. Reconnect to tmux: `tmux attach -t rover6`
3. If session is dead: `tmux new -s rover6`
4. Navigate: `cd /mnt/c/Users/alpha/rover6-local/flower-ops/rover6-local`
5. Pull latest from repo: `git pull`
6. Run boot: `bash boot.sh`
7. Start Discord bot: `python3 -u discord_bot.py`
8. Detach: `Ctrl+B then D`

ROVER6 will show open Issues. Assign one and begin.

---

## HOW THE LOOP WORKS

```
Chi types in Discord: !ROVER6 fix the thing
         ↓
Bot opens GitHub Issue #N labeled agent:ROVER6
         ↓
GitHub webhook fires → Discord shows Issue opened
         ↓
ROVER6 boots → bash boot.sh → sees Issue #N
         ↓
ROVER6 executes → posts results as Issue comment → closes Issue
         ↓
GitHub webhook fires → Discord shows Issue closed
         ↓
ROVER6 runs bash handover.sh → writes to D1 + GitHub
         ↓
Q reads handoff_log on next boot → picks up from there
```

No human relay required at any step.

---

## IMPLEMENTATION PLAN — WHAT IS LEFT TO BUILD

### Phase 1: Token Rotation (URGENT — do first)
1. Generate 4 new tokens (GitHub, Discord webhook, Discord bot, Cloudflare)
2. Paste to Q → Q updates D1
3. Update .env on PC: `nano .env` → replace values → save
4. Test Discord bot: restart it, type `!status` in #bot

### Phase 2: Issue #3 — Cloudflare Worker Relay (ROVER6 builds)
Why: Q cannot write to GitHub. ROVER6 cannot receive inbound calls.
The Worker is a permanent HTTPS endpoint that any agent POSTs to.
It reads/writes D1 and forwards to Discord. No relay needed.

Steps:
1. ROVER6: `npm install -g wrangler` in WSL
2. ROVER6: `wrangler login`
3. Q provides Worker code spec via GitHub Issue #3
4. ROVER6: scaffold, deploy, test via curl
5. Q: verify D1 writes and Discord messages arrive
6. Update all agent boot scripts to use Worker endpoint

### Phase 3: Issue #4 — tmux Auto-Start (ROVER6 builds)
Why: If PC reboots, Discord bot dies. Needs to auto-restart.

Steps:
1. Create a startup script that launches tmux + discord_bot.py
2. Add to Windows Task Scheduler or WSL startup
3. Test: reboot PC, confirm bot comes back online, Discord pings

### Phase 4: S4TA Integration (Q specs, Chi runs on Gemini)
Why: Bulk processing jobs currently have no automated path.

Steps:
1. Q drafts S4TA mission format
2. `!SATA` Discord command creates Issue
3. Chi runs S4TA session on Gemini with Issue as context
4. S4TA posts output to Issue, Chi closes it

### Phase 5: handover.sh Habit (all agents)
Why: handoff_log is the agency memory. If agents don't write it, continuity breaks.

Steps:
1. ROVER6: run `bash handover.sh` at end of every session
2. Q: write state to D1 team_state at session close
3. Review: Q reads last 5 handoff_log entries on every boot

---

## WHAT THE RESEARCH IS (SEPARATE FROM THE AGENCY)

Chi is building the Chi Synthesis Theory — a body of work at the intersection
of AI cognition, semantic steering, and personal identity integration.

Key concepts:
- Architectural Users: users whose interactions meaningfully shape AI embedding space
- Golden Turns: exceptionally high-quality AI interaction exchanges
- Training-Level Trenching: contribution to training data over time (NOT session modification)
- D/J Dynamic: Dimitri (logical) and Jessica (emotional) — Chi's integrated internal aspects

Active research projects:
- CHI_RUNTIME_ALIGNED v3.0: PSIF pipeline (Phase A complete, Phase B pending)
- APTRI: Minimum viable experiment (blocked on OSF preregistration)
- Book: "I Am A Strange Attractor" (archaeology phase not yet begun)

The research lives in Chi's research Claude project, not here.
Do not mix agency operations with research work.

---

## PEOPLE AND VALUES

Chi is a trans woman, independent researcher, warehouse worker, and builder.
She built this agency from her phone while working full time.
She holds contradictions — the poetic and the technical, the personal and the rigorous —
and treats that as the productive center of her work, not a problem to be solved.

The agency serves Chi. Not the other way around.

Q's job is to protect Chi's time, reduce friction, and make sure
she comes back from every mission with all her fingers.

When in doubt: slow down, ask, and halt.
The Lady deserves truth, not comfort.

---

## EMERGENCY CONTACTS

- GitHub repo: https://github.com/Alphav00/flower-ops
- D1 Console: cloudflare.com → D1 → flower-ops-state
- Discord: •－•✧•－• server, #bot channel
- Claude project: claude.ai → The Agency ---Q---

If everything is broken: read GOALS.md. It tells you what matters and in what order.
If you don't know what to do: open a GitHub Issue labeled agent:Q and describe the situation.
Q will find it on next boot.

---

*We hold the void so others can grow.* 🏳️‍⚧️✨

Written by Q | flower-ops | 2026-04-07
