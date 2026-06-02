---
name: Obsidian Flux
colors:
  surface: '#10131a'
  surface-dim: '#10131a'
  surface-bright: '#363940'
  surface-container-lowest: '#0b0e14'
  surface-container-low: '#191c22'
  surface-container: '#1d2026'
  surface-container-high: '#272a31'
  surface-container-highest: '#32353c'
  on-surface: '#e1e2eb'
  on-surface-variant: '#c2c6d6'
  inverse-surface: '#e1e2eb'
  inverse-on-surface: '#2e3037'
  outline: '#8c909f'
  outline-variant: '#424754'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e6a'
  primary-container: '#4d8eff'
  on-primary-container: '#00285d'
  inverse-primary: '#005ac2'
  secondary: '#4edea3'
  on-secondary: '#003824'
  secondary-container: '#00a572'
  on-secondary-container: '#00311f'
  tertiary: '#ffb3ad'
  on-tertiary: '#68000a'
  tertiary-container: '#ff5451'
  on-tertiary-container: '#5c0008'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ad'
  on-tertiary-fixed: '#410004'
  on-tertiary-fixed-variant: '#930013'
  background: '#10131a'
  on-background: '#e1e2eb'
  surface-variant: '#32353c'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  data-mono:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-caps:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 24px
  gutter: 16px
  component-gap-dense: 8px
  component-gap-normal: 16px
---

## Brand & Style

The design system is engineered for high-stakes Network Operations Center (NOC) environments where cognitive load management and rapid data synthesis are critical. The brand personality is **Technical, High-Performance, and Authoritative**, reflecting the stability required for enterprise ISP infrastructure.

The aesthetic utilizes **Modern Glassmorphism** layered over a **Minimalist Dark** foundation. This approach ensures that while the interface feels cutting-edge and immersive, it maintains the functional rigor of tools like Datadog or Cisco ThousandEyes. The emotional response should be one of "calm control"—even during network outages, the UI remains structured, legible, and clear. 

Key stylistic pillars:
- **Depth through Translucency:** Frosted glass surfaces (Backdrop Blur) differentiate active monitoring panels from the system background.
- **Precision Borders:** 1px hairline strokes define boundaries without adding visual bulk.
- **High-Signal Contrast:** Vibrant status indicators are set against muted, dark surfaces to ensure critical alerts are immediately identifiable.

## Colors

The palette is optimized for low-light NOC environments to reduce eye strain during long shifts. 

- **Foundational Neutrals:** The base is a deep `#0B0E14` charcoal. Secondary surfaces use Slate shades with varying opacities to create a sense of hierarchy through "elevation by luminance."
- **Functional Accents:** The Primary Blue (`#3B82F6`) is reserved for interactive states and primary actions.
- **Semantic Logic:** Status colors follow industry standards (Green/Yellow/Red) but are tuned to high-vibrancy levels to pierce through the dark background. 
- **Glass Effects:** Use `rgba` values for panel backgrounds to allow subtle bleed-through of background gradients or map data, enhancing the "Glassmorphism" effect.

## Typography

This design system prioritizes **information density** and **legibility**. 

- **Primary Typeface:** *Inter* is used for all UI elements due to its exceptional tall x-height and readability in small sizes.
- **Technical Typeface:** *JetBrains Mono* is employed for IP addresses, MAC addresses, throughput values, and timestamps. This ensures numeric data is easy to scan and compare vertically in tables.
- **Scale:** Sizes are kept compact. The `body-sm` (13px) is the workhorse for dense data tables.
- **Hierarchy:** Use `label-caps` for metadata headers and `display-lg` exclusively for high-level aggregate metrics (e.g., Total Network Throughput).

## Layout & Spacing

The layout model utilizes a **Fluid Grid** optimized for multi-monitor NOC setups. 

- **Grid:** A 12-column system with 16px gutters. In "Dashboard Mode," panels should snap to grid increments to maintain perfect alignment.
- **Density:** We utilize a "Compact-First" approach. Padding inside cards should be 16px, while vertical spacing between list items in a data table should be restricted to 8px.
- **Responsiveness:** 
  - **Ultrawide:** Panels expand to show additional telemetry columns.
  - **Desktop/Tablet:** Panels stack or hide secondary metrics in favor of sparklines.
  - **Mobile:** Critical alerts only; full-width cards with simplified "Status + Name" views.

## Elevation & Depth

Depth is achieved through **Tonal Layering** and **Glassmorphism** rather than traditional drop shadows.

1.  **Level 0 (Base):** `#0B0E14` (The void).
2.  **Level 1 (Panels):** Semi-transparent `rgba(31, 41, 55, 0.7)` with a `backdrop-filter: blur(12px)`.
3.  **Level 2 (Modals/Popovers):** `rgba(55, 65, 81, 0.9)` with a more intense blur and a 1px border of `rgba(255, 255, 255, 0.1)`.

**Borders:** Use subtle top-lighting on glass panels—a 1px border at 10% white opacity on the top and left, and 5% white on the bottom and right—to simulate a physical glass edge.

## Shapes

The design system uses a **Soft** shape language to balance the "hard" technical data.

- **Standard Radius:** 4px (`0.25rem`) for inputs, buttons, and small widgets.
- **Container Radius:** 8px (`0.5rem`) for glass panels and dashboard cards.
- **Pill:** Used exclusively for status chips (e.g., "Active," "Resolved") and map markers to differentiate them from structural panels.

## Components

### Glassmorphic Cards
Cards are the primary container. They must include a `1px` stroke (Slate-700) and a `12px` backdrop blur. Headers should have a subtle bottom border to separate the title from the telemetry data.

### Data Tables
- **Header:** Uppercase, 11px Inter, Bold, muted text color.
- **Rows:** 40px height for density. Hover state should use a subtle highlight `rgba(255, 255, 255, 0.05)`.
- **Status Indicators:** 8px solid circles or subtle "glow" pips next to device names.

### Data Visualization
- **Sparklines:** Stroke width of 1.5px. Areas under the line should use a 10% opacity gradient of the line color.
- **Gauges:** Semi-circular with segmented tracks. The active segment should have an `outer-glow` effect (drop-shadow with 0 spread and high blur in the primary color).

### Interactive Map Markers
Circular markers with a pulsing animation for "Critical" nodes. Use a higher elevation (Level 2) for markers to ensure they "float" above the map topography.

### Form Inputs
Dark-filled inputs (`#111827`) with a 1px border. On focus, the border transitions to Primary Blue with a subtle `0 0 0 2px rgba(59, 130, 246, 0.3)` outer glow.