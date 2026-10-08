---
name: Pastel Confection
colors:
  surface: '#faf8ff'
  surface-dim: '#d6d9ef'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f2ff'
  surface-container: '#ebedff'
  surface-container-high: '#e4e7fe'
  surface-container-highest: '#dee1f8'
  on-surface: '#171b2b'
  on-surface-variant: '#574147'
  inverse-surface: '#2c3041'
  inverse-on-surface: '#eff0ff'
  outline: '#8b7077'
  outline-variant: '#debec6'
  surface-tint: '#b21d63'
  primary: '#b21d63'
  on-primary: '#ffffff'
  primary-container: '#ff5d9e'
  on-primary-container: '#650034'
  inverse-primary: '#ffb0c8'
  secondary: '#006b5b'
  on-secondary: '#ffffff'
  secondary-container: '#7cf8dd'
  on-secondary-container: '#007261'
  tertiary: '#636036'
  on-tertiary: '#ffffff'
  tertiary-container: '#b1ad7d'
  on-tertiary-container: '#43411a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9e2'
  primary-fixed-dim: '#ffb0c8'
  on-primary-fixed: '#3e001e'
  on-primary-fixed-variant: '#8e004b'
  secondary-fixed: '#7cf8dd'
  secondary-fixed-dim: '#5ddbc1'
  on-secondary-fixed: '#00201a'
  on-secondary-fixed-variant: '#005144'
  tertiary-fixed: '#e9e5b0'
  tertiary-fixed-dim: '#cdc996'
  on-tertiary-fixed: '#1e1c00'
  on-tertiary-fixed-variant: '#4a4821'
  background: '#faf8ff'
  on-background: '#171b2b'
  surface-variant: '#dee1f8'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 18px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  gutter-lg: 1.5rem
  margin: 1.25rem
  margin-mobile: 1rem
  margin-desktop: 2.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.875rem
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style
This design system embodies a sweet, comforting, and playful consumer finance experience. Designed to dissolve financial anxiety, it embraces an approachable candy-pastel aesthetic marked by soft blush washes, tactile pill surfaces, and joyful interactions. 

The visual style blends soft minimalism with warm neo-skeuomorphic comfort:
- **Tone:** Encouraging, warm, uplifting, and cheerful.
- **Visual Personality:** Generous pill geometry, high-legibility dark charcoal type, pastel-tinted containers, and vibrant punchy micro-interactions.
- **Core Distinction:** Soft marshmallow-like elevation, dual-tone pastel metric tracks, and confectionery accents that make daily habit-tracking feel like unwrapping a treat.

## Colors
The palette balances sweet confectionery warmth with clear utility and strong legibility.

### Canvas & Base Backgrounds
- **Primary Canvas Tint:** `#FDF2F4` (softest warm blush pink backdrop).
- **Secondary Surface Tint:** `#FFF0F3` (delicate pastel blush for nested containers and banners).
- **Card Base:** `#FFFFFF` (pure white to provide contrast against tinted backdrops).

### Primary Accents & Hero Actions
- **Bubblegum Rose (`#FF5D9E`):** The primary brand punch. Used for circular Floating Action Buttons (`+`), active tab icons, hero badge accents, and key alert highlights.
- **Candy Teal (`#48C9B0`):** The functional primary CTA color. Used for progress completions, 'Continue' primary buttons, and positive growth actions.

### Pastel Confectionary Token Palette
Used for category tags, budget cards, and customizable theme selections:
- **Mint Green:** Fill `#E2F7EE`, Accent `#34D399`
- **Pastel Pink:** Fill `#FCE6EC`, Accent `#FF5D9E`
- **Baby Blue:** Fill `#E3F2FD`, Accent `#60A5FA`
- **Lavender:** Fill `#F3E8FF`, Accent `#C084FC`
- **Soft Peach:** Fill `#FFE8D6`, Accent `#FB923C`
- **Lemon Yellow:** Fill `#FEF9C3`, Accent `#FACC15`

### Neutral & Typography
- **Text Primary:** `#2D3142` (deep warm charcoal; softer than pure black while maintaining accessible contrast).
- **Text Secondary / Muted:** `#7C829D` (gentle lavender-slate).
- **Dividers & Subdued Tracks:** `#F3EDF0`.

## Typography
The typography relies exclusively on **Plus Jakarta Sans**, chosen for its friendly geometric curves, rounded terminals, and clear legible anatomy.

### Hierarchy & Usage
- **Balance & Currency Figures:** Rendered in `headline-lg` or `headline-xl` with weight `700` or `800` to anchor the dashboard.
- **Section Headers & Month Pills:** Use `headline-sm` with weight `700`, keeping character tracking standard for open readability.
- **Category Labels:** Set in `body-md` with semi-bold weight `600` alongside accompanying emojis.
- **Supporting Annotations & Statuses:** Use `label-md` or `body-sm` in secondary muted slate (`#7C829D`) or category-matched pastels for remaining budget numbers.

## Layout & Spacing
The layout follows a gentle mobile-first fluid model built around an 8px rhythmic grid with 4px half-steps for micro-alignments.

### Rhythms & Boundaries
- **Mobile Margins:** `margin-mobile` (16px) preserves lateral breathing room on compact devices.
- **Vertical Spacing:** Generous card padding (`space-lg`, 20px) gives elements an unhurried, comfortable feel.
- **Stacked Lists:** Transaction rows and category cards separate with `space-sm` (8px) to `space-md` (14px) gaps to prevent sensory clutter.
- **Breakpoints:**
  - *Mobile (< 640px):* Single fluid column, sticky bottom navigation pill, edge-to-edge floating action buttons.
  - *Tablet & Desktop (>= 640px):* Constrained content canvas (max-width: 480px for mobile app emulator, or multi-column dashboard with 24px gutters).

## Elevation & Depth
Elevation in this system replaces harsh dark drops with diffused, blush-tinted ambient glows. Depth reinforces touchability without introducing visual tension.

### Shadow Styles
- **Card Rest Elevation:** `0 6px 20px -4px rgba(235, 140, 168, 0.12), 0 2px 6px -1px rgba(0, 0, 0, 0.02)`. This creates a floating white surface over blush ground.
- **Floating Action Button (Pink FAB):** `0 8px 24px -2px rgba(255, 93, 158, 0.38), 0 3px 8px rgba(255, 93, 158, 0.2)`. Gives the hot pink FAB a bright, glowing presence.
- **CTA Teal Pill Button:** `0 6px 18px -2px rgba(72, 201, 176, 0.35)`.
- **Selected Theme Pill / Card:** Border-based ring using `2px solid #48C9B0` combined with subtle inner glow.

Surfaces do not use sharp 1px borders; separation is achieved by tonal contrast between pure `#FFFFFF` cards and the `#FDF2F4` blush canvas.

## Shapes
The shape language is committed to soft, pill-inspired radii (`level 3`). Circular contours and pill geometry evoke organic comfort and playful touchability.

### Curvature Hierarchy
- **Buttons & Pills:** Full capsule pill radius (`9999px`) for action buttons, segment selectors, and month indicators.
- **Content Cards:** `24px` to `28px` corner radius (`rounded-xl` equivalent in this high-radius setting) for budget cards, metrics panels, and modals.
- **Badges & Category Avatars:** `16px` to `20px` soft squircle or full `9999px` circle for emoji holders.
- **Progress Track Caps:** Fully rounded pill endpoints (`stroke-linecap: round`).

## Components

### Buttons & Interactive Controls
- **Primary Pill CTA ('Continue', '+ Add money'):** Background `#48C9B0`, text `#FFFFFF`, font weight `700`, full pill rounding (`9999px`), internal padding `14px 28px`. Interactive press scale: `transform: scale(0.97)`.
- **Floating Action Button (+):** Fixed circular button (56px x 56px), background `#FF5D9E`, icon color `#FFFFFF` (stroke 2.5px), pill drop shadow tint.
- **Segmented Period Switcher (Day / Week / Month / Year):** Housed in an off-white/blush pill capsule (`#FFF0F3`). Active segment is an elevated pure `#FFFFFF` pill with `#2D3142` text and subtle blush shadow.

### Headers & Month Banners
- **Month Selector Banner:** Full-width rounded card or pill container filled with pastel blush `#FFF0F3`, text centered in `headline-sm` (`#2D3142`). Subdued arrows or tap target for calendar modal.

### Budget & Metric Cards
- **Card Enclosure:** Pure white `#FFFFFF` surface with `24px` corner radii and ambient pink shadow.
- **Progress Bars:** Two-part dual-tone pill tracks:
  - *Track Background:* Light pastel tint (`#E2F7EE` for mint, `#FFE8D6` for peach).
  - *Active Fill:* Saturated counterpart (`#48C9B0` or `#FB923C`), height `8px` to `10px`, with continuous border-radius.
- **Emoji Anchor:** Leading icon in a 40px soft squircle/circle tinted with category pastel tone.

### Theme Pickers & Cards
- **Color Theme Selector:** Grid of soft pastel rounded cards (mint, pink, blue, lavender, peach, lemon). The active option features a crisp `2px solid #48C9B0` ring with a 4px white interior gap.

### Navigation Bar
- **Floating Bottom Bar:** Soft translucent white or blush surface (`rgba(255, 255, 255, 0.95)` with backdrop blur `12px`).
- **Tab Items:** Pastel icons transitioning to active vibrant rose `#FF5D9E` with micro dot indicator underneath.