# App Store screenshots — capture plan

Use **demo mode** (`Env.demoMode = true`) so seed data renders consistently.

## Required sizes (App Store Connect, iOS app)

| Device class | Pixels | Min count | Capture device |
|---|---|---|---|
| 6.7" / 6.9" iPhone | 1290 × 2796 | 3 | iPhone 16 Pro Max simulator |
| 6.5" iPhone | 1284 × 2778 | optional fallback | iPhone 14 Plus simulator |
| 5.5" iPhone | 1242 × 2208 | required for legacy | iPhone 8 Plus simulator |

Submit **same 8 captures** at the 6.7" size; App Store auto-scales.

## Capture sequence (8 frames)

1. **Hero** — Prospects list, "Chauds" filter active, 5 demo prospects with heat dots
2. **Conversation** — Thread plein écran for Marie Tremblay (10 bulles SMS animées Klaris orange / prospect muted)
3. **Briefing 7h30** — Day open, 4 KPI tiles + hot section
4. **Calendar** — Strip + 2 appointments rendered, EventKit badge visible
5. **Map** — MapKit native, 5 colored pins (Verdun + Plateau + Laval + Rosemont + NDG)
6. **Stats** — 4 KPI tiles + 6-month bar chart
7. **Settings** — Theme toggle visible, list of sections
8. **Onboarding 1** — Mascotte + welcome slide

## Mac flow

```bash
cd klaris_ios
# Set demoMode = true in lib/core/env.dart
flutter run -d "iPhone 16 Pro Max"
# In simulator: Cmd+S to capture; saved to ~/Desktop
```

Then drag captures into App Store Connect → Media Manager → 6.7" iPhone slot.

## App preview video (optional, 15-30s)

Use QuickTime → New Movie Recording → simulator selected as camera.
Storyboard: prospects list (3s) → tap hot lead (2s) → conversation thread (5s) → briefing (4s) → calendar (3s) → map (3s) → end card "klarisapp.ai" (2s).
