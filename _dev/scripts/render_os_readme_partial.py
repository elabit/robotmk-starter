#!/usr/bin/env python3
"""Renders an os/<slug> instance's README.partial.md from its Ansible role task file.

The package list and any deviation/caveat notes are the single source of
truth in _dev/_ansible/roles/browser-deps/tasks/<family>.yml (AD-3/AD-6) — this
script parses that file rather than duplicating the list by hand, so the
generated README can never drift from what Ansible actually installs.

Usage: python render_os_readme_partial.py <family> <slug> <image> <output_path>

<family> is one of: debian, redhat, suse (matches tasks/<family>.yml and
ansible_os_family, lowercased).
"""
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Error: PyYAML not found. Run: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

# Keys that appear on an Ansible task alongside its module key — anything
# else is assumed to be the module itself (e.g. ansible.builtin.apt).
NON_MODULE_KEYS = {"name", "tags", "become", "when", "register", "ignore_errors", "notify"}


def parse_role_task_file(task_file: Path) -> tuple[list[str], list[str]]:
    tasks = yaml.safe_load(task_file.read_text()) or []

    packages: list[str] = []
    caveats: list[str] = []

    for task in tasks:
        module_keys = [k for k in task if k not in NON_MODULE_KEYS]

        if "ansible.builtin.set_fact" in task:
            caveats_fact = task["ansible.builtin.set_fact"].get("install_report_caveats")
            if caveats_fact:
                for notes in caveats_fact.values():
                    caveats.extend(notes)
            continue

        for key in module_keys:
            module_args = task[key]
            if isinstance(module_args, dict) and "name" in module_args:
                packages.extend(module_args["name"])

    return packages, caveats


def render_partial(family: str, slug: str, image: str, packages: list[str], caveats: list[str]) -> str:
    lines = [
        f"A stock `{image}` container, provisioned with Ansible to install exactly the OS packages "
        f"needed for the Robot Framework suites under `tests/` (Browser Library / Playwright) to "
        f"run headless.",
        "",
        "## Packages installed by Ansible",
        "",
    ]
    lines += [f"- `{pkg}`" for pkg in packages]

    if caveats:
        lines += ["", "## Deviations / Caveats", ""]
        lines += [f"- {note}" for note in caveats]

    lines.append("")
    return "\n".join(lines)


def main() -> None:
    if len(sys.argv) != 5:
        print(f"Usage: {sys.argv[0]} <family> <slug> <image> <output_path>", file=sys.stderr)
        sys.exit(1)

    family, slug, image, output_path = sys.argv[1:5]

    repo_root = Path(__file__).resolve().parents[2]
    task_file = repo_root / "_dev" / "_ansible" / "roles" / "browser-deps" / "tasks" / f"{family}.yml"
    if not task_file.exists():
        print(f"Error: {task_file} not found for family '{family}'", file=sys.stderr)
        sys.exit(1)

    packages, caveats = parse_role_task_file(task_file)
    if not packages:
        print(f"Error: no packages parsed from {task_file}", file=sys.stderr)
        sys.exit(1)

    partial = render_partial(family, slug, image, packages, caveats)
    Path(output_path).write_text(partial)
    print(f"  ✓ Rendered {output_path} ({len(packages)} packages, {len(caveats)} caveats)")


if __name__ == "__main__":
    main()
