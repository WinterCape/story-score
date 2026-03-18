# StoryScore design handoff

This package contains a complete visual kit for the StoryScore mobile app:
- original PNG assets for icon, splash, textures, illustrations, decorative pieces, icons, premium visuals, and state badges
- 32 mobile mockups (dark + light)
- design tokens and screen specs for Flutter implementation

## Visual direction
Enchanted storybook, painterly warmth, illuminated gold ornament, mysterious but cozy. The dark theme is the hero theme for dim-table play.

## Fonts
Recommended production fonts:
- Display: Cormorant Garamond or EB Garamond
- UI: Nunito
Fallback used in rendered mockups: EB Garamond + Inter

## Accessibility
Key contrast ratios:
{
  "dark_text_on_bg": 15.05,
  "dark_text_on_card": 11.91,
  "muted_on_bg": 7.64,
  "gold_on_dark": 7.97,
  "light_text_on_bg": 8.29,
  "light_text_on_card": 9.35,
  "primary_on_light": 6.86
}

## Flutter implementation notes
- Use the supplied PNG textures as subtle overlays at low opacity.
- Prefer gradients for CTA surfaces rather than flat fills in the dark theme.
- Keep all touch targets at least 44x44.
- Use gold only as accent or achievement color; primary readable text should stay parchment/brown.
- For locked premium charts, combine the chart scaffold with `decorative/lock_badge.png`.
- Mockups are designed at 390x844 and scale cleanly to tablets when centered in a max-width layout.

## Files
- `design_tokens.json`: palette, typography, spacing, motion, component rules
- `screen_specs.json`: per-screen layout blocks and state notes
