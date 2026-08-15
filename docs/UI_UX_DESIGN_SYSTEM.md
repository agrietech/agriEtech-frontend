# UI/UX Design System & Mobile Styling Guidelines

> Material 3 design tokens, bilingual typography rules, and interactive component standards for AgriEtech.

---

## 1. Color Palette & Hazard Spectrum

The AgriEtech palette combines agricultural earth tones with standard hazard emergency indicator colors:

| Color Role | Hex Code | Semantic Purpose | Usage |
|---|---|---|---|
| **Primary Green** | `#2E7D32` | Agricultural vitality, system brand | App bars, primary action buttons, active navigation |
| **Primary Dark** | `#1B5E20` | Depth, status bars | Android status bar tint, header accents |
| **Surface Light** | `#F8FAF9` | Background | Primary scaffold background in light mode |
| **Surface Dark** | `#121B14` | Dark mode background | Primary scaffold background in dark mode |
| **Alert Red (Critical)** | `#D32F2F` | Emergency hazard / High deficit | Drought SPI $\le -2.0$, flood discharge $\ge Q_{20}$, crop disease alert |
| **Warning Amber (High)** | `#F57C00` | Heightened vigilance | Drought SPI $[-1.99, -1.5]$, flood discharge $Q_5 \le Q < Q_{20}$ |
| **Moderate Yellow** | `#FBC02D` | Advisory caution | Drought SPI $[-1.49, -1.0]$, flood discharge $Q_2 \le Q < Q_5$ |
| **Normal Green (Low)** | `#388E3C` | Safe / Optimal | Normal soil moisture, normal rainfall, zero locust activity |
| **Hydro Blue** | `#1976D2` | Water and rainfall | River discharge curves, precipitation meteograms |
| **Pest Crimson** | `#C2185B` | Desert locust swarms | Locust swarm polygons, proximity radius alerts |

---

## 2. Bilingual Typography System

Typography must scale legibly for both English and Ge'ez (Amharic) script:

| Style Token | Font Family (English) | Font Family (Amharic) | Weight | Size (sp) | Line Height |
|---|---|---|---|---|---|
| `Display Large` | Outfit | Noto Sans Ethiopic | Bold (700) | 28 | 34 |
| `Title Medium` | Outfit | Noto Sans Ethiopic | SemiBold (600) | 18 | 24 |
| `Body Large` | Outfit | Noto Sans Ethiopic | Regular (400) | 16 | 22 |
| `Body Medium` | Outfit | Noto Sans Ethiopic | Regular (400) | 14 | 20 |
| `Label Small` | Outfit | Noto Sans Ethiopic | Medium (500) | 11 | 14 |

---

## 3. Spatial System & Corner Radii

```
Spacing Scale:
xs: 4dp  ── sm: 8dp  ── md: 16dp  ── lg: 24dp  ── xl: 32dp

Corner Radii:
Small (8dp): Badges, chips, text inputs
Medium (12dp): Standard metric cards, chart containers
Large (16dp): Bottom sheets, modal dialogs, hero overview cards
Pill (999dp): Status indicators, rounded avatar containers
```

---

## 4. Accessibility & Touch Guidelines

1. **Touch Target Sizing**: All interactive buttons, chips, and map controls must maintain a minimum bounding box of **48×48dp**.
2. **Contrast Ratio**: Text against backgrounds must strictly achieve a minimum contrast ratio of **4.5:1** (WCAG AA standard).
3. **Offline Visual Indicators**: When operating without network, screens render a non-intrusive metadata pill (e.g. *"Cached: 2 hours ago"*) rather than obstructive modal dialogs.

