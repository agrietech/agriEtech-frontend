# AgriEtech Frontend Dedicated Disaster Screens & GIS Integration

## 1. Executive Summary

AgriEtech Flutter client features **6 dedicated disaster screens**, a **Master Disaster Hub**, an **Interactive USSD `*212#` Simulator**, and a **Strictly Ethiopian Spatial Risk GIS Map**.

---

## 2. Dedicated Disaster Domain Screens

```
                                  ┌──────────────────────────────────────────────┐
                                  │   /disasters (Master Disaster Hub)           │
                                  └──────────────────────┬───────────────────────┘
                                                         │
       ┌───────────────────────┬─────────────────────────┼────────────────────────┬──────────────────────┐
       ▼                       ▼                         ▼                        ▼                      ▼
┌───────────────┐      ┌───────────────┐         ┌───────────────┐        ┌───────────────┐      ┌───────────────┐
│ /seismology   │      │ /soil-        │         │ /landslides   │        │ /drought-     │      │ /flood-       │
│               │      │  degradation  │         │               │        │  intelligence │      │  intelligence │
│ • USGS Feed   │      │ • RUSLE Loss  │         │ • FS Stability│        │ • SPI-1 / 3   │      │ • GloFAS Flow │
│ • Wonji Fault │      │ • SOC Deplete │         │ • DEM Slope % │        │ • VCI Canopy  │      │ • Basin Floods│
│ • PGA / MMI   │      │ • Lime ኖራ    │         │ • SAR Sat. %  │        │ • CWSI Stress │      │ • Canal Action│
└───────────────┘      └───────────────┘         └───────────────┘        └───────────────┘      └───────────────┘
                               │                                                  │
                               └─────────────────────────┬────────────────────────┘
                                                         ▼
                                                  ┌───────────────┐
                                                  │ /volcanic-    │
                                                  │  hazards      │
                                                  │ • Calderas    │
                                                  │ • FIRMS MW    │
                                                  │ • SO₂ Gases   │
                                                  └───────────────┘
```

---

## 3. Dedicated Screen Specifications

### 3.1 🌋 Seismology & Tectonic Hazards (`/seismology`)
*File:* [`lib/features/risk/screens/seismology_detail_screen.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/features/risk/screens/seismology_detail_screen.dart)
- Live USGS Horn of Africa earthquake list ($M \ge 2.5$).
- Peak Ground Acceleration ($PGA$) in $g$, Modified Mercalli Intensity ($MMI$).
- Fault axis distance and slip rate for *Wonji Fault Belt, Afar Depression, Ankober, Ambo, and Chew Bahir*.
- 30-day $M \ge 4.5$ recurrence probability and irrigation dam tension cracking warnings.

### 3.2 🌱 Soil Degradation & RUSLE Loss (`/soil-degradation`)
*File:* [`lib/features/risk/screens/soil_degradation_screen.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/features/risk/screens/soil_degradation_screen.dart)
- Full RUSLE formula decomposition ($A = R \times K \times LS \times C \times P$).
- Annual soil loss ($\text{t/ha/yr}$) vs. FAO tolerable threshold ($10\,\text{t/ha/yr}$).
- Soil Organic Carbon (SOC) loss rate & N-P-K nutrient leaching metrics.
- Chemical health: Highland Acidification ($pH < 5.2$ Lime ኖራ requirement in Qt/ha) vs. Salinization.
- Engineering prescriptions (*Fanya Juu, Stone bunds, Vetiver grass buffer strips, Faidherbia albida*).

### 3.3 ⛰️ Landslides & Mudflows (`/landslides`)
*File:* [`lib/features/risk/screens/landslide_risk_screen.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/features/risk/screens/landslide_risk_screen.dart)
- Geotechnical Factor of Safety ($FS$) slope stability calculation ($FS < 1.15$ Critical, $FS \ge 1.50$ Stable).
- DEM 30m terrain slope % vs. Sentinel-1 SAR microwave radar volumetric soil moisture saturation %.
- High-risk mountain escarpment monitoring: Debre Sina, Gofa, Mount Choke, and Ankober.

### 3.4 ☀️ Drought & Moisture Desiccation (`/drought-intelligence`)
*File:* [`lib/features/risk/screens/drought_intelligence_screen.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/features/risk/screens/drought_intelligence_screen.dart)
- Multiscale Standardized Precipitation Index: SPI-1 (30-day) and SPI-3 (90-day seasonal).
- Vegetation Condition Index ($VCI$) from Sentinel-2 MSI NDVI anomalies.
- Crop Water Stress Index ($CWSI$) derived from Landsat 8/9 Thermal Infrared ($LST$).
- Prescriptions for drought-tolerant seeds (*Melkassa-2 Maize, Quncho Teff*) and mulching.

### 3.5 🌊 Flash Floods & River Basins (`/flood-intelligence`)
*File:* [`lib/features/risk/screens/flood_intelligence_screen.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/features/risk/screens/flood_intelligence_screen.dart)
- Copernicus GloFAS live river discharge ($m^3/s$) vs. 5-year, 20-year, and 50-year return periods.
- Basin inundation registry for *Awash River, Baro-Akobo, Omo-Gibe, and Blue Nile (Abay)*.
- Flood evacuation, levee clearing, and drainage canal diversion protocols.

### 3.6 🔥 Volcanic & Geothermal Hazards (`/volcanic-hazards`)
*File:* [`lib/features/risk/screens/volcanic_hazard_screen.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/features/risk/screens/volcanic_hazard_screen.dart)
- Buffer zones for active calderas: *Erta Ale, Dabbahu, Fentale, Alutu, Corbetti, and Dama Ali*.
- MODIS FIRMS thermal radiative power ($FRP$ in MW) and Sulfur Dioxide ($SO_2$) gas tracking.

---

## 4. Strictly Ethiopian Spatial Risk GIS Map (`/risk-map`)

*Files:* [`lib/features/analytics/widgets/ethiopia_gis_map_widget.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/features/analytics/widgets/ethiopia_gis_map_widget.dart) & [`lib/features/risk/screens/risk_map_screen.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/features/risk/screens/risk_map_screen.dart)
- Camera constrained strictly to Ethiopia ($3.2^\circ\text{N} - 15.2^\circ\text{N}, 32.8^\circ\text{E} - 48.2^\circ\text{E}$).
- Woreda choropleth risk polygons with 8 disaster layer switchers.
- Interactive Woreda Telemetry Inspector with live KPIs, bilingual advisories, and 1-tap navigation.

---

## 5. Interactive USSD `*212#` & SMS Console (`/ussd-console`)

*File:* [`lib/features/analytics/screens/ussd_alert_console_screen.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/features/analytics/screens/ussd_alert_console_screen.dart)
- Feature phone dialer simulator executing all 6 branches of the `*212#` USSD state machine.
- Real-time UCS-2 Unicode (70 chars) vs. GSM 7-bit (160 chars) SMS character budgeter and broadcast queue simulator.
