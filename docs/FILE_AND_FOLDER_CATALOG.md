# Frontend Master File & Folder Technical Catalog

An exhaustive guide describing the exact purpose, state management interaction, and UI role of every single folder and file in the `agrietech-frontend` (Flutter) repository.

---

## 📁 1. Root Configuration Files

| File Name | Purpose & Technical Responsibility | Key Packages |
|---|---|---|
| `pubspec.yaml` | Defines Flutter dependencies: Riverpod, GoRouter, Dio, Hive, flutter_map, fl_chart, Firebase, and assets. | Flutter 3.x, Dart 3.x |
| `analysis_options.yaml` | Enforces strict Flutter linter rules, const constructors, clean formatting, and best practices. | flutter_lints |
| `.env.example` | Configuration template for `API_BASE_URL`, `SOCKET_BASE_URL`, and Map tile server URLs. | flutter_dotenv |
| `README.md` | Mobile app architectural overview, Riverpod patterns, offline cache guide, and setup instructions. | Markdown |

---

## 📁 2. `lib/` — Application Entry & Shell

| File Name | Purpose & Technical Responsibility |
|---|---|
| `main.dart` | Flutter entry point (`main()`). Initializes Flutter bindings, Hive NoSQL boxes, Firebase Core, and wraps the app with `ProviderScope`. |
| `app.dart` | Configures the root `MaterialApp.router`, Material 3 light/dark themes, GoRouter navigation, and localization delegates for Amharic (`am`) and English (`en`). |

---

## 📁 3. `lib/core/` — Core Infrastructure & Reusable Utilities

### 📂 `lib/core/config/` (Configuration, Theme & Routing)
| File Name | Purpose |
|---|---|
| `env.dart` | Reads environment variables (`AppEnv.apiBaseUrl`, `AppEnv.socketBaseUrl`, `AppEnv.mapTileUrl`). |
| `app_theme.dart` | Defines the Material 3 design system: Primary Green (`#2E7D32`), Alert Red (`#D32F2F`), Amber (`#FFA000`), Hydro Blue (`#1976D2`), and dark mode tokens. |
| `app_router.dart` | Configures `GoRouter` with nested `ShellRoute` for bottom navigation and deep-linking to all feature screens. |

### 📂 `lib/core/constants/` & `lib/core/network/`
| File Name | Purpose |
|---|---|
| `constants/api_endpoints.dart` | Centralized REST API URI constants (`/auth/login`, `/farms`, `/risk-assessments`, etc.). |
| `constants/app_constants.dart` | Application-wide constants: cache TTL durations, default locale, and hazard threshold values. |
| `network/dio_client.dart` | Configured Dio HTTP client with 15s timeouts, base URLs, and default headers. |
| `network/api_interceptors.dart` | Attaches encrypted JWT Bearer tokens from SecureStorage and handles 401 token refreshes. |
| `network/socket_client.dart` | Socket.IO client managing real-time WebSocket connections and woreda channel subscriptions. |

### 📂 `lib/core/storage/` & `lib/core/localization/`
| File Name | Purpose |
|---|---|
| `storage/secure_storage_service.dart` | Encrypted keystore storage for auth tokens and farmer credentials. |
| `storage/hive_service.dart` | Initializes Hive NoSQL local database and registers model TypeAdapters for offline persistence. |
| `storage/local_cache_boxes.dart` | Declares box names: `weather_cache`, `risk_cache`, `farms_cache`, `alerts_cache`. |
| `localization/app_localizations.dart` | Contracts for localization lookup. |
| `localization/l10n/app_en.arb` | English translation key-value dictionary. |
| `localization/l10n/app_am.arb` | Amharic (አማርኛ) translation key-value dictionary with Ge'ez script support. |

### 📂 `lib/core/utils/` & `lib/core/widgets/`
| File Name | Purpose |
|---|---|
| `utils/date_utils.dart` | Gregorian to Ethiopian (Ge'ez) calendar converters and dekadal formatting. |
| `utils/geo_utils.dart` | GPS coordinate distance and polygon area calculators. |
| `utils/validators.dart` | Ethiopian phone number validation (`+2519...` / `09...`) and form validators. |
| `widgets/period_toggle.dart` | Reusable segmented button for switching between Daily, Dekadal, Monthly, and Seasonal views. |
| `widgets/risk_badge.dart` | Colored severity chip (LOW / MODERATE / HIGH / CRITICAL) with status iconography. |
| `widgets/loading_indicator.dart` | Animated shimmer and circular progress indicator. |
| `widgets/error_view.dart` | Offline error screen component with retry callback button. |

---

## 📁 4. `lib/features/` — 14 Feature Domains (Clean Architecture)

Each feature is organized by **Data** (`models/`, `repositories/`), **Domain** (`services/`), and **Presentation** (`screens/`, `widgets/`, `providers/`):

| Feature Name | Primary Screen & Widgets | Riverpod Provider | Purpose |
|---|---|---|---|
| **`auth/`** | `login_screen.dart`, `register_screen.dart` | `authProvider` | Phone number authentication, registration, woreda assignment, and token management. |
| **`boundaries/`** | `location_picker.dart` | `boundariesProvider` | Cascading dropdown selector for Ethiopian Region -> Zone -> Woreda. |
| **`farms/`** | `farm_list_screen.dart`, `farm_detail_screen.dart`, `add_farm_screen.dart`, `farm_polygon_map.dart` | `farmsProvider` | Farm plot management, GPS geofencing on OpenStreetMap, and crop selection. |
| **`weather/`** | `weather_screen.dart`, `rainfall_chart.dart`, `temperature_trend_chart.dart` | `weatherProvider` | 16-day numerical weather forecast, meteogram, and rainfall graphs via `fl_chart`. |
| **`drought/`** | `drought_risk_screen.dart`, `drought_gauge.dart` | `droughtProvider` | Radial SPI drought gauge, 30/90-day deficit trend graphs, and soil moisture status. |
| **`flood/`** | `flood_risk_screen.dart`, `basin_discharge_chart.dart` | `floodProvider` | GloFAS river discharge hydrographs and flood return period threshold warnings. |
| **`vegetation/`**| `vegetation_health_screen.dart`, `ndvi_chart.dart` | `vegetationProvider` | MODIS and Sentinel-2 NDVI vegetation vigor curves vs 10-year historical baselines. |
| **`locustPest/`** | `locust_alerts_screen.dart`, `locust_map_overlay.dart` | `locustProvider` | Interactive map displaying FAO desert locust swarm polygons and proximity warnings. |
| **`soil/`** | `soil_profile_screen.dart`, `soil_nutrient_bar.dart` | `soilProvider` | SoilGrids soil profile: pH, organic carbon, clay/sand texture, and CEC levels. |
| **`diseaseDiagnosis/`** | `leaf_photo_capture_screen.dart`, `diagnosis_result_screen.dart` | `diseaseProvider` | Camera photo capture of infected leaves, AI pathology result, and treatment steps. |
| **`riskDashboard/`**| `risk_dashboard_screen.dart`, `risk_summary_card.dart`, `multi_hazard_map.dart` | `riskDashboardProvider` | Main home dashboard: Composite Woreda risk score card, multi-hazard layer map, live alerts. |
| **`alerts/`** | `alerts_inbox_screen.dart`, `alert_tile.dart` | `alertsProvider` | Advisory inbox with detailed recommendations in Amharic & English. |
| **`analytics/`** | `analytics_dashboard_screen.dart`, `period_selector.dart`, `trend_chart.dart` | `analyticsProvider` | Multi-year historical climatology and Belg/Kiremt seasonal comparison charts. |
| **`offlineSync/`**| `background_sync_worker.dart`, `sync_service.dart` | N/A (Worker) | Workmanager background service syncing offline farm additions and field records. |

---

## 📁 5. `lib/shared/`, `assets/`, `test/`

- **`shared/`**: `api_response_model.dart` (generic JSON envelope) and `context_extensions.dart` (theme/mediaQuery shortcuts).
- **`assets/`**: `images/` (agro-illustrations), `icons/` (hazard icons), `translations/`.
- **`test/`**: Unit tests for core network client and feature repositories.
