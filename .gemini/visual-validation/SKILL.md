---
name: visual-validation
description: Erstellt und analysiert Screenshots vom physischen Gerät via ADB, um UI-Design, Farben und Kontrast zu verifizieren. Nutzen, wenn UI-Änderungen abgeschlossen sind und visuell geprüft werden müssen.
---

# Visual Validation Skill

Dieser Skill ermöglicht es dem Agenten, den tatsächlichen Zustand der App auf einem Gerät visuell zu erfassen und zu analysieren.

## Workflow

1. **Screenshot aufnehmen:**
   - Befehl: `adb shell screencap -p /sdcard/screen.png`
   
2. **Bild auf den Host ziehen:**
   - Befehl: `adb pull /sdcard/screen.png ./temp_screenshot.png`

3. **Analyse:**
   - Nutze `read_file` mit dem Pfad `./temp_screenshot.png`, um das Bild einzulesen.
   - Prüfe visuelle Aspekte:
     - Korrekte Farben (Markenfarben).
     - Textlesbarkeit (Kontrast).
     - Layout-Stimmigkeit (Spacing, Rundungen).

4. **Aufräumen:**
   - Lösche lokale Datei: `Remove-Item ./temp_screenshot.png`
   - Lösche Datei auf Gerät: `adb shell rm /sdcard/screen.png`

## Best Practices
- Screenshots erst erstellen, nachdem die App vollständig geladen wurde.
- Bei Fehlern in der Darstellung (z. B. Überlappungen) den Code korrigieren und erneut validieren.
