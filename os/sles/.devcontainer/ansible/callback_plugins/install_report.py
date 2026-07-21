"""
callback: install_report
type: aggregate
short_description: Renders a per-run Markdown install report for the os/ content type.
description:
  - Captures per-task status across a play, namespaced version and caveat
    facts registered by roles, and renders them via Jinja2 into report.md
    at the end of the playbook run -- even after a halt.
requirements:
  - jinja2
"""

from __future__ import annotations

import datetime
import os

from ansible import constants as C
from ansible.playbook.block import Block
from ansible.plugins.callback import CallbackBase

CALLBACK_VERSION = 2.0
CALLBACK_TYPE = "aggregate"
CALLBACK_NAME = "install_report"
CALLBACK_NEEDS_ENABLED = True


def _flatten_tasks(compiled_blocks):
    """Recursively walk play.compile()'s output into a flat, ordered task list.

    Only walks Block.block (the main task list) -- this playbook uses neither
    rescue nor always, so that's all that's needed here.
    """
    tasks = []
    for item in compiled_blocks:
        if isinstance(item, Block):
            tasks.extend(_flatten_tasks(item.block))
        else:
            if item.action in C._ACTION_META and item.implicit:
                continue
            tasks.append(item)
    return tasks


class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = "aggregate"
    CALLBACK_NAME = "install_report"
    CALLBACK_NEEDS_ENABLED = True

    def __init__(self):
        super().__init__()
        self._playbook_path = None
        # Tasks known at compile time only, keyed by the task's own stable
        # uuid (never by name -- two tasks, even across different roles, can
        # share a display name, and name-keying would silently merge their
        # statuses). Used solely to detect "known in advance but never even
        # started" (e.g. a halt before any task ran). This CANNOT see inside
        # a dynamic `include_tasks` (AD-3's os_family switching is dynamic,
        # since the target file depends on a runtime fact) -- those tasks
        # are only knowable once they actually start.
        self._static_tasks = []  # [(uuid, name), ...] in compile order
        # Real execution order, built as tasks start -- covers both static
        # and dynamically-included tasks accurately, unlike the compile-time
        # list above. Keyed by uuid for the same collision-avoidance reason.
        self._task_order = []  # [uuid, ...]
        self._task_names = {}  # uuid -> name
        self._status = {}  # uuid -> status
        self._versions = {}
        self._caveats = {}

    def v2_playbook_on_start(self, playbook):
        self._playbook_path = os.path.abspath(playbook._file_name)
        for play in playbook.get_plays():
            for task in _flatten_tasks(play.compile()):
                self._static_tasks.append((task._uuid, task.get_name()))

    def v2_playbook_on_task_start(self, task, is_conditional):
        uuid = task._uuid
        if uuid not in self._task_names:
            self._task_order.append(uuid)
            self._task_names[uuid] = task.get_name()

    def _record_facts(self, result):
        # `TaskResult._result` is the stable, version-independent attribute
        # (present since ansible-core's earliest callback API); a public
        # `.result` alias exists on some but not all ansible-core versions --
        # found via a real failure on ansible-core 2.16.3 (Ubuntu 24.04) that
        # didn't surface on 2.19.4 (Debian 13), which does have the alias.
        facts = result._result.get("ansible_facts", {})
        versions = facts.get("install_report_versions")
        if isinstance(versions, dict):
            for role, role_versions in versions.items():
                if isinstance(role_versions, dict):
                    self._versions.setdefault(role, {}).update(role_versions)
        caveats = facts.get("install_report_caveats")
        if isinstance(caveats, dict):
            for role, notes in caveats.items():
                notes_list = notes if isinstance(notes, list) else [notes]
                self._caveats.setdefault(role, []).extend(notes_list)

    def v2_runner_on_ok(self, result):
        self._status[result._task._uuid] = "success"
        self._record_facts(result)

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self._status[result._task._uuid] = "failed"

    def v2_runner_on_skipped(self, result):
        self._status[result._task._uuid] = "skipped"

    def v2_playbook_on_stats(self, stats):
        steps = [
            {"name": self._task_names[uuid], "status": self._status.get(uuid, "not-run")}
            for uuid in self._task_order
        ]
        # Statically-known tasks that never started at all (e.g. the play
        # halted before reaching them) -- appended after whatever did run,
        # since their true position can't be known once dynamic content is
        # in the mix.
        started = set(self._task_order)
        for uuid, name in self._static_tasks:
            if uuid not in started:
                steps.append({"name": name, "status": "not-run"})
        self._render(steps)

    def _report_path(self):
        # oncreate.sh sets INSTALL_REPORT_PATH to the exact path it itself
        # will append the RF verification result to (Story 1.4) -- reading
        # it here makes that one path the single source of truth instead of
        # two independent derivations that could silently diverge. Falls
        # back to deriving it from the playbook path (report.md lives at the
        # instance root, one level above .devcontainer/) for manual/ad-hoc
        # ansible-playbook runs that don't go through oncreate.sh.
        env_path = os.environ.get("INSTALL_REPORT_PATH")
        if env_path:
            return env_path
        devcontainer_dir = os.path.dirname(self._playbook_path)
        instance_dir = os.path.dirname(devcontainer_dir)
        return os.path.join(instance_dir, "report.md")

    def _render(self, steps):
        try:
            from jinja2 import Environment, FileSystemLoader
        except ImportError as exc:
            self._display.error(f"install_report: jinja2 not available, cannot render report.md: {exc}")
            return

        template_dir = os.path.join(os.path.dirname(__file__), "..", "templates")
        env = Environment(loader=FileSystemLoader(template_dir), trim_blocks=True, lstrip_blocks=True)
        template = env.get_template("report.md.j2")
        rendered = template.render(
            generated_at=datetime.datetime.now().isoformat(timespec="seconds"),
            steps=steps,
            versions=self._versions,
            caveats=self._caveats,
        )

        report_path = self._report_path()
        try:
            with open(report_path, "w") as f:
                f.write(rendered)
        except OSError as exc:
            self._display.error(f"install_report: failed to write {report_path}: {exc}")
