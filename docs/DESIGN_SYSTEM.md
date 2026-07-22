# Design System

## Color Palette

### Brand Colors
```
Primary:    #4CAF50  (Green 500)
Secondary:  #81C784  (Green 300)
Accent:     #FFC107  (Amber 500)
```

### Light Theme
```
background:       #FAFAFA
surface:          #FFFFFF
surfaceVariant:   #F3F3F3
onSurface:        #1C1B1F
onBackground:     #1C1B1F
primary:          #2E7D32
onPrimary:        #FFFFFF
```

### Dark Theme
```
background:       #111318
surface:          #1E2025
surfaceVariant:   #2A2D35
onSurface:        #E6E1E5
onBackground:     #E6E1E5
primary:          #81C784
onPrimary:        #1B5E20
```

---

## Typography

Font: **Inter** (fallback: Roboto)

| Style | Size | Weight | Usage |
|---|---|---|---|
| displayLarge | 57sp | W400 | Hero text |
| headlineLarge | 32sp | W700 | Screen titles |
| headlineMedium | 28sp | W700 | Section headers |
| titleLarge | 22sp | W600 | Card titles |
| titleMedium | 16sp | W600 | List items |
| titleSmall | 14sp | W600 | Captions |
| bodyLarge | 16sp | W400 | Body text |
| bodyMedium | 14sp | W400 | Secondary text |
| bodySmall | 12sp | W400 | Metadata |
| labelLarge | 14sp | W500 | Buttons |
| labelMedium | 12sp | W500 | Tags |
| labelSmall | 11sp | W500 | Micro labels |

---

## Spacing

```
xs:   4dp
sm:   8dp
md:   12dp
lg:   16dp
xl:   24dp
xxl:  32dp
xxxl: 48dp
```

---

## Border Radius

```
small:   8dp   (chips, tags)
medium:  12dp  (cards)
large:   16dp  (bottom sheets)
xlarge:  24dp  (FAB, dialogs)
full:    999dp (pills)
```

---

## Elevation

```
level0: 0dp  (flat)
level1: 1dp  (cards)
level2: 3dp  (app bar)
level3: 6dp  (FAB)
level4: 8dp  (modal)
level5: 12dp (dialog)
```

---

## Card Design (Google Keep Inspired)

- Rounded corners: 12dp
- Soft shadow (elevation 1)
- Color-coded backgrounds
- Consistent padding: 12dp
- No hard borders in light mode

---

## Icon System

Package: `material_symbols_icons`
Style: Rounded
Default size: 24dp
