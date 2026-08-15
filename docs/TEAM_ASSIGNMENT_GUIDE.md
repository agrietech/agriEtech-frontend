# Frontend Engineering Team Assignment & Module Matrix

> Module boundaries, technical responsibilities, and acceptance criteria for the AgriEtech Flutter client.

---

## 1. Developer Roster & Domain Ownership

| # | Engineer | Student ID | Assigned Feature Domains | Core Frontend Files & Directories |
|---|---|---|---|---|
| 1 | **Abraham Amogne** | `CTC-329-26` | **Frontend Lead · Core Infra, Auth & AI Diagnostics** | `lib/main.dart`<br>`lib/app.dart`<br>`lib/core/*`<br>`lib/features/auth/*`<br>`lib/features/diseaseDiagnosis/*`<br>`lib/features/riskDashboard/*` |
| 2 | **Abenezer Endrias** | `CTC-1826-26` | **Farm Geofencing & Boundary Maps** | `lib/features/farms/*`<br>`lib/features/boundaries/*`<br>`lib/core/widgets/period_toggle.dart` |
| 3 | **Abinu Mathewos** | `CTC-1258-26` | **Weather Visualizations & Agro-Analytics** | `lib/features/weather/*`<br>`lib/features/analytics/*`<br>`lib/core/utils/date_utils.dart` |
| 4 | **Alen Biruk** | `CTC-2176-26` | **Drought & Hydrology UI Modules** | `lib/features/drought/*`<br>`lib/features/flood/*`<br>`lib/core/widgets/risk_badge.dart` |
| 5 | **Banchamlak Golla** | `CTC-2952-26` | **Vegetation, Locust Alerts & Background Sync** | `lib/features/vegetation/*`<br>`lib/features/locustPest/*`<br>`lib/features/soil/*`<br>`lib/features/alerts/*`<br>`lib/features/offlineSync/*` |

---

## 2. Developer Specifications & Acceptance Criteria

### 1. Abraham Amogne (`CTC-329-26`) — Core Architecture, Auth & AI Diagnostics
- **Module Scope**: Application entry point (`main.dart`), GoRouter configuration with bottom navigation shell, Material 3 theme implementation, SecureStorage JWT session persistence, camera-based leaf disease capture, and master composite risk dashboard.
- **Acceptance Criteria**:
  - Securely persists JWT session tokens across application reboots.
  - Zero-latency page navigation with declarative GoRouter routes.
  - Leaf photo upload returns diagnosed condition, confidence score, and treatment recommendations in both Amharic and English.
  - Composite multi-hazard overview card displays live aggregated risk status.

### 2. Abenezer Endrias (`CTC-1826-26`) — Farm Geofencing & Boundary Maps
- **Module Scope**: Cascading administrative boundary picker (Region $\rightarrow$ Zone $\rightarrow$ Woreda), interactive OpenStreetMap GPS polygon drawing tool via `flutter_map`, and geodesic acreage calculation.
- **Acceptance Criteria**:
  - Boundary hierarchy loads instantly from local Hive cache with zero UI stutters.
  - Farmers and development agents can tap vertices to draw plot boundaries on map tiles, calculating area in hectares in real-time.
  - Farm polygons persist to local cache and synchronize with backend endpoints.

### 3. Abinu Mathewos (`CTC-1258-26`) — Weather Visualizations & Agro-Analytics
- **Module Scope**: 16-day numerical weather meteograms, hourly temperature curves, dekadal rainfall bar visualizations via `fl_chart`, and Belg/Kiremt seasonal comparison screens.
- **Acceptance Criteria**:
  - Weather charts render smoothly with touch-enabled tooltips and legends.
  - Period toggle control switches between Daily, Dekadal, and Seasonal views.
  - Displays bilingual Gregorian and Ge'ez (Ethiopian) calendar dates accurately.

### 4. Alen Biruk (`CTC-2176-26`) — Drought & Hydrology UI Modules
- **Module Scope**: Radial SPI drought gauge with dynamic color-coding, precipitation deficit trend charts, GloFAS river discharge hydrographs, and flood return-period badges.
- **Acceptance Criteria**:
  - Radial gauge smoothly animates needle to reflect SPI severity (-2.0 Extreme to +2.0 Wet).
  - Flood return-period indicator accurately reflects $Q_2, Q_5, Q_{20}$ warning levels.
  - Color palettes adhere to the design system (Red for Critical, Amber for High, Yellow for Moderate, Green for Low).

### 5. Banchamlak Golla (`CTC-2952-26`) — Vegetation, Locust Alerts & Background Sync
- **Module Scope**: MODIS/Sentinel-2 NDVI anomaly trend graphs, FAO locust swarm polygon map overlays with GPS proximity distance alerts, SoilGrids nutrient bars, notification inbox, and Workmanager background sync worker.
- **Acceptance Criteria**:
  - Locust swarms render as spatial polygons on map tiles with computed distance from user's registered farm.
  - Alerts inbox receives real-time WebSocket advisory broadcasts and supports offline reading.
  - Workmanager background task reconciles pending offline actions automatically when network connectivity is restored.

---

## 3. Engineering Quality Checklist

- [ ] Passes `flutter analyze` with 0 issues (`prefer_const_constructors`, strict typing).
- [ ] Every screen provides both live network fetching and transparent Hive offline cache fallback.
- [ ] Zero hardcoded UI strings; all text uses `app_en.arb` and `app_am.arb` localization keys.
- [ ] Touch targets adhere to minimum 48×48dp guidelines.


