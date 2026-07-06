#!/usr/bin/env python3
"""Generate robotmk-starter.code-workspace listing all sub-projects with a .devcontainer.

Workspace folders + a VSCode task per devcontainer project so the user can launch
any container directly via Terminal → Run Task without leaving the workspace window.

Usage: python generate-workspace.py <repo_root>
"""
import json
import sys
from pathlib import Path


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <repo_root>", file=sys.stderr)
        sys.exit(1)

    repo_root = Path(sys.argv[1])
    workspace_file = repo_root / "robotmk-starter.code-workspace"

    folders = [{"path": ".", "name": "robotmk-starter"}]
    dc_entries = []  # (folder_name, relative_path)

    for category, label in [("examples", "example"), ("templates", "template"), ("labs", "lab")]:
        base = repo_root / category
        if not base.is_dir():
            continue
        for entry in sorted(base.iterdir()):
            if entry.is_dir() and (entry / ".devcontainer").is_dir():
                name = f"[{label}] {entry.name}"
                rel_path = f"{category}/{entry.name}"
                folders.append({"path": rel_path, "name": name})
                dc_entries.append((name, rel_path))

    # One task per devcontainer project — opens the folder in VSCode which triggers
    # the "Reopen in Container" flow automatically (1 click instead of 3).
    tasks = {
        "version": "2.0.0",
        "tasks": [
            {
                "label": f"devcontainer: open {name}",
                "type": "shell",
                "command": "code",
                "args": ["${workspaceFolder:robotmk-starter}/" + rel_path],
                "presentation": {"reveal": "never", "panel": "shared"},
                "problemMatcher": [],
            }
            for name, rel_path in dc_entries
        ],
    }

    workspace = {"folders": folders, "tasks": tasks}
    with open(workspace_file, "w") as f:
        json.dump(workspace, f, indent=2)
        f.write("\n")

    dc_count = len(dc_entries)
    print(f"  ✓ Written: robotmk-starter.code-workspace ({dc_count} devcontainer folder{'s' if dc_count != 1 else ''})")


if __name__ == "__main__":
    main()
