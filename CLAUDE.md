# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SAES is an unofficial iOS app for IPN (Instituto Politécnico Nacional) students to access the Sistema de Administración Escolar. It scrapes the SAES web portal to display grades, schedules, kardex, and personal data through a native SwiftUI interface.

- **Bundle ID**: `com.roncuevas.saes-app`
- **iOS Deployment Target**: 16.0+
- **Language**: Swift 5, SwiftUI
- **Primary locale**: Spanish (Mexico), English fallback

## Build & Test Commands

```bash
# Build for simulator
xcodebuild build -project SAES.xcodeproj -scheme SAES \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'

# Run all tests
xcodebuild test -project SAES.xcodeproj -scheme SAES \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Run only unit tests
xcodebuild test -project SAES.xcodeproj -scheme SAES \
  -only-testing:SAESTests -destination 'platform=iOS Simulator,name=iPhone 15'

# Run only UI tests
xcodebuild test -project SAES.xcodeproj -scheme SAES \
  -only-testing:SAESUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

Dependencies are managed via **Swift Package Manager** (no CocoaPods/Carthage).

## Architecture: MVVM + Web Scraping

### MVVM per feature module

Each screen in `SAES/Screens/` follows this structure:

| File | Role |
|------|------|
| `*Screen.swift` / `*View.swift` | SwiftUI view, binds to ViewModel |
| `*ViewModel.swift` | `ObservableObject` with `@Published` state |
| `*DataSource.swift` | Implements `SAESDataSource` protocol, fetches HTML via URLSession |
| `*Parser.swift` | Implements `SAESParser` protocol, converts HTML to models using SwiftSoup |
| `*Error.swift` | Typed error enum for the feature |

### Two data flow paths

1. **URLSession scraping** (most features): DataSource fetches HTML → Parser extracts data via SwiftSoup → ViewModel updates `@Published` state
2. **WebView JS bridge** (teacher evaluation, complex forms): `WebViewManager` injects JavaScript into WKWebView → `WebViewHandler` receives messages via JS→Swift bridge

### Key protocols

- **`SAESDataSource`**: `fetch() async throws -> Data`, plus helpers like `SAESFetcher(url:)` and `SAESFetcherRedirected(url:)`
- **`SAESParser`**: `convert(_ data: Data) throws -> Document`
- **`SAESLoadingStateManager`**: Standard loading state machine (`idle → loading → loaded/error/noNetwork/empty`)

### Global state (EnvironmentObjects)

- `WebViewHandler.shared` — JS↔Swift message bridge with published properties
- `ToastManager.shared` — toast notifications
- `Router<NavigationRoutes>` — navigation via the `Routing` package

### Authentication

Cookie-based sessions using `ASPXFORMSAUTH` token. Passwords encrypted with ChaCha20 (CryptoSwift) and stored locally via `LocalJSON` as `{schoolCode}.json`. Cookies are manually injected into URLRequest headers.

## Key directories

- `SAES/Core/` — Infrastructure: networking, encryption, WebView bridge, Firebase, logging, persistence
- `SAES/Screens/` — Feature modules (Grades, Schedule, Kardex, Login, etc.)
- `SAES/Models/` — Data models (Codable structs)
- `SAES/Views/` — Reusable UI components
- `SAES/Others/Extensions/` — Swift type extensions
- `SAES/Constants/` — URLs, JS injection code, school codes, localization, navigation routes

## Adding a new screen

1. Create folder in `Screens/`
2. Add SwiftUI View, ViewModel (`ObservableObject` + `SAESLoadingStateManager`), DataSource (`SAESDataSource`), Parser (`SAESParser`), and Error enum
3. Register route in `NavigationRoutes` enum

## Conventions

- All localized strings go through `Localization.swift` using `NSLocalizedString`
- ViewModels use dependency injection for DataSources and Parsers (with defaults)
- Modern concurrency: `async/await`, `@MainActor` for UI updates
- File naming: `*+View.swift` for view extensions, `*Extension.swift` for type extensions
- Scheme launches with Spanish locale (`es-419`, region `MX`)

## Secrets

- **`SAES/Constants/Secrets/Secrets.swift`** contains the `cryptoKey` used for local password encryption (ChaCha20). The key value is set locally and must **NEVER** be committed to git. The file in the repo has an empty placeholder (`""`). Do not modify, overwrite, or stage this file.

## Git Commit Rules

- **No co-authorship**: Never add `Co-Authored-By` to commits
- **Follow existing nomenclature**: Use conventional commit prefixes matching the repo history (`feat:`, `refactor:`, `fix:`, etc.)
- **Atomic commits**: Make multiple small, descriptive commits instead of bundling everything into one

## Available Skills

Skills are specialized capabilities that can be invoked with `/skill-name`. The following skills are available:

### Swift Development Skills
| Skill | Description |
|-------|-------------|
| `/swift-concurrency` | Expert guidance on async/await, actors, Sendable, @MainActor, Swift 6 migration, and concurrency patterns |
| `/swiftui-expert-skill` | SwiftUI best practices: state management, view composition, performance, modern APIs, and iOS 26+ Liquid Glass |

### iOS Project Skills
| Skill | Description |
|-------|-------------|
| `/ios` | General iOS development commands |
| `/ios-feature` | Generate iOS feature modules following project architecture |
| `/ios-service` | Generate iOS service layer components |
| `/ios-uitest` | Generate iOS UI tests with Robot Pattern |
| `/ios-architecture` | iOS modular architecture guidance |

### Utility Skills
| Skill | Description |
|-------|-------------|
| `/find-skills` | Discover and install new agent skills |
| `/keybindings-help` | Customize Claude Code keyboard shortcuts |

### Skill Files Location
Custom skills are stored in `.agents/skills/` with the following structure:
```
.agents/skills/
├── swift-concurrency/
│   ├── SKILL.md
│   └── references/
└── swiftui-expert-skill/
    ├── SKILL.md
    └── references/
```
