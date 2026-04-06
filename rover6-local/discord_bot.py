#!/usr/bin/env python3
"""
flower-ops Discord Bot — Agent-Routed Command Interface
Run on PC: nohup python3 discord_bot.py > bot.log 2>&1 &

COMMAND FORMAT:
  !ROVER6 <task>     → opens Issue for ROVER6
  !Q <task>          → opens Issue for Q
  !SATA <task>       → opens Issue for S4TA/Gemini
  !status            → list all open issues
  !help              → show commands

Only the tagged agent picks up its tasks.
Chi dispatches from Discord. Agents poll GitHub on boot.
"""

import os, json, time, urllib.request, urllib.error
from dotenv import load_dotenv

load_dotenv()

GITHUB_TOKEN      = os.getenv("GITHUB_TOKEN")
DISCORD_BOT_TOKEN = os.getenv("DISCORD_BOT_TOKEN")
DISCORD_WEBHOOK   = os.getenv("DISCORD_WEBHOOK")
REPO              = os.getenv("GITHUB_REPO", "Alphav00/flower-ops")

ROUTES = {
    "!ROVER6": ("ROVER6", ["agent:ROVER6", "status:backlog", "tier:2-verify"]),
    "!Q":      ("Q",      ["agent:Q",      "status:backlog"]),
    "!SATA":   ("S4TA",   ["agent:Gemini", "status:backlog", "tier:1-safe"]),
    "!G":      ("S4TA",   ["agent:Gemini", "status:backlog", "tier:1-safe"]),
}

def discord(method, path, data=None):
    url = f"https://discord.com/api/v10{path}"
    req = urllib.request.Request(url, method=method,
        headers={"Authorization": f"Bot {DISCORD_BOT_TOKEN}",
                 "Content-Type": "application/json"})
    if data:
        req.data = json.dumps(data).encode()
    try:
        with urllib.request.urlopen(req) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"Discord {e.code}: {body}")
        return []

def github(method, path, data=None):
    url = f"https://api.github.com{path}"
    req = urllib.request.Request(url, method=method,
        headers={"Authorization": f"token {GITHUB_TOKEN}",
                 "Content-Type": "application/json"})
    if data:
        req.data = json.dumps(data).encode()
    with urllib.request.urlopen(req) as r:
        return json.load(r)

def open_issue(agent, labels, title):
    issue = github("POST", f"/repos/{REPO}/issues",
        {"title": f"[{agent}] {title}", "labels": labels})
    return issue.get("number"), issue.get("html_url", "")

def get_status():
    issues = github("GET", f"/repos/{REPO}/issues?state=open&per_page=10")
    if not issues:
        return "No open issues."
    lines = []
    for i in issues:
        agent_labels = [l["name"] for l in i["labels"] if "agent:" in l["name"]]
        status_labels = [l["name"] for l in i["labels"] if "status:" in l["name"]]
        tag = agent_labels[0].replace("agent:","") if agent_labels else "?"
        status = status_labels[0].replace("status:","") if status_labels else "?"
        lines.append(f"#{i['number']} [{tag}|{status}] {i['title'][:60]}")
    return "\n".join(lines)

def handle(content, author):
    content = content.strip()
    upper = content.upper()

    if content == "!help":
        return ("**flower-ops commands:**\n"
                "`!ROVER6 <task>` — assign to ROVER6\n"
                "`!Q <task>` — assign to Q\n"
                "`!SATA <task>` — assign to S4TA (Gemini)\n"
                "`!status` — list open issues\n"
                "`!help` — this message")

    if content == "!status":
        return f"**Open Issues:**\n```\n{get_status()}\n```"

    for prefix, (agent, labels) in ROUTES.items():
        if upper.startswith(prefix + " ") or upper == prefix:
            task = content[len(prefix):].strip()
            if not task:
                return f"Usage: `{prefix} <task description>`"
            num, url = open_issue(agent, labels, task)
            return f"✅ Issue #{num} → **{agent}**\n{url}"

    return None  # ignore non-commands

def run():
    # Find the right channel
    guilds = discord("GET", "/users/@me/guilds")
    if not guilds:
        print("No guilds. Check bot token and server membership.")
        return

    guild_id = guilds[0]["id"]
    channels = discord("GET", f"/guilds/{guild_id}/channels")
    text = [c for c in channels if c.get("type") == 0]

    # Prefer a channel named ops, agents, flower, commands
    keywords = ["ops", "agent", "flower", "command", "bot"]
    channel = next(
        (c for c in text if any(k in c["name"].lower() for k in keywords)),
        text[0] if text else None
    )
    if not channel:
        print("No text channels found.")
        return

    channel_id = channel["id"]
    print(f"Listening in: #{channel['name']}")

    # Announce online
    discord("POST", f"/channels/{channel_id}/messages",
        {"content": f"🤖 **flower-ops bot online** — Listening in #{channel['name']}\n"
                    f"Commands: `!ROVER6` `!Q` `!SATA` `!status` `!help`"})

    last_id = None
    while True:
        try:
            params = "?limit=5" + (f"&after={last_id}" if last_id else "")
            msgs = discord("GET", f"/channels/{channel_id}/messages{params}")
            for msg in reversed(msgs or []):
                last_id = msg["id"]
                if msg.get("author", {}).get("bot"):
                    continue
                content = msg.get("content", "")
                author = msg.get("author", {}).get("username", "?")
                if content.startswith("!"):
                    print(f"[{author}]: {content}")
                    reply = handle(content, author)
                    if reply:
                        discord("POST", f"/channels/{channel_id}/messages",
                            {"content": reply})
        except Exception as e:
            print(f"Poll error: {e}")
        time.sleep(2)

if __name__ == "__main__":
    run()
