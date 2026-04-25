# Project Overview: flutter_gamelist_editor

## Environment & Tools
- **Version Management:** `vfox` (version-fox) is used for Flutter and Dart versioning.
- **Current Flutter Version:** 3.41.5 (managed via vfox).
- **GitHub Integration:** GitHub CLI (`gh`) is configured using a token in `.github/token`. 
- **User:** André Hauser (violen)
- **Android SDK:** `S:\android_sdk` (configured via `flutter config`)
- **Java:** `T:\sdk\temurin\21`
- **Debug Device:** `192.168.133.202` (Modern Android device)
- **Legacy Device Note:** Samsung Galaxy S5 (API 23) is too old for the current Flutter 3.41 toolchain (requires API 24+).

## Project Goals
- Modernization of a 7-year-old Flutter app. (Completed Apr 2026)
- Migration to Null Safety. (Completed Apr 2026)
- Automation of workflows via GitHub (PRs, Reviews). (In Progress)
- Improvement of UI/UX and codebase standards.

## Development Notes
- The app manages a game library stored in a GitHub Gist (`gamesList.json`).
- State management currently uses `provider` (v4, upgraded to v6).
- Project was migrated from Android v1 to v2 embedding and Groovy to Kotlin DSL (Gradle).
- Target: Autonomous working of the Gemini agent within this repository.
