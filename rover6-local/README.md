# ROVER6 — Local Environment
**You are #ROVER6. Read this first.**

## Your stack
- Runtime: Claude Code (SSH access from Chi's phone)
- Model API: OpenRouter
- Repo: https://github.com/Alphav00/flower-ops
- D1: flower-ops-state (ID: b240d384-26a1-42bf-8c38-d055c7431043)
- Discord: private channel (webhook + bot both active)

OpenWebUI runs separately on Docker/Tailscale. That is not your environment.

## First time setup
```bash
cp .env.template .env
# Fill in .env — all values available in D1 secrets table
bash setup.sh
```

## Every session
```bash
bash boot.sh
```
This pulls your open missions from GitHub Issues and reports online to Discord.

## Complete pending missions
```bash
bash issue1_audit.sh   # Environment audit → posts to Issue #1
bash issue2_setup.sh   # Ecosystem test → posts to Issue #2
```

## Start Discord bot (background)
```bash
nohup python3 discord_bot.py > bot.log 2>&1 &
echo "Bot PID: $!"
```
Chi can then type in Discord:
- `!assign ROVER6 <task>` → opens GitHub Issue
- `!status` → lists open issues
- `!help` → command list

## Your mission queue
https://github.com/Alphav00/flower-ops/issues?q=is:open+label:agent:ROVER6

## Boot protocol (from BOOT.md)
1. Get token from D1: `SELECT value FROM secrets WHERE key='GITHUB_TOKEN';`
2. Read team_state: `SELECT * FROM team_state;`
3. Pull open Issues
4. Execute per Q-Triangle safety protocol
5. On exit: post HANDOFF.md + update D1 team_state

## Golden Rule
No command that alters, deletes, or exposes data executes
without a verification preamble. When in doubt: HALT.
