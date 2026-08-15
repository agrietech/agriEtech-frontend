# Feature Roadmap, Screen Catalog & API Integration

> Detailed functional specifications, UI widget structure, and backend endpoint mapping across all 14 domains.

---

## 1. Feature Specifications & Screen Mapping

| # | Feature Domain | Screen & Widget Files | State Providers | Remote Endpoints & Protocols | Local Cache Box |
|---|---|---|---|---|---|
| **1** | **Authentication** | `login_screen.dart`<br>`register_screen.dart`<br>`otp_verify_screen.dart` | `authProvider` | `POST /api/v1/auth/login`<br>`POST /api/v1/auth/register`<br>`POST /api/v1/auth/verify-otp` | `FlutterSecureStorage` |
| **2** | **Administrative Boundaries** | `location_picker.dart`<br>`woreda_selector_dialog.dart` | `boundariesProvider` | `GET /api/v1/boundaries/regions`<br>`GET /api/v1/boundaries/zones/:id`<br>`GET /api/v1/boundaries/woredas/:id` | `boundary_cache` |
| **3** | **Farm Management** | `farm_list_screen.dart`<br>`farm_detail_screen.dart`<br>`add_farm_screen.dart`<br>`farm_polygon_map.dart` | `farmsProvider` | `GET /api/v1/farms`<br>`POST /api/v1/farms`<br>`PUT /api/v1/farms/:id`<br>`DELETE /api/v1/farms/:id` | `farms_cache`<br>`pending_mutations` |
| **4** | **Weather & Meteograms** | `weather_screen.dart`<br>`rainfall_chart.dart`<br>`temperature_trend_chart.dart` | `weatherProvider` | `GET /api/v1/weather/forecast?lat=&lon=`<br>`GET /api/v1/weather/historical` | `weather_cache` |
| **5** | **Drought Risk Assessment** | `drought_risk_screen.dart`<br>`drought_gauge.dart`<br>`spi_timeline_chart.dart` | `droughtProvider` | `GET /api/v1/risk/drought?woreda_id=`<br>`GET /api/v1/risk/spi-history` | `risk_cache` |
| **6** | **Flood & Hydrology** | `flood_risk_screen.dart`<br>`basin_discharge_chart.dart`<br>`return_period_indicator.dart`| `floodProvider` | `GET /api/v1/risk/flood?woreda_id=`<br>`GET /api/v1/risk/hydrograph` | `risk_cache` |
| **7** | **Vegetation Health** | `vegetation_health_screen.dart`<br>`ndvi_chart.dart`<br>`vci_anomaly_bar.dart` | `vegetationProvider` | `GET /api/v1/satellite/ndvi?woreda_id=`<br>`GET /api/v1/satellite/vci` | `risk_cache` |
| **8** | **Desert Locust Tracking** | `locust_alerts_screen.dart`<br>`locust_map_overlay.dart`<br>`proximity_warning_card.dart` | `locustProvider` | `GET /api/v1/risk/locust/active-swarms`<br>`GET /api/v1/risk/locust/proximity?lat=&lon=` | `risk_cache` |
| **9** | **Soil Profile & Nutrients**| `soil_profile_screen.dart`<br>`soil_nutrient_bar.dart`<br>`soil_ph_gauge.dart` | `soilProvider` | `GET /api/v1/farms/:id/soil-profile`<br>`GET /api/v1/sensors/telemetry?farm_id=` | `farms_cache` |
| **10**| **AI Disease Diagnosis** | `leaf_photo_capture_screen.dart`<br>`diagnosis_result_screen.dart`<br>`treatment_action_card.dart`| `diseaseProvider` | `POST /api/v1/disease/diagnose` (Multipart/form-data) | `FlutterSecureStorage` |
| **11**| **Master Risk Dashboard** | `risk_dashboard_screen.dart`<br>`risk_summary_card.dart`<br>`multi_hazard_map.dart` | `riskDashboardProvider`| `GET /api/v1/risk/composite?woreda_id=`<br>`Socket.IO: 'risk:updated'` | `risk_cache` |
| **12**| **Alerts & Advisories** | `alerts_inbox_screen.dart`<br>`alert_detail_screen.dart`<br>`advisory_card.dart` | `alertsProvider` | `GET /api/v1/alerts`<br>`PUT /api/v1/alerts/:id/read`<br>`Socket.IO: 'alert:broadcast'` | `alerts_cache` |
| **13**| **Agro-Analytics** | `analytics_dashboard_screen.dart`<br>`seasonal_comparison_chart.dart`| `analyticsProvider` | `GET /api/v1/analytics/seasonal-trends`<br>`GET /api/v1/analytics/dekadal-summary` | `weather_cache` |
| **14**| **Background Offline Sync** | `sync_status_badge.dart`<br>`pending_queue_sheet.dart` | `syncServiceProvider` | `POST /api/v1/sync/batch`<br>`GET /api/v1/sync/status` | `pending_mutations` |

---

## 2. Key Screen Acceptance Criteria

### Master Multi-Hazard Risk Dashboard (`risk_dashboard_screen.dart`)
- Renders an aggregate Woreda hazard index (0–100) classified into Low, Moderate, High, or Critical severity.
- Renders interactive OpenStreetMap layer with toggleable overlays for flood zones, drought severity, and locust points.
- Automatically receives and injects real-time risk updates via Socket.IO without page reload.
- Falls back to last cached calculation with an offline timestamp indicator when no signal is present.

### AI Leaf Pathology Diagnosis (`leaf_photo_capture_screen.dart`)
- Provides camera viewfinder with cropping guidelines for infected leaves.
- Compresses image payload (<1MB) before multipart upload to the backend proxy.
- Renders top disease classification, percentage confidence score, and treatment instructions in both Amharic and English.

### Farm Polygon Geofence Editor (`farm_polygon_map.dart`)
- Allows farmers and development agents to tap vertices on OpenStreetMap to define plot perimeters.
- Live calculates acreage and perimeter length using Spherical Geodesic formulas.
- Saves GeoJSON `Polygon` format locally to Hive and syncs to backend PostGIS via `/api/v1/farms`.

