# Generate-Pipeline

## Wie Copier hier eingesetzt wird

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
├── copier.yml           ← Variablen-Definitionen (werden von versions.env befüllt)
└── template/            ← Inhalt, der nach examples/cryptolibrary/ kopiert wird
    ├── .env             ← RMKS_ENVIRONMENT + RMKS_DEVCONTAINER + projekt-spezifische Vars
    ├── robot.yaml       ← Statische Datei (wird unverändert kopiert)
    ├── suite.robot      ← Statische Datei
    ├── robot.toml       ← Statische Datei
    ├── keys/            ← Statische Dateien (CryptoLibrary-Schlüssel)
    └── .copier-answers.yml.jinja  ← Tracking-Datei (wird generiert)
    # conda.yaml fehlt hier absichtlich — wird vom Environment injiziert (s. u.)
```

> **`_subdirectory: template`** in `copier.yml` ist entscheidend: Copier kopiert nur den
> Inhalt von `template/`, nicht `copier.yml` selbst.

### Shared Environments — `_environments/` und `RMKS_ENVIRONMENT`

Mehrere Beispiele teilen sich oft dieselbe `conda.yaml` (z. B. alle, die Browser + Crypto
benötigen). Statt die `conda.yaml.jinja` in jedes Template zu duplizieren, gibt es eine
zentrale Quelle in `_environments/`.

**Ablauf beim Generieren:**

1. `generate-all.sh` liest `RMKS_ENVIRONMENT` aus `template/.env`:
   ```ini
   RMKS_ENVIRONMENT=rf-libbrowser-libcrypto
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

`RMKS_ENVIRONMENT` in `template/.env` wird von `generate-all.sh` gelesen, um den richtigen
Space zu injizieren, und von `task test` / `task shell`, um den richtigen Space an RCC zu
übergeben.

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

**Versions-Tabelle im README:**

Jedes Environment legt in `template/versions.partial.md.jinja` fest, welche Pakete es
mitbringt. `generate-all.sh` injiziert diese Datei zusammen mit `conda.yaml` ins Beispiel.
Das Shared-README inkludiert sie mit `{% include 'versions.partial.md' %}`.

```
_dev/_environments/rf-libbrowser-libcrypto/template/versions.partial.md.jinja:

| Library | Version |
|---|---|
| Python | `{{ python_version }}` |
| Node.js | `{{ nodejs_version }}` |
| Robot Framework | `{{ rf_version }}` |
| robotframework-browser | `{{ rf_lib_browser_version }}` |
| robotframework-crypto | `{{ rf_lib_crypto_version }}` |
```

**Neues Beispiel mit README:**

1. `_dev/_examples/<name>/README.partial.md` anlegen (Inhalt s. bestehende Partials als
   Vorlage). Die Partial-Datei darf selbst Jinja-Variablen (`{{ rf_version }}` etc.) nutzen.
2. `task generate EXAMPLE=<name>` — der Rest passiert automatisch.

**`_dev/_templates/` (Skeletons)** erhalten kein README — dort existiert kein
`README.partial.md`, und `generate-all.sh` überspringt die README-Injektion in diesem Fall
stillschweigend.

---

## Versionen pflegen

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

## Neues Beispiel hinzufügen

### Bestehendes Environment verwenden

Falls das neue Beispiel Browser + Crypto benötigt (wie alle bisherigen):

1. **Quellen anlegen**:
   - `_dev/_examples/<name>/copier.yml` (minimalst: nur `_subdirectory: template`)
   - `_dev/_examples/<name>/template/.env` mit `RMKS_ENVIRONMENT=rf-libbrowser-libcrypto`
     und `RMKS_DEVCONTAINER=desktop` (oder `headless`)
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
2. **`RMKS_ENVIRONMENT`** in `template/.env` auf den neuen Space-Namen setzen:
   ```ini
   RMKS_ENVIRONMENT=<space-name>
   ```
3. Falls neue Versionen nötig: in `versions.env` ergänzen und in `generate-all.sh/ps1` als
   `--data`-Parameter aufnehmen.
4. Generieren und committen wie oben.

---

## Labs hinzufügen

Labs sind Checkmk-basierte Praxisumgebungen für Studenten. Sie werden als eigenständige
GitHub-Repos veröffentlicht, die direkt als Codespace geöffnet werden können.

**Unterschiede zu `examples/` und `templates/`:**

| Aspekt | examples/ | templates/ | labs/ |
|---|---|---|---|
| Zweck | Vollständige Beispiele | Minimale Skeletons | Praxislabs (mehrere Suites) |
| Devcontainer | `desktop` oder `headless` | keiner | `cmk25` (Checkmk-Image) |
| Devcontainer-Steuerung | `RMKS_DEVCONTAINER` in `template/.env` | — | `RMKS_DEVCONTAINER` in `template/.env` |
| CI (GitHub Actions) | ✓ | — | — |
| Codespace-Zielrepo | `robotmk/example-<name>` | — | eigenes Repo (manuell pushen) |
| Suiten-Status | vollständig & lauffähig | Skeleton | können unvollständig sein |

### Neues Lab anlegen

1. **Quellen anlegen**:
   ```
   _dev/_labs/<name>/
   ├── copier.yml           ← minimal: nur _subdirectory: template
   ├── README.partial.md    ← Lab-spezifischer README-Teil (s. u.)
   └── template/
       ├── .env             ← RMKS_ENVIRONMENT=<env-name>, RMKS_DEVCONTAINER=cmk25
       ├── robot.yaml
       └── rf-suites/       ← oder beliebige Struktur
           ├── robot.toml
           └── suite.robot
   ```

2. **`README.partial.md` anlegen** — enthält `{% include 'how-to-run-lab.partial.md' %}`
   statt `how-to-run.partial.md`. Als Vorlage kann `_dev/_labs/robotmk-lab-slac26/README.partial.md`
   dienen.

3. **Generieren**:
   ```bash
   task generate EXAMPLE=<name>
   ```
   Erzeugt `labs/<name>/` mit fertigem `.devcontainer/`.

4. **Veröffentlichen** (manuell):
   ```bash
   cd labs/<name>
   git init && git add . && git commit -m "initial"
   git remote add origin git@github.com:robotmk/<name>.git
   git push -u origin main
   ```

### `how-to-run-lab.partial.md`

Für Labs gibt es eine eigene shared-Partial in `_dev/_shared/how-to-run-lab.partial.md`
mit angepasstem Codespaces-Badge und labsspezifischem Text. Der README.partial.md eines
Labs inkludiert diese statt `how-to-run.partial.md`.

---

## Populate — Zusätzliche Dateien nach dem Generieren

Nach dem Copier-Lauf kann jede Quelle (Example, Template, Lab) optional eine
`populate.yaml` enthalten. `generate-all.sh/ps1` ruft dann `_dev/scripts/populate.py`
auf, das die definierten Dateien und Verzeichnisse in das bereits erzeugte Zielverzeichnis
kopiert.

### Format

```yaml
populate:

  # Lokale Datei → Datei  (src relativ zum Repo-Root)
  - src: _dev/_shared/some-config.json
    dst: config/some-config.json

  # Lokales Verzeichnis → Verzeichnis
  - src: _dev/_shared/resources/
    dst: rf-suites/resources/
    exclude:            # optional: Glob-Patterns, auf jeder Ebene übersprungen
      - "*.pyc"
      - "__pycache__/"

  # Git-Repository → Verzeichnis  (wird bei jedem generate frisch geklont)
  - src: https://github.com/org/repo.git
    ref: v1.2.0         # optional: Branch oder Tag (keine Commit-SHAs)
    subpath: examples/  # optional: nur diesen Teilpfad aus dem Repo übernehmen
    dst: rf-suites/

  # Überschreiben verhindern (nur für Dateien)
  - src: _dev/_shared/optional-override.json
    dst: config/override.json
    overwrite: false    # Standard: true; bei false wird die Datei übersprungen
```

### Regeln

| Quelltyp | Ziel | Verhalten |
| --- | --- | --- |
| Datei | Datei | Überschreibt standardmäßig; `overwrite: false` überspringt stillschweigend |
| Verzeichnis | Verzeichnis | **Bricht mit Fehler ab**, wenn das Ziel bereits Inhalte hat |
| Git-Repo | Verzeichnis | Wie Verzeichnis; `.git` wird immer vom Kopieren ausgeschlossen |

### Pfade

- **`src`** ist immer relativ zum **Repo-Root** (z. B. `_dev/_shared/foo` oder `_dev/_examples/bar/template/suite.robot`)
- **`dst`** ist immer relativ zum **generierten Zielverzeichnis** (z. B. `examples/<name>/` oder `labs/<name>/`)
- Git-Quellen beginnen mit `https://`

### Ablauf im generate-Skript

```
inject_devcontainer → inject_env → copier copy → populate.py → cleanup
```

`populate.py` wird von beiden Skripten aufgerufen, sobald eine `populate.yaml`
im Quellverzeichnis gefunden wird. PyYAML wird als Abhängigkeit von Copier bereits
mitgebracht.
