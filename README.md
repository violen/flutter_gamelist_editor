# GameList Editor

A modern Flutter application to manage your private game library, synchronized seamlessly via GitHub Gists.

## ✨ Key Features

- **Modern Material 3 UI:** Sleek anthracite design with vibrant orange accents, optimized for dark mode.
- **Intelligent Scanning (OCR):** Add games by simply photographing the cover or spine. The app automatically extracts the title.
- **Automatic Translation:** Scanned foreign titles are identified and can be translated into German instantly.
- **Advanced Search & Filter:** Quickly find your games using combined title search, system filters (NSW, GCN, PC, etc.), and playstyle tags.
- **Robust Gist Sync:** High-performance synchronization with your GitHub Gist, including connectivity tests and error handling.
- **Safe Interaction:** Optimized list handling with swipe-to-delete and safety confirmation dialogs.

## 🚀 Getting Started

### Prerequisites
1.  **GitHub Token:** Create a Personal Access Token with the `gist` scope.
2.  **Gist Setup:** Create a Gist with a file named `gamesList.json`.
3.  **App Config:** Enter your Token and the Gist API URL (e.g., `https://api.github.com/gists/YOUR_GIST_ID`) in the app's settings.

### Gist JSON Format
```json
{
    "meta": { "lastEdit": 1714080000000 },
    "gameList" : [
        {
            "title": "Metroid Prime",
            "system": "gcn",
            "playStyle": ["casual", "letsPlay"]
        }
    ]
}
```

## 🛠 Technical Stack

- **Framework:** Flutter 3.41+ (Material 3 & Impeller)
- **Language:** Dart 3.x (Full Null Safety)
- **AI/ML:** Google ML Kit (Text Recognition, Language ID, Translation)
- **State Management:** Provider 6.x

---
*Modernized and maintained with ❤️ by [violen](https://github.com/violen) & Gemini CLI.*
