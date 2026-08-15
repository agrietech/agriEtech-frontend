# AgriEtech Frontend Team Task Assignments & Sprint Plan

This document establishes the official developer task assignments, team member roles, feature directory ownership, deliverables, acceptance criteria, and sprint schedule for the AgriEtech mobile development team.

> **Team Lead Note (Abraham Amogne)**: Abraham owns all of `lib/core/*` (architecture, networking, storage, theming, routing, localization, utilities, and shared widgets), plus the Auth and Boundaries features. All 14 feature modules are distributed across the remaining 4 team members below.

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

> Abraham handles all of `lib/core/*` and the Auth/Boundaries features.  
> The 14 feature modules in `lib/features/` are distributed as follows:

| Module Directory | Assigned To | Feature Domain |
|---|---|---|
| `lib/features/auth/` | **Abraham Amogne** | Authentication & Token Lifecycle |
| `lib/features/boundaries/` | **Abraham Amogne** | Ethiopian Region → Zone → Woreda |
| `lib/features/weather/` | **Abenezer Endrias** | 16-Day Forecast & Meteograms |
| `lib/features/analytics/` | **Abenezer Endrias** | Seasonal Climatology & Trends |
| `lib/features/farms/` | **Abinu Mathewos** | Farm Profiles & GPS Geofencing |
| `lib/features/soil/` | **Abinu Mathewos** | Soil Chemistry & Nutrient Profiles |
| `lib/features/disease_diagnosis/` | **Abinu Mathewos** | AI Crop Pathology Diagnosis |
| `lib/features/risk_dashboard/` | **Alen Biruk** | Multi-Hazard Composite Home Screen |
| `lib/features/drought/` | **Alen Biruk** | SPI Drought Gauge & Precipitation Deficit |
| `lib/features/flood/` | **Alen Biruk** | GloFAS Hydrograph & Flood Alarms |
| `lib/features/vegetation/` | **Alen Biruk** | NDVI Vegetation Health Index |
| `lib/features/locust_pest/` | **Alen Biruk** | FAO Locust Swarm Radar Map |
| `lib/features/alerts/` | **Banchamlak Golla** | Push Advisories & Notification Inbox |
| `lib/features/offline_sync/` | **Banchamlak Golla** | Workmanager Background Sync |

---

### Ownership Summary Table

| # | Full Name | Student ID | Role | Owned Modules |
|---|---|---|---|---|
| **3** | **Abraham Amogne** | `CTC-329-26` | 🏆 **Team Lead & Core** | `lib/core/*` · `lib/app.dart` · `lib/main.dart`<br>`lib/features/auth/` · `lib/features/boundaries/` |
| **1** | **Abenezer Endrias** | `CTC-1826-26` | Weather & Analytics | `lib/features/weather/` · `lib/features/analytics/` |
| **2** | **Abinu Mathewos** | `CTC-1258-26` | Farms, Soil & AI Diagnosis | `lib/features/farms/` · `lib/features/soil/` · `lib/features/disease_diagnosis/` |
| **4** | **Alen Biruk** | `CTC-2176-26` | Multi-Hazard Dashboards | `lib/features/risk_dashboard/` · `lib/features/drought/` · `lib/features/flood/` · `lib/features/vegetation/` · `lib/features/locust_pest/` |
| **5** | **Banchamlak Golla** | `CTC-2952-26` | Alerts & Real-Time Sync | `lib/features/alerts/` · `lib/features/offline_sync/` · `lib/core/network/socket_client.dart` · `lib/core/storage/hive_service.dart` |

---

## 2. Abraham Amogne (`CTC-329-26`) — 🏆 Team Lead & Core Frontend

**Modules**: `lib/core/*`, `lib/app.dart`, `lib/main.dart`, `lib/features/auth/*`, `lib/features/boundaries/*`

### `lib/core/` Sub-Directory Breakdown

| Sub-Directory | Files | Responsibility |
|---|---|---|
| `core/config/` | `env.dart`, `app_theme.dart`, `app_router.dart` | Material 3 dark/light theme tokens, GoRouter `ShellRoute` + bottom nav, `.env` variables |
| `core/constants/` | `api_endpoints.dart`, `app_constants.dart` | Centralized REST endpoint URIs, cache TTL values, hazard thresholds |
| `core/network/` | `dio_client.dart`, `api_interceptors.dart` | Dio HTTP client (15s timeout), JWT Bearer auto-attach, 401 token refresh interceptor |
| `core/storage/` | `secure_storage_service.dart`, `hive_service.dart`, `local_cache_boxes.dart` | Encrypted JWT keystore, Hive box registration & TypeAdapter setup |
| `core/localization/` | `app_localizations.dart`, `app_en.arb`, `app_am.arb` | Bilingual string contracts (English + Amharic Ge'ez) |
| `core/utils/` | `date_utils.dart`, `geo_utils.dart`, `validators.dart` | Ethiopian calendar converters, polygon area / Haversine distance, phone validators |
| `core/widgets/` | `risk_badge.dart`, `period_toggle.dart`, `loading_indicator.dart`, `error_view.dart` | Shared reusable UI components used by all 4 feature developers |

### Task List

| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T3.1** | Setup `analysis_options.yaml` linting rules & Riverpod project architecture | `Setup` | `P0 · Critical` | `🔲 Todo` |
| **T3.2** | Implement `dio_client.dart` with base URLs, 15s timeouts | `Setup` | `P0 · Critical` | `🔲 Todo` |
| **T3.3** | Implement `api_interceptors.dart` — JWT Bearer attach & 401 auto-refresh | `Setup` | `P0 · Critical` | `🔲 Todo` |
| **T3.4** | Implement `secure_storage_service.dart` (encrypted JWT keystore) | `Setup` | `P0 · Critical` | `🔲 Todo` |
| **T3.5** | Configure `app_theme.dart` — Material 3 color scheme (Green/Amber/Red/Blue) dark & light | `Setup` | `P0 · Critical` | `🔲 Todo` |
| **T3.6** | Configure `app_router.dart` — GoRouter ShellRoute, bottom nav, deep links | `Setup` | `P0 · Critical` | `🔲 Todo` |
| **T3.7** | Build all 4 shared widgets: `risk_badge.dart`, `period_toggle.dart`, `loading_indicator.dart`, `error_view.dart` | `UI` | `P0 · Critical` | `🔲 Todo` |
| **T3.8** | Implement `validators.dart` (Ethiopian `+2519...`/`09...` phone validation) & `geo_utils.dart` | `Setup` | `P0 · Critical` | `🔲 Todo` |
| **T3.9** | Complete `app_en.arb` & `app_am.arb` base translation keys for all shared strings | `Setup` | `P1 · High` | `🔲 Todo` |
| **T3.10** | Build `login_screen.dart` & `register_screen.dart` with phone input & password | `Feature` | `P1 · High` | `🔲 Todo` |
| **T3.11** | Build `location_picker.dart` with cascading Region → Zone → Woreda dropdowns (30-day Hive cache) | `Feature` | `P1 · High` | `🔲 Todo` |
| **T3.12** | Conduct PR code reviews for all 4 team members (merge gate) | `Testing` | `P1 · High` | `🔲 Todo` |
| **T3.13** | Final `flutter build apk --release` production build & verification | `DevOps` | `P0 · Critical` | `🔲 Todo` |

#### Acceptance Criteria:
- [ ] `flutter analyze` returns 0 errors across the whole codebase before release.
- [ ] User can log in, receive JWT, persist securely, and auto-redirect to home.
- [ ] All 4 feature developers can import shared widgets from `core/widgets/` immediately on Day 1.

---

## 3. Abenezer Endrias (`CTC-1826-26`) — Weather & Analytics

**Modules**: `lib/features/weather/` · `lib/features/analytics/`

> **Dependency note**: Requires Abraham's `DioClient`, `HiveService`, and `PeriodToggle` widget before starting T1.2+.

| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T1.1** | Wire `weather_provider.dart` to `/weather/forecast` API with 1-hour Hive cache (`weather_cache`) | `Integration` | `P0 · Critical` | `🔲 Todo` |
| **T1.2** | Implement `weather_screen.dart` — current conditions card (temp, rain %, wind, UV, humidity) | `Feature` | `P1 · High` | `🔲 Todo` |
| **T1.3** | Build 16-day interactive meteogram (`rainfall_chart.dart`) using `fl_chart` with touch tooltips | `UI` | `P1 · High` | `🔲 Todo` |
| **T1.4** | Build hourly temperature spline chart (`temperature_trend_chart.dart`) with gradient fill | `UI` | `P1 · High` | `🔲 Todo` |
| **T1.5** | Implement solar radiation & ET0 evapotranspiration metric cards | `UI` | `P2 · Medium` | `🔲 Todo` |
| **T1.6** | Integrate `PeriodToggle` — Daily / Dekadal / 16-Day forecast horizon switching | `UI` | `P2 · Medium` | `🔲 Todo` |
| **T1.7** | Wire `analytics_provider.dart` to `/analytics/seasonal` API with Hive cache | `Integration` | `P1 · High` | `🔲 Todo` |
| **T1.8** | Build `analytics_dashboard_screen.dart` — Belg vs. Kiremt seasonal rainfall/temperature comparison | `Feature` | `P2 · Medium` | `🔲 Todo` |

#### Acceptance Criteria:
- [ ] 16-day meteogram renders with interactive tooltips, exact precipitation & temperature values.
- [ ] Weather loads from Hive cache in < 20ms offline with "Offline / Last Cached" badge.
- [ ] Analytics dashboard displays multi-year seasonal comparison with `PeriodToggle`.

---

## 4. Abinu Mathewos (`CTC-1258-26`) — Farms, Soil & AI Diagnosis

**Modules**: `lib/features/farms/` · `lib/features/soil/` · `lib/features/disease_diagnosis/`

> **Dependency note**: Requires Abraham's `DioClient`, `HiveService`, and `GeoUtils` before starting T2.2+.

| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T2.1** | Wire `farms_provider.dart` to `/farms` API with 24-hour Hive cache (`farms_cache`) | `Integration` | `P0 · Critical` | `🔲 Todo` |
| **T2.2** | Build `farm_list_screen.dart` — farm cards showing name, crop type, area (ha), status | `Feature` | `P1 · High` | `🔲 Todo` |
| **T2.3** | Build `farm_detail_screen.dart` — full farm profile with polygon map preview | `Feature` | `P1 · High` | `🔲 Todo` |
| **T2.4** | Build `add_farm_screen.dart` & `farm_polygon_map.dart` — GPS tap-to-draw polygon with undo/clear via `flutter_map` | `UI` | `P1 · High` | `🔲 Todo` |
| **T2.5** | Auto-calculate polygon area (ha) & centroid via `geo_utils.dart` on polygon close | `Integration` | `P1 · High` | `🔲 Todo` |
| **T2.6** | Implement `leaf_photo_capture_screen.dart` — camera viewfinder, flash toggle, gallery fallback | `Feature` | `P1 · High` | `🔲 Todo` |
| **T2.7** | Build `diagnosis_result_screen.dart` — AI disease name, confidence %, treatment steps (Amharic & English) | `UI` | `P1 · High` | `🔲 Todo` |
| **T2.8** | Build `soil_profile_screen.dart` & `soil_nutrient_bar.dart` — pH, nitrogen, organic carbon, moisture dials | `UI` | `P2 · Medium` | `🔲 Todo` |

#### Acceptance Criteria:
- [ ] Farmer draws GPS polygon, closes it, and sees auto-calculated acreage appear immediately.
- [ ] Camera captures leaf photo, sends multipart POST to `/disease-diagnosis`, shows result in < 3s.
- [ ] Farm CRUD works offline — queued to `pending_actions` Hive box, synced automatically later.

---

## 5. Alen Biruk (`CTC-2176-26`) — Multi-Hazard Risk Dashboards

**Modules**: `lib/features/risk_dashboard/` · `lib/features/drought/` · `lib/features/flood/` · `lib/features/vegetation/` · `lib/features/locust_pest/`

> **Dependency note**: Requires Abraham's `DioClient`, `HiveService`, `RiskBadge`, and `PeriodToggle` before starting T4.2+.

| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T4.1** | Wire `risk_dashboard_provider.dart` to `/risk-assessments/composite` API with 4-hour Hive cache | `Integration` | `P0 · Critical` | `🔲 Todo` |
| **T4.2** | Build `risk_dashboard_screen.dart` — composite Woreda risk score card, all-hazard summary tiles, quick actions | `Feature` | `P1 · High` | `🔲 Todo` |
| **T4.3** | Build radial SPI drought gauge (`drought_gauge.dart`) with animated needle, color bands (GREEN/AMBER/RED) | `UI` | `P1 · High` | `🔲 Todo` |
| **T4.4** | Build `drought_risk_screen.dart` — 30-day & 90-day precipitation deficit trend charts | `UI` | `P1 · High` | `🔲 Todo` |
| **T4.5** | Build `flood_risk_screen.dart` & `basin_discharge_chart.dart` — GloFAS hydrograph with 2yr/5yr/20yr return period alarm lines | `UI` | `P1 · High` | `🔲 Todo` |
| **T4.6** | Build `vegetation_health_screen.dart` & `ndvi_chart.dart` — MODIS/Sentinel NDVI vs. 10-year mean baseline | `UI` | `P2 · Medium` | `🔲 Todo` |
| **T4.7** | Build `locust_alerts_screen.dart` & `locust_map_overlay.dart` — FAO swarm polygons, proximity distance badge (≤ 50 km alert) | `Feature` | `P1 · High` | `🔲 Todo` |

#### Acceptance Criteria:
- [ ] Home dashboard shows a unified Drought + Flood + Locust + Weather overview in one scroll.
- [ ] SPI gauge needle animates smoothly to the target value; band colors match severity thresholds.
- [ ] Locust swarm polygons render as semi-transparent magenta on the map with calculated km-to-farm distance.

---

## 6. Banchamlak Golla (`CTC-2952-26`) — Alerts Inbox & Real-Time Sync

**Modules**: `lib/features/alerts/` · `lib/features/offline_sync/` · `lib/core/network/socket_client.dart` · `lib/core/storage/hive_service.dart`

> **Dependency note**: T5.1 (Hive initialization) is **P0 · Critical** — all other team members depend on Hive boxes being ready on Day 1.

| Task ID | Description | Type | Priority | Status |
|---|---|---|---|---|
| **T5.1** | Initialize all 6 Hive boxes in `hive_service.dart`: `weather_cache`, `risk_cache`, `farms_cache`, `alerts_cache`, `boundary_cache`, `pending_actions` | `Setup` | `P0 · Critical` | `🔲 Todo` |
| **T5.2** | Implement `socket_client.dart` — Socket.IO connection to `/alerts` & `/risk-assessments` channels with auto-reconnect | `Integration` | `P0 · Critical` | `🔲 Todo` |
| **T5.3** | Build `alerts_inbox_screen.dart` & `alert_tile.dart` — severity badges (CRITICAL/HIGH/MODERATE/LOW), unread dot, mark-as-read | `Feature` | `P1 · High` | `🔲 Todo` |
| **T5.4** | Build `alert_detail_screen.dart` — full bilingual advisory body (Amharic & English) with timestamp & location | `Feature` | `P1 · High` | `🔲 Todo` |
| **T5.5** | Implement `background_sync_worker.dart` — Workmanager periodic task registration & queue flush | `Integration` | `P1 · High` | `🔲 Todo` |
| **T5.6** | Implement `sync_service.dart` — conflict resolution (Last-Write-Wins, Server-Authoritative, Append-Only) | `Integration` | `P1 · High` | `🔲 Todo` |
| **T5.7** | Connect `connectivity_plus` listener → trigger immediate `pending_actions` flush on network restore | `Integration` | `P2 · Medium` | `🔲 Todo` |

#### Acceptance Criteria:
- [ ] All 6 Hive boxes initialize on cold app start with zero errors.
- [ ] WebSocket push alert updates inbox badge count instantly without manual refresh.
- [ ] Offline mutations in `pending_actions` sync automatically when internet is restored.

---

## 7. Master Task Summary (All 33 Tasks)

| Task ID | Assignee | Description | Type | Priority | Status |
|---|---|---|---|---|---|
| T3.1 | Abraham | Linting & architecture setup | `Setup` | `P0 · Critical` | `🔲 Todo` |
| T3.2 | Abraham | Dio HTTP client | `Setup` | `P0 · Critical` | `🔲 Todo` |
| T3.3 | Abraham | JWT auth interceptors | `Setup` | `P0 · Critical` | `🔲 Todo` |
| T3.4 | Abraham | Secure storage service | `Setup` | `P0 · Critical` | `🔲 Todo` |
| T3.5 | Abraham | Material 3 theme tokens | `Setup` | `P0 · Critical` | `🔲 Todo` |
| T3.6 | Abraham | GoRouter + bottom nav shell | `Setup` | `P0 · Critical` | `🔲 Todo` |
| T3.7 | Abraham | 4 shared core widgets | `UI` | `P0 · Critical` | `🔲 Todo` |
| T3.8 | Abraham | Validators & geo utils | `Setup` | `P0 · Critical` | `🔲 Todo` |
| T3.9 | Abraham | ARB translation base keys | `Setup` | `P1 · High` | `🔲 Todo` |
| T3.10 | Abraham | Login & register screens | `Feature` | `P1 · High` | `🔲 Todo` |
| T3.11 | Abraham | Location picker (Region→Woreda) | `Feature` | `P1 · High` | `🔲 Todo` |
| T3.12 | Abraham | PR code reviews & merge gate | `Testing` | `P1 · High` | `🔲 Todo` |
| T3.13 | Abraham | Release APK build | `DevOps` | `P0 · Critical` | `🔲 Todo` |
| T1.1 | Abenezer | Weather provider + API integration | `Integration` | `P0 · Critical` | `🔲 Todo` |
| T1.2 | Abenezer | Weather screen current conditions | `Feature` | `P1 · High` | `🔲 Todo` |
| T1.3 | Abenezer | 16-day meteogram (`fl_chart`) | `UI` | `P1 · High` | `🔲 Todo` |
| T1.4 | Abenezer | Hourly temperature spline chart | `UI` | `P1 · High` | `🔲 Todo` |
| T1.5 | Abenezer | Solar radiation & ET0 cards | `UI` | `P2 · Medium` | `🔲 Todo` |
| T1.6 | Abenezer | Period toggle integration | `UI` | `P2 · Medium` | `🔲 Todo` |
| T1.7 | Abenezer | Analytics provider + API wiring | `Integration` | `P1 · High` | `🔲 Todo` |
| T1.8 | Abenezer | Seasonal analytics dashboard | `Feature` | `P2 · Medium` | `🔲 Todo` |
| T2.1 | Abinu | Farms provider + API integration | `Integration` | `P0 · Critical` | `🔲 Todo` |
| T2.2 | Abinu | Farm list screen | `Feature` | `P1 · High` | `🔲 Todo` |
| T2.3 | Abinu | Farm detail screen | `Feature` | `P1 · High` | `🔲 Todo` |
| T2.4 | Abinu | GPS polygon geofencing map | `UI` | `P1 · High` | `🔲 Todo` |
| T2.5 | Abinu | Polygon area auto-calculation | `Integration` | `P1 · High` | `🔲 Todo` |
| T2.6 | Abinu | Camera leaf capture screen | `Feature` | `P1 · High` | `🔲 Todo` |
| T2.7 | Abinu | AI diagnosis result screen | `UI` | `P1 · High` | `🔲 Todo` |
| T2.8 | Abinu | Soil profile & nutrient bars | `UI` | `P2 · Medium` | `🔲 Todo` |
| T4.1 | Alen | Risk dashboard provider + API | `Integration` | `P0 · Critical` | `🔲 Todo` |
| T4.2 | Alen | Multi-hazard home dashboard | `Feature` | `P1 · High` | `🔲 Todo` |
| T4.3 | Alen | Radial SPI drought gauge | `UI` | `P1 · High` | `🔲 Todo` |
| T4.4 | Alen | Drought risk screen + trends | `UI` | `P1 · High` | `🔲 Todo` |
| T4.5 | Alen | Flood hydrograph + return period | `UI` | `P1 · High` | `🔲 Todo` |
| T4.6 | Alen | NDVI vegetation time-series chart | `UI` | `P2 · Medium` | `🔲 Todo` |
| T4.7 | Alen | Locust swarm map + proximity alert | `Feature` | `P1 · High` | `🔲 Todo` |
| T5.1 | Banchamlak | Hive box initialization (6 boxes) | `Setup` | `P0 · Critical` | `🔲 Todo` |
| T5.2 | Banchamlak | Socket.IO real-time client | `Integration` | `P0 · Critical` | `🔲 Todo` |
| T5.3 | Banchamlak | Alerts inbox screen + tiles | `Feature` | `P1 · High` | `🔲 Todo` |
| T5.4 | Banchamlak | Alert detail screen (bilingual) | `Feature` | `P1 · High` | `🔲 Todo` |
| T5.5 | Banchamlak | Workmanager background worker | `Integration` | `P1 · High` | `🔲 Todo` |
| T5.6 | Banchamlak | Sync conflict resolution service | `Integration` | `P1 · High` | `🔲 Todo` |
| T5.7 | Banchamlak | Connectivity-triggered sync flush | `Integration` | `P2 · Medium` | `🔲 Todo` |

---

## 8. 7-Day Agile Sprint Schedule

```mermaid
gantt
    title AgriEtech 7-Day Sprint — Feature-Based Distribution
    dateFormat  YYYY-MM-DD
    axisFormat  Day %d

    section P0 · Foundation (Days 1-2)
    Abraham: Core Setup, Dio, Auth, Router, Widgets (T3.1-T3.8)  :active, a1, 2026-08-16, 2d
    Banchamlak: Hive Boxes + Socket.IO Client (T5.1-T5.2)        :active, b1, 2026-08-16, 2d
    Abenezer: Weather Provider + API Integration (T1.1)           :active, e1, 2026-08-16, 1d
    Abinu: Farms Provider + API Integration (T2.1)                :active, m1, 2026-08-16, 1d
    Alen: Risk Dashboard Provider + API (T4.1)                    :active, r1, 2026-08-16, 1d

    section P1 · Features (Days 3-5)
    Abraham: Auth Screens + Location Picker (T3.9-T3.11)          :a2, after a1, 1d
    Abenezer: Weather Screen + Charts (T1.2-T1.4)                 :e2, after e1, 2d
    Abinezer: Analytics Provider + Dashboard (T1.7-T1.8)          :e3, after e2, 1d
    Abinu: Farm List, Detail, Polygon Map (T2.2-T2.5)             :m2, after m1, 2d
    Abinu: Camera Capture + AI Diagnosis (T2.6-T2.7)              :m3, after m2, 1d
    Alen: Home Dashboard + Drought (T4.2-T4.4)                    :r2, after r1, 2d
    Alen: Flood + Locust Map (T4.5, T4.7)                         :r3, after r2, 1d
    Banchamlak: Alerts Inbox + Detail (T5.3-T5.4)                 :b2, after b1, 2d

    section P2 · Polish (Days 5-6)
    Abenezer: Solar Cards + Period Toggle (T1.5-T1.6)             :e4, after e3, 1d
    Abinu: Soil Profile Screen (T2.8)                             :m4, after m3, 1d
    Alen: NDVI Chart (T4.6)                                       :r4, after r3, 1d
    Banchamlak: Workmanager Sync + Conflict Resolution (T5.5-T5.7):b3, after b2, 2d

    section DevOps · Release (Day 7)
    Abraham: PR Reviews + Release APK (T3.12-T3.13)               :p1, after a2, 1d
```

---

## 9. Definition of Done (DoD) Checklist

Before submitting any pull request to **Abraham Amogne (Team Lead)**, verify:
- [ ] **Zero lint errors**: `flutter analyze` returns 0 errors / 0 warnings.
- [ ] **Offline readiness**: Screen renders from Hive cache in < 20ms with airplane mode on.
- [ ] **Bilingual**: All user-visible strings exist in both `app_en.arb` and `app_am.arb`.
- [ ] **Design compliance**: Colors, typography, spacing follow `docs/DESIGN_SYSTEM.md`.
- [ ] **Clean architecture**: Widgets only call Riverpod providers — never direct HTTP calls.
- [ ] **Status updated**: Task's Status column changed to `✅ Done` in this document.
