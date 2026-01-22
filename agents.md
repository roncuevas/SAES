# SAES iOS Application - Technical Documentation

## Overview

SAES is a native iOS application that provides students of Instituto Politecnico Nacional (IPN) with mobile access to the Sistema de Administracion Escolar (SAES). The app enables students to view grades, schedules, academic history (kardex), and personal information through a modern SwiftUI interface.

---

## Project Structure

```
SAES/SAES/SAES/
├── Core/                          # Core services and infrastructure
│   ├── Analytics/                 # Firebase Analytics management
│   ├── AppDelegate/               # App initialization & push notifications
│   ├── CryptoSwift/               # Encryption/decryption utilities
│   ├── Encryption/                # Additional encryption helpers
│   ├── Events/                    # Calendar event management
│   ├── Firebase/                  # Firebase Storage & Firestore
│   ├── Logger/                    # OSLog-based logging
│   ├── Network/                   # HTTP networking
│   ├── Persistency/               # Local storage management
│   ├── PushNotifications/         # FCM notification handling
│   ├── RemoteConfig/              # Firebase Remote Config
│   ├── SAES/                      # SAES-specific view state parsing
│   ├── Toast/                     # Toast notification management
│   └── WebView/                   # WebView integration & message handling
├── Screens/                       # Feature-specific screens (MVVM)
│   ├── Grades/                    # Grade display & teacher evaluation
│   ├── Home/                      # Home screen
│   ├── IPNSchedule/               # IPN-wide schedule view
│   ├── Kardex/                    # Academic history/transcripts
│   ├── Logged/                    # Main tab view (post-login)
│   ├── Login/                     # Authentication screen
│   ├── Main/                      # Main navigation container
│   ├── News/                      # IPN news feed
│   ├── PersonalData/              # Student information display
│   ├── Schedule/                  # Class schedule & PDF export
│   ├── ScheduleAvailability/      # Available courses search
│   └── Setup/                     # Initial app setup
├── Models/                        # Data models
│   ├── Network/                   # Remote API models
│   ├── SAES/                      # SAES-specific models
│   └── [Domain models]            # GradeItem, KardexModel, etc.
├── Views/                         # Reusable view components
│   ├── Components/                # Generic UI components
│   ├── News/                      # News display views
│   ├── PDFView/                   # PDF viewer integration
│   └── UpcomingEvents/            # Event display
├── Others/                        # Utilities & helpers
│   ├── Enums/                     # App-wide enums
│   ├── Extensions/                # Swift extensions
│   ├── Protocols/                 # Reusable protocols
│   └── ViewModifiers/             # Custom SwiftUI modifiers
├── Constants/                     # Configuration & constants
│   ├── Javascript/                # JavaScript injection code
│   ├── Localization/              # Multi-language strings
│   ├── Navigation/                # Navigation routes
│   ├── Schools/                   # School codes & data
│   ├── Secrets/                   # API keys & crypto keys
│   └── URLs/                      # SAES endpoint URLs
├── Resources/                     # App resources
│   ├── Javascript/                # External JS files
│   ├── Lottie animations/         # Animation files
│   └── PDFs/                      # Embedded PDF documents
└── Assets/                        # Image & color assets
```

---

## Architecture Pattern: MVVM + Reactive

The application implements **Model-View-ViewModel (MVVM)** architecture with reactive programming:

### Key Principles
- **SwiftUI + Combine**: Declarative UI with reactive data binding
- **@Published**: ViewModels expose published state properties
- **@EnvironmentObject**: Shares global state (WebViewHandler, ToastManager, Router)
- **Unidirectional Data Flow**: Views bind to ViewModel state
- **Separation of Concerns**: Data fetching, parsing, and UI are clearly separated

### MVVM Implementation Example

```swift
// ViewModel Structure
GradesViewModel (ViewModel)
├── @Published properties:
│   ├── loadingState: SAESLoadingState
│   ├── grades: [Grupo]
│   └── evaluateTeacher: Bool
├── Dependencies:
│   ├── gradesDataSource: SAESDataSource
│   ├── parser: GradesParser
│   └── logger: Logger
└── Public methods:
    ├── getGrades() async
    └── evaluateTeachers() async
```

---

## Technologies & Frameworks

### Core iOS
| Technology | Purpose |
|------------|---------|
| SwiftUI | Modern declarative UI framework |
| Combine | Reactive programming for data binding |
| UIKit | Specific components (WebKit, EventKit) |
| async/await | Modern concurrency |

### Firebase Suite
| Service | Purpose |
|---------|---------|
| Firebase Core | Initialization and configuration |
| Firebase Analytics | Event tracking and user analytics |
| Cloud Firestore | Data persistence and user tracking |
| Firebase Storage | Image upload for CAPTCHA training |
| Firebase Messaging | Push notifications (FCM) |
| Remote Config | Dynamic configuration management |

### Networking & Web
| Library | Purpose |
|---------|---------|
| URLSession | Native HTTP requests with cookie management |
| WebViewAMC | Custom WebView wrapper with JS injection |
| SwiftSoup | HTML parsing and DOM manipulation |
| Kingfisher | Image loading and caching |

### Security & Encryption
| Library | Purpose |
|---------|---------|
| CryptoSwift | ChaCha20 encryption for sensitive data |
| CryptoKit | SHA256 hashing |

### Local Storage
| Method | Purpose |
|--------|---------|
| UserDefaults | Key-value app preferences |
| LocalJSON | JSON file-based local storage |
| FileManager | File system operations for PDFs |

---

## External Dependencies

| Framework | Purpose | Type |
|-----------|---------|------|
| WebViewAMC | WebView with JS bridge | Custom |
| CustomKit | Custom UI components | Custom |
| Routing | Navigation routing | Custom |
| SplashScreenAMC | Splash screen Lottie | Custom |
| LocalJSON | JSON file storage | Custom |
| SwiftSoup | HTML parsing | Community |
| CryptoSwift | ChaCha20 encryption | Community |
| Kingfisher | Image loading | Community |
| Toast | Toast notifications | Community |
| Firebase | Analytics, Storage, Firestore | Google |
| Inject | Hot reload (dev only) | Community |

---

## Core Services

### WebViewManager
- Singleton instance: `WebViewManager.shared`
- Manages WKWebView with JavaScript injection
- Handles data fetching via JavaScript bridge
- Cookie management with 10-second timeout

### WebViewHandler
- Singleton: `WebViewHandler.shared`
- Message bridge between JS and Swift
- Published properties for schedule, grades, kardex, personalData

### WebViewActions
- Singleton: `WebViewActions.shared`
- Orchestrates web scraping flows
- Methods: `loginForm()`, `grades()`, `schedule()`, `kardex()`, `personalData()`

### LocalStorageManager
- Encrypted user credentials storage
- Cookie persistence
- School-specific storage keys

### CryptoSwiftManager
- ChaCha20 encryption for passwords
- Random IV generation
- JavaScript decryption for scraper

### AnalyticsManager
- Firebase Analytics event logging
- Login tracking and CAPTCHA analysis
- Firestore user data persistence

---

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interaction (SwiftUI)               │
└──────────────────┬──────────────────────────────────────────┘
                   │
        ┌──────────▼──────────┐
        │  ViewModel          │
        │  (Published State)  │
        └──────────┬──────────┘
                   │
        ┌──────────▼──────────────────┐
        │  DataSource (SAESDataSource) │
        │  (Repository Pattern)        │
        └──────────┬──────────────────┘
                   │
        ┌──────────▼──────────────────────────┐
        │  WebViewManager / URLSession        │
        │  (Network Layer)                    │
        └──────────┬──────────────────────────┘
                   │
     ┌─────────────▼──────────────┐
     │  SAES Web Server           │
     │  (HTML/JavaScript)         │
     └─────────────┬──────────────┘
                   │
        ┌──────────▼──────────────┐
        │  Parser (SAESParser)    │
        │  (HTML → Model Objects) │
        └──────────┬──────────────┘
                   │
        ┌──────────▼──────────────┐
        │  UI Re-renders          │
        │  (SwiftUI Binding)      │
        └─────────────────────────┘
```

### Two Data Flow Paths

1. **Web Scraping Flow (Standard)**
   - URLSession + Cookies → SAES Server HTML → SwiftSoup Parsing → Domain Models → Published State → SwiftUI

2. **WebView Flow (Complex Operations)**
   - WKWebView → JavaScript Injection → Message Bridge → WebViewHandler → Published State → SwiftUI

---

## Key Protocols

### SAESDataSource
```swift
protocol SAESDataSource {
    func fetch() async throws -> Data
    func SAESFetcher(url: URL) async throws -> Data
    func SAESFetcherRedirected(url: URL) async throws -> (data: Data, redirected: Bool)
    func SAESFetcherString(url: URL) async throws -> String?
}
```

### SAESParser
```swift
protocol SAESParser {
    func convert(_ data: Data) throws -> Document
}
```

### SAESLoadingState
```swift
enum SAESLoadingState {
    case idle       // No operation
    case loading    // Fetching data
    case loaded     // Data available
    case error      // Error occurred
    case noNetwork  // Network unavailable
    case empty      // No data found
}
```

---

## Main Features

### 1. Authentication & Session Management
- CAPTCHA-based login flow
- Password encryption (ChaCha20)
- Cookie-based session persistence
- Automatic session restoration

### 2. Grade Management
- Display grades by semester/group
- Teacher evaluation automation
- JavaScript-based form filling

### 3. Schedule Management
- Weekly class schedule display
- Schedule PDF export
- Course availability search

### 4. Academic History (Kardex)
- Full academic transcript
- GPA by semester
- Grade history by period

### 5. Personal Information
- Student profile display
- Profile photo management
- Dynamic form parsing

### 6. News & Updates
- IPN institutional news feed

### 7. Calendar Integration
- Save schedule to native calendar
- EventKit integration

---

## Data Storage

### Remote (Cloud)
- **Firestore**: User credentials, login events, captcha metadata
- **Firebase Storage**: Captcha images for ML training
- **Remote Config**: Dynamic app configuration

### Local (Device)
- **UserDefaults**: App preferences (school code, isLogged flag)
- **LocalJSON files**: Encrypted user credentials by school code
- **FileManager**: Temporary PDF exports
- **HTTPCookieStorage**: Session cookies

---

## Navigation Architecture

```
SplashScreenView (Entry Point)
  ↓
  ├─→ Login Flow
  │   └─→ LoginView
  │       └─→ Setup (if new user)
  │
  └─→ Logged Flow (if authenticated)
      └─→ LoggedView (TabView)
          ├─→ PersonalDataScreen
          ├─→ ScheduleView
          ├─→ HomeScreen
          ├─→ GradesScreen
          └─→ KardexView
```

### Menu Options
- News
- IPN Schedule
- Schedule Availability
- Debug
- Feedback
- Logout

---

## Error Handling

### Error Types
- `SAESParserError`: HTML parsing failures
- `SAESFetcherError`: Network/authentication errors
- `GradesError`: Grade-specific errors
- `PersonalDataError`: Data parsing failures

### Strategy
- Async/await with try/catch
- State transitions for UI feedback
- Logger logging at error level
- Toast notifications for user-facing errors
- Fallback UI (NoContentView with retry)

---

## Localization

- **Primary**: Spanish (Mexico)
- **Fallback**: English
- Centralized in `Localization.swift`
- 100+ string keys

---

## Build Configuration

| Property | Value |
|----------|-------|
| Bundle ID | com.roncuevas.saes-app |
| Minimum iOS | 12.0+ |
| Swift Version | 5.7+ |
| Xcode | 14+ required |

---

## Security Implementation

### Encryption
- **ChaCha20**: Password encryption at rest
- **Random IV**: Per-user initialization vectors

### Session Management
- HTTP Cookies (ASPXAUTH token)
- Cookie headers manually injected
- Auto-login from saved cookies

### Privacy
- OSLog privacy filtering
- HTTPS enforcement

---

## Project Statistics

| Metric | Value |
|--------|-------|
| Total Swift Files | 125 |
| Total Directories | 111 |
| Architecture | MVVM |
| UI Framework | SwiftUI |

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `Core/WebView/WebViewManager.swift` | WebView singleton management |
| `Core/WebView/WebViewHandler.swift` | JS-Swift message bridge |
| `Core/WebView/WebViewActions.swift` | Web scraping orchestration |
| `Core/Persistency/LocalStorageManager.swift` | Local data persistence |
| `Core/CryptoSwift/CryptoSwiftManager.swift` | Encryption utilities |
| `Core/Analytics/AnalyticsManager.swift` | Firebase analytics |
| `Constants/URLs/URLs.swift` | SAES endpoint definitions |
| `Constants/Javascript/JScriptCode.swift` | JavaScript injection code |
| `Models/LocalUserModel.swift` | Encrypted user model |
| `Screens/Login/LoginView.swift` | Authentication UI |
| `Screens/Grades/GradesViewModel.swift` | Grades business logic |

---

## Development Guidelines

### Adding a New Screen
1. Create folder in `Screens/`
2. Add View file (SwiftUI)
3. Add ViewModel with `@Published` state
4. Add DataSource implementing `SAESDataSource`
5. Add Parser implementing `SAESParser`
6. Register route in `NavigationRoutes`

### Adding a New Feature
1. Define models in `Models/`
2. Create DataSource for data fetching
3. Create Parser for HTML transformation
4. Build ViewModel with loading states
5. Design View with proper bindings

### Testing
- Unit tests in `SAESTests/`
- Manager tests in `SAESTests/Managers/`
- UI tests in `SAESUITests/`
