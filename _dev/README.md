# _dev — Maintainer Tooling

> **Dieses Verzeichnis ist für Maintainer des Repos gedacht, nicht für Nutzer.**  
> Nutzer arbeiten ausschließlich mit dem `examples/`-Ordner.

---

## Überblick

```
_dev/
├── _devcontainers/      ← Zentralisierte Devcontainer-Templates
│   ├── headless/        ← Für Beispiele mit RMKS_DEVCONTAINER=headless
│   │   ├── copier.yml
│   │   └── template/
│   │       └── .devcontainer/
│   │           ├── devcontainer.json.jinja
│   │           └── setup.sh
│   └── desktop/         ← Für Beispiele mit RMKS_DEVCONTAINER=desktop
│       ├── copier.yml
│       └── template/
│           └── .devcontainer/
│               ├── devcontainer.json.jinja
│               └── setup.sh
├── _environments/       ← Gemeinsame RCC-Environments (conda.yaml-Quellen)
│   ├── rf/
│   ├── rf-libbrowser/
│   ├── rf-libbrowser-libcrypto/
│   └── rf-libcrypto/
│       ├── copier.yml
│       └── template/
│           ├── conda.yaml.jinja
│           └── versions.partial.md.jinja   ← Versions-Tabelle für README
├── _examples/           ← Copier-Quellen für examples/ (vollständige Beispiele)
│   ├── cryptolibrary-simple/
│   │   ├── copier.yml
│   │   ├── README.partial.md    ← Beispiel-spezifischer README-Teil
│   │   ├── populate.yaml        ← optional: zusätzliche Dateien nach dem Generieren → generate.md
│   │   └── template/
│   │       └── .env             ← RMKS_ENVIRONMENT, RMKS_DEVCONTAINER, VNC_RESOLUTION optional
│   ├── web-cryptolibrary/
│   │   ├── copier.yml
│   │   ├── README.partial.md
│   │   └── template/
│   │       └── .env             ← RMKS_ENVIRONMENT, RMKS_DEVCONTAINER, VNC_RESOLUTION optional
│   └── web-webshop/
│       └── …
├── _shared/
│   └── README.md.jinja          ← Gemeinsame README-Sektionen
├── _templates/          ← Copier-Quellen für templates/ (minimale Skeletons)
├── _labs/               ← Copier-Quellen für labs/ (Checkmk-Praxislabs für Studenten)
│   └── robotmk-lab-slac26/
│       ├── copier.yml
│       ├── README.partial.md    ← Lab-spezifischer README-Teil
│       └── template/
│           └── .env             ← RMKS_ENVIRONMENT, RMKS_DEVCONTAINER, VNC_RESOLUTION optional
├── config/
│   └── versions.env     ← Versionspins (einzige Pflegestelle!)
├── .rcc/                ← Nur RCC-Binaries (NICHT für Konfiguration, NICHT committed)
└── scripts/
    ├── generate-all.sh   ← Alle examples/ und templates/ generieren (Linux/macOS)
    ├── generate-all.ps1  ← Alle examples/ und templates/ generieren (Windows)
    └── populate.py       ← Post-Copier-Populate-Schritt (wird von generate-Skripten aufgerufen)
```

---

## Setup nach dem Klonen

Alle wiederkehrenden Aufgaben sind als [Taskfile](https://taskfile.dev)-Tasks definiert.
Installation (einmalig, falls noch nicht vorhanden):

```bash
brew install go-task   # macOS
# oder: https://taskfile.dev/installation/
```

Danach genügt ein einziger Befehl für den vollständigen Setup:

```bash
task setup   # installiert copier + lädt RCC-Binary herunter
```

Oder manuell:

```bash
task install-copier   # Copier ins .venv installieren
task download-rcc     # RCC-Binary nach _dev/.rcc/ laden (Linux/macOS, nur Binary, keine .rcc-Konfig mehr)
task download-rcc-windows  # RCC-Binary laden (Windows)
```

### Verfügbare Tasks

```
task setup                          # Einmaliger Setup (copier + RCC + git hooks)
task install-copier                 # Nur copier installieren
task download-rcc                   # Nur RCC laden (Linux/macOS)
task install-hooks                  # Git hooks registrieren (.githooks/)
task generate                       # Alle examples/ aus Templates generieren
task generate EXAMPLE=cryptolibrary # Einzelnes Beispiel generieren
task test EXAMPLE=cryptolibrary     # Beispiel lokal testen
task shell EXAMPLE=cryptolibrary    # Interaktive Shell im RCC-Environment
```

---

## Weiterführende Dokumentation

| Thema | Datei |
| --- | --- |
| Generate-Pipeline (Copier, Versionen, neue Beispiele, Labs, Populate) | [generate.md](generate.md) |
| RCC — Robot Command Center | [rcc.md](rcc.md) |
| CI, Branches & Automatisierung | [ci.md](ci.md) |
| Codespaces & Devcontainer | [devcontainer.md](devcontainer.md) |
| Sub-Repo-Sync | [sync.md](sync.md) |
