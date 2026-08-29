# AgriEtech Design System & Theme Standards

## 1. Overview

The AgriEtech design system combines agricultural warmth with high-tech satellite and telemetry aesthetics. It adheres to material design standards while providing custom tokens for agro-intelligence data visualization.

---

## 2. Color Palette & Tokens

*File:* [`lib/core/theme/app_theme.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/core/theme/app_theme.dart)

### 2.1 Brand & Neutral Colors
- **Primary Brand**: `#15803D` (Forest Green - Core Agricultural)
- **Primary Dark**: `#14532D` (Deep Leaf Green)
- **Secondary**: `#F59E0B` (Golden Amber - Crop Harvest / Sun)
- **Background Light**: `#F8FAF8` (Crisp Off-White)
- **Background Dark**: `#0D190D` (Night OLED Tone)
- **Surface Dark**: `#132213` (Dark Canopy Green)

### 2.2 Telemetry & Risk Indicators
- **Critical / Severe Alert**: `#DC2626` (Crimson Red)
- **High Risk**: `#EA580C` (Deep Orange)
- **Moderate / Watch**: `#F59E0B` (Amber)
- **Low / Healthy**: `#10B981` (Emerald Green)
- **Sentinel-2 NDVI Telemetry**: `#22C55E` (High-Vigor Green)
- **IoT Sensors**: `#38BDF8` (Cyan Blue)
- **USSD Shortcode *212#**: `#0D9488` (Teal)

---

## 3. Typography

- **Headings & Badges**: Google Fonts `Outfit` (Bold, Modern geometric)
- **Body & Captions**: Google Fonts `Inter` (Legible at small sizes and tabular telemetry)
- **Ethiopic Script Support**: System fallback for Amharic (አማርኛ) and Afaan Oromoo.

---

## 4. Gradients & Micro-Interactions

- **`techHeaderGradient`**: Linear gradient from `Color(0xFF1B5E20)` to `Color(0xFF0F3E14)` with subtle satellite watermark opacity.
- **Card Elevations**: Standardized 2dp elevation with 16dp rounded border radius and responsive hover states.
