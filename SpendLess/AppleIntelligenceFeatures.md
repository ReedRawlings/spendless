# SpendLess — Apple Intelligence Feature Guide

A prioritized overview of Apple Intelligence integrations and related features under consideration.

---

## Executive Summary

Apple Intelligence offers several integration points for SpendLess. This guide organizes all features by priority, balancing user impact, development effort, and technical readiness.

**Key Insight:** The most impactful Apple Intelligence feature for V1 is **Siri App Intents** — low effort, immediate value, no waiting for new APIs. The more advanced features (Foundation Models, Image Playground) are better suited for V1.5/V2 once the core app is proven.

---

## Priority Tiers

### 🥇 V1 — Ship With Launch

These features are ready now, low-to-medium effort, and core to the value proposition.

| Feature | Type | Effort | Impact | Status |
|---------|------|--------|--------|--------|
| **Siri App Intents** | Apple Intelligence | Low | High | Ready to build |
| **Writing Tools** | Apple Intelligence | None | Medium | Automatic |
| Dark Pattern Cards | Education | Medium | High | Designed |
| Letter from Future You | Psychology | Low | High | Designed |
| Enhanced Celebrations | Engagement | Low | High | Designed |
| Activity Suggestions | Coping Tools | Low | Medium | Designed |
| Goal Countdown Timer | Motivation | Low | Medium | Designed |

---

### 🥈 V1.5 — Post-Launch Update

Ship after gathering user feedback. Medium effort, high differentiation.

| Feature | Type | Effort | Impact | Status |
|---------|------|--------|--------|--------|
| **Foundation Models Coach** | Apple Intelligence | Medium | Very High | Requires iOS 26 |
| Saved Cards Walkthrough | Friction | Medium | Medium | Designed |
| Danger Time Auto-Detection | Intelligence | Medium | High | Needs data |
| Achievement Badges | Gamification | Medium | Medium | Designed |

---

### 🥉 V2 — Major Update

High effort features that require proven product-market fit first.

| Feature | Type | Effort | Impact | Status |
|---------|------|--------|--------|--------|
| **"Future You" Image Generation** | Apple Intelligence | High | Medium | Experimental |
| Full Gamification System | Engagement | High | High | Designed |
| Email Unsubscribe Integration | Friction | High | Medium | Gmail only |
| Visual Intelligence Integration | Apple Intelligence | High | Medium | Speculative |
| Conversational Siri (2026) | Apple Intelligence | Low | High | Waiting on Apple |

---

## V1 Features — Detailed

### 1. Siri App Intents ⭐ PRIORITY

**Why it matters:** Hands-free access during moments of temptation. User can say "Hey Siri, I'm feeling an impulse" without unlocking phone or finding app.

**Intents to implement:**

| Intent | Phrase | Action |
|--------|--------|--------|
| Impulse Help | "I'm feeling an impulse in SpendLess" | Opens Panic Button flow |
| Check Progress | "Check my savings in SpendLess" | Siri speaks streak + savings |
| Learn a Trick | "Teach me a trick in SpendLess" | Shows Dark Pattern Card |
| Read My Letter | "Read my letter in SpendLess" | Shows Future Letter |
| Quick Log | "Log a win in SpendLess" | Quick Graveyard entry |

**Effort:** ~2-3 days
**Requires:** iOS 16+, AppIntents framework
**Documentation:** Added to implementation doc ✅

---

### 2. Writing Tools (Automatic)

**Why it matters:** Free enhancement to any text field in the app.

**Where it applies:**
- Letter from Future You (user can refine their message)
- Waiting list item reasons
- Goal descriptions

**Effort:** Zero — automatic for standard SwiftUI text views
**Requires:** iOS 18+, Apple Intelligence enabled device

---

### 3. Dark Pattern Recognition Cards

**Why it matters:** Education builds long-term resilience. Users learn to recognize manipulation tactics.

**Content:** 10 cards covering fake scarcity, urgency timers, confirm shaming, etc.

**Delivery:**
- Daily card on dashboard (optional)
- Siri intent: "Teach me a trick"
- Swipeable deck in Learn section

**Effort:** ~3-4 days (content exists, need UI)

---

### 4. Letter from Future You

**Why it matters:** Self-authored motivation is more powerful than generic messages.

**Flow:**
1. Written during onboarding (after commitment signature)
2. Resurfaced during Panic Button flow
3. Accessible via Siri: "Read my letter"

**Effort:** ~1-2 days

---

### 5. Enhanced Celebrations

**Why it matters:** Dopamine redirection. Make resistance feel rewarding.

**Components:**
- Sound effects (coin drop, cha-ching, level up)
- Visual animations (coin shower, progress bar pulse)
- Variable rewards (15% chance bonus badge)
- Contextual messages ("$79 saved → 2 museum tickets in Paris")

**Effort:** ~3-4 days

---

## V1.5 Features — Detailed

### 6. Foundation Models "Impulse Coach" ⭐ HIGH POTENTIAL

**Why it matters:** True conversational support during temptation. User can describe what they want to buy and get personalized, contextual guidance.

**Example interaction:**
```
User: "I really want these wireless earbuds I saw on Amazon"

Coach: "I hear you! Those can be tempting. Quick question — 
are your current earbuds broken, or is this more of a 'nice 
to have'? You're 18 days into your streak and $1,247 toward 
Paris. 🗼"
```

**Technical approach:**
- Use `LanguageModelSession` with custom instructions
- Inject user's streak, goal, and savings as context
- Feed dark pattern knowledge and coping strategies
- Maintain conversation history within session

**Key advantages:**
- 100% on-device, 100% private
- Zero API costs
- Works offline
- Native Swift integration

**Effort:** ~1-2 weeks
**Requires:** iOS 26+, iPhone 15 Pro or later
**Fallback:** Pre-written decision trees for older devices

---

### 7. Danger Time Auto-Detection

**Why it matters:** Proactive protection during high-risk periods.

**How it works:**
1. Track when users trigger Panic Button or log impulses
2. After 2 weeks, identify patterns (e.g., Sunday evenings, late nights)
3. Auto-enable Firm mode during detected danger times
4. Send preemptive notification: "Entering your danger zone"

**Effort:** ~1 week
**Requires:** 2 weeks of user data minimum

---

## V2 Features — Detailed

### 8. "Future You" Image Generation (Experimental)

**Why it matters:** Novel intervention — see yourself with the item before buying. Creates cognitive distance and a moment of reflection.

**How it works:**
1. User uploads selfie (one-time, stored locally)
2. User describes item they want to buy
3. Image Playground generates cartoon "you" holding/wearing item
4. Prompt: "Does this spark joy? Or just look like... stuff?"

**Technical reality:**
- API supports `sourceImage` parameter ✅
- Output is cartoonish (animation/illustration style)
- May not look much like actual user
- Requires iPhone 15 Pro+

**Honest assessment:**
- The *pause* is valuable, not the image quality
- Better as viral marketing hook than core feature
- Consider as Pro-only experimental feature

**Effort:** ~1-2 weeks
**Requires:** iOS 18.2+, Image Playground framework

---

### 9. Full Gamification System

**Why it matters:** Sustained engagement through achievement loops.

**Components:**
- SpendLess Coins (earn for resisting, spend on cosmetics)
- Achievement badges (Week Warrior, Century Club, etc.)
- Weekly challenges
- Virtual shop OR Growing Garden

**Consideration:** May conflict with anti-consumerism message. Virtual shop lets users "buy" things safely, redirecting acquisition urge.

**Effort:** ~3-4 weeks
**Dependency:** Core app must be sticky first

---

### 10. Conversational Siri (2026)

**Why it matters:** Natural language interaction without opening app.

**What Apple promises:**
- "Help me decide if I should buy this" → contextual response
- Multi-step actions across apps
- Personal context awareness

**Current status:** Apple confirmed Spring 2026 release

**Our preparation:** V1 App Intents implementation positions us for easy adoption

**Effort:** Low (when available)
**Requires:** iOS 26.4+ (expected)

---

## Decision Framework

### When to build each feature:

```
                    HIGH IMPACT
                         │
     ┌───────────────────┼───────────────────┐
     │                   │                   │
     │  Foundation       │   Siri Intents    │
     │  Models Coach     │   Dark Patterns   │
     │  (V1.5)           │   Future Letter   │
     │                   │   (V1)            │
LOW ─┼───────────────────┼───────────────────┼─ HIGH
EFFORT                   │                   EFFORT
     │                   │                   │
     │  Goal Countdown   │   Gamification    │
     │  Writing Tools    │   Image Gen       │
     │  (V1)             │   Email Unsub     │
     │                   │   (V2)            │
     └───────────────────┼───────────────────┘
                         │
                    LOW IMPACT
```

---

## Technical Requirements Summary

| Feature | Min iOS | Device Requirement | Framework |
|---------|---------|-------------------|-----------|
| Siri App Intents | 16.0 | Any | AppIntents |
| Writing Tools | 18.0 | Apple Intelligence | Automatic |
| Foundation Models | 26.0 | iPhone 15 Pro+ | FoundationModels |
| Image Playground | 18.2 | iPhone 15 Pro+ | ImagePlayground |
| Conversational Siri | 26.4 | TBD | AppIntents |

---

## Recommended Roadmap

### V1 Launch (Now)
1. ✅ Core app (blocking, waiting list, graveyard, streaks)
2. ✅ Siri App Intents (5 intents)
3. ✅ Dark Pattern Cards
4. ✅ Letter from Future You
5. ✅ Enhanced Celebrations

### V1.5 (1-2 months post-launch)
1. Foundation Models Impulse Coach (iOS 26 users)
2. Danger Time Auto-Detection
3. Achievement Badges
4. Saved Cards Walkthrough

### V2 (3-6 months post-launch)
1. Full Gamification OR Growing Garden
2. "Future You" Image Generation (Pro feature)
3. Email Unsubscribe (Gmail)
4. Conversational Siri (when Apple ships)

---

## Open Questions

1. **Gamification vs. Anti-Consumerism:** Does a virtual shop undermine the message? Or is it healthy redirection of acquisition urges?

2. **Foundation Models Fallback:** What experience do users on older devices get? Pre-written decision trees? No coach feature?

3. **Image Generation Positioning:** Fun experiment or core feature? Free or Pro-only?

4. **Siri Discovery:** How aggressively do we promote Siri commands? Post-onboarding modal? Settings section? Both?

---

*Document Version: 1.0*
*Last Updated: December 2025* 