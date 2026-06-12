#!/usr/bin/env python3
"""Post-copier populate step.

Reads populate.yaml from a source folder and copies files/directories into the
already-generated project output directory.

Usage: python populate.py <populate.yaml> <repo_root> <dest_dir>

populate.yaml format:

  populate:

    # Local file → file (src is repo-root-relative)
    - src: _dev/_shared/some-config.json
      dst: config/some-config.json

    # Local directory → directory
    - src: _dev/_shared/resources/
      dst: rf-suites/resources/
      exclude:            # optional glob patterns to skip (applied at every level)
        - "*.pyc"
        - "__pycache__/"

    # Git repository → directory (always cloned fresh)
    - src: https://github.com/org/repo.git
      ref: v1.2.0         # optional: branch or tag (not commit SHAs)
      subpath: examples/  # optional: copy only this subtree from the repo root
      dst: rf-suites/

    # Per-entry options
    #   overwrite: true   # overwrite destination file if it exists (default: true)
    #                     # for directories: abort if destination is non-empty (always)

Rules:
  - src file   → dst file.  Overwrites unless overwrite: false.
  - src dir    → dst dir.   Aborts if dst already exists and is non-empty.
  - src git    → dst dir.   Same non-empty check; .git is always excluded from copy.
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Error: PyYAML not found. Run: pip install pyyaml", file=sys.stderr)
    sys.exit(1)


def copy_item(src: Path, dst: Path, overwrite: bool, exclude: list) -> None:
    if src.is_file():
        if dst.exists() and not overwrite:
            print(f"    (skipped — overwrite=false): {dst}")
            return
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        print(f"    ✓ file  {src} → {dst}")

    elif src.is_dir():
        if dst.exists() and any(dst.iterdir()):
            print(
                f"  Error: destination '{dst}' already exists and is non-empty. "
                "Aborting to avoid accidental overwrite.",
                file=sys.stderr,
            )
            sys.exit(1)
        dst.mkdir(parents=True, exist_ok=True)
        ignore_fn = shutil.ignore_patterns(*exclude) if exclude else None
        shutil.copytree(src, dst, dirs_exist_ok=True, ignore=ignore_fn)
        print(f"    ✓ dir")
        print(f"        {src}/")
        print(f"        {dst}/")

    else:
        print(f"  Error: source '{src}' does not exist or is not a file/directory.", file=sys.stderr)
        sys.exit(1)


def run_populate(populate_file: Path, repo_root: Path, dest_dir: Path) -> None:
    with open(populate_file) as f:
        data = yaml.safe_load(f)

    entries = data.get("populate") or []
    if not entries:
        return

    for entry in entries:
        src_str = str(entry["src"])
        dst_str = str(entry["dst"])
        overwrite = bool(entry.get("overwrite", True))
        exclude = list(entry.get("exclude") or [])
        dst = dest_dir / dst_str

        if src_str.startswith("https://"):
            ref = entry.get("ref")
            subpath = entry.get("subpath")
            label = src_str + (f"@{ref}" if ref else "") + (f" subpath={subpath}" if subpath else "")
            print(f"    ↳ Cloning {label} ...")

            with tempfile.TemporaryDirectory() as tmpdir:
                clone_dir = Path(tmpdir) / "repo"
                cmd = ["git", "clone", "--depth", "1"]
                if ref:
                    cmd += ["--branch", ref]
                cmd += [src_str, str(clone_dir)]

                result = subprocess.run(cmd, capture_output=True, text=True)
                if result.returncode != 0:
                    print(f"  Error: git clone failed:\n{result.stderr}", file=sys.stderr)
                    sys.exit(1)

                src = clone_dir / subpath if subpath else clone_dir
                copy_item(src, dst, overwrite, [".git"] + exclude)
        else:
            src = repo_root / src_str
            copy_item(src, dst, overwrite, exclude)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <populate.yaml> <repo_root> <dest_dir>", file=sys.stderr)
        sys.exit(1)

    run_populate(
        populate_file=Path(sys.argv[1]),
        repo_root=Path(sys.argv[2]),
        dest_dir=Path(sys.argv[3]),
    )
