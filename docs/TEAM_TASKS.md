# AgriEtech Frontend Team Task Assignments & Sprint Plan

This document establishes the official developer task assignments, team member roles, feature directory ownership, deliverables, acceptance criteria, and sprint schedule for the **agriEtech** mobile development team.

> **Team Lead Note (Abraham Amogne)**: Abraham owns all of `lib/core/*` (architecture, networking, storage, theming, routing, localization, utilities, and shared widgets), plus Auth, Boundaries, and Home shell modules. All remaining feature modules are distributed across the team below.

---

## 0. Task Classification System

All tasks are classified using three dimensions:

### 🏷️ Priority Labels
| Label | Meaning | Must ship by |
|---|---|---|
| `P0 · Critical` | Blocks other team members if delayed | Day 1–2 |
| `P1 · High` | Core user-facing feature, required for MVP | Day 3–5 |
| `P2 · Medium` | Enhances experience, required for release | Day 5–6 |
| `P3 · Low` | Polish, nice-to-have, post-MVP acceptable | Day 7+ |

### 🔖 Task Type Labels
| Label | Meaning |
|---|---|
| `Setup` | Initial configuration, wiring, environment |
| `Feature` | New user-facing screen or functionality |
| `UI` | Visual widget, chart, or animation |
| `Integration` | API binding, provider wiring, or data layer |
| `Testing` | Unit tests, widget tests, or QA |
| `DevOps` | Build, release, linting, CI/CD |

### 🚦 Status Labels
| Label | Meaning |
|---|---|
| `🔲 Todo` | Not yet started |
| `🔄 In Progress` | Actively being worked on |
| `✅ Done` | Complete and passes acceptance criteria |
| `🚫 Blocked` | Waiting on another task or team member |

---

## 1. Official Team Member Roster & Module Ownership

### Feature Module Distribution

| Module Directory | Assigned To | Feature Domain |
|---|---|---|
| `lib/core/*` | **Abraham Amogne** | Core Architecture, Network, Storage, Theming, Utilities & Shared Widgets |
| `lib/features/auth/` | **Abraham Amogne** | Authentication (Username/Email), JWT Lifecycle, Forgot Password & RBAC |
| `lib/features/boundaries/` | **Abraham Amogne** | Ethiopian Region → Zone → Woreda Administrative Hierarchy |
| `lib/features/home/` | **Abraham Amogne** | Application Navigation Shell, Bottom Nav & Drawer |
| `lib/features/weather/` | **Abenezer Endrias** | 16-Day Forecast, Meteograms & Evapotranspiration |
| `lib/features/analytics/` | **Abenezer Endrias** | Seasonal Climatology, Belg/Kiremt Comparisons & Dekadal Trends |
| `lib/features/farms/` | **Abinu Mathewos** | Farm CRUD, OpenStreetMap GPS Polygons & Geofencing |
| `lib/features/soil/` | **Abinu Mathewos** | SoilGrids Chemistry, pH & Volumetric Moisture |
| `lib/features/diagnosis/`, `disease/`, `disease_diagnosis/` | **Abinu Mathewos** | AI Crop Leaf Pathology, Camera Capture & Treatment Advisories |
| `lib/features/dashboard/`, `risk/`, `risk_dashboard/` | **Alen Biruk** | Multi-Hazard Master Dashboard & Composite Risk Index |
| `lib/features/drought/` | **Alen Biruk** | Animated Radial SPI Drought Gauge & Deficit Trends |
| `lib/features/flood/` | **Alen Biruk** | GloFAS River Discharge Hydrographs & Return Period Alarms |
| `lib/features/vegetation/` | **Alen Biruk** | MODIS / Sentinel-2 NDVI Time Series & Health Index |
| `lib/features/locust_pest/` | **Alen Biruk** | FAO Desert Locust Radar Map & Farm Proximity Warnings |
| `lib/features/alerts/` | **Banchamlak Golla** | Real-Time Push Advisories, WebSocket Streams & Notification Inbox |
| `lib/features/sensors/` | **Banchamlak Golla** | IoT Sensor Telemetry (4 types), fl_chart Telemetry & Battery Alarms |
| `lib/features/offline_sync/` | **Banchamlak Golla** | Workmanager Background Sync, Hive Queue & Conflict Resolution |

---

### Ownership Summary Table

| # | Full Name | Student ID | Role | Owned Modules |
|---|---|---|---|---|
| **1** | **Abraham Amogne** | `CTC-329-26` | 🏆 **Team Lead & Core Frontend** | `lib/core/*` · `lib/app.dart` · `lib/main.dart`<br>`lib/features/auth/` · `lib/features/boundaries/` · `lib/features/home/` |
| **2** | **Abenezer Endrias** | `CTC-1826-26` | 🌤️ **Weather & Analytics Engineer** | `lib/features/weather/` · `lib/features/analytics/` |
| **3** | **Abinu Mathewos** | `CTC-1258-26` | 🌱 **Farms, Soil & AI Pathology Engineer** | `lib/features/farms/` · `lib/features/soil/`<br>`lib/features/diagnosis/` · `lib/features/disease/` · `lib/features/disease_diagnosis/` |
| **4** | **Alen Biruk** | `CTC-2176-26` | 🛡️ **Multi-Hazard Dashboards Engineer** | `lib/features/dashboard/` · `lib/features/risk/` · `lib/features/risk_dashboard/`<br>`lib/features/drought/` · `lib/features/flood/` · `lib/features/vegetation/` · `lib/features/locust_pest/` |
| **5** | **Banchamlak Golla** | `CTC-2952-26` | 📡 **Alerts, IoT Sensors & Sync Engineer** | `lib/features/alerts/` · `lib/features/sensors/` · `lib/features/offline_sync/`<br>`lib/core/network/socket_client.dart` · `lib/core/storage/hive_service.dart` |

---

## 2. Abraham Amogne (`CTC-329-26`) — 🏆 Team Lead & Core Frontend

**Modules**: `lib/core/*`, `lib/app.dart`, `lib/main.dart`, `lib/features/auth/`, `lib/features/boundaries/`, `lib/features/home/`

### Detailed Responsibilities:
- Project architecture, dependency management, linting rules, and Riverpod container setup.
- Core network client (`DioClient`, interceptors for Bearer tokens, token refresh on 401).
- Encrypted keystore storage via `FlutterSecureStorage` and core repositories.
- Forest Green Material 3 theme system (`AppTheme`), typography, and `AgriEtechLogo` 3-segment branding.
- GoRouter navigation shell (`AppRouter`), route guards, and bottom navigation.
- Authentication screens (Login via Username/Email, Register, Forgot Password Dialog) and Role-Based Access Control (`RoleUtils`).
- Administrative Boundary Hierarchy (Region → Zone → Woreda) with 30-day offline cache.

### Task List:
| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T1.1** | Configure `analysis_options.yaml` & Riverpod clean architecture structure | `Setup` | `P0 · Critical` | `✅ Done` |
| **T1.2** | Implement `dio_client.dart` with base URLs, 15s timeouts & response handling | `Setup` | `P0 · Critical` | `✅ Done` |
| **T1.3** | Implement `api_interceptors.dart` — auto Bearer token attachment & 401 refresh | `Setup` | `P0 · Critical` | `✅ Done` |
| **T1.4** | Implement `secure_storage_service.dart` for encrypted JWT credentials | `Setup` | `P0 · Critical` | `✅ Done` |
| **T1.5** | Configure `app_theme.dart` — Forest Green M3 color scheme (dark & light) | `Setup` | `P0 · Critical` | `✅ Done` |
| **T1.6** | Implement `agrietech_logo.dart` — 3-segment brand logo (`agri` + `E` + `tech`) | `UI` | `P0 · Critical` | `✅ Done` |
| **T1.7** | Build shared core widgets: `risk_badge.dart`, `period_toggle.dart`, `loading_indicator.dart`, `error_view.dart` | `UI` | `P0 · Critical` | `✅ Done` |
| **T1.8** | Implement `validators.dart`, `role_utils.dart`, and `date_formatter.dart` | `Setup` | `P0 · Critical` | `✅ Done` |
| **T1.9** | Complete bilingual ARB keys (`app_en.arb`, `app_am.arb`) for English & Amharic | `Setup` | `P1 · High` | `✅ Done` |
| **T1.10** | Build `login_screen.dart` (Username/Email + Password), `register_screen.dart`, and `forgot_password_dialog.dart` | `Feature` | `P1 · High` | `✅ Done` |
| **T1.11** | Build `location_picker.dart` with cascading Region → Zone → Woreda selectors | `Feature` | `P1 · High` | `✅ Done` |
| **T1.12** | Implement unit tests for Auth, Network, Validators & Theme (`test/core/*`, `test/features/auth_test.dart`) | `Testing` | `P0 · Critical` | `✅ Done` |

#### Acceptance Criteria:
- `flutter analyze` returns 0 errors across the entire codebase.
- User can log in with username or email, securely persist JWT token, and reset password via dialog.
- All team members can import shared widgets and core utilities seamlessly.

---

## 3. Abenezer Endrias (`CTC-1826-26`) — 🌤️ Weather & Analytics Engineer

**Modules**: `lib/features/weather/`, `lib/features/analytics/`

### Detailed Responsibilities:
- Open-Meteo 16-day weather forecast integration with 1-hour Hive caching (`weather_cache`).
- Real-time weather screen showing current temperature, precipitation probability, humidity, wind, UV index, and ET0.
- Interactive 16-day meteogram and hourly temperature spline charts using `fl_chart`.
- Seasonal climatology analytics: Belg vs. Kiremt rainfall/temperature comparison and dekadal trends.

### Task List:
| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T2.1** | Wire `weather_provider.dart` to `/weather/forecast` API with 1-hour Hive cache | `Integration` | `P0 · Critical` | `✅ Done` |
| **T2.2** | Build `weather_screen.dart` — current conditions overview card with dynamic weather icons | `Feature` | `P1 · High` | `✅ Done` |
| **T2.3** | Build interactive 16-day meteogram (`rainfall_chart.dart`) using `fl_chart` with touch tooltips | `UI` | `P1 · High` | `✅ Done` |
| **T2.4** | Build hourly temperature spline chart (`temperature_trend_chart.dart`) with gradient fill | `UI` | `P1 · High` | `✅ Done` |
| **T2.5** | Implement solar radiation & ET0 evapotranspiration metric cards | `UI` | `P2 · Medium` | `✅ Done` |
| **T2.6** | Wire `analytics_repository.dart` & `analytics_provider.dart` to seasonal climatology endpoints | `Integration` | `P1 · High` | `✅ Done` |
| **T2.7** | Build `analytics_dashboard_screen.dart` — Belg vs. Kiremt seasonal rainfall comparison charts | `Feature` | `P1 · High` | `✅ Done` |
| **T2.8** | Integrate `PeriodToggle` (Daily / Dekadal / Monthly / Seasonal) into analytics dashboard | `UI` | `P2 · Medium` | `✅ Done` |

#### Acceptance Criteria:
- 16-day meteogram renders with accurate touch tooltips and precipitation amounts.
- Weather data renders instantly from Hive cache in < 20ms when offline.
- Climatology analytics chart toggles seamlessly between Belg and Kiremt seasons.

---

## 4. Abinu Mathewos (`CTC-1258-26`) — 🌱 Farms, Soil & AI Pathology Engineer

**Modules**: `lib/features/farms/`, `lib/features/soil/`, `lib/features/diagnosis/`, `lib/features/disease/`, `lib/features/disease_diagnosis/`

### Detailed Responsibilities:
- Farm management CRUD operations, crop selection (14 Ethiopian staples), and 24-hour Hive cache.
- Interactive OpenStreetMap GPS polygon drawing tool with `flutter_map` and automatic area calculation.
- AI Crop Disease Diagnosis via camera leaf capture and gallery upload with confidence scoring.
- Localized treatment instructions and prevention recommendations in English and Amharic.
- SoilGrids soil profile screen displaying pH, texture (clay/sand/silt), CEC, and volumetric moisture.

### Task List:
| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T3.1** | Wire `farm_repository.dart` & `farmsProvider` to `/farms` API with 24-hour Hive cache | `Integration` | `P0 · Critical` | `✅ Done` |
| **T3.2** | Build `farm_list_screen.dart` with farm profile cards showing crop type, area (ha), status | `Feature` | `P1 · High` | `✅ Done` |
| **T3.3** | Build `farm_detail_screen.dart` with full farm metadata and polygon map preview | `Feature` | `P1 · High` | `✅ Done` |
| **T3.4** | Build `add_farm_screen.dart` & `farm_polygon_map.dart` — GPS tap-to-draw polygon with undo/clear | `UI` | `P1 · High` | `✅ Done` |
| **T3.5** | Connect `geo_utils.dart` to compute polygon area (hectares) and centroid coordinates on polygon close | `Integration` | `P1 · High` | `✅ Done` |
| **T3.6** | Implement camera leaf photo capture and gallery picker in `leaf_photo_capture_screen.dart` | `Feature` | `P1 · High` | `✅ Done` |
| **T3.7** | Build `diagnosis_result_screen.dart` displaying AI disease prediction, confidence score & treatments | `UI` | `P1 · High` | `✅ Done` |
| **T3.8** | Build `soil_profile_screen.dart` with SoilGrids pH meter, nutrient bars, and volumetric moisture dials | `UI` | `P2 · Medium` | `✅ Done` |

#### Acceptance Criteria:
- Farmer can draw a multi-point GPS polygon on OpenStreetMap and see auto-calculated hectares immediately.
- Leaf photo upload returns AI diagnosis with confidence percentage in < 3 seconds.
- Farm creation works offline by queuing actions into `pending_actions` Hive box.

---

## 5. Alen Biruk (`CTC-2176-26`) — 🛡️ Multi-Hazard Dashboards Engineer

**Modules**: `lib/features/dashboard/`, `lib/features/risk/`, `lib/features/risk_dashboard/`, `lib/features/drought/`, `lib/features/flood/`, `lib/features/vegetation/`, `lib/features/locust_pest/`

### Detailed Responsibilities:
- Multi-hazard executive dashboard combining Drought, Flood, Locust, and Vegetation Stress into a composite Woreda risk score.
- Radial animated SPI drought gauge with color-coded severity bands (Low, Moderate, High, Critical).
- GloFAS hydrological river discharge hydrographs with 2-year, 5-year, and 20-year return period alarms.
- MODIS/Sentinel-2 NDVI time-series comparison against 10-year historical baselines.
- FAO Desert Locust swarm radar overlays on map with real-time farm proximity alerts (≤ 50 km).

### Task List:
| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T4.1** | Wire `risk_repository.dart` & `dashboardProvider` to `/risk-assessments` API with 4-hour Hive cache | `Integration` | `P0 · Critical` | `✅ Done` |
| **T4.2** | Build `dashboard_screen.dart` & `risk_dashboard_screen.dart` with composite risk summary & hazard tiles | `Feature` | `P1 · High` | `✅ Done` |
| **T4.3** | Build radial animated SPI drought gauge (`drought_gauge.dart`) with smooth needle transitions | `UI` | `P1 · High` | `✅ Done` |
| **T4.4** | Build `drought_risk_screen.dart` with 30-day & 90-day precipitation deficit trend charts | `UI` | `P1 · High` | `✅ Done` |
| **T4.5** | Build `flood_risk_screen.dart` & `basin_discharge_chart.dart` with GloFAS river discharge & return period lines | `UI` | `P1 · High` | `✅ Done` |
| **T4.6** | Build `vegetation_health_screen.dart` & `ndvi_chart.dart` tracking NDVI vs. 10-year mean baseline | `UI` | `P2 · Medium` | `✅ Done` |
| **T4.7** | Build `locust_alerts_screen.dart` & `locust_map_overlay.dart` with FAO swarm polygons & distance proximity badges | `Feature` | `P1 · High` | `✅ Done` |

#### Acceptance Criteria:
- Master dashboard displays unified multi-hazard summary in a single scrollable view.
- SPI gauge needle animates smoothly to calculated drought index with exact severity badge color.
- Locust swarm polygons render with semi-transparent magenta overlay and proximity warning badge.

---

## 6. Banchamlak Golla (`CTC-2952-26`) — 📡 Alerts, IoT Sensors & Sync Engineer

**Modules**: `lib/features/alerts/`, `lib/features/sensors/`, `lib/features/offline_sync/`, `lib/core/network/socket_client.dart`, `lib/core/storage/hive_service.dart`

### Detailed Responsibilities:
- Real-time Socket.IO WebSocket stream (`SocketClient`) for live alert broadcasts and telemetry.
- Push advisory inbox (`alerts_inbox_screen.dart`) with severity filters (Critical, High, Moderate, Low), unread badges, and bilingual details.
- IoT sensor fleet management (Soil Moisture, Temperature, Rain Gauge, Leaf Wetness) with `fl_chart` telemetry graphs and battery alarms.
- Workmanager background worker (`background_sync_worker.dart`) and offline conflict resolution policies.
- Hive offline database setup (all 6 boxes: `weather_cache`, `risk_cache`, `farms_cache`, `alerts_cache`, `sensors_cache`, `pending_actions`).

### Task List:
| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T5.1** | Initialize Hive boxes and register TypeAdapters in `hive_service.dart` | `Setup` | `P0 · Critical` | `✅ Done` |
| **T5.2** | Implement `socket_client.dart` — Socket.IO client with auto-reconnection and room listeners | `Integration` | `P0 · Critical` | `✅ Done` |
| **T5.3** | Build `alerts_inbox_screen.dart` & `alert_tile.dart` with severity badges and mark-as-read | `Feature` | `P1 · High` | `✅ Done` |
| **T5.4** | Build `alert_detail_screen.dart` with bilingual advisory content (English + Amharic) | `Feature` | `P1 · High` | `✅ Done` |
| **T5.5** | Build `sensors_list_screen.dart` & `sensor_detail_screen.dart` with real-time telemetry line charts | `Feature` | `P1 · High` | `✅ Done` |
| **T5.6** | Implement low-battery alerts and multi-metric sensor historical graphs using `fl_chart` | `UI` | `P1 · High` | `✅ Done` |
| **T5.7** | Implement `background_sync_worker.dart` (Workmanager periodic background flush) | `Integration` | `P1 · High` | `✅ Done` |
| **T5.8** | Implement `sync_service.dart` conflict resolution (Last-Write-Wins, Server-Authoritative, Append-Only) | `Integration` | `P1 · High` | `✅ Done` |

#### Acceptance Criteria:
- All 6 Hive boxes initialize on app startup with zero runtime exceptions.
- Real-time WebSocket push notifications update inbox instantly without page reload.
- IoT telemetry stream visualizes live sensor metrics with battery status indicators.
- Offline mutations in `pending_actions` sync automatically once network connectivity is restored.

---

## 7. Master Task Summary & Verification Matrix

| Task ID | Assignee | Module Domain | Description | Type | Priority | Status |
|---|---|---|---|---|---|---|
| **T1.1** | Abraham | Core / Arch | Analysis options & Riverpod structure | `Setup` | `P0` | `✅ Done` |
| **T1.2** | Abraham | Core / Network | Dio HTTP client & timeouts | `Setup` | `P0` | `✅ Done` |
| **T1.3** | Abraham | Core / Network | JWT Bearer interceptor & refresh | `Setup` | `P0` | `✅ Done` |
| **T1.4** | Abraham | Core / Storage | Secure storage for JWT keystore | `Setup` | `P0` | `✅ Done` |
| **T1.5** | Abraham | Core / Theme | Material 3 Forest Green theme | `Setup` | `P0` | `✅ Done` |
| **T1.6** | Abraham | Core / UI | 3-Segment `agriEtech` brand logo | `UI` | `P0` | `✅ Done` |
| **T1.7** | Abraham | Core / UI | Reusable widgets (RiskBadge, etc.) | `UI` | `P0` | `✅ Done` |
| **T1.8** | Abraham | Core / Utils | Validators, RoleUtils & DateFormatters | `Setup` | `P0` | `✅ Done` |
| **T1.9** | Abraham | Core / L10n | English & Amharic ARB dictionary | `Setup` | `P1` | `✅ Done` |
| **T1.10** | Abraham | Auth / RBAC | Login (Username/Email), Register & Reset | `Feature` | `P1` | `✅ Done` |
| **T1.11** | Abraham | Boundaries | Region → Zone → Woreda cascade | `Feature` | `P1` | `✅ Done` |
| **T1.12** | Abraham | Testing / QA | Core & Auth unit tests (50/50 pass) | `Testing` | `P0` | `✅ Done` |
| **T2.1** | Abenezer | Weather | Open-Meteo API & 1-hr Hive cache | `Integration` | `P0` | `✅ Done` |
| **T2.2** | Abenezer | Weather | Weather screen current conditions card | `Feature` | `P1` | `✅ Done` |
| **T2.3** | Abenezer | Weather | 16-day interactive meteogram chart | `UI` | `P1` | `✅ Done` |
| **T2.4** | Abenezer | Weather | Hourly temperature spline chart | `UI` | `P1` | `✅ Done` |
| **T2.5** | Abenezer | Weather | Solar radiation & ET0 metric cards | `UI` | `P2` | `✅ Done` |
| **T2.6** | Abenezer | Analytics | Climatology repository & provider | `Integration` | `P1` | `✅ Done` |
| **T2.7** | Abenezer | Analytics | Belg vs. Kiremt seasonal dashboard | `Feature` | `P1` | `✅ Done` |
| **T2.8** | Abenezer | Analytics | Period selector integration | `UI` | `P2` | `✅ Done` |
| **T3.1** | Abinu | Farms | Farm repository & 24-hr Hive cache | `Integration` | `P0` | `✅ Done` |
| **T3.2** | Abinu | Farms | Farm list screen with crop cards | `Feature` | `P1` | `✅ Done` |
| **T3.3** | Abinu | Farms | Farm detail profile & polygon preview | `Feature` | `P1` | `✅ Done` |
| **T3.4** | Abinu | Farms | GPS tap-to-draw polygon mapping | `UI` | `P1` | `✅ Done` |
| **T3.5** | Abinu | Farms | Automatic hectare & centroid calculation | `Integration` | `P1` | `✅ Done` |
| **T3.6** | Abinu | Diagnosis | Camera leaf capture & gallery picker | `Feature` | `P1` | `✅ Done` |
| **T3.7** | Abinu | Diagnosis | AI diagnosis results & treatment advice | `UI` | `P1` | `✅ Done` |
| **T3.8** | Abinu | Soil | SoilGrids pH, nutrient & moisture dials | `UI` | `P2` | `✅ Done` |
| **T4.1** | Alen | Dashboard | Multi-hazard repository & cache | `Integration` | `P0` | `✅ Done` |
| **T4.2** | Alen | Dashboard | Composite Woreda risk home screen | `Feature` | `P1` | `✅ Done` |
| **T4.3** | Alen | Drought | Radial animated SPI drought gauge | `UI` | `P1` | `✅ Done` |
| **T4.4** | Alen | Drought | 30d/90d precipitation deficit charts | `UI` | `P1` | `✅ Done` |
| **T4.5** | Alen | Flood | GloFAS hydrograph & return period alarms | `UI` | `P1` | `✅ Done` |
| **T4.6** | Alen | Vegetation | Sentinel/MODIS NDVI time series | `UI` | `P2` | `✅ Done` |
| **T4.7** | Alen | Locust | FAO locust swarm map & proximity alert | `Feature` | `P1` | `✅ Done` |
| **T5.1** | Banchamlak | Storage | Hive boxes setup & TypeAdapters | `Setup` | `P0` | `✅ Done` |
| **T5.2** | Banchamlak | Network | Socket.IO real-time stream client | `Integration` | `P0` | `✅ Done` |
| **T5.3** | Banchamlak | Alerts | Alerts inbox screen with severity tiles | `Feature` | `P1` | `✅ Done` |
| **T5.4** | Banchamlak | Alerts | Bilingual alert detail advisory view | `Feature` | `P1` | `✅ Done` |
| **T5.5** | Banchamlak | Sensors | IoT sensor fleet list & detail screens | `Feature` | `P1` | `✅ Done` |
| **T5.6** | Banchamlak | Sensors | Real-time telemetry fl_chart streaming | `UI` | `P1` | `✅ Done` |
| **T5.7** | Banchamlak | Sync | Workmanager background sync worker | `Integration` | `P1` | `✅ Done` |
| **T5.8** | Banchamlak | Sync | Conflict resolution & offline queue | `Integration` | `P1` | `✅ Done` |

---

## 8. Definition of Done (DoD) Checklist

Before submitting or reviewing any PR:
- [x] **Zero lint errors**: `flutter analyze` returns 0 issues found.
- [x] **Zero test regressions**: `flutter test` executes with 100% passing tests (50/50).
- [x] **Offline readiness**: Instant render from Hive cache (< 16ms) in offline mode.
- [x] **Bilingual support**: English and Amharic translations configured.
- [x] **Design compliance**: Forest Green tokens, 3-segment brand logo, and Material 3 guidelines followed.
- [x] **Clean architecture**: Strict separation between Presentation, Domain, Data, and Core layers.
