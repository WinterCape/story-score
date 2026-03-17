# StoryScore Design System

## Color Tokens

All colors are defined in `lib/app/theme/color_tokens.dart` as static constants.

### Dark Palette (Default)

| Token | Hex | Usage |
|---|---|---|
| `darkBackground` | `#1A1025` | Scaffold background |
| `darkSurface` | `#241735` | Card / elevated surface |
| `darkSurfaceVariant` | `#2D2040` | Secondary surface, containers |
| `midnightBlue` | `#0D1B2A` | Secondary container |
| `goldAccent` | `#D4A742` | Highlights, premium badge, tertiary |
| `goldAccentLight` | `#E8C876` | On-tertiary-container text |
| `auroraTeal` | `#2EC4B6` | Positive actions, secondary |
| `softViolet` | `#7B68EE` | Primary, decorative elements |
| `auroraGreen` | `#4ADE80` | Success states |
| `coralAccent` | `#FF6B6B` | Error, destructive actions |
| `darkOnSurface` | `#E8E0F0` | Primary text on dark |
| `darkOnSurfaceVariant` | `#B8A8CC` | Secondary text on dark |

### Light Palette

| Token | Hex | Usage |
|---|---|---|
| `lightBackground` | `#FDF8F0` | Scaffold background (warm parchment) |
| `lightSurface` | `#FFFFFF` | Card surface |
| `lightSurfaceVariant` | `#F0E8F5` | Secondary surface |
| `lightPrimary` | `#5B3E96` | Primary actions |
| `lightGoldAccent` | `#B8912E` | Tertiary / highlights |
| `lightOnSurface` | `#1A1025` | Primary text on light |
| `lightOnSurfaceVariant` | `#5A4A6E` | Secondary text on light |

### Gradients

Defined in `StoryScoreThemeExtension`:

- **Aurora gradient**: `auroraTeal -> softViolet -> goldAccent` (top-left to bottom-right). Used for decorative headers and emphasis.
- **Card gradient**: `darkSurface -> darkSurfaceVariant` (dark) or `lightSurface -> lightSurfaceVariant` (light). Applied to elevated card surfaces.

## Typography

**Font family**: Nunito (variable weight, bundled in `assets/fonts/Nunito-Variable.ttf`).

Defined in `lib/app/theme/text_tokens.dart`.

### Weight Scale

| Token | Weight |
|---|---|
| `light` | w300 |
| `regular` | w400 |
| `medium` | w500 |
| `semiBold` | w600 |
| `bold` | w700 |
| `extraBold` | w800 |

### Type Scale

| Style | Size | Weight | Letter Spacing | Line Height |
|---|---|---|---|---|
| `displayLarge` | 57 | bold | -0.25 | 1.12 |
| `displayMedium` | 45 | bold | 0 | 1.16 |
| `displaySmall` | 36 | semiBold | 0 | 1.22 |
| `headlineLarge` | 32 | semiBold | 0 | 1.25 |
| `headlineMedium` | 28 | semiBold | 0 | 1.29 |
| `headlineSmall` | 24 | semiBold | 0 | 1.33 |
| `titleLarge` | 22 | semiBold | 0 | 1.27 |
| `titleMedium` | 16 | semiBold | 0.15 | 1.50 |
| `titleSmall` | 14 | semiBold | 0.1 | 1.43 |
| `bodyLarge` | 16 | regular | 0.5 | 1.50 |
| `bodyMedium` | 14 | regular | 0.25 | 1.43 |
| `bodySmall` | 12 | regular | 0.4 | 1.33 |
| `labelLarge` | 14 | medium | 0.1 | 1.43 |
| `labelMedium` | 12 | medium | 0.5 | 1.33 |
| `labelSmall` | 11 | medium | 0.5 | 1.45 |

### Score-Specific Styles

| Style | Size | Weight | Use |
|---|---|---|---|
| `scoreDisplay` | 72 | extraBold | Main score counter |
| `scoreMedium` | 40 | bold | Score in list cards |
| `scoreSmall` | 24 | bold | Inline score values |

## Spacing + Corner Radius

Defined in `lib/app/theme/spacing_tokens.dart`.

### Spacing Scale

| Token | Value |
|---|---|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 16 |
| `lg` | 24 |
| `xl` | 32 |
| `xxl` | 48 |

### Corner Radius Scale

| Token | Value | Usage |
|---|---|---|
| `radiusSm` | 8 | Small chips, badges |
| `radiusMd` | 12 | Buttons, inputs |
| `radiusLg` | 16 | Cards |
| `radiusXl` | 24 | Bottom sheets |

## Motion Tokens

Defined in `lib/app/theme/motion_tokens.dart`.

### Durations

| Token | ms | Usage |
|---|---|---|
| `durationFast` | 150 | Button press, checkbox toggle |
| `durationMedium` | 300 | Card expand, bottom-sheet slide |
| `durationSlow` | 500 | Page transitions, large layout shifts |
| `durationEmphasis` | 800 | Confetti, score milestone celebration |

### Curves

| Token | Curve | Usage |
|---|---|---|
| `curveStandard` | `easeInOut` | Default transitions |
| `curveDecelerate` | `easeOut` | Elements entering screen |
| `curveAccelerate` | `easeIn` | Elements leaving screen |
| `curveEmphasized` | `easeInOutCubicEmphasized` | Large/dramatic motion |
| `curveBounce` | `elasticOut` | Playful feedback (score increment) |
| `curveSpring` | `easeOutBack` | Snappy overshoot interactions |

## Player Colors

12 distinct hues for player assignment, designed for contrast in both themes. Defined in `ColorTokens.playerColors` and `PlayerColors.all`.

| Name | Hex | Swatch |
|---|---|---|
| `aurora_teal` | `#2EC4B6` | Teal |
| `soft_violet` | `#7B68EE` | Violet |
| `gold` | `#D4A742` | Gold |
| `coral` | `#FF6B6B` | Coral |
| `emerald` | `#2DD4BF` | Emerald |
| `ocean_blue` | `#3B82F6` | Blue |
| `sunset_orange` | `#FB923C` | Orange |
| `rose_pink` | `#F472B6` | Pink |
| `lime_green` | `#A3E635` | Lime |
| `slate_blue` | `#64748B` | Slate |
| `amber` | `#F59E0B` | Amber |
| `plum` | `#A855F7` | Plum |

Auto-assignment uses `PlayerColors.nextAvailable(usedKeys)` to pick the next unused color in order.

## Component Patterns

### Cards
- `CardTheme`: 0 elevation, `radiusLg` (16) corners, `surfaceContainerHighest` fill.
- Gradient cards use `StoryScoreThemeExtension.cardGradient` as a `Container` decoration.

### Buttons
- **FilledButton**: `labelLarge` text, `radiusMd` (12) corners.
- **OutlinedButton**: Same shape, outline only.

### Inputs
- Filled style, `surfaceContainerHighest` fill, `radiusMd` corners, no visible border.
- Content padding: 16 horizontal, 12 vertical.

### Bottom Sheets
- Surface color background, `radiusXl` (24) top corners.

### App Bar
- No elevation, no scroll shadow, center-aligned title, surface background.

### Theme Extension Access
```dart
final gold = Theme.of(context).storyScore.goldAccent;
final gradient = Theme.of(context).storyScore.auroraGradient;
```
