#!/usr/bin/env python3
"""
update_suite_table.py — Updates the suite version table and CI badge URL in README.md.

Reads conda.yaml from each examples/ and templates/ subdirectory to extract
the exact library versions, and reads .rcc for the space name.

Usage:
    python3 update_suite_table.py <repo_root>

Environment:
    GITHUB_REPOSITORY  — e.g. "myorg/robotmk-starter"  (optional, updates badge URL)
"""

import os
import re
import sys
import yaml
from pathlib import Path


def parse_suite_doc(suite_dir: Path) -> str:
    """Extract the suite-level Documentation from the first .robot file found."""
    robot_files = sorted(suite_dir.glob("*.robot"))
    if not robot_files:
        return "—"
    in_settings = False
    in_doc = False
    doc_lines = []
    for robot_file in robot_files:
        for line in robot_file.read_text(encoding="utf-8").splitlines():
            stripped = line.strip()
            if re.match(r"^\*+\s*Settings\s*\*+", stripped, re.IGNORECASE):
                in_settings = True
                in_doc = False
                continue
            if re.match(r"^\*+\s*\w", stripped) and not re.match(r"^\*+\s*Settings\s*\*+", stripped, re.IGNORECASE):
                if in_settings:
                    break  # left Settings section
                continue
            if not in_settings:
                continue
            if re.match(r"^Documentation\b", line, re.IGNORECASE):
                in_doc = True
                # Text starts after "Documentation" + whitespace
                text = re.sub(r"^Documentation\s*", "", line, flags=re.IGNORECASE).strip()
                if text:
                    doc_lines.append(text)
                continue
            if in_doc and stripped.startswith("..."):
                text = stripped[3:].strip()
                if text:
                    doc_lines.append(text)
                continue
            in_doc = False
        if doc_lines:
            break
    return " ".join(doc_lines) if doc_lines else "—"


def parse_conda_versions(conda_yaml: Path) -> dict:
    """Extract package versions from a conda.yaml file."""
    if not conda_yaml.exists():
        return {}
    with open(conda_yaml) as f:
        data = yaml.safe_load(f)
    versions = {}
    for dep in data.get("dependencies", []):
        if isinstance(dep, str):
            # conda package: name=version
            m = re.match(r"^([\w-]+)=([^=].*)$", dep)
            if m:
                versions[m.group(1)] = m.group(2)
        elif isinstance(dep, dict) and "pip" in dep:
            for pip_dep in dep["pip"]:
                # pip package: name==version
                m = re.match(r"^([\w-]+)==(.+)$", pip_dep)
                if m:
                    versions[m.group(1)] = m.group(2)
    return versions


def get_space(suite_dir: Path) -> str:
    rcc_file = suite_dir / ".rcc"
    if not rcc_file.exists():
        return "—"
    for line in rcc_file.read_text().splitlines():
        if line.startswith("SPACE="):
            return line.split("=", 1)[1].strip()
    return "—"


def build_table(repo_root: Path, parent: str) -> str:
    header = "| Suite | Description | Dependencies |"
    sep    = "|---|---|---|"
    rows = []
    parent_dir = repo_root / parent
    if parent_dir.exists():
        for suite_dir in sorted(parent_dir.iterdir()):
            if not suite_dir.is_dir() or suite_dir.name.startswith("."):
                continue
            v = parse_conda_versions(suite_dir / "conda.yaml")
            doc = parse_suite_doc(suite_dir)
            rel = f"{parent}/{suite_dir.name}"
            deps = "<br>".join(
                f"• {name}=={version}" for name, version in sorted(v.items())
            )
            rows.append(f"| [{rel}]({rel}) | {doc} | {deps} |")
    return "\n".join([header, sep] + rows)


def replace_between_markers(content: str, start: str, end: str, replacement: str) -> tuple[str, bool]:
    pattern = rf"({re.escape(start)}).*?({re.escape(end)})"
    new_content, count = re.subn(
        pattern,
        rf"\1\n\n{replacement}\n\n\2",
        content,
        flags=re.DOTALL,
    )
    if count == 0:
        raise ValueError(f"Markers not found: {start!r} … {end!r}")
    return new_content, new_content != content


def update_badge(content: str, repo: str) -> tuple[str, bool]:
    """Replace YOUR_ORG/robotmk-starter with the actual repo in the badge section."""
    new = content.replace("YOUR_ORG/robotmk-starter", repo)
    return new, new != content


def main():
    repo_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    readme = repo_root / "README.md"

    if not readme.exists():
        print(f"ERROR: README.md not found at {readme}", file=sys.stderr)
        sys.exit(1)

    content = readme.read_text()
    changed = False

    # Update examples table
    content, t1 = replace_between_markers(
        content,
        "<!-- EXAMPLES-TABLE-START -->",
        "<!-- EXAMPLES-TABLE-END -->",
        build_table(repo_root, "examples"),
    )
    # Update templates table
    content, t2 = replace_between_markers(
        content,
        "<!-- TEMPLATES-TABLE-START -->",
        "<!-- TEMPLATES-TABLE-END -->",
        build_table(repo_root, "templates"),
    )
    if t1 or t2:
        print("Suite tables updated.")
        changed = True

    # Update badge URL if GITHUB_REPOSITORY is available
    gh_repo = os.environ.get("GITHUB_REPOSITORY", "")
    if gh_repo and "YOUR_ORG" in content:
        content, badge_changed = update_badge(content, gh_repo)
        if badge_changed:
            print(f"Badge URL updated to {gh_repo}.")
            changed = True

    if changed:
        readme.write_text(content)
    else:
        print("README.md already up to date.")


if __name__ == "__main__":
    main()
