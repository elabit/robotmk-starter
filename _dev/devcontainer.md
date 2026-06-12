# Codespaces & Devcontainer

## Generierte Devcontainer (examples, templates, labs)

Für Workshops und schnellen Einstieg ohne lokale Installation.

### Zentralisierte Devcontainer-Templates (`_devcontainers/`)

Devcontainer-Konfigurationen werden **nicht** direkt in den Beispiel-Templates gepflegt,
sondern zentral in `_dev/_devcontainers/` und beim Generieren injiziert.

```
_dev/_devcontainers/
├── headless/           ← Reines Python-Image, kein VNC
│   ├── copier.yml
│   └── template/.devcontainer/
│       ├── devcontainer.json.jinja
│       └── setup.sh
├── desktop/            ← Python-Image + desktop-lite (noVNC, Port 6080)
│   ├── copier.yml
│   └── template/.devcontainer/
│       ├── devcontainer.json.jinja
│       └── setup.sh
└── cmk25/              ← Checkmk Pro 2.5 + desktop-lite + RCC (für Labs)
    ├── copier.yml
    └── template/.devcontainer/
        ├── devcontainer.json.jinja
        ├── setup.sh
        └── install_cmk_agent.sh
```

**Steuerung über `RMKS_DEVCONTAINER` in `template/.env`:**

`generate-all.sh` liest `RMKS_DEVCONTAINER` direkt aus `template/.env` und injiziert
den passenden Devcontainer-Typ. Kein separates `.devcontainer-type`-File nötig.

| `RMKS_DEVCONTAINER` | Injizierter Typ | Beschreibung |
|---|---|---|
| `desktop` | `desktop` | Python-Image + noVNC-Desktop |
| `headless` | `headless` | Python-Image, kein VNC |
| `cmk25` | `cmk25` | Checkmk Pro 2.5 + desktop-lite + RCC |
| nicht gesetzt / keine `.env` | — | Injektion übersprungen |

### VNC-Auflösung (`VNC_RESOLUTION`)

Für `desktop`-Container kann die Auflösung des VNC-Desktops in `.env` konfiguriert werden.
`setup.sh` liest `VNC_RESOLUTION` und setzt sie via `xrandr` in `~/.fluxbox/startup`.

```dotenv
# .env — optionaler Eintrag
VNC_RESOLUTION=1920x1080   # Standard: 1280x1024 wenn nicht gesetzt
```

Der Eintrag ist **auskommentiert** in den generierten `.env`-Dateien vorhanden — als
Hinweis für Nutzer. Die Änderung erfordert **keinen Rebuild** des Containers; `setup.sh`
läuft bei `postCreateCommand`, also einmalig nach der Erstellung.

### `setup.sh` — Was beim Container-Start passiert

Alle Typen führen `setup.sh` per `postCreateCommand` aus.

**`headless` und `desktop`** (Schritte 1–5 bzw. 1–6):

1. Lädt RCC nach `~/bin/rcc`
2. Baut das holotree-Environment (`rcc holotree vars`)
3. Legt Symlink `~/.rcc-env` → holotree-Root an (betrifft nur die Nutzung von RCC als Binary, nicht mehr für Konfigurationszwecke)
4. Ergänzt `~/.bashrc` mit `PATH` (idempotent, Marker-basiert)
5. Schreibt `.vscode/settings.json` (Python-Interpreter, RobotCode-Settings)
6. *(nur `desktop`)* Trägt `xrandr --output VNC-0 --mode <VNC_RESOLUTION>` in
   `~/.fluxbox/startup` vor `exec fluxbox` ein (idempotent)

**`cmk25`** (Schritte 1–9, auf Basis des `checkmk/check-mk-pro:2.5.0-latest`-Images):

1–6. Identisch mit `desktop`
7. Installiert den Checkmk-Agenten via `install_cmk_agent.sh vanilla`
8. Installiert Firefox via Mozilla PPA (`firefox-esr`)
9. Fügt einen `Checkmk`-Eintrag im Fluxbox-Menü hinzu und startet Fluxbox neu

### Devcontainer für ein neues Beispiel (examples/templates)

In `template/.env` eintragen:

```dotenv
RMKS_DEVCONTAINER=desktop    # → desktop-Devcontainer wird injiziert
# oder:
RMKS_DEVCONTAINER=headless   # → headless-Devcontainer wird injiziert
```

`task generate EXAMPLE=<name>` erledigt den Rest.

### Devcontainer für ein neues Lab

In `template/.env` eintragen:

```dotenv
RMKS_DEVCONTAINER=cmk25
```

Damit wird der `cmk25`-Typ injiziert.

### Codespaces-Badge in Sub-Repos

Sub-Repos, die ein `.devcontainer/` haben, erhalten beim Sync automatisch einen
„Open in GitHub Codespaces"-Badge oben und unten in der README. Die Repo-ID wird
zur Sync-Zeit via `gh api` ermittelt (s. `.github/scripts/sync-examples.sh`).

---

## CheckMK Devcontainer (Repo-Root `.devcontainer/`)

Das Repo-Root enthält ein eigenes `.devcontainer/` — unabhängig von den Beispiel-Devcontainern.
Es startet eine vollständige **CheckMK Pro**-Instanz mit VNC-Desktop, um die Robotmk-Integration
lokal zu entwickeln und testen (z. B. Regeln konfigurieren, Scheduler beobachten).

### Image & Desktop

| Eigenschaft | Wert |
|---|---|
| Base-Image | `checkmk/check-mk-pro:2.5.0-daily` |
| Desktop | `desktop-lite`-Feature (Fluxbox + TigerVNC + noVNC) |
| noVNC Web | Port **6080** → wird auto-forwarded und im Browser geöffnet |
| VNC-Passwort | `vscode` |
| CheckMK Web UI | Port **5000** → `http://localhost:5000/cmk/` |
| Login | `cmkadmin` / `cmk` |

### Wie es funktioniert

- **`overrideCommand: false`**: Der CheckMK-Entrypoint startet OMD (inkl. Apache, Livestatus,
  Scheduler). Ohne diesen Eintrag würde VS Code den Entrypoint mit `sleep infinity` ersetzen
  — CheckMK würde nie hochfahren.
- **`CMK_PASSWORD: cmk`**: Der Entrypoint setzt beim ersten Start das `cmkadmin`-Passwort.
- **`CMK_SITE_ID: cmk`**: Setzt den Site-Namen (Standard wäre `cmk`, hier explizit).
- **`desktop-lite`-Feature**: Installiert Fluxbox + TigerVNC + noVNC über den devcontainer-
  Feature-Mechanismus — kein eigenes Image nötig.
- **`--shm-size=1g`**: Verhindert Abstürze bei GUI-Anwendungen im VNC-Desktop.

### Workflow im Container

1. **Reopen in Container** → CheckMK startet (OMD-Init dauert ~30 s)
2. Port **6080** öffnet sich automatisch im Browser → noVNC-Desktop → Passwort `vscode`
3. Port **5000** → `http://localhost:5000/cmk/` → CheckMK-Weboberfläche
4. Im Fluxbox-Desktop laufen grafische Tools (Browser, xterm) im selben Container-Kontext

### Upgraden

Nur das Image-Tag in `.devcontainer/devcontainer.json` ändern:

```json
"image": "checkmk/check-mk-pro:2.5.0p1"
```

Dann **Rebuild Container** — OMD-Init läuft beim nächsten Start erneut durch.
