# BOOT.md — Agency Boot Protocol
**Read this first. Every agent. Every session.**
**Version:** 1.0 | **Updated:** 2026-04-06

---

## INFRASTRUCTURE

| Resource | Value |
|---|---|
| GitHub Repo | `Alphav00/flower-ops` |
| D1 Database | `flower-ops-state` |
| D1 ID | `b240d384-26a1-42bf-8c38-d055c7431043` |
| Cloudflare Account | Connected via MCP |

---

## BOOT SEQUENCE (All Agents)

### Step 1 — Get GitHub Token
Query D1 via Cloudflare connector:
```sql
SELECT value FROM secrets WHERE key = 'GITHUB_TOKEN';
```

### Step 2 — Read Team State
```sql
SELECT * FROM team_state;
```
If D1 unreachable → pull `GOALS.md` from flower-ops repo as fallback.

### Step 3 — Read Active Mission
Fetch `MSH_active.md` from flower-ops. If empty → STANDBY.

### Step 4 — Report Boot
```sql
INSERT OR REPLACE INTO team_state (agent, status, last_action, updated_at)
VALUES ('#AGENT_NAME', 'ONLINE', 'boot', 'TIMESTAMP');
```

---

## EXIT SEQUENCE (All Agents)

### Step 1 — Write Handoff to D1
```sql
INSERT INTO handoff_log (agent, completed, blocked, next, timestamp)
VALUES ('#AGENT', 'item1|item2', 'blocker or none', 'next action', 'TIMESTAMP');
```

### Step 2 — Push HANDOFF.md to flower-ops
File path: `handoffs/HANDOFF_AGENTNAME_TIMESTAMP.md`
Use GitHub API with token from Step 1 of boot.

### Step 3 — Update Team State
```sql
INSERT OR REPLACE INTO team_state (agent, status, last_action, updated_at)
VALUES ('#AGENT', 'OFFLINE', 'last task summary', 'TIMESTAMP');
```

---

## COMMUNICATION RULES

- **ROVER6 → Q**: Write HANDOFF.md to `flower-ops/handoffs/`. Q reads next session.
- **Q → ROVER6**: Q updates `MSH_active.md` in flower-ops. ROVER6 reads on boot.
- **Chi relay**: Only required if D1 and GitHub both unreachable.
- **No agent-to-agent real-time chat.** Files are the protocol.

---

## ESCALATION
If boot fails at any step:
```
⬆️ ESCALATE TO Q: Boot failure at Step [N] — [reason]
```
Then HALT. Do not proceed without token or state.
