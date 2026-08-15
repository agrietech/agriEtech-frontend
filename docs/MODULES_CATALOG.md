# AgriEtech Frontend Modules & Directory Catalog

An exhaustive reference catalog detailing the architecture, screens, widgets, providers, models, and repositories for all 14 feature modules and core utilities in the `agrietech-frontend` codebase.

---

## 1. Directory Structure Overview

```
lib/
├── app.dart                          # MaterialApp.router configuration & theme bindings
├── main.dart                         # App entry point, Hive initialization, ProviderScope
├── core/
│   ├── config/                       # Environment variables, themes, GoRouter routing
│   ├── constants/                    # API endpoints, hazard thresholds, storage keys
│   ├── localization/                 # Bilingual ARB files (app_en.arb, app_am.arb)
│   ├── network/                      # Dio HTTP client, JWT interceptors, Socket.IO client
│   ├── storage/                      # SecureStorage and Hive box declarations
│   ├── utils/                        # Ethiopian calendar, geo-calculations, phone validators
│   └── widgets/                      # Global reusable widgets (RiskBadge, PeriodToggle, etc.)
├── features/                         # 14 Clean Architecture Feature Domains
│   ├── alerts/                       # Push & WebSocket advisory inbox
│   ├── analytics/                    # Seasonal climatology & historical trends
│   ├── auth/                         # Phone authentication & token management
│   ├── boundaries/                   # Ethiopian Region -> Zone -> Woreda selectors
│   ├── disease_diagnosis/            # Camera leaf photo capture & AI pathology
│   ├── drought/                      # Radial SPI drought gauge & precipitation trends
│   ├── farms/                        # Farm profiles & interactive GPS polygon mapping
│   ├── flood/                        # GloFAS river discharge hydrographs & alert bars
│   ├── locust_pest/                  # FAO locust swarm map overlays & proximity alerts
│   ├── offline_sync/                 # Workmanager background synchronization worker
│   ├── risk_dashboard/               # Multi-hazard composite home screen
│   ├── soil/                         # SoilGrids chemistry, pH & nutrient charts
│   ├── vegetation/                   # MODIS / Sentinel-2 NDVI time series
│   └── weather/                      # 16-day Open-Meteo weather forecast & meteograms
└── shared/                           # Generic API response envelope & context extensions
```

---

## 2. Feature Domains Reference

### 1. `features/auth/` (Authentication & Security)
- **Screens**: `login_screen.dart`, `register_screen.dart`
- **Widgets**: `auth_header.dart`, `language_selector_tile.dart`
- **Providers**: `authProvider` (`AsyncNotifierProvider`)
- **Data Models**: `UserModel`, `AuthTokenModel`
- **Purpose**: Authenticates farmers via Ethiopian phone number (`+2519...`), registers assigned Woreda, and manages JWT refresh cycles.

### 2. `features/boundaries/` (Administrative Hierarchy)
- **Screens / Widgets**: `location_picker.dart`
- **Providers**: `boundariesProvider`
- **Data Models**: `RegionModel`, `ZoneModel`, `WoredaModel`
- **Purpose**: Cascading administrative boundaries for Ethiopia, seeded from HDX datasets with 30-day Hive offline persistence.

### 3. `features/farms/` (Farm Management & Geofencing)
- **Screens**: `farm_list_screen.dart`, `farm_detail_screen.dart`, `add_farm_screen.dart`
- **Widgets**: `farm_card.dart`, `farm_polygon_map.dart`
- **Providers**: `farmsProvider`
- **Data Models**: `FarmModel`, `PolygonCoordinateModel`
- **Purpose**: Allows farmers to manage multiple plots, draw GPS polygons on OpenStreetMap, and track primary crop types.

### 4. `features/weather/` (Weather & Forecasting)
- **Screens**: `weather_screen.dart`
- **Widgets**: `rainfall_chart.dart`, `temperature_trend_chart.dart`, `weather_metric_card.dart`
- **Providers**: `weatherProvider`
- **Data Models**: `WeatherForecastModel`, `HourlyForecastModel`, `DailyForecastModel`
- **Purpose**: Displays 16-day Open-Meteo weather predictions, 24-hour temperature splines, and precipitation totals.

### 5. `features/drought/` (Drought Risk Monitoring)
- **Screens**: `drought_risk_screen.dart`
- **Widgets**: `drought_gauge.dart`, `spi_trend_chart.dart`
- **Providers**: `droughtProvider`
- **Data Models**: `DroughtAssessmentModel`, `SpiIndexModel`
- **Purpose**: Visualizes real-time Standardized Precipitation Index (SPI-30 / SPI-90) with interactive radial needle gauge.

### 6. `features/flood/` (Hydrological & Flood Early Warning)
- **Screens**: `flood_risk_screen.dart`
- **Widgets**: `basin_discharge_chart.dart`, `return_period_indicator.dart`
- **Providers**: `floodProvider`
- **Data Models**: `FloodRiskModel`, `RiverDischargeModel`
- **Purpose**: Tracks river discharge ($m^3/s$) from GloFAS and warns when levels breach 2-year, 5-year, or 20-year return periods.

### 7. `features/vegetation/` (Vegetation Health & NDVI)
- **Screens**: `vegetation_health_screen.dart`
- **Widgets**: `ndvi_chart.dart`, `vigor_indicator.dart`
- **Providers**: `vegetationProvider`
- **Data Models**: `NdviObservationModel`, `VegetationAnomalyModel`
- **Purpose**: Compares current satellite NDVI against 10-year historical means to detect crop stress and pasture degradation.

### 8. `features/locust_pest/` (Desert Locust Swarm Radar)
- **Screens**: `locust_alerts_screen.dart`
- **Widgets**: `locust_map_overlay.dart`, `proximity_alert_card.dart`
- **Providers**: `locustProvider`
- **Data Models**: `LocustSwarmModel`, `SwarmGeometryModel`
- **Purpose**: Displays live FAO desert locust swarm polygons on map and calculates real-time proximity to user's registered farms.

### 9. `features/soil/` (Soil Chemistry & Moisture)
- **Screens**: `soil_profile_screen.dart`
- **Widgets**: `soil_nutrient_bar.dart`, `soil_moisture_dial.dart`
- **Providers**: `soilProvider`
- **Data Models**: `SoilProfileModel`, `SoilTextureModel`
- **Purpose**: Visualizes SoilGrids baseline data: pH, clay/sand/silt percentages, CEC, and volumetric soil moisture.

### 10. `features/disease_diagnosis/` (AI Crop Pathology)
- **Screens**: `leaf_photo_capture_screen.dart`, `diagnosis_result_screen.dart`
- **Widgets**: `camera_viewfinder.dart`, `treatment_recommendation_card.dart`
- **Providers**: `diseaseProvider`
- **Data Models**: `DiagnosisResultModel`, `TreatmentModel`
- **Purpose**: Captures photo of diseased leaf, performs AI diagnosis, and returns localized treatment recommendations in Amharic & English.

### 11. `features/risk_dashboard/` (Multi-Hazard Master Dashboard)
- **Screens**: `risk_dashboard_screen.dart`
- **Widgets**: `risk_summary_card.dart`, `multi_hazard_map.dart`, `quick_action_bar.dart`
- **Providers**: `riskDashboardProvider`
- **Data Models**: `CompositeRiskModel`, `HazardScoreModel`
- **Purpose**: The primary home screen uniting Drought, Flood, Locust, and Climatology scores into an actionable Woreda risk score.

### 12. `features/alerts/` (Advisories & Notification Center)
- **Screens**: `alerts_inbox_screen.dart`, `alert_detail_screen.dart`
- **Widgets**: `alert_tile.dart`, `severity_chip.dart`
- **Providers**: `alertsProvider`
- **Data Models**: `AlertNotificationModel`
- **Purpose**: Notification inbox for high-priority SMS, push, and WebSocket advisories with bilingual descriptions.

### 13. `features/analytics/` (Climatology Analytics)
- **Screens**: `analytics_dashboard_screen.dart`
- **Widgets**: `period_selector.dart`, `trend_chart.dart`
- **Providers**: `analyticsProvider`
- **Data Models**: `RainfallAnalyticsModel`, `TemperatureAnalyticsModel`
- **Purpose**: Multi-year seasonal comparison (Belg vs. Kiremt seasons) and dekadal rainfall trends.

### 14. `features/offline_sync/` (Background Sync Infrastructure)
- **Workers**: `background_sync_worker.dart`
- **Services**: `sync_service.dart`
- **Purpose**: Workmanager-driven periodic task that flushes queued offline farm additions, diagnosis records, and reports to backend API.

---

## 3. Core Shared Utilities & Widgets

| File Path | Description |
|---|---|
| `lib/core/widgets/risk_badge.dart` | Severity badge with dynamic color & icon based on risk level |
| `lib/core/widgets/period_toggle.dart` | Segmented period selector (Daily / Dekadal / Monthly / Seasonal) |
| `lib/core/widgets/loading_indicator.dart` | Shimmer effect and progress indicator for async states |
| `lib/core/widgets/error_view.dart` | Clean offline-friendly error state with retry callback |
| `lib/core/utils/date_utils.dart` | Ethiopian Ge'ez calendar converters and dekad date formatters |
| `lib/core/utils/geo_utils.dart` | Haversine distance and polygon area calculators |
| `lib/core/utils/validators.dart` | Ethiopian phone number and form input validators |
