# Feature Roadmap & Screen Catalog

---

## 📱 Screen Catalog & User Journeys

| Feature | Screen File | Key UI Elements | Data Providers |
|---|---|---|---|
| **Auth** | `login_screen.dart` | Phone input (+251), password field, language switch | `authProvider` |
| **Boundaries** | `location_picker.dart` | Cascading dropdowns (Region -> Zone -> Woreda) | `boundariesProvider` |
| **Farms** | `farm_list_screen.dart`, `add_farm_screen.dart` | Farm cards, GPS polygon map editor (`flutter_map`) | `farmsProvider` |
| **Weather** | `weather_screen.dart` | 16-day meteogram, hourly temperature trend chart | `weatherProvider` |
| **Drought** | `drought_risk_screen.dart` | Radial SPI drought gauge, 30/90-day deficit trend | `droughtProvider` |
| **Flood** | `flood_risk_screen.dart` | GloFAS river discharge hydrograph, return period bars | `floodProvider` |
| **Vegetation**| `vegetation_health_screen.dart`| MODIS/Sentinel NDVI curve vs. 10-year baseline | `vegetationProvider`|
| **Locust** | `locust_alerts_screen.dart` | Map with swarm polygons, proximity distance alert | `locustProvider` |
| **Soil** | `soil_profile_screen.dart` | Soil moisture gauge, pH, clay/sand/organic matter bars| `soilProvider` |
| **Diagnosis** | `leaf_photo_capture_screen.dart` | Camera viewfinder, AI disease confidence & treatment | `diseaseProvider` |
| **Dashboard** | `risk_dashboard_screen.dart` | Composite woreda score card, multi-hazard map | `riskDashboardProvider` |
| **Alerts** | `alerts_inbox_screen.dart` | Notification list with Amharic advisory details | `alertsProvider` |
| **Analytics** | `analytics_dashboard_screen.dart`| Comparative seasonal rainfall & temperature trends | `analyticsProvider` |
