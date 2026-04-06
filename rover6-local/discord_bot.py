#!/usr/bin/env python3
"""
flower-ops Discord Bot
Chi types a command in the private channel → bot creates a GitHub Issue
Runs on PC. Keep alive in background: nohup python3 discord_bot.py &

Commands (type in Discord):
  !assign ROVER6 <task description>   → opens Issue labeled agent:ROVER6
  !assign Q <task description>        → opens Issue labeled agent:Q
  !status                             → posts current open issues
  !help                               → shows commands
"""

import os, json, urllib.request, urllib.parse
from dotenv import load_dotenv

load_dotenv()

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
DISCORD_BOT_TOKEN = os.getenv("DISCORD_BOT_TOKEN")
DISCORD_WEBHOOK = os.getenv("DISCORD_WEBHOOK")
REPO = os.getenv("GITHUB_REPO", "Alphav00/flower-ops")

AGENT_LABELS = {
    "ROVER6": ["agent:ROVER6", "status:backlog", "tier:2-verify"],
    "Q":      ["agent:Q", "status:backlog"],
    "SATA":   ["agent:Gemini", "status:backlog", "tier:1-safe"],
    "G":      ["agent:Gemini", "status:backlog", "tier:1-safe"],
}

def gh(method, path, data=None):
    url = f"https://api.github.com{path}"
    req = urllib.request.Request(url, method=method,
        headers={"Authorization": f"token {GITHUB_TOKEN}",
                 "Content-Type": "application/json"})
    if data:
        req.data = json.dumps(data).encode()
    with urllib.request.urlopen(req) as r:
        return json.load(r)

def discord_post(msg):
    if not DISCORD_WEBHOOK:
        return
    req = urllib.request.Request(DISCORD_WEBHOOK, method="POST",
        headers={"Content-Type": "application/json"},
        data=json.dumps({"content": msg}).encode())
    try:
        urllib.request.urlopen(req)
    except:
        pass

def open_issue(agent, title):
    labels = AGENT_LABELS.get(agent.upper(), ["status:backlog"])
    issue = gh("POST", f"/repos/{REPO}/issues",
        {"title": f"[{agent.upper()}] {title}", "labels": labels})
    return issue.get("number"), issue.get("html_url")

def get_open_issues():
    issues = gh("GET", f"/repos/{REPO}/issues?state=open&per_page=10")
    if not issues:
        return "No open issues."
    lines = []
    for i in issues:
        labels = [l["name"] for l in i["labels"] if "agent:" in l["name"]]
        lines.append(f"#{i['number']} {labels} {i['title']}")
    return "\n".join(lines)

def handle_message(content, author):
    content = content.strip()

    if content == "!help":
        return ("**flower-ops commands:**\n"
                "`!assign ROVER6 <task>` — assign to ROVER6\n"
                "`!assign Q <task>` — assign to Q\n"
                "`!assign SATA <task>` — assign to S4TA\n"
                "`!status` — list open issues\n"
                "`!help` — this message")

    if content == "!status":
        return f"**Open Issues:**\n```\n{get_open_issues()}\n```"

    if content.startswith("!assign "):
        parts = content[8:].strip().split(" ", 1)
        if len(parts) < 2:
            return "Usage: `!assign ROVER6 <task description>`"
        agent, title = parts[0], parts[1]
        if agent.upper() not in AGENT_LABELS:
            return f"Unknown agent: {agent}. Use ROVER6, Q, or SATA."
        num, url = open_issue(agent, title)
        return f"✅ Issue #{num} opened for **{agent.upper()}**\n{url}"

    return None  # ignore non-commands

# ── Gateway (polling fallback — no dependencies needed) ──
def run_polling():
    """Poll Discord for messages using REST. No websocket library needed."""
    import time
    last_id = None
    print("flower-ops bot running (polling mode)...")
    print("Listening for commands in your private channel...")

    # Get bot's channel list — find first guild text channel
    channels = gh_discord("GET", "/users/@me/guilds")
    if not channels:
        print("❌ No guilds found. Check bot token and server membership.")
        return

    guild_id = channels[0]["id"]
    all_channels = gh_discord("GET", f"/guilds/{guild_id}/channels")
    text_channels = [c for c in all_channels if c["type"] == 0]

    if not text_channels:
        print("❌ No text channels found.")
        return

    # Use first text channel — or filter by name "flower-ops" / "agents"
    channel = next((c for c in text_channels if "agent" in c["name"].lower() or
                   "flower" in c["name"].lower() or "ops" in c["name"].lower()),
                   text_channels[0])
    channel_id = channel["id"]
    print(f"Listening in: #{channel['name']} ({channel_id})")
    discord_post(f"🤖 **flower-ops bot online** — listening in #{channel['name']}")

    while True:
        try:
            params = "?limit=5"
            if last_id:
                params += f"&after={last_id}"
            msgs = gh_discord("GET", f"/channels/{channel_id}/messages{params}")
            for msg in reversed(msgs):
                last_id = msg["id"]
                if msg.get("author", {}).get("bot"):
                    continue
                content = msg.get("content", "")
                author = msg.get("author", {}).get("username", "unknown")
                if content.startswith("!"):
                    print(f"[{author}]: {content}")
                    reply = handle_message(content, author)
                    if reply:
                        gh_discord("POST", f"/channels/{channel_id}/messages",
                                  {"content": reply})
        except Exception as e:
            print(f"Poll error: {e}")
        time.sleep(2)

def gh_discord(method, path, data=None):
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
        print(f"Discord API error {e.code}: {e.read()}")
        return []

if __name__ == "__main__":
    run_polling()
