---
name: github-workflow
description: Autonomer GitHub Workflow für PR-Erstellung, Review und Aufgabenfortführung. Nutze diesen Skill IMMER für Commits und PRs.
---

# GitHub Autonomer Workflow (V2 - Sicherheit Fokus)

Dieser Skill stellt sicher, dass Änderungen am Projekt sauber, verifiziert und vollständig in das Repository fließen.

## 1. Vorbereitung & Prüfung (MANDATORISCH)
- **Status prüfen:** Führe `git status` aus. Es dürfen keine unerwarteten Änderungen in anderen Dateien vorliegen.
- **Diff Review:** Führe `git diff` aus und lies den Output aufmerksam. Entspricht der Code exakt dem Plan? Sind keine Debug-Prints oder Platzhalter enthalten?
- **Analyse:** Führe IMMER `flutter analyze` aus. Ein PR darf nur erstellt werden, wenn keine Fehler (Errors) vorliegen. Warnungen sollten nach Möglichkeit behoben werden.

## 2. Commit & Branching
- **Branch-Name:** `feature/<task-name>` oder `fix/<bug-name>`.
- **Atomic Commits:** Teile große Änderungen in kleine, logische Einheiten auf (z.B. "UI: Update theme colors", "Fix: Gist parsing").
- **Commit-Stil:** Kurz und prägnant (max. 50 Zeichen), historisch konsistent.
- **Vorgehen:** 
  1. `git checkout -b <branch>`
  2. `git add <files>` (Nur die Dateien, die wirklich zum Task gehören!)
  3. `git commit -m "<message>"`

## 3. Pull Request (PR) & Self-Review
- **Push:** `git push origin <branch>`
- **Erstellung:** `gh pr create --title "<Titel>" --body "<body>"`
- **Self-Review Checkliste:**
  - [ ] Wurden ALLE geplanten Änderungen committet? (Prüfung via `git status` nach dem Commit).
  - [ ] Ist der Branch-Stand auf dem Remote aktuell?
  - [ ] Funktioniert der Build? (Ggf. im Hintergrund testen).

## 4. Merging
- Erst mergen, wenn der Agent absolut sicher ist, dass der lokale Stand sauber ist.
- Nach dem Merge: `git checkout develop` und `git pull origin develop`.

## Besondere Sicherheitsregeln
- **KEIN SCHNELLDURCHLAUF:** Wenn der Agent bemerkt, dass Dateien im "Modified" Status zurückbleiben, muss er den Prozess stoppen und den Grund finden.
- **SYNC-CHECK:** Vor jedem PR prüfen: `git fetch origin` gefolgt von einem Vergleich, ob der lokale Stand wirklich das ist, was hochgepusht werden soll.
