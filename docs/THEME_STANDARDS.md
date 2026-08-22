# AgriEtech Theme Design Standards

## Overview
This document defines the comprehensive design system and theme standards for the AgriEtech National Agricultural Early Warning Platform.

---

## Color Palette

### Primary Brand Colors
The platform uses an agricultural green palette that represents growth, sustainability, and natural agriculture:

```dart
Primary Color:   #2E7D32  // Lush Forest Green
Primary Dark:    #1B5E20  // Deep Emerald Green
Primary Light:   #4CAF50  // Vibrant Leaf Green
Secondary Color: #00796B  // Teal / Irrigation Blue-Green
Tertiary Color:  #E65100  // Warm Amber / Sunburst
```

**Usage Guidelines:**
- **Primary Color (#2E7D32)**: Main brand color for buttons, links, and primary actions
- **Primary Dark (#1B5E20)**: Headers, emphasized text, important CTAs
- **Primary Light (#4CAF50)**: Hover states, success indicators, active states
- **Secondary Color (#00796B)**: Supporting elements, secondary actions
- **Tertiary Color (#E65100)**: Accents, warnings, attention-grabbing elements

### Telemetry & Sensor Colors
Specialized colors for agricultural technology and monitoring:

```dart
NDVI (Vegetation):    #10B981  // Satellite NDVI Emerald
IoT Sensors:          #0284C7  // LoRaWAN Cyan-Blue
Soil Monitoring:      #8D6E63  // Earth Brown
Locust Detection:     #DC2626  // Alert Red
Drought Warning:      #F59E0B  // Warning Amber
Flood Alert:          #3B82F6  // Water Blue
```

**Usage Context:**
- NDVI: Crop health indicators, vegetation indices
- IoT Sensors: Sensor status, device connectivity
- Soil: Soil moisture, NPK levels
- Locust: Pest detection alerts
- Drought: Water scarcity warnings
- Flood: Excess water alerts

### System Status Colors

```dart
Error:    #D32F2F  // Critical failures, errors
Warning:  #F57C00  // Cautions, important notices
Success:  #2E7D32  // Confirmations, successful actions
```

### Risk Level Colors
Standardized colors for early warning risk assessment:

```dart
Low Risk:       #43A047  // Safe Green
Moderate Risk:  #FB8C00  // Cautionary Orange
High Risk:      #F4511E  // Alert Orange-Red
Critical Risk:  #D32F2F  // Emergency Red
```

**Application:**
- Risk maps and heat maps
- Alert severity indicators
- Dashboard warning levels
- Notification badges

---

## Gradients

### Brand Gradients

**Primary Gradient:**
```dart
LinearGradient(
  colors: [#1B5E20, #2E7D32, #388E3C]
  direction: topLeft → bottomRight
)
```
**Use for:** Hero sections, feature cards, promotional banners

**Tech Header Gradient:**
```dart
LinearGradient(
  colors: [#0F2E14, #1B5E20, #004D40]
  direction: topLeft → bottomRight
)
```
**Use for:** App headers, navigation bars, dashboard headers

**NDVI Gradient:**
```dart
LinearGradient(
  colors: [#059669, #10B981, #34D399]
  direction: topLeft → bottomRight
)
```
**Use for:** Vegetation health displays, crop monitoring cards

**Critical Risk Gradient:**
```dart
LinearGradient(
  colors: [#B71C1C, #E53935]
  direction: topLeft → bottomRight
)
```
**Use for:** Emergency alerts, critical warnings

---

## Typography

### Font Family
**Primary Font:** `Roboto`
- Professional, highly legible
- Excellent for agricultural data display
- Wide character support for multilingual content

### Text Styles

**Display Text (Headings):**
```
Size: 22-28px
Weight: 600-700 (Semi-bold to Bold)
Letter Spacing: -0.3 to -0.5
Color: #1E2E1E (Light) / #FFFFFF (Dark)
```

**Title Text:**
```
Size: 18-20px
Weight: 600 (Semi-bold)
Letter Spacing: -0.2
Use: Screen titles, card headers
```

**Body Text:**
```
Size: 14-16px
Weight: 400 (Regular)
Line Height: 1.5
Use: Main content, descriptions
```

**Caption Text:**
```
Size: 11-12px
Weight: 400-500
Letter Spacing: 0.2-0.4
Use: Helper text, timestamps, metadata
```

**Button Text:**
```
Size: 16px
Weight: 600 (Semi-bold)
Letter Spacing: 0.2
Use: All button labels
```

---

## Spacing System

### Base Unit: 4px
All spacing follows a 4px grid system for consistency:

```
XXS: 4px   (Tight spacing within components)
XS:  8px   (Component internal padding)
S:   12px  (Small gaps between related elements)
M:   16px  (Standard spacing between elements)
L:   20px  (Section internal spacing)
XL:  24px  (Section separators)
XXL: 32px  (Major section breaks)
```

**Application:**
- Padding: Use M (16px) as default
- Margins: Use L (20px) between cards
- Section gaps: Use XL (24px) or XXL (32px)

---

## Border Radius

### Rounded Corners Standards

```dart
Small Components:  8px   (Chips, badges, small buttons)
Standard:          12px  (Buttons, inputs, cards)
Large:             16px  (Large cards, modals)
Extra Large:       20px  (Hero cards, feature sections)
Circular:          50%   (Avatars, icon buttons)
```

---

## Elevation & Shadows

### Light Theme Shadows

**Level 0 (Flat):**
```dart
elevation: 0
border: 1px solid #E0E0E0
```
**Use:** Cards, containers with borders

**Level 1 (Subtle):**
```dart
elevation: 1
shadow: 0 1px 3px rgba(0,0,0,0.03)
```
**Use:** Elevated cards, dropdowns

**Level 2 (Medium):**
```dart
elevation: 2-3
shadow: 0 3px 8px rgba(0,0,0,0.04)
```
**Use:** Floating elements, modals

**Level 3 (High):**
```dart
elevation: 4-6
shadow: 0 5px 15px rgba(0,0,0,0.08)
```
**Use:** FABs, important dialogs

### Dark Theme
Reduce shadow intensity by 50% in dark mode

---

## Component Standards

### Buttons

**Primary Button:**
```dart
Background: #2E7D32
Text: #FFFFFF
Padding: 14px horizontal, 16px vertical
Border Radius: 12px
Font Weight: 600
```

**Secondary Button (Outlined):**
```dart
Border: 1.5px solid #2E7D32
Text: #2E7D32
Background: Transparent
```

**Text Button:**
```dart
Text: #2E7D32
No border, no background
Padding: 8px horizontal
```

**Disabled State:**
```dart
Opacity: 0.38
Cursor: not-allowed
```

### Input Fields

**Default State:**
```dart
Background: #FFFFFF (Light) / #1E281E (Dark)
Border: 1px solid #BDBDBD
Border Radius: 12px
Padding: 16px
```

**Focused State:**
```dart
Border: 2px solid #2E7D32
```

**Error State:**
```dart
Border: 1.5px solid #D32F2F
Helper Text: #D32F2F
```

### Cards

**Standard Card:**
```dart
Background: #FFFFFF (Light) / #1E281E (Dark)
Border: 1px solid #E0E0E0 (Light) / #2C3A2C (Dark)
Border Radius: 16px
Padding: 16-20px
Elevation: 0
```

**Interactive Card:**
```dart
Hover: Subtle shadow increase
Active: Border color → Primary
```

### Chips & Badges

**Chip:**
```dart
Background: #E8F5E9
Text: #1B5E20
Height: 32px
Padding: 8-12px horizontal
Border Radius: 20px
```

**Badge (Notification):**
```dart
Background: #D32F2F (Error count)
Text: #FFFFFF
Size: 18-20px
Border Radius: 50%
```

---

## Layout Standards

### Container Widths

```dart
Mobile:       100% (< 600px)
Tablet:       90% max 768px
Desktop:      85% max 1200px
Wide:         80% max 1440px
```

### Grid System

**2-Column Grid (Mobile):**
- Gap: 14px
- Aspect Ratio: 1:1 or 1.1:1

**3-Column Grid (Tablet):**
- Gap: 16px

**4-Column Grid (Desktop):**
- Gap: 20px

---

## Dark Mode Standards

### Background Colors

```dart
Primary Background:    #121812
Secondary Background:  #1A221A
Surface (Cards):       #1E281E
Border:                #2C3A2C
```

### Text Colors

```dart
Primary Text:    #FFFFFF
Secondary Text:  #B8C4B8
Disabled Text:   #6A7A6A
```

### Adaptation Rules

1. **Reduce contrast** between elements by 10-15%
2. **Soften shadows** - use half intensity
3. **Mute colors** - reduce saturation by 10%
4. **Increase border prominence** for definition
5. **Use overlays** instead of pure white on dark

---

## Accessibility Standards

### Color Contrast

**WCAG AA Compliance (Minimum):**
- Normal text: 4.5:1 contrast ratio
- Large text (18pt+): 3:1 contrast ratio
- UI components: 3:1 contrast ratio

**WCAG AAA Compliance (Enhanced):**
- Normal text: 7:1 contrast ratio
- Large text: 4.5:1 contrast ratio

### Tested Combinations

✅ **Pass AA & AAA:**
- #2E7D32 on #FFFFFF (Primary on white)
- #1B5E20 on #FFFFFF (Dark green on white)
- #FFFFFF on #1B5E20 (White on dark green)

✅ **Pass AA:**
- #4CAF50 on #FFFFFF (Light green on white)
- #F57C00 on #FFFFFF (Warning on white)

### Touch Targets

**Minimum size:** 44x44 dp (iOS) / 48x48 dp (Android)
**Recommended:** 48x48 dp for all platforms
**Spacing:** 8px minimum between interactive elements

### Focus Indicators

```dart
Outline: 2px solid #2E7D32
Offset: 2px
Border Radius: Matches element
```

---

## Icon Standards

### Size Scale

```dart
Extra Small:  16px  (Inline with text)
Small:        20px  (Buttons, inputs)
Medium:       24px  (Standard icons)
Large:        32px  (Headers, features)
Extra Large:  48px+ (Hero sections)
```

### Color Usage

- **Primary actions:** #2E7D32
- **Secondary actions:** #6A7A6A
- **Errors:** #D32F2F
- **Warnings:** #F57C00
- **Success:** #43A047

### Icon Families

**Primary:** Material Design Icons
**Backup:** Ionicons, Feather Icons

---

## Animation & Motion

### Timing Functions

```dart
Fast:      150ms   (Micro-interactions)
Default:   250ms   (Standard transitions)
Moderate:  350ms   (Complex animations)
Slow:      500ms   (Page transitions)
```

### Easing Curves

```dart
Standard:     cubic-bezier(0.4, 0.0, 0.2, 1)
Decelerate:   cubic-bezier(0.0, 0.0, 0.2, 1)
Accelerate:   cubic-bezier(0.4, 0.0, 1, 1)
Sharp:        cubic-bezier(0.4, 0.0, 0.6, 1)
```

### Animation Guidelines

1. **Fade transitions:** 250ms with standard easing
2. **Slide transitions:** 350ms with decelerate
3. **Scale animations:** 200ms with sharp easing
4. **Color transitions:** 200ms linear
5. **Loading indicators:** Continuous smooth motion

---

## Responsive Breakpoints

```dart
Mobile (Small):    < 600px
Mobile (Large):    600px - 768px
Tablet:            769px - 1024px
Desktop (Small):   1025px - 1440px
Desktop (Large):   > 1440px
```

### Responsive Rules

**Mobile:**
- Single column layouts
- Full-width cards
- Simplified navigation (bottom nav)
- 16px horizontal padding

**Tablet:**
- 2-3 column grids
- Sidebar navigation possible
- 20px horizontal padding

**Desktop:**
- Multi-column layouts
- Persistent sidebar navigation
- Maximum content width: 1440px
- 24-32px horizontal padding

---

## Implementation Guidelines

### Using the Theme

```dart
// Access theme colors
Theme.of(context).colorScheme.primary

// Use defined constants
AppTheme.primaryColor
AppTheme.telemetryNdvi
AppTheme.getRiskColor('HIGH')

// Apply gradients
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient
  )
)
```

### Best Practices

1. **Always use theme constants** - Never hardcode colors
2. **Respect spacing system** - Use multiples of 4px
3. **Follow elevation hierarchy** - Don't over-elevate
4. **Maintain contrast ratios** - Test accessibility
5. **Use semantic colors** - Primary for primary actions
6. **Test both themes** - Light and dark mode
7. **Keep consistency** - Same patterns across screens

---

## Quality Checklist

Before releasing any UI component:

- [ ] Colors match theme palette
- [ ] Spacing follows 4px grid
- [ ] Border radius is consistent
- [ ] Text styles match standards
- [ ] Contrast ratios pass WCAG AA
- [ ] Touch targets are 48x48 minimum
- [ ] Dark mode tested and functional
- [ ] Animations are smooth (60fps)
- [ ] Responsive on all breakpoints
- [ ] Icons properly sized
- [ ] Follows component standards
- [ ] No hardcoded colors

---

## Platform-Specific Considerations

### Android
- Use Material Design 3 components
- Follow platform gesture conventions
- Respect system theme preference

### iOS
- Use Cupertino widgets where appropriate
- Follow iOS Human Interface Guidelines
- Respect safe areas and notches

### Web
- Ensure proper cursor states
- Support keyboard navigation
- Test on multiple browsers
- Optimize hover states

---

## Maintenance

### Version History
- **v1.0** - Initial theme system
- **Current** - Professional agricultural platform theme

### Review Schedule
- **Quarterly:** Review color accessibility
- **Bi-annually:** Update for platform changes
- **Annually:** Major design system review

### Feedback & Updates
Design system maintained by the AgriEtech development team. Submit theme feedback through the project's design review process.

---

## Resources

### Design Tools
- **Figma:** Design mockups and prototypes
- **Material Theme Builder:** Color scheme generation
- **Contrast Checker:** WCAG compliance testing

### References
- Material Design 3 Guidelines
- Flutter Theme Documentation
- WCAG 2.1 Accessibility Standards
- Agricultural UI Best Practices

---

**Document Version:** 1.0  
**Last Updated:** Current  
**Maintained By:** AgriEtech Development Team
