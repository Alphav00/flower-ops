# 🌷 flower-ops
> *just tending garden*

Covert automation agency. Distributed nodes. Quiet growth.

## 🤖 AGENT ROUTING
| Call Sign | Role | Constitution | Reads |
|-----------|------|--------------|-------|
| `---<Q>---` | Strategy, audits, architecture | `CLAUDE.md` | `GOALS.md`, `handoffs/`, D1 state |
| `---<#>---` / `#ROVER6` | Execution, deploys, terminal | `ROVER6.md` | `BOOT.md`, `MSH_active.md`, `rover6-local/` |
| `---g---` / `S4TA` | Bulk text, formatting, data | `S4TA.md` | task input only |
| `---<X>--- Lady Chi` | Command, field presence, final authority | — | All |

## 📁 STRUCTURE
- `BOOT.md` — boot/exit sequence every agent runs
- `CLAUDE.md` — Q's constitution (v3.2); also loaded by Claude Code in this repo
- `ROVER6.md`, `S4TA.md` — executor and bulk-processor constitutions
- `GOALS.md` — mission board (Q maintains)
- `MSH_active.md` — current mission heuristics (STANDBY when empty)
- `COLD_START.md` — full orientation for anyone starting from zero
- `handoffs/` — session handover records (`HANDOVER_FORMAT.md` is the template spec)
- `rover6-local/` — ROVER6's local scripts and Discord bot (clone and run on the PC)
- `artifacts/` — mission outputs

## 🤖 AGENT BOOT SEQUENCE
1. Read `BOOT.md`, then your own constitution.
2. Read `team_state` (D1), falling back to `GOALS.md`; read `MSH_active.md`.
3. Verify all Tier 2/3 commands with Q-Triangle preamble.
4. On exit: write to D1 `handoff_log` and push `handoffs/HANDOFF_<AGENT>_<TIMESTAMP>.md`
   as `{agent, date, completed, blocked, next}`.
5. Never modify constitutions without `⬆️ ESCALATE TO Q`.

## 🚀 QUICK START
```bash
git clone https://github.com/Alphav00/flower-ops
cd flower-ops/rover6-local
cp .env.template .env   # fill in from rotated secrets; never commit .env
# see rover6-local/README.md
```

## 🔒 SAFETY & CONVENTIONS
- No secrets in repo. Use `.env` + the D1 `secrets` table (Tier 3).
- `ABORT` = immediate halt. `⬆️ ESCALATE TO Q` = pause for strategy.
- Keep files < 50KB for AI context windows. Split large configs.
- Use standard Markdown/YAML. No ambiguous formatting.

*Roots deep. Bloom unseen.*
