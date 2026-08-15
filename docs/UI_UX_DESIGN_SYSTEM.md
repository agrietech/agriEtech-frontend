# UI/UX Design System Specification

## Brand Identity

| Property | Value |
|---|---|
| **Primary Color** | `#2E7D32` (Agricultural Green) |
| **Primary Dark** | `#1B5E20` |
| **Primary Light** | `#E8F5E9` |
| **Accent Amber** | `#FFA000` (Warning/Attention) |
| **Critical Red** | `#D32F2F` (Drought/Emergency) |
| **Hydro Blue** | `#1976D2` (Flood/Water) |
| **Locust Pink** | `#C2185B` (Pest/Infestation) |

## Typography

| Usage | Font Family | Weight | Size |
|---|---|---|---|
| **App Title** | Outfit | Bold (700) | 22sp |
| **Section Headers** | Outfit | SemiBold (600) | 18sp |
| **Body Text (English)** | Outfit | Regular (400) | 14sp |
| **Body Text (Amharic)** | Noto Sans Ethiopic | Regular (400) | 14sp |
| **Captions & Labels** | Outfit | Medium (500) | 12sp |
| **Stat Values** | Outfit | Bold (700) | 28sp |

## Spacing Scale

| Token | Value | Usage |
|---|---|---|
| `xs` | 4dp | Icon padding, inline gaps |
| `sm` | 8dp | Card internal padding |
| `md` | 16dp | Section spacing |
| `lg` | 24dp | Screen edge padding |
| `xl` | 32dp | Between major sections |

## Corner Radius

| Token | Value | Usage |
|---|---|---|
| `radius-sm` | 8dp | Buttons, badges, chips |
| `radius-md` | 12dp | Cards, panels |
| `radius-lg` | 16dp | Modal sheets, hero cards |
| `radius-full` | 999dp | Avatars, circular indicators |

## Component Library

### Hazard Severity Badges
| Severity | Background | Text Color | Label |
|---|---|---|---|
| CRITICAL | `#FEE2E2` | `#991B1B` | "CRITICAL" |
| HIGH | `#FFEDD5` | `#9A3412` | "HIGH" |
| MODERATE | `#FEF9C3` | `#854D0E` | "MODERATE" |
| LOW | `#DCFCE7` | `#166534` | "LOW" |

### Status Pills
| Status | Background | Text Color |
|---|---|---|
| Dispatched | `#DCFCE7` | `#166534` |
| Pending | `#FEE2E2` | `#991B1B` |
| Monitoring | `#F3F4F6` | `#4B5563` |

### Card Shadows
| Level | CSS Box Shadow |
|---|---|
| Elevation 1 | `0 1px 3px rgba(0,0,0,0.06)` |
| Elevation 2 | `0 4px 6px -1px rgba(0,0,0,0.08)` |
| Elevation 3 | `0 10px 15px -3px rgba(0,0,0,0.1)` |

## Accessibility

- **Minimum touch target**: 48×48dp (Material Design guideline)
- **Color contrast ratio**: >= 4.5:1 for text on backgrounds
- **Amharic Ethiopic script**: Always rendered with Noto Sans Ethiopic for clarity
- **Screen reader labels**: All interactive elements must have semantic labels
- **Offline indicators**: Subtle banner when device is offline, not blocking UI

## Animation Guidelines

| Interaction | Duration | Curve |
|---|---|---|
| Page transitions | 300ms | `Curves.easeInOut` |
| Card expand/collapse | 250ms | `Curves.fastOutSlowIn` |
| Loading shimmer | 1500ms loop | Linear |
| Gauge needle rotation | 800ms | `Curves.elasticOut` |
| Pull-to-refresh | 500ms | `Curves.decelerate` |
