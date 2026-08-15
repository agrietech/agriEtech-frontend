# Frontend Team Assignment & Implementation Guide

---

## 👥 Role & Feature Assignment Matrix

| Developer Role | Assigned Feature Modules | Primary Responsibilities | Acceptance Criteria |
|---|---|---|---|
| **Dev 1: Core Infra & Auth** | `core/network/*`, `core/storage/*`, `features/auth/*`, `features/boundaries/*` | Setup Dio client, SecureStorage, Hive caching, Login/Register UI, Location picker. | User can log in, select Woreda, and persist session token securely. |
| **Dev 2: Farm Geofencing & Maps** | `features/farms/*`, `core/widgets/*` | Farm list/detail screens, interactive flutter_map polygon geofence editor. | Farmer can draw plot boundaries on map and save coordinates. |
| **Dev 3: Weather & Analytics** | `features/weather/*`, `features/analytics/*` | 16-day meteogram, fl_chart rainfall and temperature trend visualizations. | Weather charts render smoothly; Period toggle switches daily/dekadal views. |
| **Dev 4: Drought & Flood Modules** | `features/drought/*`, `features/flood/*` | Radial drought gauge, GloFAS hydrograph charts, severity level advisories. | SPI levels display correct color coding (Red/Amber/Green); Flood return periods render. |
| **Dev 5: Vegetation & Locust Map** | `features/vegetation/*`, `features/locustPest/*` | NDVI anomaly trend lines, FAO locust swarm map overlay, GPS proximity alert. | Locust swarms render as polygons on map with distance calculation from farm. |
| **Dev 6: AI Diagnostics & Dashboard**| `features/diseaseDiagnosis/*`, `features/riskDashboard/*`, `features/alerts/*` | Camera photo capture & diagnosis UI, Multi-hazard composite dashboard, Alerts inbox. | Camera takes leaf picture, displays AI diagnosis result and treatment in Amharic & English. |

---

## 🛠️ Developer Checklist
1. Review feature requirements in `docs/FEATURE_ROADMAP.md`.
2. Ensure UI adheres to `docs/UI_UX_DESIGN_SYSTEM.md`.
3. Test offline state: Disable WiFi/Data and verify Hive cache loads gracefully.
4. Verify both Amharic and English text strings in `lib/core/localization/l10n/`.
