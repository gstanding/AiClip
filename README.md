# AiClip - AI Clipboard Manager

An intelligent clipboard manager for **iOS** and **macOS** with on-device AI-powered categorization, smart tagging, and semantic search.

## Features

- **Smart Clipboard Monitoring** - Automatically captures clipboard content on both iOS and macOS
- **AI Content Analysis** - On-device content type detection (URLs, emails, code, JSON, colors, etc.)
- **Auto Categorization** - Automatically sorts clips into categories (work, development, social, finance, etc.)
- **Semantic Search** - Find clips by meaning, not just keywords, using Apple NaturalLanguage embeddings
- **Smart Tags** - AI-generated tags with named entity recognition (people, places, organizations)
- **iCloud Sync** - Seamless sync between all your devices via CloudKit + SwiftData
- **macOS Menu Bar** - Quick access to recent clips from the menu bar
- **iOS Widget** - Home screen widget showing recent clipboard history (small, medium, large)
- **Pin & Favorites** - Keep important clips easily accessible
- **Privacy First** - All AI processing happens on-device, no data leaves your device

## Requirements

- **iOS 17.0+** / **macOS 14.0+**
- **Xcode 15.0+**
- **XcodeGen 2.35+** (for project generation)
- Apple Developer account (for iCloud/CloudKit features)

## Setup

1. Install XcodeGen if you don't have it:
   ```bash
   brew install xcodegen
   ```

2. Clone the repository and generate the Xcode project:
   ```bash
   git clone <repo-url>
   cd AiClip
   xcodegen generate
   ```

3. Open the project in Xcode:
   ```bash
   open AiClip.xcodeproj
   ```

4. Select your Development Team in **Signing & Capabilities** for all targets

5. Build and run on your target device or simulator

## Architecture

```
SwiftUI + SwiftData + MVVM
├── On-device AI (Apple NaturalLanguage framework)
├── Cross-platform (iOS / macOS via #if os() compilation)
├── iCloud sync (CloudKit via SwiftData)
└── Reactive state (Combine + @Published)
```

### Tech Stack

| Component | Technology |
|-----------|-----------|
| UI | SwiftUI |
| Data | SwiftData + CloudKit |
| AI/NLP | NaturalLanguage framework |
| Reactivity | Combine |
| Widget | WidgetKit |

## Project Structure

```
AiClip/
├── project.yml                  # XcodeGen project configuration
├── AiClip/
│   ├── App/
│   │   ├── AiClipApp.swift      # App entry point, SwiftData + MenuBarExtra
│   │   └── ContentView.swift    # Root navigation (SplitView / TabView)
│   ├── Models/
│   │   └── ClipboardItem.swift  # SwiftData @Model, ContentType, ItemCategory
│   ├── Services/
│   │   ├── AIService.swift      # On-device AI analysis engine
│   │   ├── PasteboardMonitor.swift  # Cross-platform clipboard monitoring
│   │   └── CloudSyncManager.swift   # iCloud sync management
│   ├── ViewModels/
│   │   └── ClipboardManager.swift   # Main state manager
│   ├── Views/
│   │   ├── SidebarView.swift        # macOS sidebar navigation
│   │   ├── ClipboardListView.swift  # Main clip list with sorting
│   │   ├── DetailView.swift         # Clip detail with AI analysis
│   │   ├── CategoriesView.swift     # Category browser
│   │   ├── SettingsView.swift       # App settings
│   │   ├── MenuBarView.swift        # macOS menu bar popover
│   │   └── Components/
│   │       └── ClipboardItemRow.swift  # Reusable list row
│   ├── Utilities/
│   │   ├── Extensions.swift     # Helper extensions
│   │   └── Constants.swift      # App-wide constants
│   └── Resources/
│       └── Assets.xcassets      # App icons and colors
├── AiClipWidget/
│   └── AiClipWidget.swift       # iOS/macOS home screen widget
├── AiClipTests/
│   └── AiClipTests.swift        # Unit tests
└── AiClipUITests/
    └── AiClipUITests.swift      # UI tests
```

## AI Features

AiClip uses Apple's **NaturalLanguage** framework for all AI processing, ensuring privacy and offline capability:

| Feature | Description |
|---------|-------------|
| Content Detection | Identifies URLs, emails, phone numbers, code, JSON, hex colors, addresses |
| Categorization | Maps clips to categories based on content patterns and domain analysis |
| Summarization | Generates concise summaries based on content type |
| Tag Generation | NER-based tagging (people, places, organizations) + language detection |
| Semantic Search | NLEmbedding-based similarity matching for natural language queries |

## License

MIT License
