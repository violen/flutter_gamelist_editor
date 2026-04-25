---
name: github-workflow
description: Autonomer GitHub Workflow für PR-Erstellung, Review und Aufgabenfortführung. Nutzen, wenn Änderungen abgeschlossen sind und in das Repository (PR) fließen sollen oder wenn nach einem PR die nächste Aufgabe gestartet werden soll.
---

# GitHub Autonomer Workflow

Dieser Skill ermöglicht es dem Agenten, Änderungen am Projekt eigenständig in den GitHub-Workflow zu überführen und nahtlos an der nächsten Aufgabe weiterzuarbeiten.

## 1. Commit & Branching
- **Branch-Name:** `feature/<task-name>` oder `fix/<bug-name>`.
- **Commit-Stil:** Kurz und prägnant (maximal 50 Zeichen), orientiert am historischen Stil des Projekts (z. B. "Add SystemBubble", "Refactor models").
- **Vorgehen:** Alle relevanten Dateien stagen, Commits erstellen, in den Remote-Branch pushen.

## 2. Pull Request (PR) Erstellung
- **Titel:** Klarer Titel der Änderung.
- **Body:** Kurze Zusammenfassung der Änderungen, inklusive technischer Highlights (z. B. "Migrated to Null Safety").
- **Befehl:** `gh pr create --title "<Titel>" --body "<body>"`

## 3. Pull Request Review (Self-Review)
- **Checkliste:**
  - [ ] Code wurde mit `flutter analyze` geprüft.
  - [ ] App wurde auf einem physischen Gerät (IP `192.168.133.202`) oder Emulator getestet.
  - [ ] `GEMINI.md` wurde aktualisiert, falls nötig.
- **Vorgehen:** Der Agent führt einen Self-Review durch und dokumentiert dies im PR-Kommentar oder in der PR-Beschreibung.

## 4. Fortführung (Keep Going)
- Nach erfolgreicher PR-Erstellung soll der Agent:
  1. Den aktuellen Status in `GEMINI.md` unter "Completed" oder "In Progress" aktualisieren.
  2. Die nächste logische Aufgabe aus dem Projektplan oder den Zielen in `GEMINI.md` identifizieren.
  3. Den Benutzer kurz informieren: "PR #X erstellt. Ich fahre nun fort mit: <Nächste Aufgabe>."
  4. Die nächste Aufgabe ohne explizite Aufforderung starten.

## Besondere Regeln
- Bei kritischen Fehlern im Build oder in der Analyse: **STOPP** und den Benutzer informieren.
- Keine PRs mergen, außer der Benutzer hat dies explizit erlaubt (Standard: PR erstellen und auf Review warten).
