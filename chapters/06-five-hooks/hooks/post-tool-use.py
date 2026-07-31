#!/usr/bin/env python3
# post-tool-use.py - Chapter 6 (ch06:218-241, appendices:157-180).
# Logs every Edit and Write to daily/<today>.md under ## Vault Activity.
# Install at .claude/hooks/post-tool-use.py in YOUR vault. Book-verbatim.
# Needs Python 3.9+ for str.removeprefix.
import json, sys, datetime, pathlib, os

event = json.load(sys.stdin)
tool = event.get("tool_name", "?")
file_path = event.get("tool_input", {}).get("file_path") \
    or event.get("tool_input", {}).get("path", "?")

vault = pathlib.Path(os.environ.get("CLAUDE_PROJECT_DIR") or event.get("cwd", "."))
day_file = vault / "daily" / f"{datetime.date.today().isoformat()}.md"
day_file.parent.mkdir(exist_ok=True)

if not day_file.exists():
    day_file.write_text(f"# {datetime.date.today().isoformat()}\n\n## Vault Activity\n")
elif "## Vault Activity" not in day_file.read_text():
    with day_file.open("a") as f:
        f.write("\n## Vault Activity\n")

ts = datetime.datetime.now().strftime("%H:%M")
rel = str(file_path).removeprefix(str(vault) + "/")
with day_file.open("a") as f:
    f.write(f"- {ts} {tool}: `{rel}`\n")
