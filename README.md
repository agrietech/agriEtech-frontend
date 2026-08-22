<<<<<<< HEAD
# AgriEtech Flutter Mobile Client

> Cross-Platform Multi-Hazard Early Warning & Agro-Climate Advisory System for Ethiopia

---

## System Overview

AgriEtech is a dual-mode Flutter mobile application engineered for smallholder farmers, agricultural development agents, and Woreda agricultural officers across Ethiopia. The platform connects users directly to real-time agrometeorological intelligence, satellite-derived risk analytics, and localized advisory services.

The application operates in a **Hybrid Dual-Mode** model:
- **Connected Mode (Online)**: Streams live multi-hazard sensor feeds, receives instant WebSocket alerts, conducts real-time AI leaf disease diagnoses via cloud inference, downloads high-resolution map tiles, and synchronizes farm telemetry with the backend PostgreSQL/PostGIS database.
- **Resilient Mode (Offline)**: Automatically persists forecasts, advisories, hazard zones, and farm boundaries to a local Hive NoSQL database. Field workers can record farm polygons, log crop symptoms, and review advisories with zero connectivity; all offline mutations queue locally and automatically reconcile upon reconnection.

### Core Capabilities

- **Multi-Hazard Risk Engine**: Real-time composite scoring and spatial visualization for Drought (SPI), Flood (GloFAS river discharge), Desert Locust (FAO swarm tracking), and Vegetation Stress (MODIS/Sentinel-2 NDVI).
- **Dual-Mode Data Layer**: Online live HTTP/WebSocket communication paired with transparent Hive NoSQL caching for zero-latency screen transitions (<16ms) and uninterrupted field productivity.
- **Bilingual Interface**: Native support for **Amharic (አማርኛ)** with complete Ge'ez script typography alongside **English**.
- **Interactive Farm Geofencing**: GPS boundary drawing and acreage calculation on OpenStreetMap using `flutter_map`.
- **Agrometeorological Visualizations**: 16-day meteograms, hourly temperature curves, dekadal rainfall charts, and seasonal Belg/Kiremt anomaly analytics using `fl_chart`.
- **AI Crop Pathology**: Camera capture workflow for on-field crop disease diagnosis with localized treatment recommendations.
- **Multi-Channel Alert Dispatch**: Live WebSocket notifications on the app, backed by automated SMS and USSD fallback for non-smartphone users.

---

## Technical Architecture

The frontend strictly enforces **Clean Architecture** organized by **Feature-First** modular boundaries.

```mermaid
flowchart TD
    subgraph Presentation_Layer["Presentation Layer (Flutter)"]
        UI_Screens["Feature Screens & Pages"]
        UI_Widgets["Custom UI Components & Charts"]
        State_Providers["Riverpod AsyncNotifiers & StateNotifiers"]
    end

    subgraph Domain_Layer["Domain Layer (Pure Dart)"]
        Domain_Services["Business Logic & Validation Services"]
        Domain_Entities["Domain Entities & Value Objects"]
    end

    subgraph Data_Layer["Data Layer (Repositories & Sources)"]
        Data_Repos["Repository Implementations"]
        Remote_Source["Dio HTTP Client + Socket.IO Client"]
        Local_Source["Hive NoSQL Cache + FlutterSecureStorage"]
    end

    subgraph Backend_Cloud["AgriEtech Cloud Backend"]
        REST_API["Express REST API (PostgreSQL / PostGIS)"]
        WS_Stream["Socket.IO Live Alert Gateway"]
    end

    UI_Screens --> State_Providers
    UI_Widgets --> State_Providers
    State_Providers --> Domain_Services
    Domain_Services --> Data_Repos
    Data_Repos --> Remote_Source
    Data_Repos --> Local_Source
    Remote_Source <--> REST_API
    Remote_Source <--> WS_Stream
=======
# agriEtech — Multi-Hazard Early Warning & Agriculture Advisory System

**Production-ready Flutter cross-platform client (Android, iOS, Web, Desktop) for agricultural multi-hazard monitoring, AI crop pathology, IoT telemetry, and early warning in Ethiopia.**

---

## 🌟 Overview

**agriEtech** connects smallholder farmers, development agents, woreda officers, and agricultural researchers to real-time climatological hazard models, AI crop pathology, OpenStreetMap farm geofencing, and IoT telemetry streams.

- **Status**: ✅ **100% Complete — 50/50 Tests Passing — 0 Analyzer Issues**
- **Brand Identity**: 3-Segment `agriEtech` Typography (`agri` + `E` + `tech`) with Forest Green (`#2E7D32` / `#1B5E20`) Material 3 Theme
- **Target Platforms**: Android, iOS, Web, Windows, macOS, Linux
- **Backend Service**: Node.js REST API + Socket.IO WebSockets (`agriEtech-backend`)
- **Architecture**: Clean Architecture with Riverpod 2.x State Management & Cache-First Offline Persistence

---

## 👥 Development Team & Module Assignments

| # | Team Member | Student ID | Role | Owned Module Domains |
|---|---|---|---|---|
| **1** | **Abraham Amogne** | `CTC-329-26` | 🏆 **Team Lead & Core Frontend** | `lib/core/*` (Network, Storage, Theme, Routing, Utils, Widgets)<br>`lib/features/auth/` · `lib/features/boundaries/` · `lib/features/home/` |
| **2** | **Abenezer Endrias** | `CTC-1826-26` | 🌤️ **Weather & Analytics Engineer** | `lib/features/weather/` (16-day forecast, meteograms, ET0)<br>`lib/features/analytics/` (Belg vs. Kiremt seasonal climatology) |
| **3** | **Abinu Mathewos** | `CTC-1258-26` | 🌱 **Farms, Soil & AI Pathology Engineer** | `lib/features/farms/` (GPS polygon mapping, geofencing)<br>`lib/features/soil/` (SoilGrids pH & moisture)<br>`lib/features/diagnosis/`, `disease/`, `disease_diagnosis/` |
| **4** | **Alen Biruk** | `CTC-2176-26` | 🛡️ **Multi-Hazard Dashboards Engineer** | `lib/features/dashboard/`, `risk/`, `risk_dashboard/` (Composite index)<br>`lib/features/drought/` (SPI gauge) · `lib/features/flood/` (GloFAS hydrograph)<br>`lib/features/vegetation/` (NDVI) · `lib/features/locust_pest/` (FAO swarm radar) |
| **5** | **Banchamlak Golla** | `CTC-2952-26` | 📡 **Alerts, IoT Sensors & Sync Engineer** | `lib/features/alerts/` (Real-time push, WebSocket, inbox)<br>`lib/features/sensors/` (IoT telemetry & battery alerts)<br>`lib/features/offline_sync/` (Workmanager & Hive queue) |

---

## ✨ Core Feature Domains

### 1. 🔐 Authentication & Role-Based Access Control
- JWT-based authentication supporting login via **Username or Email** with encrypted token keystore.
- Forgot Password reset dialog with backend token dispatch.
- 5 User Roles with granular capability enforcement: `FARMER`, `DEVELOPMENT_AGENT`, `WOREDA_OFFICER`, `RESEARCHER`, `ADMIN`.

### 2. 🛡️ Multi-Hazard Composite Dashboard
- Master Woreda risk score uniting 6 hazard types: Drought, Flood, Locust Swarms, Vegetation Stress, Frost, and Heat Stress.
- Color-coded severity indicators (Low, Moderate, High, Critical).
- Role-specific quick actions and immediate summary banners.

### 3. 🗺️ Farm Geofencing & GPS Mapping
- Interactive OpenStreetMap drawing tool with `flutter_map` and `latlong2`.
- Automatic polygon area calculation (hectares) and centroid coordinates.
- Selection of 14 Ethiopian staple crops, soil types, and irrigation methods.

### 4. 🌤️ Weather Forecasting & Climatology Analytics
- 16-day Open-Meteo predictions with hourly temperature spline curves.
- Interactive meteogram with precipitation amounts and touch tooltips.
- Solar radiation, humidity, wind velocity, and ET0 evapotranspiration metrics.
- Seasonal climatology comparisons (Belg vs. Kiremt seasons) with dekadal trends.

### 5. 🔬 AI Crop Pathology & Disease Diagnosis
- Camera viewfinder capture and gallery image analysis.
- AI disease classification with confidence percentage score.
- Localized actionable treatment plans and prevention tips in English and Amharic.

### 6. 📡 IoT Sensor Fleet Management & Telemetry
- Supports 4 sensor types: Soil Moisture, Temperature, Rain Gauge, and Leaf Wetness.
- Real-time telemetry line charts with configurable time horizons (24h, 7d, 30d).
- Low battery alerts (< 20%) and sensor operational health tracking.

### 7. 🚨 Real-Time Advisories & Alert Inbox
- Live Socket.IO WebSocket stream + Firebase Cloud Messaging push advisories.
- 3 Priority Channels (Critical, High, General) with severity filtering.
- Role-gated alert creation for Woreda Officers and Administrators.

### 8. 🏜️ Drought, Flood, Locust & NDVI Specialized Views
- **Drought**: Radial animated needle SPI gauge (SPI-30 / SPI-90) and deficit trends.
- **Flood**: GloFAS river discharge hydrographs with 2-year, 5-year, and 20-year return period alarms.
- **NDVI**: MODIS & Sentinel-2 satellite vegetation health against 10-year baselines.
- **Locust Radar**: FAO swarm polygon map overlays and real-time proximity alerts (≤ 50 km).

### 9. 📴 Offline-First Synchronization Architecture
- High-speed Hive NoSQL local key-value caching across 6 core boxes.
- `pending_actions` queue flushed via Workmanager background jobs when connectivity is restored.
- Conflict resolution policies: Last-Write-Wins, Server-Authoritative, and Append-Only.

---

## 🏗️ Technical Architecture

```mermaid
graph TB
    subgraph UI["Presentation Layer (Flutter)"]
        SC["Screens (25+ Views)"]
        WG["Widgets (50+ Components)"]
        PR["Riverpod Notifiers & StateProviders"]
    end

    subgraph Domain["Domain Layer"]
        MD["Models (User, Farm, Risk, Sensor, Alert)"]
        RU["RoleUtils & Policy Guards"]
        UT["Date, Geo & Validation Utils"]
    end

    subgraph Data["Data Layer"]
        RP["Repositories (Cache-First)"]
        DIO["Dio HTTP Client (REST)"]
        WS["SocketClient (WebSocket)"]
        HIV["Hive NoSQL Database"]
        SEC["FlutterSecureStorage"]
    end

    SC --> PR
    WG --> PR
    PR --> RP
    RP --> MD
    RP --> DIO
    RP --> WS
    RP --> HIV
    RP --> SEC
    PR --> RU
    PR --> UT
>>>>>>> develop
```

---

<<<<<<< HEAD
## Directory Organization

```
agrietech-frontend/
├── assets/
│   ├── images/                          # Agro-illustrations and branded graphics
│   ├── icons/                           # Hazard indicators (drought, flood, locust, leaf)
│   └── translations/
│
├── lib/
│   ├── main.dart                        # Application bootstrap, Hive initialization, ProviderScope
│   ├── app.dart                         # MaterialApp.router, Material 3 theme configuration, l10n
│   │
│   ├── core/                            # Cross-cutting foundational infrastructure
│   │   ├── config/
│   │   │   ├── env.dart                 # Environment configuration (API and WebSocket URLs)
│   │   │   ├── app_theme.dart           # Agricultural green and severity color palette tokens
│   │   │   └── app_router.dart          # GoRouter declarations with bottom navigation shell
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart       # REST API route constants
│   │   │   └── app_constants.dart       # Business thresholds and cache expiry durations
│   │   ├── network/
│   │   │   ├── dio_client.dart          # Configured Dio HTTP client with retry and timeout policies
│   │   │   ├── api_interceptors.dart    # JWT Bearer authentication and refresh interceptors
│   │   │   └── socket_client.dart       # Socket.IO client for live woreda alert broadcasts
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart  # Encrypted keystore storage for auth tokens
│   │   │   ├── hive_service.dart            # Hive database lifecycle and adapter registration
│   │   │   └── local_cache_boxes.dart       # Cache box identifiers
│   │   ├── localization/
│   │   │   ├── app_localizations.dart   # Localization lookup contracts
│   │   │   └── l10n/
│   │   │       ├── app_en.arb           # English translation catalog
│   │   │       └── app_am.arb           # Amharic (አማርኛ) translation catalog
│   │   ├── utils/
│   │   │   ├── date_utils.dart          # Ethiopian (Ge'ez) calendar converters
│   │   │   ├── geo_utils.dart           # GPS coordinates and polygon geometry helpers
│   │   │   └── validators.dart          # Ethiopian phone number and form validators
│   │   └── widgets/
│   │       ├── period_toggle.dart       # Daily / Dekadal / Monthly / Seasonal filter control
│   │       ├── risk_badge.dart          # Severity indicator: LOW / MODERATE / HIGH / CRITICAL
│   │       ├── loading_indicator.dart   # Shimmer skeleton and progress indicators
│   │       └── error_view.dart          # Network and system error view with retry callback
│   │
│   ├── features/                        # 14 isolated domain modules
│   │   ├── auth/                        # Phone authentication, registration, OTP verification
│   │   ├── boundaries/                  # Region -> Zone -> Woreda administrative selector
│   │   ├── farms/                       # Farm profile management and polygon map editor
│   │   ├── weather/                     # 16-day meteogram and historical weather analytics
│   │   ├── drought/                     # Radial SPI drought gauge and precipitation deficit
│   │   ├── flood/                       # GloFAS discharge hydrographs and flood return periods
│   │   ├── vegetation/                  # MODIS / Sentinel-2 NDVI vegetation health curves
│   │   ├── locustPest/                  # FAO desert locust swarm tracking and proximity alerts
│   │   ├── soil/                        # SoilGrids nutrient and moisture composition gauges
│   │   ├── diseaseDiagnosis/            # Leaf photography capture and AI diagnostic results
│   │   ├── riskDashboard/               # Composite Woreda risk score and multi-hazard map
│   │   ├── alerts/                      # Advisory notification center with bilingual content
│   │   ├── analytics/                   # Multi-year historical climatology comparisons
│   │   └── offlineSync/                 # Workmanager queue for background synchronization
│   │
│   └── shared/                          # Generic API response envelope and context extensions
│
└── docs/                                # Technical documentation suite
    ├── ARCHITECTURE_OVERVIEW.md         # Layer design, dual-mode data model, and dependency rules
    ├── STATE_MANAGEMENT_GUIDE.md        # Riverpod 2.x AsyncNotifier and caching patterns
    ├── UI_UX_DESIGN_SYSTEM.md           # Material 3 tokens, accessibility, and typography
    ├── FEATURE_ROADMAP.md               # Screen specifications and acceptance criteria
    └── TEAM_ASSIGNMENT_GUIDE.md         # Frontend developer responsibilities and checklists
```
=======
## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>= 3.0.0`
- Dart SDK `>= 3.0.0`
- Node.js backend running on `localhost:5000` (or `10.0.2.2:5000` for Android emulator)
>>>>>>> develop

### Installation & Run

<<<<<<< HEAD
## Getting Started

### Prerequisites

| Requirement | Supported Version | Notes |
|---|---|---|
| Flutter SDK | `>= 3.19.0` | Channel `stable` |
| Dart SDK | `>= 3.3.0` | Bundled with Flutter SDK |
| Java Development Kit | OpenJDK 17 | Required for Android build toolchain |
| Android SDK Platform | API Level 34 | Android 14.0 |
| Development Tools | VS Code / Android Studio | Flutter & Dart plugins installed |

### Installation and Run

```bash
# 1. Clone the repository
git clone https://github.com/your-org/agrietech-frontend.git
cd agrietech-frontend

# 2. Configure environment parameters
cp .env.example .env

# 3. Retrieve package dependencies
flutter pub get

# 4. Run the code generation engine (if modifying models)
dart run build_runner build --delete-conflicting-outputs

# 5. Launch the application on a target device or emulator
flutter run
=======
```bash
# 1. Clone repository and navigate to folder
cd c:\Users\a\Desktop\agrietech-frontend

# 2. Install dependencies
flutter pub get

# 3. Verify code quality & tests
flutter analyze
flutter test

# 4. Run application
flutter run -d chrome     # Run on Web (Chrome)
flutter run -d windows    # Run on Windows Desktop
flutter run -d edge       # Run on Microsoft Edge
>>>>>>> develop
```

---

<<<<<<< HEAD
## Development Team & Engineering Ownership

The frontend client is engineered and maintained by a team of 5 developers, each leading dedicated feature slices:

| # | Engineer | Student ID | Primary Frontend Domains | Key Module Responsibilities |
|---|---|---|---|---|
| 1 | **Abraham Amogne** | `CTC-329-26` | **Frontend Lead · Core Infra & AI Diagnostics** | Application lifecycle, GoRouter navigation shell, Material 3 theme system, SecureStorage auth tokens, AI leaf camera diagnosis, and master risk dashboard. |
| 2 | **Abenezer Endrias** | `CTC-1826-26` | **Farm Geofencing & Administrative Maps** | Region/Zone/Woreda cascading selectors, interactive `flutter_map` GPS polygon drawing, and plot acreage computation. |
| 3 | **Abinu Mathewos** | `CTC-1258-26` | **Weather Visualizations & Agro-Analytics** | 16-day numerical weather meteograms, hourly temperature curves, dekadal rainfall charts, and Belg/Kiremt seasonal analytics. |
| 4 | **Alen Biruk** | `CTC-2176-26` | **Drought Risk & Hydrology UI** | Radial SPI drought meter, precipitation deficit trend charts, GloFAS river discharge hydrographs, and flood return-period badges. |
| 5 | **Banchamlak Golla** | `CTC-2952-26` | **Vegetation, Locust Alerts & Offline Sync** | MODIS/Sentinel-2 NDVI trend lines, FAO locust swarm map overlays with GPS proximity alerts, SoilGrids nutrient bars, and Workmanager sync queue. |

---

## Technical Documentation Hub

The [`docs/`](./docs/) directory contains essential technical specifications for frontend developers:

| Document | Focus Area |
|---|---|
| [Architecture Overview](./docs/ARCHITECTURE_OVERVIEW.md) | Clean Architecture layers, dual-mode operational model, and directory boundaries. |
| [State Management Guide](./docs/STATE_MANAGEMENT_GUIDE.md) | Riverpod 2.x `AsyncNotifier` patterns, Hive caching integration, and UI consumer templates. |
| [UI/UX Design System](./docs/UI_UX_DESIGN_SYSTEM.md) | Material 3 design tokens, Amharic Ge'ez typography (Noto Sans Ethiopic), and hazard color palettes. |
| [Feature Roadmap](./docs/FEATURE_ROADMAP.md) | 14 feature domain screens, custom widget structures, and technical acceptance criteria. |
| [Team Assignment Guide](./docs/TEAM_ASSIGNMENT_GUIDE.md) | Developer feature assignments, file boundaries, and quality checklists. |

---

## License

Proprietary — AgriEtech Engineering Team. All rights reserved.
=======
## 🧪 Quality & Test Suite Verification

| Test Suite | File | Tests | Status |
|---|---|---|---|
| **AgriEtechLogo** | `test/core/agrietech_logo_test.dart` | 5 | ✅ Pass |
| **App Theme** | `test/core/app_theme_test.dart` | 2 | ✅ Pass |
| **Date Formatter** | `test/core/date_formatter_test.dart` | 8 | ✅ Pass |
| **Error Handler** | `test/core/error_handler_test.dart` | 4 | ✅ Pass |
| **Network & API** | `test/core/network_test.dart` | 3 | ✅ Pass |
| **Role Utils** | `test/core/role_utils_test.dart` | 6 | ✅ Pass |
| **Validators** | `test/core/validators_test.dart` | 11 | ✅ Pass |
| **Alert Repository** | `test/features/alert_repository_test.dart` | 2 | ✅ Pass |
| **Auth & RBAC** | `test/features/auth_test.dart` | 4 | ✅ Pass |
| **Boundaries** | `test/features/boundary_repository_test.dart` | 1 | ✅ Pass |
| **Diagnosis** | `test/features/diagnosis_repository_test.dart` | 1 | ✅ Pass |
| **Farms** | `test/features/farms_statistics_test.dart` | 1 | ✅ Pass |
| **Sensors** | `test/features/sensor_repository_test.dart` | 1 | ✅ Pass |
| **Smoke Test** | `test/widget_test.dart` | 1 | ✅ Pass |
| **TOTAL** | **14 Test Files** | **50 / 50** | ✅ **100% Pass** |

---

## 📚 Technical Documentation

For in-depth architecture details, consult the `docs/` folder:
- 📖 [Architecture Guide](file:///c:/Users/a/Desktop/agrietech-frontend/docs/ARCHITECTURE.md) — Clean Architecture, Riverpod flows, and offline sync.
- 🗂️ [Modules Catalog](file:///c:/Users/a/Desktop/agrietech-frontend/docs/MODULES_CATALOG.md) — Comprehensive catalog of all 20 feature directories and core utilities.
- 👥 [Team Tasks & Sprint Plan](file:///c:/Users/a/Desktop/agrietech-frontend/docs/TEAM_TASKS.md) — Team member roles, student IDs, deliverables, and acceptance criteria.
- 🎨 [Design System](file:///c:/Users/a/Desktop/agrietech-frontend/docs/DESIGN_SYSTEM.md) — Color palettes, typography, spacing, and UI components.
>>>>>>> develop
