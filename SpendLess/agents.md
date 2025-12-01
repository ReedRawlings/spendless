agents for spendless App

## Project Overview

SpendLess is an iOS app that helps users overcome compulsive shopping and impulse buying. It uses Apple's Screen Time API to block shopping apps, combined with behavioral intervention features to help users pause, reflect, and redirect their spending toward meaningful goals.

**Target Audience:** Primarily women aged 22-45 struggling with impulse shopping, online shopping addiction, or compulsive buying behaviors. Many may have ADHD or use shopping as emotional regulation.

**Design Philosophy:** Vibrant, warm, and encouraging. Not clinical or punishing. Think supportive friend, not drill sergeant. Recovery-focused, not shame-based.

**Current Status:** Greenfield project — implementation doc and feature spec complete, code not yet written.

---

## Tech Stack

### Core Frameworks
- **SwiftUI** — Primary UI framework (no UIKit unless absolutely necessary)
- **FamilyControls** — Authorization and app selection via `FamilyActivityPicker`
- **ManagedSettings** — Applying shields/blocks to selected apps
- **DeviceActivity** — Scheduling and monitoring blocked app access attempts
- **SwiftData** — Primary persistence (UserDefaults as fallback for simple prefs)

### Required App Extensions
1. `DeviceActivityMonitorExtension` — Responds to schedule events
2. `ShieldConfigurationExtension` — Custom blocking screen UI
3. `ShieldActionExtension` — Handle user actions on block screen

### Third-Party Dependencies
- **Superwall** — Paywall A/B testing and management
- **RevenueCat** — Subscription management
- **Mixpanel** or **Amplitude** — Analytics (opt-in, privacy-respecting)

### Entitlements
- `com.apple.developer.family-controls` — Required for Screen Time API (must request from Apple, 2-6 week approval)
- App Groups — Required for sharing data between main app and extensions

---

## Architecture

### Navigation Structure
```
TabBar
├── Home (Dashboard)
├── Waiting List
├── Graveyard
└── Settings
```

### Key Data Models

```swift
// Core goal tracking
struct UserGoal {
    let id: UUID
    var name: String                    // "Trip to Japan"
    var targetAmount: Decimal           // 4500.00
    var savedAmount: Decimal            // 1247.00
    var imageData: Data?                // Optional vision board image
    var createdAt: Date
}

// 7-day cooling off period for impulse items
struct WaitingListItem {
    let id: UUID
    var name: String
    var amount: Decimal
    var reason: String?
    var addedAt: Date
    var expiresAt: Date                 // addedAt + 7 days
    var checkinCount: Int
}

// Resisted purchases
struct GraveyardItem {
    let id: UUID
    var name: String
    var amount: Decimal
    var buriedAt: Date
    var source: GraveyardSource         // .waitingList, .panicButton, .blockIntercept, .returned
}

// User state
struct UserProfile {
    var triggers: [ShoppingTrigger]
    var difficultyMode: DifficultyMode  // .gentle, .firm, .lockdown
    var isPro: Bool
    var futureLetterText: String?
}

// Streak tracking
struct Streak {
    var currentDays: Int
    var longestDays: Int
    var lastImpulseDate: Date?
}
```

### App Groups Data Sharing
Extensions run in separate processes. Use shared container:
```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
```

---

## Core Features

### 1. Block Intercept Flow
When user opens blocked app → Shield screen appears → User chooses:
- "Just browsing" → Friction based on difficulty mode
- "Something specific" → Add to 7-day Waiting List
- "I actually need this" → Pro questionnaire flow

### 2. Waiting List
- Items wait 7 days before user can buy guilt-free
- Check-in notifications at Day 2, 4, 6, 7
- "Bury it" moves to Graveyard and adds $ to goal

### 3. Cart Graveyard
- Collection of resisted purchases
- Shows total $ saved
- Items from: waiting list, panic button, block intercept, returns

### 4. Panic Button
- Dashboard button for when urge hits outside blocked apps
- Breathing exercise → Activity suggestions → Log item → Celebration

### 5. Goal Visualization
- Progress bar toward user's goal
- Money "flies" to goal on each save
- Translations: "$79 saved → 2 museum tickets in Paris"

---

## Coding Conventions

### SwiftUI
- Use `@Observable` (iOS 17+) over `ObservableObject` where possible
- Prefer `@State` and `@Binding` over complex state management
- Extract reusable components into separate files
- Use `ViewModifier` for repeated styling patterns

### Naming
- Files: `PascalCase.swift`
- Views: `{Feature}View.swift` (e.g., `WaitingListView.swift`)
- Models: `{Name}.swift` in `/Models` folder
- Extensions: `{Type}+{Functionality}.swift`

### File Organization
```
SpendLess/
├── App/
│   └── SpendLessApp.swift
├── Models/
├── Views/
│   ├── Onboarding/
│   ├── Dashboard/
│   ├── WaitingList/
│   ├── Graveyard/
│   └── Settings/
├── Components/          # Reusable UI components
├── Extensions/
│   ├── DeviceActivityMonitor/
│   ├── ShieldConfiguration/
│   └── ShieldAction/
├── Services/
│   └── ScreenTimeManager.swift
└── Resources/
```

### Error Handling
- Use `Result` types for async operations
- Show user-friendly error messages, log technical details
- Screen Time API requires physical device — handle simulator gracefully

### Accessibility
- All interactive elements need meaningful labels
- Support Dynamic Type (all text sizes)
- Check `UIAccessibility.isReduceMotionEnabled` for animations
- Minimum 4.5:1 contrast ratio

---

## Design Guidelines

### Visual Direction
- **Warm, not clinical** — Coral/terracotta primary, sage green secondary, golden accents
- **Celebratory** — Confetti, haptics, sound effects for wins
- **Feminine-leaning** — Rounded fonts, friendly icons, avoid tech-bro aesthetics

### Tone of Voice
- Supportive friend, not drill sergeant
- "You didn't spend $79" not "You saved $79" (accurate framing)
- Celebrate progress, never shame slips
- "It happens" not "You failed"

### Animations
- Spring animations for progress updates
- Confetti for milestones
- Money flying animation for savings
- 60fps target, respect reduced motion

### Key Copy Patterns
```
// Goal translations
"$79 saved → That's 2 museum tickets in Paris"

// Streak celebrations  
"14 days. Most people can't go 14 hours."

// Relapse handling
"It happens. What matters is what you do next."

// Never say
"You earned $X" — say "You didn't spend $X"
```

---

## Screen Time API Notes

### Critical Limitations
- **Simulator does NOT work** — Must test on physical device
- Max 50 app tokens per shield
- Max 50 named ManagedSettingsStores
- Max 20 DeviceActivity schedules
- Tokens are opaque — cannot get app bundle IDs or names directly

### Authorization Flow
```swift
import FamilyControls

let center = AuthorizationCenter.shared
try await center.requestAuthorization(for: .individual)
```

### Applying Shields
```swift
import ManagedSettings

let store = ManagedSettingsStore()
store.shield.applications = selection.applicationTokens
store.shield.applicationCategories = .specific(selection.categoryTokens)
store.shield.webDomains = selection.webDomainTokens  // Safari blocking
```

### Key Resources
- [WWDC21: Meet the Screen Time API](https://developer.apple.com/videos/play/wwdc2021/10123/)
- [WWDC22: What's New in Screen Time API](https://developer.apple.com/videos/play/wwdc2022/110336/)
- [Julius Brussee's Implementation Guide](https://medium.com/@juliusbrussee/a-developers-guide-to-apple-s-screen-time-apis)

---

## Monetization

### Freemium Model
**Free Tier:**
- Block up to 5 apps
- 1 goal, 3 waiting list items
- Basic streak tracking

**Pro ($6.99/mo or $39.99/yr):**
- Unlimited blocking
- Multiple goals
- Full graveyard analytics
- "Do I Really Need This?" questionnaire
- Custom activities, danger time scheduling

### Paywall Triggers
1. After onboarding (soft prompt if >5 apps selected)
2. When hitting limits
3. Settings → Upgrade to Pro

---

## Project Documents

| Document | Purpose |
|----------|---------|
| `spendless-implementation-doc.md` | Full technical spec, all screens, data models, flows |
| `spendless-feature-additions.md` | V1 and V2 feature enhancements |
| `Shopping_Compulsion_in_the_Digital_Age.md` | Research foundation — psychology, what works |

---

## Development Priorities

### V1 Must-Haves
1. Onboarding flow with Screen Time authorization
2. App blocking with custom shield screens
3. Waiting List with 7-day timer
4. Cart Graveyard
5. Goal tracking with visual progress
6. Panic button with breathing exercise
7. Streak tracking
8. Basic paywall

### V1 Nice-to-Haves
- Dark pattern education cards
- Letter from Future You
- Activity suggestions
- Saved payment removal walkthrough
- Enhanced celebrations (sounds, variable rewards)

### V2 Roadmap
- Gamification (coins, badges, challenges)
- Growing garden visualization
- Email unsubscribe integration (Gmail only)
- Danger time auto-detection
- Community features

---

## Testing Notes

- **Physical device required** for Screen Time API
- Test both authorized and unauthorized states
- Test streak preservation edge cases
- Verify App Groups data sharing with extensions
- Test paywall flows with RevenueCat sandbox

---

## Common Gotchas

1. **FamilyActivityPicker crashes when searching** — Use dictation or paste instead
2. **First picker open shows empty** — Dismiss and reopen
3. **Shields persist after app termination** — Expected behavior
4. **Extension entitlements** — Request separately for EACH target
5. **Savings ≠ actual money** — Frame as "didn't spend" not "earned"
6. **Users can always disable** via Settings → Screen Time — design for trust, not circumvention

---

*Last updated: Project inception*