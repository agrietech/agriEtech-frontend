# AgriEtech UI/UX Design System Specification

A unified specification for design tokens, typography, color palettes, components, and motion guidelines for the AgriEtech mobile application.

---

## 1. Brand & Hazard Color Palette

The color system is purpose-built for climate and agricultural risk visualization with WCAG AA compliance (minimum 4.5:1 contrast ratio).

| Token | Hex Value | Name | Usage |
|---|---|---|---|
| `primary` | `#2E7D32` | Forest Green | Primary buttons, app bars, active tabs, healthy indicators |
| `primaryDark` | `#1B5E20` | Dark Green | Headers, high-emphasis icons, active states |
| `primaryLight` | `#E8F5E9` | Mint Tint | Card backgrounds, badge surfaces, selected chips |
| `warningAmber` | `#FFA000` | Alert Amber | Moderate risk, approaching threshold, cautionary advisories |
| `criticalRed` | `#D32F2F` | Emergency Red | High drought risk, severe flood alarm, critical locust invasion |
| `hydroBlue` | `#1976D2` | Hydro Blue | Flood risk screens, precipitation graphs, soil moisture |
| `locustPink` | `#C2185B` | Pest Magenta | FAO locust swarm map polygons and proximity alerts |
| `surfaceDark` | `#121212` | Dark Background | Dark mode background canvas |
| `surfaceLight` | `#F8FAF9` | Off-White Background | Light mode background canvas |

---

## 2. Bilingual Typography

AgriEtech strictly supports English and Amharic (አማርኛ). Ethiopic scripts require proper font pairing for high legibility on mobile screens:

| Style | English Font | Amharic Font | Weight | Size | Line Height |
|---|---|---|---|---|---|
| **Display Large** | Outfit | Noto Sans Ethiopic | Bold (700) | 28sp | 34sp |
| **Headline Medium** | Outfit | Noto Sans Ethiopic | SemiBold (600) | 20sp | 26sp |
| **Title Medium** | Outfit | Noto Sans Ethiopic | Medium (500) | 16sp | 22sp |
| **Body Regular** | Outfit | Noto Sans Ethiopic | Regular (400) | 14sp | 20sp |
| **Caption Small** | Outfit | Noto Sans Ethiopic | Regular (400) | 12sp | 16sp |
| **Stat / Metric** | Outfit | Outfit / Ethiopic | Bold (700) | 32sp | 38sp |

---

## 3. Spacing & Elevation Tokens

### Spacing Scale
- `xs` (4dp) — Micro-gaps between badge icon and text.
- `sm` (8dp) — Internal padding inside cards, chips, and table cells.
- `md` (16dp) — Standard layout margin, padding inside list tiles, and form field gaps.
- `lg` (24dp) — Screen edge horizontal padding and separation between widget blocks.
- `xl` (32dp) — Major section dividers and modal sheet headers.

### Corner Radii
- `radius-sm` (8dp) — Action buttons, status chips, severity badges.
- `radius-md` (12dp) — Feature cards, weather metric panels, bottom sheets.
- `radius-lg` (16dp) — Map view containers, camera viewfinder frame, dialog boxes.
- `radius-full` (999dp) — Avatars, floating action buttons, circular progress meters.

### Elevation & Shadows
- **Elevation 1**: `0 1px 3px rgba(0,0,0,0.06)` (List tiles, subtle cards)
- **Elevation 2**: `0 4px 6px -1px rgba(0,0,0,0.08)` (Floating summary cards, bottom bar)
- **Elevation 3**: `0 10px 15px -3px rgba(0,0,0,0.12)` (Modals, popup advisories)

---

## 4. Reusable Component Standards

### Hazard Severity Badges

| Severity | Surface Hex | Text Hex | Icon |
|---|---|---|---|
| **CRITICAL** | `#FEE2E2` | `#991B1B` | `Icons.warning_rounded` |
| **HIGH** | `#FFEDD5` | `#9A3412` | `Icons.error_outline_rounded` |
| **MODERATE** | `#FEF9C3` | `#854D0E` | `Icons.info_outline_rounded` |
| **LOW** | `#DCFCE7` | `#166534` | `Icons.check_circle_outline_rounded` |

### Chart Visualizations
- **Meteograms & Temperature Trends**: Line chart with smooth spline interpolation, shaded gradient fills, and touch tooltip indicators.
- **Drought SPI Gauge**: Radial meter with color-coded segments (-3.0 to +3.0) and animated needle.
- **Hydrographs**: Multi-threshold step charts displaying 2-year, 5-year, and 20-year flood alert levels.
- **NDVI Curves**: Dual-series trend charts comparing current 16-day composite against the 10-year historical mean.

---

## 5. Motion & Micro-Interactions

| Interaction | Duration | Curve | Purpose |
|---|---|---|---|
| Screen Transition | 250ms | `Curves.easeInOut` | Smooth page navigation |
| Gauge Needle Sweep | 750ms | `Curves.elasticOut` | Delightful metric presentation |
| Card Expand / Collapse | 200ms | `Curves.fastOutSlowIn` | Fluid accordion details |
| Shimmer Loading Skeleton | 1200ms loop | `Curves.linear` | Perceived speed optimization |
