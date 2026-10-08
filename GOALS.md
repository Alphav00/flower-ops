# GOALS.md — Agency Mission Board
**Maintainer:** Q
**Authority:** Lady Chi
**Updated:** 2026-10-08 (reconciled against handoff 2026-04-07; no agent activity logged since)
**Scope:** Agency infrastructure only. Research lives elsewhere.

---

## PRIORITY 1 — AGENTS OPERATIONAL
Goal: Every agent can receive a task and produce a handoff without Chi in the middle.

| Item | Owner | Status | Dependency |
|---|---|---|---|
| ROVER6 constitution live | Chi | ✅ Done | — |
| Q constitution live | Chi | ✅ Done (v3.2) | — |
| ROVER6 executes task + writes handoff | ROVER6 | ✅ Done — Issues #1, #2 executed and closed | ROVER6 deployed |
| Gemini constitution drafted | Q | ✅ S4TA.md committed | — |
| Gemini dispatch configured | Chi | ⬜ Pending | Gemini constitution |

---

## PRIORITY 2 — SHARED STATE BACKBONE 🔒 LOCKED
Goal: Agents read/write shared state. Chi stops being the postal service.
Decision (revised 2026-04-07): GitHub (flower-ops) for files and issues + Cloudflare D1
(`flower-ops-state`) for `team_state`, `handoff_log`, `secrets`. Original "no database" decision superseded.

| Item | Owner | Status |
|---|---|---|
| flower-ops repo created | Chi | ✅ Done |
| D1 state tables + Cloudflare connector for Q | Chi | ✅ Done |
| Handoff template committed | Q | ✅ `handoffs/HANDOVER_FORMAT.md`, `HANDOFF_template.md` |
| ROVER6 writes handoff on exit | ROVER6 | ✅ `rover6-local/handover.sh` (GitHub + D1 dual write still to verify) |
| Burned tokens rotated (GitHub, Discord webhook, CF) | Chi | ⬜ Pending — Discord bot token already rotated |
| Worker smart relay — Issue #3 | ROVER6 build / Q review | ⬜ Backlog — next build mission |
| tmux auto-start on PC boot — Issue #4 | ROVER6 | ⬜ Backlog |
| NoteHub connected to repo | Chi | ❓ Unverified — drop if no longer wanted |

---

## PRIORITY 3 — MOBILE DASHBOARD
Goal: Chi opens one view on her phone and sees full team status.

| Item | Owner | Status |
|---|---|---|
| Discord `!status` lists open Issues | ROVER6 | ✅ Live |
| GOALS.md readable as status board on phone | Chi | ⬜ Pending |
| Single-glance status convention established | Q | ⬜ Pending |

---

## PRIORITY 4 — WORKFLOW PROVEN END-TO-END
Goal: One complete mission runs. Q specs → ROVER6 executes → handoff logged → Q audits.

| Item | Owner | Status |
|---|---|---|
| First live mission assigned to ROVER6 | Chi | ✅ Issues #1, #2 |
| ROVER6 Q-Triangle preamble verified | Chi/Q | ⬜ Pending |
| HANDOFF reviewed by Q | Q | ✅ Q session close 2026-04-07 |
| Workflow declared production-ready | Chi | ⬜ Blocked on token rotation + Issue #3 |

---

## FUTURE
- Gemini automated dispatch — bulk tasks without Chi in the middle
- Tasker integration — route handoffs via existing mobile automation
- `MODEL_ROUTING.md` — referenced in earlier handovers, never written
