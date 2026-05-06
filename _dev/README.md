# _dev — Maintainer Tooling

> **Dieses Verzeichnis ist für Maintainer des Repos gedacht, nicht für Nutzer.**  
> Nutzer arbeiten ausschließlich mit dem `examples/`-Ordner.

---

## Überblick

```
_dev/
├── _environments/       ← Gemeinsame RCC-Environments (conda.yaml-Quellen)
│   └── rf-libbrowser-libcrypto/
│       ├── copier.yml
│       └── template/
│           └── conda.yaml.jinja
├── _examples/           ← Copier-Quellen für examples/ (vollständige Beispiele)
│   ├── cryptolibrary/
│   │   ├── .rcc         ← Zeigt auf Environment: SPACE=rf-libbrowser-libcrypto
│   │   ├── copier.yml
│   │   └── template/
│   └── web-webshop/
│       ├── .rcc
│       ├── copier.yml
│       └── template/
├── _templates/          ← Copier-Quellen für templates/ (minimale Skeletons)
│   ├── cryptolibrary/
│   │   ├── .rcc
│   │   └── template/
│   └── web-webshop/
│       ├── .rcc
│       └── template/
├── config/
│   └── versions.env     ← Versionspins (einzige Pflegestelle!)
├── .rcc/                ← RCC-Binaries (NICHT committed, lokal herunterladen)
│   ├── rcc              ← nach task download-rcc (Linux/macOS)
│   └── rcc.exe          ← nach task download-rcc-windows (Windows)
└── scripts/
    ├── download-rcc.sh   ← RCC-Binary herunterladen (Linux/macOS)
    ├── download-rcc.ps1  ← RCC-Binary herunterladen (Windows)
    ├── generate-all.sh   ← Alle examples/ und templates/ generieren (Linux/macOS)
    └── generate-all.ps1  ← Alle examples/ und templates/ generieren (Windows)
```

---

## 1. Erster Setup nach dem Klonen

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
task download-rcc     # RCC-Binary nach _dev/.rcc/ laden (Linux/macOS)
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

## 2. Wie Copier hier eingesetzt wird (Modell 2 — intern)

Copier wird **ausschließlich vom Maintainer** genutzt. Nutzer sehen Copier nie.

### Warum Copier?

Die Beispiele in `examples/` sind keine handgeschriebenen Einzeldateien — sie werden
aus Templates in `_dev/_templates/` **generiert**. Das ermöglicht:

- **Konsistenz**: `conda.yaml`, `robot.yaml` und Boilerplate sind in allen Beispielen identisch
- **Versionspflege**: Eine Stelle (`generate-all.sh`) steuert alle Versionen
- **Reproducibility**: `.copier-answers.yml` in jedem generierten Ordner hält fest, mit
  welchen Versionen das Beispiel zuletzt generiert wurde

### Template-Struktur

Jeder Beispieltyp hat ein eigenes Template (kein Mono-Template mit `{% if %}`-Chains):

```
_dev/_examples/cryptolibrary/
├── .rcc                 ← Zeigt auf das RCC-Environment: SPACE=rf-libbrowser-libcrypto
├── copier.yml           ← Variablen-Definitionen (werden von versions.env befüllt)
└── template/            ← Inhalt, der nach examples/cryptolibrary/ kopiert wird
    ├── robot.yaml       ← Statische Datei (wird unverändert kopiert)
    ├── suite.robot      ← Statische Datei
    ├── robot.toml       ← Statische Datei
    ├── keys/            ← Statische Dateien (CryptoLibrary-Schlüssel)
    ├── .rcc             ← Wird ins generierte Beispiel kopiert (Space-Name)
    └── .copier-answers.yml.jinja  ← Tracking-Datei (wird generiert)
    # conda.yaml fehlt hier absichtlich — wird vom Environment injiziert (s. u.)
```

> **`_subdirectory: template`** in `copier.yml` ist entscheidend: Copier kopiert nur den
> Inhalt von `template/`, nicht `copier.yml` selbst.

### Shared Environments — `_environments/` und `.rcc`

Mehrere Beispiele teilen sich oft dieselbe `conda.yaml` (z. B. alle, die Browser + Crypto
benötigen). Statt die `conda.yaml.jinja` in jedes Template zu duplizieren, gibt es eine
zentrale Quelle in `_environments/`.

**Ablauf beim Generieren:**

1. `generate-all.sh` liest die `.rcc`-Datei im Quell-Verzeichnis:
   ```ini
   SPACE=rf-libbrowser-libcrypto
   ```
2. Es ruft Copier für `_environments/rf-libbrowser-libcrypto/` auf und **injiziert**
   `conda.yaml` in `_dev/_examples/<name>/template/` (temporär, für den nächsten Schritt).
3. Danach folgt die eigentliche Generierung: Copier kopiert alles aus `template/` —
   inklusive der frisch injizierten `conda.yaml` — nach `examples/<name>/`.

**Environment-Struktur:**

```
_dev/_environments/rf-libbrowser-libcrypto/
├── copier.yml           ← Variablen (rf_version, rf_lib_browser_version, …)
└── template/
    └── conda.yaml.jinja ← Eine conda.yaml für alle Beispiele mit diesem Environment
```

Der **Space-Name** (`rf-libbrowser-libcrypto`) hat zwei Bedeutungen:
- Verzeichnisname in `_environments/` → Copier findet das richtige Template
- RCC Holotree Space-Name → Beispiele mit demselben Space teilen sich den Environment-Cache

Das generierte `examples/<name>/.rcc` (mit `SPACE=rf-libbrowser-libcrypto`) wird auch von
`task test` und dem GitHub-Actions-Workflow gelesen, um den richtigen Space zu übergeben.

### `.copier-answers.yml` — Tracking-Datei

Jedes generierte Beispiel enthält eine `.copier-answers.yml`. Diese Datei wird **committed**
und dient als "Stempel": welche Template-Version und welche Paketversionen wurden zuletzt
verwendet.

```yaml
# .copier-answers.yml (Beispiel)
_src_path: /Users/simon/…/_dev/_templates/cryptolibrary
rf_version: 7.1.1
browser_version: 19.12.5
```

### Shared README — `_shared/` und Partials

Jedes generierte Beispiel erhält ein einheitlich aufgebautes `README.md`. Die Struktur ist
aufgeteilt in einen **gemeinsamen** und einen **beispiel-spezifischen** Teil:

```
_dev/
├── _shared/
│   └── README.md.jinja          ← Gemeinsame Sektionen (Prerequisites, Libraries & Versions,
│                                   How to Run); enthält {% include 'README.partial.md' %}
└── _examples/
    └── <name>/
        ├── README.partial.md    ← Beispiel-spezifisch: Titel, Beschreibung, What This
        │                           Demonstrates, Test Cases, Key Files, Links
        └── template/            ← README.partial.md liegt bewusst NICHT hier
            └── README.md.jinja  ← wird vom Skript temporär hierhin kopiert (s. u.)
```

**Ablauf beim Generieren:**

1. `generate-all.sh` prüft, ob `_dev/_shared/README.md.jinja` und
   `_dev/_examples/<name>/README.partial.md` beide existieren.
2. Falls ja: `README.md.jinja` wird temporär nach `_dev/_examples/<name>/template/` kopiert
   (damit Copier es als Output-Datei `README.md` rendert).
3. Copier rendert `README.md.jinja` — dabei löst `{% include 'README.partial.md' %}` die
   Partial-Datei auf. Copier's Jinja-Loader sucht Includes im **Root** des Quell-Verzeichnisses
   (neben `copier.yml`), deshalb liegt `README.partial.md` dort und nicht in `template/`.
4. Das temporäre `README.md.jinja` wird nach dem Copier-Lauf wieder entfernt.

**Bedingte Library-Tabelle:**

`README.md.jinja` rendert die Versions-Tabelle bedingt — gesteuert durch Flags in `copier.yml`:

```yaml
# _dev/_examples/<name>/copier.yml
use_browser:
  type: bool
  default: true   # oder false für Beispiele ohne Browser-Library

use_crypto:
  type: bool
  default: true
```

Im Template:
```jinja
{% if use_browser %}| robotframework-browser | `{{ rf_lib_browser_version }}` |{% endif %}
{% if use_crypto %}| robotframework-crypto  | `{{ rf_lib_crypto_version }}`  |{% endif %}
```

**Neues Beispiel mit README:**

1. `_dev/_examples/<name>/README.partial.md` anlegen (Inhalt s. bestehende Partials als
   Vorlage). Die Partial-Datei darf selbst Jinja-Variablen (`{{ rf_version }}` etc.) nutzen.
2. `use_browser` / `use_crypto` in `copier.yml` korrekt setzen.
3. `task generate EXAMPLE=<name>` — der Rest passiert automatisch.

**`_dev/_templates/` (Skeletons)** erhalten kein README — dort existiert kein
`README.partial.md`, und `generate-all.sh` überspringt die README-Injektion in diesem Fall
stillschweigend.

---

## 3. Versionen pflegen

**Einzige Pflegestelle**: [`_dev/config/versions.env`](config/versions.env)

```ini
RF_VERSION=7.1.1
RF_LIB_BROWSER_VERSION=19.12.5
RF_LIB_CRYPTO_VERSION=0.3.0
PYTHON_VERSION=3.12
PIP_VERSION=23.2.1
NODEJS_VERSION=22.11.0
```

Beide Skripte (`generate-all.sh` und `generate-all.ps1`) lesen diese Datei automatisch —
keine Anpassung in den Skripten selbst nötig.

Nach einer Anpassung:

```bash
task generate
git add examples/
git commit -m "chore: bump RF to 7.2.0"
```

Für ein einzelnes Beispiel:

```bash
task generate EXAMPLE=cryptolibrary
```

---

## 4. Neues Beispiel hinzufügen

### Bestehendes Environment verwenden

Falls das neue Beispiel Browser + Crypto benötigt (wie alle bisherigen):

1. **Quellen anlegen**:
   - `_dev/_examples/<name>/copier.yml` (minimalst: nur `_subdirectory: template`)
   - `_dev/_examples/<name>/.rcc` mit `SPACE=rf-libbrowser-libcrypto`
   - `_dev/_examples/<name>/template/` mit `robot.yaml`, `suite.robot`, `robot.toml`, ...
   - Analog für `_dev/_templates/<name>/` (Skeleton-Variante)
2. **Generieren**: `task generate EXAMPLE=<name>`
3. **Commit**: `examples/<name>/` und `templates/<name>/` committen (inkl. `.copier-answers.yml`)
4. **CI**: Der `detect-changes`-Job erkennt das neue Verzeichnis automatisch.

### Neues Environment anlegen

Falls das neue Beispiel andere Dependencies braucht (z. B. nur SeleniumLibrary):

1. **Environment-Verzeichnis anlegen**:
   ```
   _dev/_environments/<space-name>/
   ├── copier.yml           ← mindestens: _subdirectory: template
   └── template/
       └── conda.yaml.jinja ← conda-Abhängigkeiten mit Jinja2-Variablen
   ```
2. **`.rcc` im Quell-Verzeichnis** auf den neuen Space zeigen lassen:
   ```ini
   SPACE=<space-name>
   ```
3. Falls neue Versionen nötig: in `versions.env` ergänzen und in `generate-all.sh/ps1` als
   `--data`-Parameter aufnehmen.
4. Generieren und committen wie oben.

---

## 5. RCC — Robot Command Center

RCC ist das Umgebungs- und Task-Runner-Tool von Robocorp, das auch Robotmk intern nutzt.
Es baut isolierte Python-Environments aus `conda.yaml` und führt Robot Framework-Suites aus.

### Warum RCC statt `pip install`?

- RCC baut **reproduzierbare, isolierte Environments** (Holotree) — identisch lokal und in CI
- Nutzer brauchen **kein Python** installiert — nur RCC
- `rccPostInstall` in `conda.yaml` führt `rfbrowser init` nach dem Environment-Build aus

### RCC lokal verwenden

```bash
# Suite ausführen (baut Environment automatisch beim ersten Mal)
task test EXAMPLE=cryptolibrary

# Interaktive Shell im RCC-Environment (Debug, rfbrowser init prüfen, …)
task shell EXAMPLE=cryptolibrary
```

### RCC Binary herunterladen

Binaries werden **nicht committed** (`.gitignore`-Eintrag: `_dev/.rcc/rcc*`).

```bash
task download-rcc          # Linux/macOS
task download-rcc-windows  # Windows
```


Das Skript lädt RCC v4.0.0 aus dem Robotmk-Release herunter:
`https://github.com/elabit/robotmk/releases/download/v4.0.0/rcc_linux64`  
Für eine andere Version: URL und Tag in `download-rcc.sh` / `download-rcc.ps1` anpassen.

---

## 6. GitHub Actions CI

### Workflow: `test-examples.yml`

2-stufiges Design:

```
Push zu main (examples/** geändert)

  │
  ▼
Job: detect-changes
  git diff HEAD~1 HEAD 
  → welche Ordner in examples/ geändert?
  Output: JSON-Array, z. B. ["cryptolibrary"]

  │
  ▼
Job: test  (Matrix: os × example)
  ubuntu-latest  ×  cryptolibrary  → Download RCC → holotree build → robot run
  windows-latest ×  cryptolibrary  → Download RCC → holotree build → robot run
```

- **`fail-fast: false`**: Ein fehlgeschlagenes Beispiel bricht nicht den Rest ab
- **`workflow_dispatch`**: Manueller Trigger; `example`-Input für gezielten Test eines Beispiels
- **RCC in CI**: Wird per `curl` von GitHub Releases heruntergeladen — kein committed Binary nötig

### Lokale CI-Tests mit `act`

[`act`](https://github.com/nektos/act) simuliert GitHub Actions lokal in Docker.

```bash
# Installation (macOS)
brew install act
```

Eine `.actrc` im Repo-Root setzt das Docker-Image vor — kein manuelles Flag nötig:

```
-P ubuntu-latest=catthehacker/ubuntu:act-22.04
```

Danach:

```bash
# Alle geänderten Suites testen (simuliert push)
act push -j test

# Nur eine Suite (workflow_dispatch)
act workflow_dispatch -j test --input suite=examples/cryptolibrary
act workflow_dispatch -j test --input suite=templates/cryptolibrary

# Nur den detect-changes Job
act push -j detect-changes
```

### Workflow: `release-please.yml`

Auf jedem Merge in `main` prüft Release Please, ob Conventional-Commit-Messages
einen Release rechtfertigen (`feat:`, `fix:`, etc.). Falls ja, öffnet es automatisch
einen Release-PR mit Changelog. Nach dem Merge wird ein GitHub Release erzeugt.

---

## 7. Branch-Strategie für ältere Versionen

`main` enthält immer die **aktuellste** Dependency-Kombination.

Für ältere Kombinationen (z. B. RF 6 + Browser 19.1) gibt es `compat/**`-Branches:

```bash
git checkout -b compat/rf6-browser191
# Versionen in generate-all.sh anpassen → RF_VERSION="6.1.1", BROWSER_VERSION="19.1.x"
task generate
git commit -m "chore: set versions for RF6/Browser191 compat branch"
git push origin compat/rf6-browser191
```

Der CI-Workflow läuft automatisch auch auf `compat/**`-Branches (`branches: ["main", "compat/**"]`).

---

## 8. Codespaces / Devcontainer

Für Workshops und schnellen Einstieg ohne lokale Installation.

- `.devcontainer/devcontainer.json` — Basis: Ubuntu 24.04
- Port **6080** → noVNC-Desktop (Browser-Tests sichtbar, `ROBOTMK_HEADLESS_HOST=false`)
- `on-create.sh`: installiert xfce4, tigervnc, noVNC, Playwright-Systemdeps, lädt RCC herunter
- `post-start.sh`: startet VNC-Server + noVNC-Proxy bei jedem Start

Nach dem Start: im Forwarded-Ports-Tab auf Port 6080 klicken → Browser-Desktop öffnet sich.
