# AgriEtech Frontend Modules & Directory Catalog

An exhaustive reference catalog detailing the architecture, screens, widgets, providers, models, and repositories for all 20 feature modules and core infrastructure packages in the **agriEtech** codebase.

---

## 1. Directory Structure Overview

```
lib/
├── app.dart                          # MaterialApp.router configuration, theme bindings & localization
├── main.dart                         # Entry point, Hive initialization, ProviderScope, ErrorWidget setup
├── core/                             # Core Infrastructure & Cross-Cutting Concerns
│   ├── config/                       # Environment variables, themes, GoRouter routing
│   ├── constants/                    # API endpoints, hazard thresholds, storage keys, asset paths
│   ├── error/                        # Custom exceptions, failure models & global ErrorHandler
│   ├── l10n/                         # Localization delegate & generated arb bindings
│   ├── localization/                 # Bilingual ARB source files (app_en.arb, app_am.arb)
│   ├── models/                       # Core shared models (User, Role, Token, Woreda, Risk)
│   ├── network/                      # Dio HTTP client, JWT interceptors, Socket.IO client
│   ├── repositories/                 # Central data repositories (Auth, Farm, Alert, Risk, Analytics)
│   ├── routing/                      # GoRouter navigation shells, route paths & auth redirect guards
│   ├── services/                     # Background sync, notification & device services
│   ├── storage/                      # SecureStorage and Hive box declarations & TypeAdapters
│   ├── theme/                        # Forest green M3 color schemes, typography & card styles
│   ├── utils/                        # Ethiopian calendar, geo-calculations, role utils & validators
│   └── widgets/                      # Global reusable widgets (RiskBadge, PeriodToggle, AgriEtechLogo, etc.)
├── features/                         # 20 Clean Architecture Feature Domains
│   ├── alerts/                       # Push & WebSocket advisory inbox, alert creation & filtering
│   ├── analytics/                    # Seasonal climatology, rainfall & temperature analytics
│   ├── auth/                         # JWT login (Username/Email), registration & password reset
│   ├── boundaries/                   # Ethiopian Region -> Zone -> Woreda selectors & 30-day cache
│   ├── dashboard/                    # Primary multi-hazard executive dashboard & summary tiles
│   ├── diagnosis/                    # AI crop disease pathology & localized treatment steps
│   ├── disease/                      # Disease encyclopedia & historical pathology records
│   ├── disease_diagnosis/            # Camera leaf capture, AI inference & prevention advisories
│   ├── drought/                      # Radial SPI drought gauge & precipitation deficit trends
│   ├── farms/                        # Farm CRUD, OpenStreetMap GPS polygon geofencing & crop selection
│   ├── flood/                        # GloFAS river discharge hydrographs & return period alert bars
│   ├── home/                         # Application navigation shell, bottom nav & quick actions
│   ├── locust_pest/                  # FAO desert locust swarm radar & farm proximity alerts
│   ├── offline_sync/                 # Workmanager background sync worker & mutation queue
│   ├── risk/                         # Risk scoring engine, hazard indicators & risk filters
│   ├── risk_dashboard/               # Multi-hazard composite home screen & woreda risk index
│   ├── sensors/                      # IoT sensor telemetry (moisture, temp, rain, leaf) & battery alerts
│   ├── soil/                         # SoilGrids chemistry, pH & nutrient profiles
│   ├── vegetation/                   # MODIS / Sentinel-2 NDVI time series & vegetation health index
│   └── weather/                      # 16-day Open-Meteo weather forecast, meteograms & ET0 metrics
└── shared/                           # Generic API response envelope & context extensions
```

---

## 2. Core Infrastructure Modules Reference (`lib/core/`)

| Directory | Key Files | Responsibility |
|---|---|---|
| `core/config/` | `app_config.dart`, `app_router.dart` | Environment configuration, GoRouter shell navigation, bottom nav routing |
| `core/constants/` | `api_constants.dart`, `app_constants.dart` | REST API endpoints, base URLs, timeouts, hazard threshold values |
| `core/error/` | `error_handler.dart`, `app_error.dart` | Centralized exception handling, user-friendly error translations |
| `core/l10n/` | `app_localizations.dart` | Generated localization accessors for English & Amharic |
| `core/localization/`| `app_en.arb`, `app_am.arb` | Bilingual dictionary for agricultural terms and system messages |
| `core/models/` | `user_model.dart`, `woreda_model.dart`, `role_model.dart` | Cross-cutting entity models with JSON serialization |
| `core/network/` | `dio_client.dart`, `api_interceptors.dart`, `socket_client.dart` | Dio HTTP engine, auto Bearer token attach, Socket.IO live stream |
| `core/repositories/`| `auth_repository.dart`, `farm_repository.dart`, `alert_repository.dart`, `risk_repository.dart`, `analytics_repository.dart` | Central data repositories with cache-first logic |
| `core/routing/` | `route_names.dart`, `app_routes.dart` | Named routes, deep link definitions & role-based route guards |
| `core/services/` | `notification_service.dart`, `connectivity_service.dart` | Device notifications, real-time network state monitoring |
| `core/storage/` | `secure_storage_service.dart`, `hive_service.dart` | Encrypted JWT keystore & high-speed Hive key-value offline boxes |
| `core/theme/` | `app_theme.dart`, `color_schemes.dart` | Forest Green M3 theme tokens, typography, dark/light modes |
| `core/utils/` | `date_formatter.dart`, `geo_utils.dart`, `role_utils.dart`, `validators.dart` | Ethiopian Ge'ez calendar, GPS calculators, RBAC permission checkers |
| `core/widgets/` | `agrietech_logo.dart`, `risk_badge.dart`, `period_toggle.dart`, `loading_indicator.dart`, `error_view.dart` | Standardized reusable UI components, 3-segment brand logo |

---

## 3. Feature Domains Reference (`lib/features/`)

### 1. `features/auth/` (Authentication & Security)
- **Screens**: `login_screen.dart`, `register_screen.dart`
- **Widgets**: `auth_header.dart`, `forgot_password_dialog.dart`, `language_selector_tile.dart`
- **Providers**: `authProvider` (`StateNotifierProvider<AuthNotifier, AuthState>`)
- **Repositories / Services**: `AuthRepository`, `SecureStorageService`
- **Purpose**: Handles authentication with Username or Email, JWT token storage, password reset dialog, and role authorization.

### 2. `features/boundaries/` (Administrative Hierarchy)
- **Screens / Widgets**: `location_picker.dart`, `boundary_selector.dart`
- **Providers**: `boundariesProvider`
- **Data Models**: `RegionModel`, `ZoneModel`, `WoredaModel`
- **Purpose**: Cascading administrative boundaries for Ethiopia, seeded from HDX datasets with 30-day Hive offline persistence.

### 3. `features/dashboard/` & `features/risk_dashboard/` (Multi-Hazard Master Dashboard)
- **Screens**: `dashboard_screen.dart`, `risk_dashboard_screen.dart`
- **Widgets**: `risk_summary_card.dart`, `quick_action_grid.dart`, `recent_alerts_banner.dart`, `hazard_summary_tile.dart`
- **Providers**: `dashboardProvider`, `riskDashboardProvider`
- **Purpose**: Central executive home dashboard uniting composite Woreda risk scores, live weather highlights, active alerts, and role-based quick actions.

### 4. `features/farms/` (Farm Management & Geofencing)
- **Screens**: `farm_list_screen.dart`, `farm_detail_screen.dart`, `add_farm_screen.dart`
- **Widgets**: `farm_card.dart`, `farm_polygon_map.dart`, `crop_type_selector.dart`
- **Providers**: `farmsProvider`
- **Data Models**: `FarmModel`, `PolygonCoordinateModel`
- **Purpose**: Farm CRUD operations, OpenStreetMap GPS polygon drawing with automatic area calculation (ha), soil type, and irrigation tracking.

### 5. `features/weather/` (Weather & Forecasting)
- **Screens**: `weather_screen.dart`
- **Widgets**: `rainfall_chart.dart`, `temperature_trend_chart.dart`, `weather_metric_card.dart`, `uv_index_gauge.dart`
- **Providers**: `weatherProvider`
- **Data Models**: `WeatherForecastModel`, `HourlyForecastModel`, `DailyForecastModel`
- **Purpose**: 16-day Open-Meteo forecasts, hourly temperature splines, precipitation probability, solar radiation, and ET0 evapotranspiration metrics.

### 6. `features/alerts/` (Advisories & Notification Center)
- **Screens**: `alerts_inbox_screen.dart`, `alert_detail_screen.dart`, `create_alert_screen.dart`
- **Widgets**: `alert_tile.dart`, `severity_chip.dart`, `alert_filter_bar.dart`
- **Providers**: `alertsProvider`
- **Data Models**: `AlertModel`, `AlertNotificationModel`
- **Purpose**: Real-time push advisories via WebSocket and FCM, priority channels (critical, high, general), role-based alert creation, and bilingual advisory bodies.

### 7. `features/diagnosis/`, `features/disease/` & `features/disease_diagnosis/` (AI Crop Pathology)
- **Screens**: `leaf_photo_capture_screen.dart`, `diagnosis_result_screen.dart`, `diagnosis_history_screen.dart`
- **Widgets**: `camera_viewfinder.dart`, `treatment_recommendation_card.dart`, `confidence_meter.dart`
- **Providers**: `diseaseProvider`, `diagnosisProvider`
- **Data Models**: `DiagnosisResultModel`, `TreatmentModel`, `DiseaseModel`
- **Purpose**: AI disease detection from camera/gallery leaf images, confidence percentage calculation, localized treatment instructions, and prevention tips.

### 8. `features/sensors/` (IoT Sensor Telemetry)
- **Screens**: `sensors_list_screen.dart`, `sensor_detail_screen.dart`, `register_sensor_screen.dart`
- **Widgets**: `sensor_metric_card.dart`, `telemetry_chart.dart`, `battery_level_indicator.dart`
- **Providers**: `sensorProvider`
- **Data Models**: `SensorModel`, `TelemetryDataPoint`
- **Purpose**: Manages 4 IoT sensor types (Soil Moisture, Temperature, Rain Gauge, Leaf Wetness), real-time fl_chart telemetry streaming, and low-battery warning alerts.

### 9. `features/drought/` (Drought Risk Monitoring)
- **Screens**: `drought_risk_screen.dart`
- **Widgets**: `drought_gauge.dart`, `spi_trend_chart.dart`, `soil_deficit_card.dart`
- **Providers**: `droughtProvider`
- **Data Models**: `DroughtAssessmentModel`, `SpiIndexModel`
- **Purpose**: Real-time Standardized Precipitation Index (SPI-30 / SPI-90) visualization with interactive radial needle gauge and rainfall deficit graphs.

### 10. `features/flood/` (Hydrological & Flood Early Warning)
- **Screens**: `flood_risk_screen.dart`
- **Widgets**: `basin_discharge_chart.dart`, `return_period_indicator.dart`, `flood_hazard_card.dart`
- **Providers**: `floodProvider`
- **Data Models**: `FloodRiskModel`, `RiverDischargeModel`
- **Purpose**: GloFAS river discharge monitoring ($m^3/s$) with return period alarm levels (2-year, 5-year, 20-year) and basin flood warnings.

### 11. `features/vegetation/` (Vegetation Health & NDVI)
- **Screens**: `vegetation_health_screen.dart`
- **Widgets**: `ndvi_chart.dart`, `vigor_indicator.dart`, `vegetation_anomaly_card.dart`
- **Providers**: `vegetationProvider`
- **Data Models**: `NdviObservationModel`, `VegetationAnomalyModel`
- **Purpose**: MODIS and Sentinel-2 satellite NDVI time-series tracking against 10-year historical baselines for crop stress and pasture degradation detection.

### 12. `features/locust_pest/` (Desert Locust Swarm Radar)
- **Screens**: `locust_alerts_screen.dart`
- **Widgets**: `locust_map_overlay.dart`, `proximity_alert_card.dart`, `swarm_density_badge.dart`
- **Providers**: `locustProvider`
- **Data Models**: `LocustSwarmModel`, `SwarmGeometryModel`
- **Purpose**: Live FAO desert locust swarm polygon map overlays and real-time distance proximity calculations to registered farm coordinates (≤ 50 km warning).

### 13. `features/soil/` (Soil Chemistry & Moisture)
- **Screens**: `soil_profile_screen.dart`
- **Widgets**: `soil_nutrient_bar.dart`, `soil_moisture_dial.dart`, `texture_triangle_chart.dart`
- **Providers**: `soilProvider`
- **Data Models**: `SoilProfileModel`, `SoilTextureModel`
- **Purpose**: Visualizes SoilGrids baseline data: soil pH, organic carbon, clay/sand/silt texture breakdown, CEC, and volumetric moisture levels.

### 14. `features/analytics/` (Climatology Analytics)
- **Screens**: `analytics_dashboard_screen.dart`
- **Widgets**: `period_selector.dart`, `trend_chart.dart`, `season_comparison_card.dart`
- **Providers**: `analyticsProvider`
- **Data Models**: `RainfallAnalyticsModel`, `TemperatureAnalyticsModel`
- **Purpose**: Multi-year seasonal climatology comparison (Belg vs. Kiremt seasons), dekadal rainfall trends, and historical temperature anomalies.

### 15. `features/offline_sync/` (Background Sync Infrastructure)
- **Workers**: `background_sync_worker.dart`
- **Services**: `sync_service.dart`
- **Providers**: `syncProvider`
- **Purpose**: Workmanager-driven periodic task that flushes queued offline farm additions, diagnosis records, and reports to the backend API upon network restoration.

### 16. `features/home/` (Application Shell)
- **Screens**: `home_shell_screen.dart`
- **Widgets**: `bottom_nav_bar.dart`, `app_drawer.dart`
- **Purpose**: Container for bottom navigation and top app bar with unified brand identity and role-based menu items.
