# Second Brain 🧠

> **Save Everything. Find Anything.**

Second Brain is an offline-first personal knowledge management Flutter application. Store notes, documents, images, bookmarks, and voice recordings in one beautiful, fast, and private application. No account. No cloud. No tracking.

---

## ✨ Features

| Feature | Description |
|---|---|
| 📝 **Notes** | Rich text editor with bold, italic, checklists, code blocks, headings |
| 📄 **Documents** | Import PDFs, DOCs, PPTs, XLS, and more |
| 🖼️ **Images** | Capture or import images with fullscreen viewer |
| 🔖 **Bookmarks** | Save URLs with metadata, favicon, and tags |
| 🎤 **Voice Notes** | Record, playback, and organize audio notes |
| 📁 **Collections** | Organize everything into color-coded collections |
| 🏷️ **Tags** | Multi-tag any item for fast filtering |
| ⭐ **Favorites** | Universal favorites across all content types |
| 🔍 **Search** | Global search across all titles, content, and tags |
| 🌙 **Themes** | Dark, Light, and System theme modes |

---

## 🏗️ Architecture

- **Pattern**: Feature-first Clean Architecture
- **State**: Riverpod (providers, notifiers)
- **Database**: Drift (SQLite)
- **Navigation**: go_router
- **Models**: Freezed + JSON Serializable

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.38.5+
- Dart 3.10.4+
- Android Studio / Xcode

### Installation

```bash
git clone <repo>
cd second_brain
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## 📁 Project Structure

```
lib/
├── core/           # Shared infrastructure
├── features/       # Feature modules
└── shared/         # Reusable widgets
```

See [FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) for the full tree.

---

## 📄 Documentation

| File | Description |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design and patterns |
| [DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) | Drift table definitions |
| [DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Color, typography, spacing |
| [THEME_GUIDE.md](docs/THEME_GUIDE.md) | Material 3 theming guide |
| [STATE_MANAGEMENT.md](docs/STATE_MANAGEMENT.md) | Riverpod patterns |
| [TESTING_GUIDE.md](docs/TESTING_GUIDE.md) | Testing strategy |
| [ROADMAP.md](docs/ROADMAP.md) | Future features |

---

## 🔒 Privacy

- **100% offline** — no data ever leaves your device
- **No analytics** — zero tracking
- **No accounts** — no sign-up required
- **Open storage** — your files stay in your app sandbox

---

## 📱 Platform Support

| Platform | Status |
|---|---|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| macOS | 🔜 Planned |
| Web | 🔜 Planned |

---

## 📝 License

MIT License. See LICENSE for details.
