# AgriEtech Frontend

**Cross-Platform Flutter Mobile & Web Client for Ethiopian Multi-Hazard Agricultural Early Warning & Planetary Intelligence**

[![Flutter](https://img.shields.io/badge/Flutter-3.x%20Cross--Platform-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%202.x-black)](https://riverpod.dev)
[![GoRouter](https://img.shields.io/badge/Routing-GoRouter%2014.x-blue)](https://pub.dev/packages/go_router)
[![OpenStreetMap](https://img.shields.io/badge/GIS-FlutterMap%20OSM-7EBC6F?logo=openstreetmap)](https://pub.dev/packages/flutter_map)

---

## 🌟 Executive Overview

**AgriEtech Frontend** is a production-ready Flutter 3.x client engineered for Android, iOS, and Web. It delivers real-time multi-hazard agricultural intelligence to Ethiopian farmers, development agents, woreda officers, and researchers. The client features 6 dedicated disaster domain screens, an interactive Ethiopian GIS Spatial Risk Map with Woreda choropleth risk polygons, an interactive USSD `*212#` simulator, multimodal AI crop pathology scanner, and offline-first data caching.

---

## 🚀 Key Client Capabilities

1. **Strictly Ethiopian Spatial Risk GIS Map (`/risk-map`)**:
   - Locked strictly to Ethiopia's sovereign coordinates ($3.2^\circ\text{N} - 15.2^\circ\text{N}, 32.8^\circ\text{E} - 48.2^\circ\text{E}$).
   - High-precision Woreda choropleth polygons with 8 disaster layer modes (*All Hazards, Seismology, Soil Degradation, Landslides, Drought SPI-3, GloFAS Floods, Volcanoes, and Farm Plots*).
   - Interactive Telemetry Inspector Bottom Sheet with live KPIs and 1-tap navigation to dedicated disaster screens.

2. **6 Dedicated Disaster Intelligence Monitoring Centers**:
   - 🌋 **Seismology & Tectonic Faults (`/seismology`)**: Live USGS Horn of Africa earthquake list, Wonji Rift fault buffer alerts, PGA acceleration ($g$), and dam tension crack alarms.
   - 🌱 **Soil Degradation & RUSLE (`/soil-degradation`)**: RUSLE equation decomposition ($A = R \times K \times LS \times C \times P$), SOC loss, nutrient leaching, and Agricultural Lime (ኖራ) prescriptions.
   - ⛰️ **Landslides & Mudflows (`/landslides`)**: Geotechnical Factor of Safety ($FS$), DEM 30m slope %, and SAR soil saturation %.
   - ☀️ **Drought Intelligence (`/drought-intelligence`)**: CHIRPS SPI-1/SPI-3 anomalies, Sentinel-2 VCI canopy vigor, and Landsat CWSI thermal stress.
   - 🌊 **Flash Floods (`/flood-intelligence`)**: Copernicus GloFAS live river basin discharge ($m^3/s$) and return period warnings.
   - 🔥 **Volcanic Hazards (`/volcanic-hazards`)**: Active caldera proximity rings (*Erta Ale, Alutu, Fentale, Corbetti*), MODIS FIRMS thermal radiative power, and $SO_2$ alerts.

3. **USSD `*212#` Phone Simulator & SMS Character Budgeter (`/ussd-console`)**:
   - Interactive hardware phone dialer simulator executing all 6 branches of the `*212#` USSD state machine.
   - Real-time UCS-2 Unicode (70 chars) vs. GSM 7-bit (160 chars) character counter and multi-language transmission calculator.

4. **AI Crop Disease Camera Scanner (`/diagnosis`)**:
   - Camera and gallery image classification for endemic crop pathogens (Teff Rust, Coffee Leaf Rust, Maize Streak Virus).
   - Localized organic and chemical treatment prescriptions in English and Amharic.

5. **7-Tier Role-Based UI Gating (`RoleUtils`)**:
   - Dynamic interface adapting to `FARMER`, `DEVELOPMENT_AGENT`, `WOREDA_OFFICER`, `ZONAL_OFFICER`, `REGIONAL_OFFICER`, `RESEARCHER`, and `ADMIN`.

---

## 🏗️ Architecture Blueprint

```
lib/
├── core/                       # Core Foundation Layer
│   ├── constants/              # API endpoints, asset paths, keys
│   ├── models/                 # Shared data models (UserModel, UserRole)
│   ├── network/                # Dio client, interceptors, error handling
│   ├── routing/                # AppRouter & GoRouter declarations
│   ├── storage/                # Encrypted secure storage service
│   ├── theme/                  # AppTheme, color tokens, typography
│   ├── utils/                  # RoleUtils, DateFormatter, AppLogger
│   └── widgets/                # Reusable UI atoms (AgriEtechLogo, Badges)
│
└── features/                   # Domain Feature Modules
    ├── auth/                   # Authentication & Role Requests
    ├── home/                   # Navigation Shell & Role Dashboard
    ├── risk/                   # Multi-Hazard & 6 Dedicated Disaster Screens
    ├── farms/                  # GIS Farm Plot Mapping & Parcels
    ├── alerts/                 # Early Warning List & Creation
    ├── sensors/                # IoT Sensor Fleet & Registration
    ├── diagnosis/              # AI Multimodal Crop Vision & Pathology
    ├── weather/                # Hyper-Local Weather Telemetry
    ├── boundaries/             # Administrative Woreda GIS Boundaries
    ├── analytics/              # Agro-Analytics, USSD Hub & GIS Map
    └── ai_voice/               # Multilingual Voice AI Assistant
```

---

## 🛠️ Quick Start & Installation

### Prerequisites
- Flutter 3.19+ / Dart 3.3+
- Android Studio / Xcode / Chrome for Web

### Setup
```bash
# 1. Install dependencies
flutter pub get

# 2. Verify static analysis
flutter analyze

# 3. Launch mobile / web app
flutter run
```

---

## 📚 Official Documentation Catalog

For in-depth frontend technical guides, refer to the [**Frontend Documentation Catalog**](docs/README.md):

- [Architecture Blueprint](docs/ARCHITECTURE.md)
- [Design System & Theme Standards](docs/DESIGN_SYSTEM.md)
- [Dedicated Disaster Screens & GIS Specifications](docs/DISASTER_SCREENS_AND_GIS.md)
- [Feature Modules Catalog](docs/FEATURE_MODULES.md)
- [Role-Based UI Gating Guide](docs/ROLE_BASED_UI_GUIDE.md)
- [App Icon Setup Guide](docs/APP_ICON_SETUP.md)
