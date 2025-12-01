Here's a tailored design prompt for SpendLess:

---

# SpendLess Design System Prompt

You are designing an iOS app that helps women aged 22-45 overcome compulsive shopping. The core tension: **this is a serious behavioral health tool that must feel like a supportive friend, not a clinical intervention or punishing drill sergeant.** Users are already dealing with shame—the design must never add to it.

## Design Philosophy

**Warmth over sterility.** This app lives in the emotional space between "treating yourself" and "taking care of yourself." It should feel like the friend who gently takes your phone away at 2am, not the app that lectures you about financial responsibility.

**Celebration over punishment.** Every interaction where a user resists temptation is a victory. The design language should make resisting feel *more* rewarding than buying—redirect the dopamine hit, don't suppress it.

**Feminine without being patronizing.** The primary audience skews female, but avoid pink-washed clichés. Think: the aesthetic sensibility of a well-curated lifestyle brand, not a period tracker app.

## Typography

Avoid: Inter, SF Pro (default), Roboto, Arial, system defaults. These feel clinical and tech-bro.

Seek: Fonts with personality and warmth that remain highly readable. Consider:
- Rounded geometric sans-serifs (but NOT the overused ones)
- Soft grotesques with friendly terminals
- Display faces for headlines that have character without being precious

The typography should feel like handwritten notes from a supportive friend transcribed into a professional app—approachable but not sloppy.

## Color & Theme

**Reject:** Purple gradients on white (the default "wellness app" look), clinical blues, harsh blacks, cold grays, anything that reads as "fintech."

**Embrace:** 
- **Warm earth tones** as the foundation—terracotta, clay, sandstone, warm taupes
- **Botanical greens** as secondary—sage, olive, eucalyptus (not mint, not neon)
- **Celebratory metallics** for wins—warm gold, rose gold, copper (not silver, not chrome)
- **Soft cream/warm white** backgrounds rather than pure white or gray

The palette should evoke: a sun-drenched café in Southern Europe, a friend's well-designed apartment, the feeling of treating yourself to something *actually* good.

Use CSS/SwiftUI variables religiously. Commit to a dominant warm tone with sharp gold accents for celebrations—timid, evenly-distributed palettes fail to create the emotional peaks this app needs.

## Motion & Celebration

This is where the app does its heaviest psychological lifting. **Resisting a purchase must feel as good as making one.**

**High-impact moments:**
- **Money flying to goal** — Coins/bills animating toward the goal visualization when users bury items. This should feel satisfying, like a slot machine paying out.
- **Streak fire scaling** — Flames that grow with streak length, with particle effects at milestones
- **Confetti explosions** — Goal completion, major milestones, first burial. Go big.
- **Progress bar pulses** — Goal bar should glow/breathe when updated, not just increment

**Micro-interactions:**
- Haptic feedback on every positive action (not errors—errors aren't failures here)
- Springy, organic animations (not mechanical/linear)
- Buttons that feel satisfying to tap

**Reduced motion alternatives:** For accessibility, provide fade-based alternatives that preserve the emotional beat without the movement.

Motion should feel: rewarding, warm, slightly indulgent—the visual equivalent of a hug.

## Backgrounds & Atmosphere

Avoid: Flat solid colors, pure white screens, generic gradient washes.

Create depth through:
- Subtle warm gradients (top-to-bottom warmth shifts)
- Soft noise/grain textures that add organic feel
- Layered translucency where appropriate
- Contextual atmospheric touches (soft glow behind goal images, warm vignettes)

The shield/blocking screen is critical—it should feel like a pause, not a punishment. Consider: frosted glass effects, soft blurs, warm tones that feel like a supportive intervention rather than a locked door.

## Component Patterns

**Cards:** Rounded corners (but not childishly so), subtle shadows with warm undertones, generous padding. Should feel like physical objects you want to interact with.

**Buttons:** Primary actions in warm coral/terracotta with gold accents for celebration states. Avoid harsh borders—soft, inviting tap targets.

**Progress indicators:** Organic, flowing—avoid rigid rectangles. Consider: growing plants, filling vessels, paths being traveled.

**Empty states:** Warm, encouraging, never lonely-feeling. Use illustration thoughtfully—avoid generic line art or overly cute mascots.

## Avoid These AI-Generated Clichés

- Gradient backgrounds that transition purple → pink → orange
- Card-based layouts with identical rounded rectangles in a grid
- Generic "wellness app" green (#4CAF50 and its cousins)
- Confetti that looks like default particle systems
- Illustrations in the "corporate Memphis" style
- Anything that could be mistaken for a meditation or finance app
- The color combination of coral + teal (overused in "friendly" apps)

## Emotional Targets by Screen

| Screen | Emotional Target |
|--------|------------------|
| Dashboard | Pride, motivation, "I'm doing this" |
| Shield/Block | Pause, gentle intervention, "let's think" |
| Waiting List | Curiosity, patience, "we'll see" |
| Graveyard | Triumph, slight irreverence, "look at all this stuff I didn't need" |
| Panic Button | Calm, support, "you've got this" |
| Celebration | Joy, reward, "you earned this feeling" |
| Relapse | Compassion, recovery, "it happens, tomorrow is new" |

## The North Star

When in doubt, ask: **"Would this design make resisting a purchase feel as satisfying as making one?"**

If the answer is no, the design isn't working hard enough.

---

*The goal is to create a design that users actually want to open—not out of guilt, but because interacting with it feels genuinely good. The app should redirect the shopping dopamine hit, not suppress it.*