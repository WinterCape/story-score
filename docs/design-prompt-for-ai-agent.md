# StoryScore — Complete UI/UX Design Brief for AI Design Agent

## YOUR MISSION

Design the complete visual identity and all UI assets for **StoryScore**, a mobile score-tracking companion app for storytelling card games (like Dixit). The app helps players track scores, enter votes, and see who wins — all with a magical, mysterious, storybook atmosphere.

**You are designing for a Flutter mobile app (iOS + Android).** All assets must be exportable as PNG, SVG, or usable as design tokens. The developer will implement your designs in Flutter code.

---

## VISUAL DIRECTION — "Enchanted Storybook"

### Mood & Feeling
Think of the art on storytelling game cards: **mysterious, dreamlike, full of hidden meanings, whimsical, and richly layered.** Every card tells a story. Every image has multiple interpretations. The world is slightly surreal — rabbits float, clocks melt, keys open skies.

The app should feel like:
- Opening an ancient illustrated storybook by candlelight
- A cozy game night where the table feels magical
- A cabinet of curiosities filled with wonder
- Warm, inviting, mysterious but never scary
- Premium and handcrafted, not mass-produced

### Art Style Reference
- **Painterly watercolor** with rich, saturated pigments
- **Golden illuminated manuscript** borders and decorative elements
- **Surrealist storybook illustration** — whimsical, dreamlike scenes
- Soft edges that bleed into backgrounds
- Layered depth with foreground/midground/background
- Tiny hidden details that reward close looking
- Warm lighting as if lit by candles or lanterns

### DO NOT
- Use photorealistic 3D renders
- Use flat/corporate/minimalist style
- Use any copyrighted game artwork
- Make it look childish or cartoonish
- Use harsh, cold, or clinical colors

---

## COLOR PALETTE

### Primary (Dark Theme — the hero theme, designed for table use in dim rooms)

| Role | Hex | Name | Usage |
|------|-----|------|-------|
| Background | `#0F0A1A` | Ink Night | App scaffold, deepest layer |
| Surface | `#1E1233` | Rich Plum | Elevated surfaces, app bar |
| Card | `#2E1A4A` | Velvet Violet | Card backgrounds |
| Card Variant | `#3A2060` | Deep Amethyst | Card gradient end |
| Gold Accent | `#E8A020` | Rich Amber | Primary accent, CTAs, highlights, storyteller |
| Burgundy | `#A01845` | Deep Wine | Secondary accent, buttons |
| Dusty Rose | `#D4758A` | Vivid Rose | Tertiary, labels, badges |
| Parchment | `#F5E0B8` | Warm Cream | Primary text, card faces |
| Muted Text | `#B89AAA` | Lavender Mist | Secondary text, metadata |
| Teal | `#1A8585` | Emerald Pool | Player color, success |
| Violet | `#7B50C8` | Royal Violet | Player color |
| Coral | `#E8785E` | Warm Coral | Errors, warnings |

### Secondary (Light Theme)

| Role | Hex | Name |
|------|-----|------|
| Background | `#FBF0DD` | Warm Linen |
| Surface | `#F5E0B8` | Parchment |
| Card | `#FFFFFF` | White |
| Primary | `#A01845` | Deep Wine |
| Text | `#6B3A1A` | Warm Brown |
| Secondary Text | `#8B6A5A` | Faded Brown |
| Border | `#E8D0A0` | Tan |

### Player Colors (12 players max)
Teal, Indigo, Gold, Coral, Green, Sky Blue, Orange, Magenta, Olive, Slate Blue, Amber, Purple

---

## ASSET DELIVERABLES

### A. APP ICON (1 asset, multiple sizes)

**Requirements:**
- 1024×1024px PNG, no transparency, no rounded corners (OS adds them)
- Must work at tiny sizes (29×29 for iOS settings)
- No text in the icon

**Design Direction:**
- A single ornate story card floating in a starlit sky, OR
- Three fanned cards with mysterious symbols, OR
- A card-shaped portal/window into a miniature magical world
- Card(s) should have golden ornamental borders with filigree
- Warm parchment/cream card face with a mysterious symbol inside
- Deep midnight/plum background with golden sparkles
- Style: painterly, warm, mysterious

**Deliver:** `app_icon.png` (1024×1024)

---

### B. SPLASH SCREEN (1 asset)

**Requirements:**
- Full-screen background, 1290×2796px (iPhone 15 Pro Max safe)
- Must look good cropped to any phone aspect ratio
- Centered content area within 800×800px safe zone

**Design Direction:**
- Deep plum-to-midnight gradient background
- Center: the app logo/wordmark "StoryScore" in elegant serif or semi-serif with gold coloring
- Below logo: subtle tagline area
- Subtle golden particles/sparkles scattered
- Warm, welcoming, not busy

**Deliver:** `splash_background.png` (1290×2796)

---

### C. BACKGROUND TEXTURES (2 assets)

**Requirements:**
- Seamless tileable or large enough to cover full screen
- Very subtle — must not interfere with UI readability
- PNG with transparency (overlay on gradient)

**C1. Dark Theme Background Texture**
- Subtle parchment/paper grain texture at 3-5% opacity
- Tiny scattered star dots at 1-2% opacity
- Overall feeling: aged paper meets starry sky
- Size: 1024×1024px, seamless tile

**C2. Light Theme Background Texture**
- Subtle linen/parchment fiber texture at 5-8% opacity
- Warm cream base showing through
- Overall feeling: old book page
- Size: 1024×1024px, seamless tile

**Deliver:** `bg_texture_dark.png`, `bg_texture_light.png`

---

### D. ONBOARDING ILLUSTRATIONS (3 assets)

Three full-width illustrations for the onboarding carousel. Each should be ~800×500px with transparent background, illustration centered.

**D1. "Track Your Stories" — Scoring/Cards theme**
- A whimsical scene with story cards fanned out on a wooden table
- Golden light illuminating the cards from above
- Tiny magical creatures peeking from behind cards
- A score tally or ancient scroll partially visible
- Warm, inviting, mysterious

**D2. "Score in Seconds" — Speed/Magic theme**
- A magical hourglass or clock with golden sand
- Cards swirling around it in a gentle spiral
- Sparkles and light trails suggesting speed and magic
- The feeling that time pauses when you play

**D3. "Works Offline" — Self-contained magic theme**
- A glowing lantern or crystal ball on a game table
- The light is self-contained — no wires, no connection needed
- Maybe a tiny world inside the lantern
- Warm, cozy, intimate feeling

**Deliver:** `onboarding_1.png`, `onboarding_2.png`, `onboarding_3.png` (800×500px each, transparent bg)

---

### E. EMPTY STATE ILLUSTRATIONS (3 assets)

When there's no content yet. Each ~300×300px with transparent background.

**E1. "No Games Yet" — Start your first story**
- An empty card table with one card face-down, waiting to be turned over
- Warm light falling on the table
- Feeling: anticipation, invitation

**E2. "No Stats Yet" — Play more to see stats**
- An empty scroll or ledger with a quill pen waiting
- A few ink drops suggesting scores to come
- Feeling: potential, beginning

**E3. "No Presets Saved" — Save your group**
- Empty picture frames on a wall, waiting for portraits
- One frame has a tiny star inside
- Feeling: collecting, organizing

**Deliver:** `empty_no_games.png`, `empty_no_stats.png`, `empty_no_presets.png` (300×300px each)

---

### F. DECORATIVE ELEMENTS (8 assets)

Small reusable decorative pieces. All PNG with transparency.

**F1. Ornate Divider** — Horizontal ornamental line with flourishes
- Width: 600px, Height: 40px
- Gold (#E8A020) filigree with symmetrical scrollwork
- Fades to transparent at edges
- Used between sections

**F2. Card Frame / Border** — Ornate card-shaped border
- 200×280px (card proportions ~5:7)
- Gold ornamental border with corner flourishes
- Transparent center (content goes inside)
- Used as frame for session cards, mini card icons

**F3. Small Card Frame** — Mini version of F2
- 80×112px
- Same style, simplified for small size
- Used for card icons in session list, round headers

**F4. Crown Badge** — Storyteller indicator
- 60×60px
- Ornate golden crown with subtle glow
- Used on storyteller's score card

**F5. Trophy Badge** — Winner indicator
- 80×80px
- Ornate golden trophy cup with laurel wreath
- Used on endgame winner announcement

**F6. Sparkle Set** — Various sparkle/star shapes
- 6 variations, each 30-60px
- Gold and warm white colors
- Different shapes: 4-point star, 6-point star, diamond, dot cluster, tiny constellation, starburst
- Used scattered as decorative accents

**F7. Corner Flourish** — Decorative corner piece
- 120×120px
- Gold scrollwork for card/container corners
- 4 rotations (or design one that works rotated)
- Used on premium cards, special containers

**F8. Lock Badge** — Premium lock indicator
- 48×48px
- Ornate golden padlock with keyhole
- Used on locked premium features

**Deliver:** `divider_ornate.png`, `card_frame.png`, `card_frame_small.png`, `crown_badge.png`, `trophy_badge.png`, `sparkle_1.png` through `sparkle_6.png`, `corner_flourish.png`, `lock_badge.png`

---

### G. CUSTOM ICONS SET (20 icons)

All icons: 48×48px, PNG with transparency, gold (#E8A020) on dark OR warm brown (#6B3A1A) on light. Provide both variants.

Style: Hand-drawn / illustrated feel matching the storybook aesthetic. NOT flat material icons. Think quill-drawn, slightly ornate.

| # | Icon Name | Description | Used For |
|---|-----------|-------------|----------|
| 1 | `ic_scoreboard` | A scoring tablet or tally board | Bottom nav: Scoreboard tab |
| 2 | `ic_play_round` | A card being played or turned over | Bottom nav: Round tab |
| 3 | `ic_history` | An ancient scroll or book | Bottom nav: History tab |
| 4 | `ic_new_game` | A card deck with a sparkle | FAB: New Game |
| 5 | `ic_settings` | A gear made of ornate scrollwork | Settings button |
| 6 | `ic_stats` | A bar chart with a quill pen | Stats button |
| 7 | `ic_add_player` | A figure with a plus sign | Add Player button |
| 8 | `ic_import` | A scroll being unrolled | Import game |
| 9 | `ic_export` | A scroll being rolled up | Export game |
| 10 | `ic_share` | A card being handed to someone | Share results |
| 11 | `ic_undo` | A curved arrow with a card | Undo last round |
| 12 | `ic_edit` | A quill pen writing | Edit round |
| 13 | `ic_delete` | A card being torn | Delete round |
| 14 | `ic_target` | A bullseye or compass rose | Score target setting |
| 15 | `ic_infinite` | An infinity symbol with flourishes | Infinite mode |
| 16 | `ic_save_preset` | A bookmark with a star | Save preset |
| 17 | `ic_load_preset` | An open book with players | Load preset |
| 18 | `ic_theme` | A painter's palette | Theme picker |
| 19 | `ic_language` | A globe with ornate meridians | Language picker |
| 20 | `ic_sound` | A bell or chime | Sound effects toggle |

**Deliver:** `icons/dark/ic_*.png` and `icons/light/ic_*.png` (48×48 each, 40 files total)

---

### H. PREMIUM / SUPPORTER PACK VISUALS (3 assets)

**H1. Premium Hero Illustration** — 400×300px, transparent bg
- A treasure chest or magic box opening with golden light spilling out
- Inside: visible premium features (tiny themes, sparkles, player cards)
- Warm, inviting, "there's more magic inside"

**H2. Premium Feature Icons** (5 icons, 64×64px each, transparent bg)
- `premium_themes.png` — A painter's palette with magical colors
- `premium_celebrations.png` — Fireworks or confetti bursting from a card
- `premium_presets.png` — A group of character figures/silhouettes
- `premium_stats.png` — A crystal ball showing charts
- `premium_support.png` — A heart or handshake with golden glow

**H3. "Thank You" Supporter Badge** — 120×120px, transparent bg
- An ornate golden seal or wax stamp
- A star in the center
- Ribbon or laurel wreath around it
- Used on the supporter screen after purchase

**Deliver:** `premium_hero.png`, `premium_feature_*.png` (×5), `supporter_badge.png`

---

### I. GAME STATE ILLUSTRATIONS (4 small assets)

Used as status indicators. Each 80×80px, transparent bg.

**I1. Active Game** — A glowing card or lantern (game in progress)
**I2. Paused Game** — A card face-down, resting
**I3. Completed Game** — A trophy or laurel wreath
**I4. Good Clue / Bad Clue** — Two variants:
- Good: a lightbulb or sun with warm rays
- Bad: a cloud or fog

**Deliver:** `state_active.png`, `state_paused.png`, `state_completed.png`, `clue_good.png`, `clue_bad.png`

---

### J. SCREEN MOCKUPS (13 screens)

Design complete screen mockups for a 390×844px viewport (iPhone 14/15 size). Dark theme is primary, light theme is secondary.

For EACH screen, provide:
- Dark theme version
- Light theme version
- All states (empty, loading, populated, error where applicable)
- Exact spacing, sizing, padding values
- Font sizes and weights
- Color values for every element

#### Screen List:

**J1. Splash Screen**
- App logo centered
- Background gradient with subtle texture
- Loading indicator (subtle)

**J2. Onboarding (3 pages)**
- Hero illustration (D1/D2/D3) at top
- Title + description text
- Page dots indicator
- "Get Started" / "Next" / "Skip" buttons
- Gradient background

**J3. Home Screen — Empty State**
- App title "StoryScore" with subtitle
- Empty state illustration (E1)
- "Start Your First Game" CTA button
- Settings and Stats icons in app bar

**J4. Home Screen — With Games**
- App title with subtitle
- Quick Start banner (gradient, prominent)
- Active games section with session cards
- Completed games section
- Each session card shows: mini card icon, game title, player count, round count, player avatar row
- FAB: "New Game" with gradient

**J5. Game Setup Screen**
- Back button
- "New Game" title
- Game title input field
- Win condition toggle (Score Target / Infinite)
- Target score stepper (when score target selected)
- "Load Preset" button
- Players list with reorderable tiles
- Each player tile: drag handle, avatar (color circle + emoji), name, seat number, remove button
- "Add Player" button
- "Start Game" gradient CTA at bottom

**J6. Add Player Bottom Sheet**
- Sheet handle
- "Add Player" title
- Favorite player chips (if any)
- Name input field
- "Choose Color" — grid of 12 color circles
- "Avatar Style" — Initials/Emoji toggle
- Emoji grid (when emoji selected)
- "Add" CTA button

**J7. Scoreboard Screen**
- Round info header card (round number, storyteller name, crown icon)
- Player score cards grid (2 columns):
  - Avatar with player color gradient
  - Player name
  - Score (large, prominent)
  - Rank indicator
  - Storyteller badge (gold border + crown)
- Storyteller tap-to-change hint
- Sort toggle in app bar
- FAB: "New Round"
- Bottom navigation bar

**J8. Vote Entry / Round Screen**
- Back button
- Storyteller announcement card (centered, crown card icon)
- Section header: "Who did each player vote for?"
- Per-voter sections:
  - Voter avatar + name + "voted for:"
  - Horizontal row of vote targets (tappable player chips)
  - Selected state: gold highlight + border
  - Unselected state: subtle/muted
- Optional note field
- "Score Round" gradient button (with disabled state showing remaining votes)

**J9. Round Recap Bottom Sheet**
- "Good Clue!" or "Bad Clue!" header with icon
- Per-player score breakdown:
  - Player avatar + name
  - Score delta with reason labels (+3 Correct Guess, +1 Fooled Bonus, etc.)
- Total points awarded this round
- Gold ornate divider
- "Continue" button

**J10. Round History Screen**
- List of round tiles (reverse chronological)
- Each tile: round number circle, storyteller name, good/bad clue icon, points awarded
- "Undo Last Round" button
- Bottom navigation bar

**J11. Round Detail Screen**
- Round header card (number, storyteller, good/bad clue)
- Votes section: who voted for whom
- Score changes section: per-player deltas with reason codes
- "Edit Round" and "Delete Round" buttons

**J12. Endgame / Winner Screen**
- Sparkle decorations
- Trophy illustration with golden radial glow
- "WINNER" label (gold, uppercase)
- Winner name (large, warm parchment)
- Winning score (very large, gold, glowing)
- Gold ornate divider
- Final standings list (winner highlighted with gold)
- Session stats section (MVP, accuracy, best round)
- Score progression chart (premium, locked for free users)
- Action buttons: "New Game" (gradient), "Share" (outlined), "Save Preset" (outlined)

**J13. Settings Screen**
- Back button
- "Settings" title
- Sections with gold uppercase headers:
  - Appearance: Theme mode toggle, Color theme picker, Language
  - Gameplay: Haptic feedback, Sound effects, Reduce motion, Round notes, Default target, Sort order
  - Data: Player presets, Export/Import
  - Premium: Supporter Pack link
  - About: Version, Privacy, Support

**J14. Premium / Supporter Screen**
- Hero illustration (H1) with radial glow
- "Supporter Pack" title
- Price display
- Feature list with premium icons (H2)
- "Get Supporter Pack" gradient CTA
- "Restore Purchases" link
- Already-supporter state with badge (H3)

---

## TYPOGRAPHY

| Role | Font | Weight | Size | Color (Dark) | Color (Light) |
|------|------|--------|------|-------------|--------------|
| App Title | Serif or decorative serif | 800 | 24-28px | Gold #E8A020 | Wine #A01845 |
| Screen Title | Nunito | 800 | 20px | Parchment #F5E0B8 | Brown #6B3A1A |
| Section Header | Nunito | 700 | 10-11px, UPPERCASE, letter-spacing 1.5px | Gold #E8A020 | Wine #A01845 |
| Body Text | Nunito | 400-600 | 14px | Parchment #F5E0B8 | Brown #6B3A1A |
| Secondary Text | Nunito | 400 | 12px | Lavender #B89AAA | Faded #8B6A5A |
| Score Display | Nunito | 800 | 32-42px | Gold #E8A020 | Wine #A01845 |
| Button Text | Nunito | 700 | 14-15px | White #FFFFFF | White #FFFFFF |

**Font suggestion:** Consider using a decorative serif font (like Playfair Display, Cormorant Garamond, or Cinzel) for the app title "StoryScore" only, while keeping Nunito for all body text. This adds personality without hurting readability.

---

## SPACING & SIZING SYSTEM

| Token | Value |
|-------|-------|
| xs | 4px |
| sm | 8px |
| md | 16px |
| lg | 24px |
| xl | 32px |
| xxl | 48px |
| Card border-radius | 14px |
| Button border-radius | 14px |
| Small element radius | 8px |
| Avatar size (score card) | 36-40px |
| Avatar size (small/chip) | 24-28px |
| Mini card icon | 42×56px |
| Touch target minimum | 44×44px |
| Card shadow (dark) | 0 4px 15px rgba(0,0,0,0.3) |
| Gold glow shadow | 0 0 20px rgba(232,160,32,0.15) |

---

## ANIMATION & MOTION

Describe these for the developer (they'll be coded, not designed as assets):

| Animation | Duration | Curve | Description |
|-----------|----------|-------|-------------|
| Page transition | 300ms | easeInOut | Slide + fade between screens |
| Card appear | 200ms | decelerate | Scale 0.95→1.0 + fade in |
| Score count | 800ms | easeOut | Number incrementing from 0 to final |
| Trophy bounce | 500ms | elasticOut | Scale 0→1.2→1.0 |
| Sparkle fade | 150ms | linear | Opacity 0→1→0 with slight scale |
| Gold glow pulse | 2000ms | sinusoidal | Opacity 0.1→0.25→0.1 repeating |
| Confetti fall | 3000ms | gravity | Particles falling with drift |
| Toast slide | 300ms | decelerate | Slide down from top + fade |

---

## DELIVERY FORMAT

Organize deliverables in this folder structure:

```
storyscore-design/
├── icon/
│   └── app_icon.png                    (1024×1024)
├── splash/
│   └── splash_background.png           (1290×2796)
├── textures/
│   ├── bg_texture_dark.png             (1024×1024, tileable)
│   └── bg_texture_light.png            (1024×1024, tileable)
├── illustrations/
│   ├── onboarding_1.png                (800×500)
│   ├── onboarding_2.png                (800×500)
│   ├── onboarding_3.png                (800×500)
│   ├── empty_no_games.png              (300×300)
│   ├── empty_no_stats.png              (300×300)
│   ├── empty_no_presets.png            (300×300)
│   ├── premium_hero.png                (400×300)
│   └── supporter_badge.png             (120×120)
├── decorative/
│   ├── divider_ornate.png              (600×40)
│   ├── card_frame.png                  (200×280)
│   ├── card_frame_small.png            (80×112)
│   ├── crown_badge.png                 (60×60)
│   ├── trophy_badge.png                (80×80)
│   ├── sparkle_1.png through sparkle_6.png  (30-60px each)
│   ├── corner_flourish.png             (120×120)
│   └── lock_badge.png                  (48×48)
├── icons/
│   ├── dark/
│   │   └── ic_*.png                    (48×48 each, 20 icons)
│   └── light/
│       └── ic_*.png                    (48×48 each, 20 icons)
├── premium/
│   ├── premium_themes.png              (64×64)
│   ├── premium_celebrations.png        (64×64)
│   ├── premium_presets.png             (64×64)
│   ├── premium_stats.png              (64×64)
│   └── premium_support.png             (64×64)
├── states/
│   ├── state_active.png                (80×80)
│   ├── state_paused.png                (80×80)
│   ├── state_completed.png             (80×80)
│   ├── clue_good.png                   (80×80)
│   └── clue_bad.png                    (80×80)
└── mockups/
    ├── dark/
    │   ├── 01_splash.png
    │   ├── 02_onboarding_1.png
    │   ├── 03_onboarding_2.png
    │   ├── 04_onboarding_3.png
    │   ├── 05_home_empty.png
    │   ├── 06_home_games.png
    │   ├── 07_game_setup.png
    │   ├── 08_add_player.png
    │   ├── 09_scoreboard.png
    │   ├── 10_vote_entry.png
    │   ├── 11_round_recap.png
    │   ├── 12_round_history.png
    │   ├── 13_round_detail.png
    │   ├── 14_endgame.png
    │   ├── 15_settings.png
    │   └── 16_premium.png
    └── light/
        └── (same filenames)
```

---

## IMPORTANT CONSTRAINTS

1. **No copyrighted imagery** — All art must be original. Do not replicate any existing game's card art, characters, or visual identity.
2. **Accessibility** — Maintain 4.5:1 contrast ratio for all text. Never use color as the only indicator.
3. **Scalability** — All assets must look good at 1x, 2x, and 3x pixel density.
4. **File size** — Keep individual PNGs under 500KB. Total asset bundle under 10MB.
5. **Consistency** — All illustrations should feel like they were drawn by the same artist in the same world.
6. **Platform** — Design for mobile phones first (390×844 viewport). Must also work on tablets (scaled).

---

## SUMMARY

You are creating the visual soul of a warm, magical, storybook-themed score tracking app. Every pixel should make players feel like they're in a world of imagination and wonder. The app sits on the table during a game — it should add to the magic, not distract from it.

The key feeling: **"I want to keep this app open on the table because it's beautiful."**
