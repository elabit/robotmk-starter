# Sub-Repo-Sync

Jedes Beispiel in `examples/` wird als Snapshot in ein eigenes GitHub-Repo
(`robotmk/example-<name>`) gespiegelt — damit Nutzer ein einzelnes Repo klonen oder
in Codespaces öffnen können, ohne den ganzen Starter zu clonen.

## Workflow: `sync-examples.yml`

Wird ausgelöst nach erfolgreichem CI-Lauf (`workflow_run` auf `Run Suites`) oder manuell.
Benötigt das Secret `SYNC_TOKEN` (PAT mit `Contents` + `Administration` Write auf die
`robotmk`-Org).

## Skript: `.github/scripts/sync-examples.sh`

```bash
# Alle Beispiele syncen
.github/scripts/sync-examples.sh

# Nur ein Beispiel
.github/scripts/sync-examples.sh cryptolibrary-simple
```

**Ablauf pro Beispiel:**

1. `ensure_repo` — erstellt `robotmk/example-<name>` falls noch nicht vorhanden (`gh repo create`)
2. Repo-ID via `gh api repos/robotmk/example-<name> --jq '.id'` abrufen
3. Sub-Repo clonen (shallow), Token in Remote-URL einbetten (Auth)
4. Alle getrakten Dateien löschen (`git rm -rf .`)
5. Inhalte rsync-en, Exclude-Liste anwenden (`.copier-answers.yml`, `output/`, `browser/`, …)
6. Sync-Header **und** Sync-Footer in `README.md` einsetzen:
   - Header: Hinweis "synced from …" + Codespaces-Badge (falls `.devcontainer/` vorhanden)
   - Footer: Codespaces-Badge (Wiederholung am Ende)
7. Commit + Push (nur wenn Änderungen vorhanden)

**Exclude-Liste** (wird nicht ins Sub-Repo übertragen):
`.copier-answers.yml`, `output/`, `log.html`, `report.html`, `output.xml`, `browser/`,
`playwright-log.txt`
