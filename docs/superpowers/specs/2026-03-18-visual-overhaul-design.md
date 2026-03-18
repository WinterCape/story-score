# StoryScore Visual Overhaul — Design Spec

## Direction
**Warm Storybook — Rich & Dramatic.** Transform the app from a cold, corporate utility into a warm, magical game companion that feels like opening a fairy tale book by candlelight.

## Core Problem
The app is for storytelling card games (imaginative, social, playful) but the UI feels like a task management app (efficient, serious, corporate). Muted colors, flat surfaces, no decorative elements, minimal animations.

## Color Palette

### Dark Theme (Primary)
| Token | Hex | Name | Usage |
|-------|-----|------|-------|
| darkBackground | `#0F0A1A` | Ink night | Main scaffold background |
| darkSurface | `#1E1233` | Rich plum | Elevated surfaces |
| darkCard | `#2E1A4A` | Velvet violet | Cards, sheets, dialogs |
| darkCardVariant | `#3A2060` | Deep amethyst | Card gradient end |
| goldAccent | `#E8A020` | Rich amber | Primary accent, CTAs, highlights |
| burgundy | `#A01845` | Deep wine | Secondary accent, storyteller |
| dustyRose | `#D4758A` | Vivid rose | Tertiary, labels, subtitles |
| parchment | `#F5E0B8` | Warm cream | Primary text on dark |
| mutedText | `#B89AAA` | Lavender mist | Secondary text |
| teal | `#1A8585` | Emerald pool | Player color, success states |
| violet | `#7B50C8` | Royal violet | Player color, accents |

### Light Theme
| Token | Hex | Name | Usage |
|-------|-----|------|-------|
| lightBackground | `#FBF0DD` | Warm linen | Main scaffold |
| lightSurface | `#F5E0B8` | Parchment | Elevated surfaces |
| lightCard | `#FFFFFF` | White | Cards |
| lightPrimary | `#A01845` | Deep wine | Primary actions |
| lightOnSurface | `#6B3A1A` | Warm brown | Body text |
| lightOnSurfaceVar | `#8B6A5A` | Faded brown | Secondary text |
| lightCardBorder | `#E8D0A0` | Tan | Card borders |

### Gradients
| Name | Definition | Usage |
|------|-----------|-------|
| mainSurface | `linear(135deg, #0F0A1A → #1E1233 → #2E1A4A)` | Screen backgrounds |
| warmGlow | `linear(180deg, #0F0A1A → #1E1233, amber hint at 300%)` | Home, endgame |
| accentGradient | `linear(135deg, #A01845 → #E8A020)` | Buttons, FABs, banners |
| cardGradient | `linear(135deg, #2E1A4A → #3A2060)` | Card backgrounds |
| parchmentGradient | `linear(135deg, #FBF0DD → #F5E0B8 → #E8D0A0)` | Light theme surfaces |
| goldDivider | `linear(90deg, transparent → #E8A020 → transparent)` | Ornate dividers |

## Decorative Elements

### Card Shapes
- Session cards on home screen include a mini card-shaped icon (parchment bg, gold border, emoji inside)
- Active sessions: gold border glow on the card icon
- Completed sessions: muted card icon with trophy emoji

### Sparkle Particles
- Subtle star characters (`★`, `✦`) scattered on backgrounds at low opacity (0.1-0.2)
- Gold and rose colors
- Static positioning (not animated) for performance
- 3-5 per screen, randomized but deterministic positions

### Ornate Dividers
- Gold gradient line (`transparent → #E8A020 → transparent`)
- Used between sections on endgame, premium, onboarding screens
- Width: 120px, centered

### Player Avatars
- Circle with gradient background matching player color
- Emoji centered inside
- Subtle border (2px) in slightly lighter shade
- Optional glow shadow for storyteller

## Screen Changes

### All Screens
- Background: gradient (`mainSurface`) instead of flat color
- Cards: `cardGradient` background with subtle border (`rgba(E8A020, 0.15)` for active, `rgba(FFF, 0.04)` for inactive)
- Card shadows: `0 4px 15px rgba(0,0,0,0.3)` for depth
- Card border-radius: 14px (up from 8-12)
- Section headers: gold color, uppercase, letter-spacing 1.5px, weight 700
- Text colors: parchment for primary, dusty rose for labels, lavender mist for secondary
- App bar: gradient background with gold border-bottom at 0.1 opacity

### Home Screen
- "StoryScore" title in gold, bold, with warm subtitle
- Quick Start banner: full-width gradient card (burgundy → gold) with emoji and arrow
- Session cards: include card-shaped game icon (parchment mini-card with emoji), player avatar bubbles row
- Active sessions: gold border accent on card icon
- FAB: extended with "New Game" text, gradient background

### Scoreboard
- Round info header: card with gold "ROUND N" label, storyteller name, crown emoji card icon
- Player score cards: gradient backgrounds, emoji avatars in gradient circles with borders
- Storyteller card: gold border (1.5px, 0.4 opacity), gold glow shadow
- Score numbers: gold color for 1st place, parchment for others
- Rank labels: dusty rose
- FAB: gradient (burgundy → gold)

### Vote Entry (Round Screen)
- Storyteller announcement: centered card with crown emoji, gold round label
- Per-voter sections: voter avatar + name + "voted for:" label
- Vote targets: tappable chips with emoji + name
- Selected vote: gold background highlight (`rgba(E8A020, 0.15)`), gold border
- Unselected: subtle transparent background
- Waiting state: dashed border
- Score Round button: gradient, disabled state at 0.5 opacity with "N votes remaining"

### Endgame Screen
- Sparkle particles at multiple positions
- Trophy with radial gold glow behind it
- Winner announcement: gold "WINNER" label, parchment name, large gold score
- Ornate gold gradient divider
- Standings: winner row highlighted with gold gradient background, others plain
- Each standing has rank number, avatar, name, score
- Action buttons: "New Game" gradient, "Share" outlined with gold border

### Onboarding
- Hero: 3 fanned card shapes (parchment background, gold border, emoji) rotated -10°/0°/+10°
- Center card slightly larger with stronger shadow
- Title: gold "StoryScore" with rose subtitle
- Feature list: warm gradient icon tiles (40x40, rounded 12px) with gold border
- Page dots: gold filled for active, gold at 0.3 opacity for inactive
- CTA: gradient button (burgundy → gold)

### Settings
- Section headers: gold uppercase labels
- List tiles: parchment text, lavender mist subtitles
- Switches: gold track color when on
- Theme picker swatches: warm border, gold check on selected

### Round Recap Sheet
- "Good Clue" / "Bad Clue" with gold/rose colors
- Per-player score deltas in warm styled rows
- Ornate divider above total

### Round History
- Round tiles: card gradient background, gold round number circle
- Storyteller name in parchment, good/bad clue icon in gold/rose

### Premium Screen
- Hero gradient background (warm glow)
- Feature list with warm icon tiles
- Gold "Get Supporter Pack" button
- Price shown in parchment

### Empty States
- Larger emoji (48px) with gold glow filter
- Warm parchment title text
- Rose subtitle
- Gradient CTA button

## Typography Updates
- Keep Nunito font family
- Title weight: 800 (up from 600-700)
- Section headers: 10-11px, uppercase, letter-spacing 1.5-2px, gold color
- Score displays: gold color for leaders, parchment for others, text-shadow glow
- Body: parchment (#F5E0B8) on dark, warm brown (#6B3A1A) on light

## Testing
- Visual regression: update golden tests for new colors
- Accessibility: verify contrast ratios for new palette (parchment on velvet violet ≥ 4.5:1)
- Both themes: ensure light theme also feels warm (parchment backgrounds, not cold white)
- Reduced motion: sparkle particles are static, no impact
