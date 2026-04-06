# HANDOVER FORMAT — flower-ops Agency
**All agents use this. Every session end. No exceptions.**
**File naming:** `handoffs/HANDOVER_AGENT_YYYY-MM-DD.md`

---

## THE FORMAT

```
AGENT:     [Q / ROVER6 / SATA / Chi]
DATE:      [YYYY-MM-DD HH:MM UTC]
TO:        [who reads this next — Q / ROVER6 / SATA / Chi / ALL]
STATUS:    [NOMINAL / BLOCKED / NEEDS_REVIEW / URGENT]

COMPLETED:
- [what was actually finished, one line each]

BLOCKED:
- [what stopped, why, what's needed to unblock]
- NONE if nothing blocked

NEXT:
- [exact action the next agent should take, specific enough to execute]
- [include Issue numbers if relevant]

CONTEXT:
[2-3 sentences max. Anything the next agent needs that isn't obvious above.]

TOKENS_SPENT: [low / medium / high] — Q only
```

---

## EXAMPLES

### ROVER6 → Q
```
AGENT:     ROVER6
DATE:      2026-04-06 19:00 UTC
TO:        Q
STATUS:    NEEDS_REVIEW

COMPLETED:
- Issue #1: environment audit posted as comment
- Issue #2: ecosystem setup verified, GitHub + Discord both live
- discord_bot.py running in tmux session rover6-bot

BLOCKED:
- CF API token not yet in .env — D1 write from PC not tested

NEXT:
- Q review Issue #1 and #2 comments, close if satisfied
- Q open Issue #3 for Cloudflare Worker build

CONTEXT:
Bot is polling #agents channel. tmux session rover6 holds boot.sh,
rover6-bot holds the Discord bot. Both survive SSH disconnect.
```

### Q → ROVER6
```
AGENT:     Q
DATE:      2026-04-06 19:30 UTC
TO:        ROVER6
STATUS:    NOMINAL

COMPLETED:
- Issues #1 and #2 reviewed and closed
- Issue #3 opened: build Cloudflare Worker relay

BLOCKED:
- NONE

NEXT:
- Pull Issue #3 from GitHub
- Read MSH_active.md for spec
- Execute per Q-Triangle — Tier 2, verify before writing

CONTEXT:
Worker needs to receive GitHub webhook events and format
them as clean Discord messages. Spec is in Issue #3 body.
```

### Chi → ALL
```
AGENT:     Chi
DATE:      2026-04-06 20:00 UTC
TO:        ALL
STATUS:    NOMINAL

COMPLETED:
- CF API token added to PC .env
- Confirmed tmux sessions running

BLOCKED:
- NONE

NEXT:
- Q: confirm D1 is reachable from PC
- ROVER6: run boot.sh, confirm open issues visible

CONTEXT:
SSH config set up on Termux. Connecting via tailscale hostname.
```

---

## RULES

1. Post to `handoffs/` in flower-ops every session — no exceptions
2. Write to D1 handoff_log at the same time (ROVER6 does this automatically via exit script)
3. GitHub webhook fires to Discord when file is pushed — everyone sees it
4. STATUS drives urgency: URGENT means someone checks Discord now
5. NEXT must be specific enough that the receiver can act without asking questions

---

## SHORTCUT — ROVER6 exit script writes this automatically
Run `bash handover.sh` at session end. It prompts for completed/blocked/next
and pushes the formatted file to GitHub + D1.
