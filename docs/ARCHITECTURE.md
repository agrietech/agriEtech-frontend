# AgriEtech Frontend Architecture Blueprint

## 1. Architectural Principles

The AgriEtech Flutter client is engineered with clean, modular, layer-first architecture powered by:
- **Flutter 3.x**: Cross-platform runtime targeting Android, iOS, and Web.
- **Riverpod 2.x**: Compile-time safe, testable state management without BuildContext dependency.
- **GoRouter 14.x**: Declarative URL-based routing with deep linking, route guards, and redirection.
- **Dio 5.x**: HTTP client configured with JWT interceptors, auto-retry, and offline fallback.
- **Flutter Map & LatLong2**: High-performance OpenStreetMap and GIS polygon rendering.
- **Flutter Secure Storage**: Hardware-backed encrypted key-value store for JWT tokens.

---

## 2. Directory Structure & Layering

```
lib/
├── core/                       # Core Foundation Layer
│   ├── constants/              # API endpoints, asset paths, keys
│   ├── models/                 # Shared data models (UserModel, UserRole)
│   ├── network/                # Dio client, interceptors, error handling
│   ├── routing/                # AppRouter & GoRouter declarations
│   ├── storage/                # Encrypted secure storage service
│   ├── theme/                  # AppTheme, color tokens, typography
│   ├── utils/                  # RoleUtils, DateFormatter, AppLogger
│   └── widgets/                # Reusable UI atoms (AgriEtechLogo, Badges)
│
└── features/                   # Domain Feature Modules
    ├── auth/                   # Authentication & Password Recovery
    ├── home/                   # Navigation Shell & Role-Based Dashboard
    ├── risk/                   # Multi-Hazard & Dedicated Disaster Screens
    ├── farms/                  # GIS Farm Plot Mapping & Parcels
    ├── alerts/                 # Early Warning List & Creation
    ├── sensors/                # IoT Sensor Fleet & Registration
    ├── diagnosis/              # AI Multimodal Crop Vision & Pathology
    ├── weather/                # Hyper-Local Weather Telemetry
    ├── boundaries/             # Administrative Woreda GIS Boundaries
    ├── analytics/              # Agro-Analytics, USSD Hub & GIS Map
    └── ai_voice/               # Multilingual Voice AI Assistant
```

---

## 3. State Management & Navigation

- **Providers**: Every domain feature encapsulates repository, state notifier, and family async providers.
- **Declarative Router**: Registered in `AppRouter` with authentication redirection and deep-linking support.
- **Offline Resilience**: Cached state preserves critical early warning alerts and farm geometries when offline in rural settings.
