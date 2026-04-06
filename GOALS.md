# GOALS.md — Agency Mission Board
**Maintainer:** Q
**Authority:** Lady Chi
**Updated:** 2026-04-06
**Scope:** Agency infrastructure only. Research lives elsewhere.

---

## PRIORITY 1 — AGENTS OPERATIONAL
Goal: Every agent can receive a task and produce a handoff without Chi in the middle.

| Item | Owner | Status | Dependency |
|---|---|---|---|
| ROVER6 constitution live | Chi | ✅ Done | — |
| Q constitution live | Chi | ✅ Done | — |
| ROVER6 executes task + writes HANDOFF.md | ROVER6 | ⬜ Untested | ROVER6 deployed |
| Gemini constitution drafted | Q | ⬜ Pending | — |
| Gemini dispatch configured | Chi | ⬜ Pending | Gemini constitution |

---

## PRIORITY 2 — SHARED STATE BACKBONE 🔒 LOCKED
Goal: Agents read/write shared state. Chi stops being the postal service.
Decision: GitHub (flower-ops) + NoteHub. Flat markdown. No database. No server.

| Item | Owner | Status |
|---|---|---|
| flower-ops repo created | Chi | ✅ Done |
| NoteHub connected to repo | Chi | ⬜ Pending |
| HANDOFF.md template committed | Q | ⬜ Pending |
| ROVER6 writes HANDOFF.md on exit | ROVER6 | ⬜ Pending |
| Q reads handoffs via project context | Chi/Q | ⬜ Pending |

---

## PRIORITY 3 — MOBILE DASHBOARD
Goal: Chi opens one view on her phone and sees full team status.

| Item | Owner | Status |
|---|---|---|
| GOALS.md readable as status board via NoteHub | Chi | ⬜ Pending |
| Single-glance status convention established | Q | ⬜ Pending |

---

## PRIORITY 4 — WORKFLOW PROVEN END-TO-END
Goal: One complete mission runs. Q specs → ROVER6 executes → handoff logged → Q audits.

| Item | Owner | Status |
|---|---|---|
| First live mission assigned to ROVER6 | Chi | ⬜ Pending |
| ROVER6 Q-Triangle preamble verified | Chi/Q | ⬜ Pending |
| HANDOFF.md reviewed by Q | Q | ⬜ Pending |
| Workflow declared production-ready | Chi | ⬜ Pending |

---

## FUTURE
- MCP server (Cloudflare Workers) — Q reads state directly, no Lady relay
- Gemini automated dispatch — bulk tasks without Chi in the middle
- Tasker integration — route handoffs via existing mobile automation

