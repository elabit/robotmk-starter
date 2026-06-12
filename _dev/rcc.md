# RCC — Robot Command Center

RCC ist das Umgebungs- und Task-Runner-Tool von Robocorp, das auch Robotmk intern nutzt.
Es baut isolierte Python-Environments aus `conda.yaml` und führt Robot Framework-Suites aus.

## Warum RCC statt `pip install`?

- RCC baut **reproduzierbare, isolierte Environments** (Holotree) — identisch lokal und in CI
- Nutzer brauchen **kein Python** installiert — nur RCC
- `rccPostInstall` in `conda.yaml` führt `rfbrowser init` nach dem Environment-Build aus

## RCC lokal verwenden

```bash
# Suite ausführen (baut Environment automatisch beim ersten Mal)
task test EXAMPLE=cryptolibrary

# Interaktive Shell im RCC-Environment (Debug, rfbrowser init prüfen, …)
task shell EXAMPLE=cryptolibrary
```

## RCC Binary herunterladen

Binaries werden **nicht committed** (`.gitignore`-Eintrag: `_dev/.rcc/rcc*`).
Hinweis: Die `.rcc`-Verzeichnisse enthalten nur noch die RCC-Binaries, nicht mehr die Konfigurationsdateien. Die Auswahl der Umgebung erfolgt jetzt ausschließlich über `.env` mit `RMKS_ENVIRONMENT` und `RMKS_DEVCONTAINER`.

```bash
task download-rcc          # Linux/macOS
task download-rcc-windows  # Windows
```

Das Skript lädt RCC v4.0.0 aus dem Robotmk-Release herunter:
`https://github.com/elabit/robotmk/releases/download/v4.0.0/rcc_linux64`  
Für eine andere Version: URL und Tag in `download-rcc.sh` / `download-rcc.ps1` anpassen.
