# SpendLess — Implementation Document

## Overview

SpendLess is an iOS app that helps users overcome compulsive shopping and impulse buying. It uses Apple's Screen Time API to block shopping apps, combined with behavioral intervention features to help users pause, reflect, and redirect their spending toward meaningful goals.

**Target Audience:** Primarily women aged 22-45 struggling with impulse shopping, online shopping addiction, or compulsive buying behaviors. Many may have ADHD or use shopping as emotional regulation.

**Design Reference:** See `designdoc.md` for all visual design guidelines, color palette, typography, and animation specifications.

---

## Implementation Status

### ✅ Completed (V1 Foundation)

| Component | Status | Location |
|-----------|--------|----------|
| Theme System | ✅ Complete | `Theme/Theme.swift` |
| Data Models (SwiftData) | ✅ Complete | `Models/*.swift` |
| App State Management | ✅ Complete | `Services/AppState.swift` |
| Screen Time Manager (Stub) | ✅ Complete | `Services/ScreenTimeManager.swift` |
| UI Components | ✅ Complete | `Components/*.swift` |
| Tab Navigation | ✅ Complete | `Views/MainTabView.swift` |
| Dashboard View | ✅ Complete | `Views/Dashboard/DashboardView.swift` |
| Panic Button Flow | ✅ Complete | `Views/Dashboard/DashboardView.swift` |
| Waiting List View | ✅ Complete | `Views/WaitingList/WaitingListView.swift` |
| Graveyard View | ⏸️ On Hiatus | `Views/Graveyard/GraveyardView.swift` (on hiatus, not actively developing) |
| Learning Library | ✅ Complete | `Views/LearningLibrary/*.swift` |
| Settings View | ✅ Complete | `Views/Settings/SettingsView.swift` |
| Onboarding (15 screens) | ✅ Complete | `Views/Onboarding/*.swift` |
| Extension Templates | ✅ Complete | `Extensions/*.swift` |
| Haptic Feedback System | ✅ Complete | `Components/HapticFeedback.swift` |
| Accessibility Helpers | ✅ Complete | `Components/AccessibilityModifiers.swift` |
| RevenueCat Integration | ✅ Complete | `Services/SubscriptionService.swift` |
| Superwall SDK Integration | 🔄 In Progress | `Services/SuperwallService.swift` - SDK added, needs dashboard config |
| Paywall UI | 🔄 In Progress | `Views/Settings/PaywallView.swift` - Currently using RevenueCat PaywallView, needs Superwall replacement |

### ✅ Screen Time Integration (Complete)

| Component | Status | Notes |
|-----------|--------|-------|
| FamilyActivityPicker Integration | ✅ Complete | Real picker integrated in onboarding |
| Shield Screen (Live) | ✅ Complete | Custom shield UI with difficulty modes |
| App Blocking (Live) | ✅ Complete | Shields applied via DeviceActivityMonitor |
| DeviceActivityMonitor Extension | ✅ Complete | Fully implemented, working on device |
| ShieldConfiguration Extension | ✅ Complete | Custom shield configuration with dynamic content |
| ShieldAction Extension | ✅ Complete | Handles shield button actions |

### 📋 Deferred to Later

| Component | Status | Notes |
|-----------|--------|-------|
| Notification Manager | 📋 Deferred | Waiting list reminders, streak celebrations |
| "Do I Really Need This?" Questionnaire | 📋 Deferred | Pro feature |
| Sharing / Social Cards | 📋 Deferred | V1.1 |
| Analytics Integration | 📋 Deferred | Mixpanel/Amplitude |
| Shortcuts Automation Setup | 📋 Deferred | For rich intervention flows |

---

## Technical Stack

### Required Frameworks
- **SwiftUI** — Primary UI framework
- **SwiftData** — On-device persistence
- **FamilyControls** — Authorization and app selection via `FamilyActivityPicker`
- **ManagedSettings** — Applying shields/blocks to selected apps
- **DeviceActivity** — Scheduling and monitoring blocked app access attempts

### App Extensions Required
- `DeviceActivityMonitorExtension` — Responds to schedule events
- `ShieldConfigurationExtension` — Custom blocking screen UI
- `ShieldActionExtension` — Handle user actions on block screen

### Data Storage
- **SwiftData** for all persistence (on-device only for v1)
- **App Groups** — Required for sharing data between main app and extensions
- **UserDefaults** — Simple preferences and extension communication

### Third-Party Services
- **RevenueCat** — ✅ Integrated — Subscription management (`Services/SubscriptionService.swift`)
- **Superwall** — 🔄 In Progress — Paywall A/B testing and management (`Services/SuperwallService.swift` - SDK added, dashboard config pending)
- **Mixpanel** or **Amplitude** — 📋 Planned — Analytics (opt-in, privacy-respecting)

### Entitlements Required
- `com.apple.developer.family-controls` — Must request from Apple via developer portal
- Request for main app AND all extensions separately. Approval takes 2-6 weeks.

---

## App Architecture

### Navigation Structure

```
TabBar
├── Home (Dashboard)    → DashboardView.swift
├── Waiting List        → WaitingListView.swift
├── Learn              → LearningLibraryView.swift
└── Settings           → SettingsView.swift
                          └── Cart Graveyard → GraveyardView.swift
```

### File Structure (Current)

```
SpendLess/
├── App/
│   └── SpendLessApp.swift
├── Models/
│   ├── Enums.swift
│   ├── UserGoal.swift
│   ├── WaitingListItem.swift
│   ├── GraveyardItem.swift
│   ├── DarkPatternCard.swift
│   ├── Streak.swift
│   └── UserProfile.swift
├── Views/
│   ├── MainTabView.swift
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── WaitingList/
│   │   └── WaitingListView.swift
│   ├── Graveyard/
│   │   └── GraveyardView.swift
│   ├── LearningLibrary/
│   │   ├── LearningLibraryView.swift
│   │   └── CardStackView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Onboarding/
│       ├── OnboardingCoordinatorView.swift
│       ├── OnboardingScreens.swift
│       └── OnboardingScreens2.swift
├── Components/
│   ├── PrimaryButton.swift
│   ├── SecondaryButton.swift
│   ├── Card.swift
│   ├── FlipCard.swift
│   ├── ProgressBar.swift
│   ├── GoalProgressView.swift
│   ├── CelebrationOverlay.swift
│   ├── MoneyFlyingAnimation.swift
│   ├── BreathingExercise.swift
│   ├── TextField+Styling.swift
│   ├── EmptyStateView.swift
│   ├── HapticFeedback.swift
│   └── AccessibilityModifiers.swift
├── Services/
│   ├── AppState.swift
│   ├── ScreenTimeManager.swift
│   ├── LearningCardService.swift
│   ├── SubscriptionService.swift
│   └── SuperwallService.swift
├── Theme/
│   └── Theme.swift
└── Extensions/
    ├── EXTENSION_SETUP.md
    ├── DeviceActivityMonitor/
    │   └── DeviceActivityMonitorExtension.swift
    ├── ShieldConfiguration/
    │   └── ShieldConfigurationExtension.swift
    └── ShieldAction/
        └── ShieldActionExtension.swift
```

### Data Models (Implemented)

All models use SwiftData `@Model` macro for persistence:

- **UserGoal** — Goal tracking with name, target amount, saved amount, optional image
- **WaitingListItem** — 7-day waiting list with expiration, check-in tracking
- **GraveyardItem** — Buried items with source tracking
- **Streak** — Current/longest streak, grace period tracking
- **UserProfile** — Triggers, difficulty mode, onboarding state

### Enums (Implemented)

- `ShoppingTrigger` — Behavioral triggers from onboarding
- `ShoppingTiming` — When user tends to impulse shop
- `DifficultyMode` — gentle, firm, lockdown
- `GraveyardSource` — waitingList, panicButton, blockIntercept, returned
- `SpendRange` — Monthly spend estimates

---

## Learning Library (Dark Pattern Education)

### Overview

The Learning Library is a tab in the main navigation that provides educational content about shopping manipulation tactics. It's organized into "Learn" (dark pattern cards) and "Tools" (interactive calculators and helpers).

### Features

- **List View** — `LessonsListView` shows all available cards with progress tracking
- **Card Stack View** — `CardStackView` provides full-screen card learning experience
- **Flip Card Mechanic** — Users see a tactic name on front, tap to reveal psychology on back
- **Progress Tracking** — Cards marked as learned, with progress persisted to UserDefaults
- **Review Mode** — After all cards are completed, users can review all cards again
- **Completed Card Styling** — Learned cards appear with 60% opacity in list view
- **Cooldown System** — Cards can resurface after cooldown period (default: 14 days)
- **Shareable Cards** — Cards can be shared as images/text (to be implemented)

### Data Model

`DarkPatternCard` (struct, not SwiftData for V1):
- `id: UUID`
- `sortOrder: Int` — Display sequence
- `icon: String` — Emoji
- `name: String` — Pattern name (e.g., "Fake Urgency")
- `tactic: String` — Example quote (e.g., "Sale ends in 2 hours!")
- `explanation: String` — Psychology explanation
- `reframe: String` — Actionable tip for next time
- `learnedAt: Date?` — nil = not yet learned
- `cooldownDuration: Int` — Days before resurfacing (default: 14)

### Views

| View | Purpose |
|------|---------|
| `LearningLibraryView` | Main tab view with grid: Learn, Podcasts (coming soon), Articles (coming soon), Tools |
| `LessonsListView` | List of all dark pattern cards with progress summary |
| `CardStackView` | Full-screen card learning experience with flip animations and card transitions |

### Components

| Component | Purpose |
|-----------|---------|
| `FlipCard` | Reusable 3D flip card with Y-axis rotation animation |
| `LessonRow` | Card row in list view with icon, name, tactic preview, and completion indicator |

### Services

| Service | Purpose |
|---------|---------|
| `LearningCardService` | Observable service for card data, progress tracking, UserDefaults persistence |

### Animation Specs

- **Card Flip**: 0.4s spring animation, scale dips to 0.95x at midpoint
- **Card Transition**: 0.3s slide-out/slide-in between cards
- **List to Stack Transition**: Custom flip-and-expand animation when opening card from list
- **Haptics**: `HapticFeedback.celebration()` on card completion
- Respects `UIAccessibility.isReduceMotionEnabled`

### Current Cards (V1)

Three cards implemented:

1. **Fake Urgency** ⏰
   - Tactic: "Sale ends in 2 hours!"
   - Explanation: Psychology of loss aversion and timer manipulation
   - Reframe: "Would I want this if there was no timer?"

2. **Dopamine Menu** 📋
   - Tactic: "I'll just browse for a minute..."
   - Explanation: Shopping gives quick dopamine, but alternatives exist. Pre-made menu creates pause.
   - Reframe: "What's on my dopamine menu today?"

3. **Frictionless vs Effortful Dopamine** ⚡
   - Tactic: "One-click purchase"
   - Explanation: Difference between easy dopamine (addictive) and effortful dopamine (satisfying)
   - Reframe: "Can I add friction to this purchase?"

### Card Flow

1. User opens "Learn" from Learning Library tab
2. `LessonsListView` shows all cards with progress summary
3. User taps a card → transitions to `CardStackView` starting at that card
4. Card shows front (icon, name, tactic) → user taps to flip
5. Back shows explanation and reframe → user taps "I understand"
6. Card marked as learned → animates to next available card
7. When all cards learned → completion screen → review mode available

### Future Enhancements

- **Card Sharing** — Generate shareable image/text for each card (Instagram stories format)
- Add remaining cards (Fake Scarcity, Social Proof, Confirm Shaming, etc.)
- Migrate to SwiftData for persistence
- Card grouping by category
- Cooldown visibility UI
- New content notifications
- Podcasts & Articles section

---

## Onboarding Flow (Implemented)

15 screens with progress indicator. All stored in `Views/Onboarding/`:

1. **Welcome** — "Ready to break free from impulse shopping?"
2. **Behaviors** — Multi-select shopping triggers
3. **Timing** — When they impulse shop
4. **Problem Apps** — Educational display of common shopping apps
5. **Monthly Spend** — Estimate selection ($50-100 to $500+)
6. **Impact Visualization** — Animated yearly/decade cost calculation
7. **Goal Selection** — What they'd rather have (includes "Just want to stop wasting")
8. **Goal Details** — Name, amount (if goal type requires details). Shows selected goal type at top with contextual placeholders. 
    **Future: Apple Intelligence integration opportunity** — Use AI to help craft personalized goal descriptions, suggest realistic target amounts based on user's monthly spend, and generate motivational copy.
9. **Commitment** — Tap to commit "I'm done buying things I don't need"
10. **Permission Explanation** — Screen Time access explanation
11. **App Selection** — FamilyActivityPicker (fully integrated)
12. **Website Blocking** — Option to block shopping sites in Safari
13. **Selection Confirmation** — Show selected apps
14. **How It Works** — Animated walkthrough of the 7-day waiting list flow
15. **Difficulty Mode** — Gentle/Firm/Lockdown selection

### Future Onboarding Addition: Shortcuts Setup

After entitlement approval, add optional screen for rich intervention:

**"Supercharge Your Blocks" (Optional)**
```
┌─────────────────────────────────────┐
│                                     │
│    Want breathing exercises when    │
│    you try to open shopping apps?   │
│                                     │
│    We'll set up a Shortcut that     │
│    opens SpendLess first.           │
│                                     │
│    ┌─────────────────────────────┐  │
│    │      Set Up Shortcut        │  │
│    └─────────────────────────────┘  │
│                                     │
│           Skip for now              │
│                                     │
└─────────────────────────────────────┘
```

This enables the rich intervention flows (breathing exercises, item logging, questionnaires) that aren't possible within the Shield screen itself.

---

## Core Feature: Block Intercept Flow

### Critical: Shield API Limitations

**Apple's ShieldConfiguration API is severely limited.** You can only customize:

| Element | What You Control |
|---------|------------------|
| `backgroundBlurStyle` | UIBlurEffect style |
| `backgroundColor` | UIColor |
| `icon` | UIImage (your app logo) |
| `title` | ShieldConfiguration.Label (text + color) |
| `subtitle` | ShieldConfiguration.Label (text + color) |
| `primaryButtonLabel` | ShieldConfiguration.Label (text + color) |
| `primaryButtonBackgroundColor` | UIColor |
| `secondaryButtonLabel` | ShieldConfiguration.Label (optional) |

**You CANNOT:**
- Add custom SwiftUI views or layouts
- Add text input fields
- Add more than 2 buttons
- Show animations
- Display dynamic data (streak, savings) that updates in real-time
- Open your parent app from a button tap

**Button actions are limited to three responses:**
- `.close` — Dismiss shield, app stays blocked
- `.defer` — Redraw the shield (can update text via App Groups)
- `.none` — Do nothing

**There is NO `.openParentApp` option.** Apple explicitly does not support opening the parent app from a ShieldActionExtension. Developers have tried `openURL` with deep links and `NSExtensionContext` but neither works.

### How Apps Like "one sec" Handle This

Apps like "one sec" that show breathing exercises use **iOS Shortcuts Automations**, not the Shield screen:

1. User sets up a Shortcut that triggers "When [App] is opened"
2. The Shortcut runs and opens the parent app (one sec) first
3. Parent app shows full custom UI (breathing exercise, etc.)
4. After completion, parent app can open the target app or dismiss

**Tradeoff:** This requires users to manually set up Shortcuts during onboarding, which adds friction but enables full UI flexibility.

### SpendLess Hybrid Approach

We'll use **both** methods:

**Method 1: Shield Screen (Simple Intercept)**
For basic blocking with limited but branded UI.

**Method 2: Shortcuts Automation (Rich Intercept)** 
For full breathing exercises, item logging, questionnaires. Requires user setup during onboarding.

---

### Shield Screen Design (What's Actually Possible)

The shield is a **gateway**, not a full intervention UI. Keep it simple and redirect complex flows to the main app via Shortcuts.

```
┌─────────────────────────────────────┐
│                                     │
│         [SpendLess Icon]            │
│                                     │
│           🛑 HOLD ON                │
│                                     │
│      Is this a need or a want?      │
│                                     │
│    ┌─────────────────────────────┐  │
│    │     I need to think...      │  │  ← Primary: Dismiss, stay blocked
│    └─────────────────────────────┘  │
│                                     │
│         Let me in anyway            │     ← Secondary: Unlock for 15 min
│                                     │
└─────────────────────────────────────┘
```

**What we CAN show via App Groups shared data:**
- Custom title/subtitle text based on difficulty mode
- User's goal name in the subtitle
- Different messages based on time of day

**What we CANNOT show:**
- Live streak counter
- Savings amount (would need constant updates)
- Text input fields
- Multi-step flows

### Shield Configuration by Difficulty Mode

**Gentle Mode:**
```swift
ShieldConfiguration(
    backgroundColor: .systemBackground,
    icon: UIImage(named: "AppIcon"),
    title: ShieldConfiguration.Label(text: "Pause", color: .label),
    subtitle: ShieldConfiguration.Label(text: "Is this bringing you closer to [Goal]?", color: .secondaryLabel),
    primaryButtonLabel: ShieldConfiguration.Label(text: "You're right, I'll pass", color: .white),
    primaryButtonBackgroundColor: .systemGreen,
    secondaryButtonLabel: ShieldConfiguration.Label(text: "Let me in", color: .systemBlue)
)
```
- Primary: `.close` (dismiss, stay blocked)
- Secondary: Unlock app for 15 minutes, log intercept

**Firm Mode:**
```swift
ShieldConfiguration(
    backgroundColor: .systemBackground,
    icon: UIImage(named: "AppIcon"),
    title: ShieldConfiguration.Label(text: "🛑 Stop", color: .systemRed),
    subtitle: ShieldConfiguration.Label(text: "Take a breath. Open SpendLess to continue.", color: .secondaryLabel),
    primaryButtonLabel: ShieldConfiguration.Label(text: "Open SpendLess", color: .white),
    primaryButtonBackgroundColor: .systemOrange,
    secondaryButtonLabel: nil  // No easy escape
)
```
- Primary: `.close` — User must manually open SpendLess app for breathing exercise
- Note: We can't auto-open our app, but we can instruct user to do so

**Lockdown Mode:**
```swift
ShieldConfiguration(
    backgroundColor: .black,
    icon: UIImage(named: "AppIcon"),
    title: ShieldConfiguration.Label(text: "Blocked", color: .white),
    subtitle: ShieldConfiguration.Label(text: "This app is off-limits right now.", color: .gray),
    primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
    primaryButtonBackgroundColor: .darkGray,
    secondaryButtonLabel: nil
)
```
- Primary: `.close` — No access, period

---

### Shortcuts-Based Rich Intervention (Firm/Pro Mode)

For full intervention flows (breathing exercises, item logging, questionnaires), we guide users to set up a Shortcut automation during onboarding.

**Shortcut Setup Flow:**
1. Open Shortcuts app (we provide deep link)
2. Create new Automation → "App" → "Is Opened"
3. Select the shopping apps
4. Action: "Open App" → SpendLess
5. Turn off "Ask Before Running"

**When Shortcut Triggers:**
SpendLess opens with a deep link parameter indicating which app triggered it. We show:

1. **Breathing Exercise** (4-7-8 breathing, animated)
2. **Reflection Prompt**: "What were you looking for?"
3. **Options:**
   - "Just browsing" → Log $1, show encouragement, dismiss
   - "Something specific" → Open item logging flow
   - "I actually need this" → Questionnaire (Pro)

4. **After completion**, user can:
   - Return to home screen (default)
   - Proceed to the target app (we open it via URL scheme if they pass questionnaire)

---

### Main App: Full Intervention Flow

When SpendLess opens (via Shortcut or manually during urge):

**Screen 1: Breathing Exercise**
```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│         [Animated Circle]           │
│          Expanding/Contracting      │
│                                     │
│          Breathe in...              │
│                                     │
│            4 seconds                │
│                                     │
│                                     │
└─────────────────────────────────────┘
```
- 4-7-8 breathing: Inhale 4s, Hold 7s, Exhale 8s
- Visual: Circle expands/contracts
- Haptic feedback on transitions
- Skip option after first cycle (not recommended)

**Screen 2: Reflection**
```
┌─────────────────────────────────────┐
│                                     │
│    What brought you here?           │
│                                     │
│    ┌─────────────────────────────┐  │
│    │      Just browsing          │  │
│    └─────────────────────────────┘  │
│    ┌─────────────────────────────┐  │
│    │   Something specific        │  │
│    └─────────────────────────────┘  │
│    ┌─────────────────────────────┐  │
│    │   I actually need this      │  │
│    └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**"Just Browsing" Path:**
- Show: "Browsing leads to buying. You've been shopping-free for X days."
- Auto-add $1 to savings (small win)
- Button: "Back to what I was doing" (dismiss to home screen)

**"Something Specific" Path:**
```
┌─────────────────────────────────────┐
│                                     │
│    What is it?                      │
│    ┌─────────────────────────────┐  │
│    │ Wireless earbuds            │  │
│    └─────────────────────────────┘  │
│                                     │
│    How much?                        │
│    ┌─────────────────────────────┐  │
│    │ $ 79                        │  │
│    └─────────────────────────────┘  │
│                                     │
│    Why do you want it? (optional)   │
│    ┌─────────────────────────────┐  │
│    │ My old ones broke           │  │
│    └─────────────────────────────┘  │
│                                     │
│    ┌─────────────────────────────┐  │
│    │  Add to 7-day Waiting List  │  │
│    └─────────────────────────────┘  │
│                                     │
│    "If you still want it in 7       │
│    days, buy it guilt-free."        │
│                                     │
└─────────────────────────────────────┘
```
- Creates `WaitingListItem`
- Celebration animation (money flies to goal)
- Returns to home screen (NOT to shopping app)

**"I Actually Need This" Path (Pro):**

Questionnaire flow — one question per screen:

1. "Do you already own something similar?" [Yes/No]
2. "Will you still want this in 30 days?" [Yes/No]
3. "Did you know about this item before today?" [Yes/No]
4. "Is this in your budget?" [Yes/No]
5. "Are you buying because of a sale?" [Yes/No]

**Scoring:**
- Good answers: No, Yes, Yes, Yes, No
- 4-5 good: "Seems like a real need. Go ahead." → Open target app
- 2-3 good: "This might be an impulse. Add to waiting list instead?"
- 0-1 good: "This looks like impulse buying." → Encouragement, no access

---

## Core Feature: Waiting List (Implemented)

### Waiting List Tab View

```
┌─────────────────────────────────────┐
│  ⏳ WAITING LIST                    │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 🎧 Wireless earbuds — $79       ││
│  │    5 days remaining             ││
│  │    ░░░░░░░████████████          ││
│  │    [Still want it] [Bury it]    ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 👟 Running shoes — $120         ││
│  │    2 days remaining             ││
│  │    ░░░░░░░░░░░░░░░████          ││
│  │    [Still want it] [Bury it]    ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐ │
│    + Add something you resisted     │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘ │
│                                     │
└─────────────────────────────────────┘
```

### Reminder Notifications (Deferred)

Schedule local notifications for waiting list items:

- **Day 2:** "Still thinking about [item]? 5 days left on the clock."
- **Day 4:** "Halfway there. Still want [item]?" (Deep link to item)
- **Day 6:** "Tomorrow's the day. Still want [item]?"
- **Day 7:** "Time's up for [item]! Decide: buy it or bury it?"

### Actions

**"Still want it":**
- Resets nothing, just acknowledges
- Increment `checkinCount`
- Optional: extend by 2 more days if they've checked in 3+ times

**"Bury it":**
- Move to Graveyard
- Add amount to `UserGoal.savedAmount`
- Celebration animation (money flying to goal, confetti)
- Haptic feedback

**"Buy it" (Day 7 only):**
- Briefly unlock the relevant app category (15 min)
- Remove from waiting list
- No judgment, no savings added
- Track for analytics

---

## Core Feature: Cart Graveyard (⏸️ On Hiatus)

**Status:** This feature is currently on hiatus and not being actively developed. The code exists but future enhancements are deferred.

### Graveyard Tab View

```
┌─────────────────────────────────────┐
│  🪦 CART GRAVEYARD                  │
│  "Things you wanted. Then didn't."  │
│                                     │
│  ┌─────────────────────────────────┐│
│  │  Total buried: $2,847           ││
│  │  Items resisted: 47             ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 🎧 Sony headphones      $249    ││
│  │ Buried 34 days ago              ││
│  │ "I already have headphones"     ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 👗 Floral dress          $47    ││
│  │ Buried 21 days ago              ││
│  │ "Don't even remember this"      ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

### Item Sources
Items enter the graveyard from:
1. Waiting list expiration/dismissal
2. Panic button logging
3. Block intercept "walked away" actions
4. Manual entry
5. Returns (with special 🔄 badge)

### Returns Tracking

Returning an impulse purchase is a win too — it shows growing awareness.

**"I Returned Something" Flow:**
```
┌─────────────────────────────────────┐
│                                     │
│    🔄 Log a Return                  │
│                                     │
│    What did you return?             │
│    ┌─────────────────────────────┐  │
│    │ That dress from last week   │  │
│    └─────────────────────────────┘  │
│                                     │
│    How much was it?                 │
│    ┌─────────────────────────────┐  │
│    │ $67                         │  │
│    └─────────────────────────────┘  │
│                                     │
│    ┌─────────────────────────────┐  │
│    │       Log Return            │  │
│    └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Returns in Graveyard:**
Show with special badge:
```
┌─────────────────────────────────────┐
│ 👗 That dress           $67   🔄   │
│ Returned 2 days ago                 │
│ "Realized I have 3 just like it"   │
└─────────────────────────────────────┘
```

**Returns in Stats:**
- Track separately: "X items returned, $Y recovered"
- Different from "money not spent" — this is money actually back

### Pro Features (Graveyard Analytics) — Deferred
- Total amount saved (all time)
- Monthly/weekly breakdowns
- Category breakdown (clothing, electronics, home, etc.)
- "Most resisted" insights
- Export to PDF/share image

---

## Core Feature: Home Dashboard (Implemented)

### Dashboard Layout

```
┌─────────────────────────────────────┐
│                                     │
│            ✈️ PARIS 🗼              │
│         [Goal Image Here]           │
│                                     │
│    ████████████░░░░░░░░░░░░░░░░     │
│           $1,247 / $4,500           │
│              27% there              │
│                                     │
│    "You'll be sipping wine by       │
│     the Seine in no time"           │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🔥 18 day streak                   │
│                                     │
│  💰 $89 saved this week             │
│                                     │
│  🛒 12 impulses resisted            │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────────┐│
│  │        🆘 PANIC BUTTON          ││
│  │     "Feeling tempted?"          ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

### Savings Visualization

When money is added (from any source):
- Animate money flying into the goal
- Update progress bar with spring animation
- Show contextual message:
  - "That Shein haul → 3 croissants in Paris"
  - "+$79 → 2% closer to your goal"
- Haptic feedback (success)

### Streak Logic
- Streak = consecutive days without opening a blocked app
- Breaking a streak: Actually accessing a blocked app (not just triggering the shield)
- Display: "🔥 X day streak"
- Milestones: 7, 14, 30, 60, 90 days (special celebrations)

### Panic Button (Implemented)
Large, prominent button for when user feels urge but isn't at a blocked app.

**Flow:**
1. Tap panic button
2. Optional breathing exercise (15-30 seconds)
3. "What were you about to buy?"
4. Log item name + amount
5. "You just saved $X. It's now in your goal."
6. Move to graveyard
7. Celebration animation

---

## Core Feature: Goal Completion & No-Goal Mode

### When User Reaches Their Goal

When `savedAmount >= targetAmount`, trigger celebration flow:

**Screen 1: Celebration**
```
┌─────────────────────────────────────┐
│                                     │
│            🎉🎉🎉                   │
│                                     │
│        YOU DID IT!                  │
│                                     │
│    ✈️ Paris is yours 🗼             │
│                                     │
│    You resisted 47 impulses         │
│    over 89 days to get here.        │
│                                     │
│    ┌─────────────────────────────┐  │
│    │      Share My Win 📲        │  │
│    └─────────────────────────────┘  │
│                                     │
│    [Continue]                       │
│                                     │
└─────────────────────────────────────┘
```

- Confetti animation
- Haptic celebration
- **Share button** generates a card for Instagram/social (deferred)

**Screen 2: Now What?**
```
┌─────────────────────────────────────┐
│                                     │
│    Now go enjoy Paris!              │
│                                     │
│    And when you're ready...         │
│                                     │
│    ┌─────────────────────────────┐  │
│    │    Set a new goal           │  │
│    └─────────────────────────────┘  │
│                                     │
│    ┌─────────────────────────────┐  │
│    │    Keep saving (no goal)    │  │
│    └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### Important: Savings ≠ Actual Money

**Critical distinction:** Skipping purchases means money NOT spent, not money earned.

**How we handle this:**
- Never say "You earned $X" — say "You didn't spend $X"
- Frame as "kept in your pocket" not "added to your account"
- Goal progress is motivational, not a literal bank account
- Consider copy like:
  - "You've kept $1,247 in your pocket"
  - "$1,247 not wasted on impulse buys"
  - "That's $1,247 that didn't disappear"

### "No Goal" Mode — Cash Pile Visualization

For users who selected "Just want to stop wasting" or finished a goal:

```
┌─────────────────────────────────────┐
│                                     │
│            💰💰💰                   │
│         [Cash pile grows]           │
│                                     │
│    $2,847 kept in your pocket       │
│                                     │
│    "Money you didn't waste          │
│     on things you didn't need"      │
│                                     │
│    ┌─────────────────────────────┐  │
│    │   Set a goal for this? →    │  │
│    └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

- Cash pile grows visually as savings increase
- Periodically prompt: "You've saved enough for [X]. Want to make it a goal?"

---

## Core Feature: Relapse Handling

### Philosophy
Recovery, not punishment. Users will slip — our job is to help them get back on track without shame.

### When a Streak Breaks

If user accesses a blocked app (passes through all friction):

**Immediate Response:**
```
┌─────────────────────────────────────┐
│                                     │
│    It happens.                      │
│                                     │
│    You opened [App] after           │
│    a 12-day streak.                 │
│                                     │
│    What matters is what you         │
│    do next.                         │
│                                     │
│    ┌─────────────────────────────┐  │
│    │   Start fresh tomorrow      │  │
│    └─────────────────────────────┘  │
│                                     │
│    ┌─────────────────────────────┐  │
│    │   I didn't buy anything!    │  │
│    └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**"I didn't buy anything" option:**
- Acknowledge the win: "Browsing without buying is progress!"
- Offer streak preservation: "Want to keep your streak going?"
- If yes: streak continues (grace period — limit to 1x per week)
- Track this separately for analytics

### Educational Content on Relapse

Show once after first relapse, then available in Settings:

**"Why We Slip"**
- Triggers: stress, boredom, FOMO, sales pressure
- It's neurological, not moral failure
- Each slip is data, not defeat

**"Getting Back Up"**
- Don't "what the hell" spiral (one slip → buying spree)
- Identify what triggered this instance
- Adjust your blocked apps or difficulty if needed
- Tomorrow is a new day

### Relapse Tracking (Internal)

Track for user's own insight (not for shaming):
- Date/time of relapse
- Which app
- Optional: what they bought (self-reported)
- Patterns over time (Pro feature: "You tend to slip on Sundays")

---

## Contextual Education (First-Time Experiences)

Instead of explaining all features in onboarding, teach them in context.

### First Block Intercept
Add an info card at the top of the shield screen:
```
💡 NEW: How this works
You can tell us what you wanted, add it to your Waiting List, or walk away and save the money.
```

### First Waiting List Add
After adding first item, show modal:
```
💡 Here's how it works:
We'll check in every 2 days. If you still want it after 7 days, you can buy it guilt-free.
Most people forget about 70% of the things they add here.
[Got it]
```

### First Burial
After first item goes to graveyard:
```
🪦 BURIED
"Wireless earbuds — $79" has been sent to your Cart Graveyard.

💵 +$79 → ✈️🗼

You're now 2% closer to [goal]!

💡 Your Cart Graveyard is where forgotten impulses go to rest. Visit anytime to see how much you've saved.

[View Graveyard] [Continue]
```

---

## Core Feature: Sharing & Social Proof (Deferred)

### Shareable Moments

Generate shareable cards (PNG/Instagram stories format) for:

1. **Goal Completion** — "I saved $4,500 for Paris by skipping impulse buys ✈️"
2. **Milestone Streaks** — "🔥 30 days impulse-free"
3. **Graveyard Flex** — "My Cart Graveyard: 47 things I didn't need"
4. **Weekly/Monthly Wins** — "This month: $340 kept in my pocket"

### Implementation (Deferred)
- Generate card as UIImage
- Use `UIActivityViewController` for native share sheet
- Pre-populate caption: "Stopped impulse shopping with @spendlessapp 💪"

---

## Settings Screen (Implemented)

```
┌─────────────────────────────────────┐
│  ⚙️ SETTINGS                        │
│                                     │
│  BLOCKING                           │
│  ├─ Blocked Apps          [Edit →]  │
│  ├─ Difficulty Mode       [Firm →]  │
│  └─ Block Schedule        [Pro 🔒]  │
│                                     │
│  MY GOAL                            │
│  ├─ Edit Goal             [Edit →]  │
│  └─ Reset Savings         [Reset]   │
│                                     │
│  ACCOUNT                            │
│  ├─ Upgrade to Pro        [Pro →]   │
│  ├─ Restore Purchases              │
│  └─ Export My Data        [Pro 🔒]  │
│                                     │
│  ABOUT                              │
│  ├─ How SpendLess Works            │
│  ├─ Privacy Policy                 │
│  ├─ Terms of Service               │
│  └─ Contact Support                │
│                                     │
│  DEBUG (Dev only)                   │
│  ├─ Reset Onboarding               │
│  └─ Add Sample Data                │
│                                     │
│  Version 1.0.0                      │
│                                     │
└─────────────────────────────────────┘
```

---

## Notifications Strategy (Deferred)

### Types of Notifications

**Waiting List Reminders** (Core feature)
- Day 2, 4, 6, 7 check-ins for each item
- Deep link to specific item

**Streak Celebrations** (Engagement)
- "🔥 7 day streak! You're on fire."
- Milestone celebrations at 14, 30, 60, 90 days

**Weekly Summary** (Engagement)
- Sunday evening: "This week: X impulses resisted, $Y saved. You're Z% closer to [goal]."

**Re-engagement** (Retention)
- If no app opens in 7 days: "Still on track? Your streak is at X days."

### Implementation Notes
- All notifications are local (no push server needed for v1)
- Request notification permission after onboarding, not during
- Allow granular control in Settings

---

## Features Not Yet Implemented

### V1 Gaps (Should implement before launch)

| Feature | Priority | Notes |
|---------|----------|-------|
| Notification Manager | High | Waiting list reminders are critical |
| No-Goal Mode UI | Medium | Cash pile visualization for users without specific goals |
| Relapse Handling Flow | Medium | Grace period logic, educational content |
| Returns Logging | Low | Already in graveyard, just needs dedicated entry point |
| Paywall Integration | High | RevenueCat + Superwall, trial + subscription model |
| Card Sharing | Medium | Generate shareable images/text for dark pattern cards |
| Share to Waitlist | Medium | Share items from Amazon/Target directly to waitlist (iOS Share Extension) |

### V1.5 Feature Candidates

These features have strong research backing but aren't essential for MVP. Consider adding after launch based on user feedback.

#### 1. Additional Dark Pattern Cards

Currently 3 cards implemented. Add remaining cards to expand library:

**Remaining Cards to Add:**
| Name | Tactic | Reality |
|------|--------|---------|
| Fake Scarcity | "Only 3 left!" | There's almost always more. They want panic-buying. |
| Social Pressure | "47 people viewing this" | Designed to trigger competition anxiety. |
| Confirm Shaming | "No thanks, I hate saving" | Guilt language to manipulate you. |
| Hidden Costs | "Free shipping at $50!" | You'll spend $20 to "save" $5. |
| Anchoring | "Was $200, now $79!" | The "original" price may never have existed. |
| One-Click Trap | "Buy Now™" | Eliminates pause between impulse and purchase. |
| Infinite Scroll | Keep scrolling... | Keeps you browsing longer than intended. |
| Push Notifications | "Your cart misses you 🥺" | Engineered to trigger FOMO. |
| Personalized Ads | "Picked just for you!" | Algorithms exploit your weaknesses. |
| Loyalty Traps | "You're 50 points from Gold!" | Designed to keep you spending |
| Subscription Creep | "Subscribe & save 15%" | Recurring charges you'll forget |

**Future Delivery Options:**
- Daily card on dashboard (swipeable)
- Contextual: show relevant card when user logs item from specific app
- Card grouping by category (urgency tactics, social proof, pricing tricks)

#### 2. ADHD-Friendly Considerations

Research shows ADHD brains are 4x more likely to impulse shop due to dopamine deficits.

**"ADHD Mode" toggle in Settings:**
- Extra celebratory animations (more dopamine)
- Shorter waiting list check-ins (every day instead of every 2 days)
- More aggressive gamification
- Simpler breathing exercise (shorter, more visual)

**Time blindness helpers:**
- Show "X days until [goal]" prominently
- "You've been shopping-free longer than [relatable comparison]"

**Default to automation over willpower:**
- Encourage Shortcuts setup
- Auto-add $1 on every resist

#### 3. HALT Check Integration ✅ **IMPLEMENTED**

HALT (Hungry, Angry, Lonely, Tired) check is integrated as an intervention step.

**Implementation:**
- `InterventionHALTCheckView` — Shows HALT state selection
- `InterventionManager` — Manages HALT check flow and redirect logic
- Available as standalone intervention type or part of full flow
- When HALT state selected → shows redirect screen with contextual suggestions
- User can accept redirect (adds $1 to savings) or decline and continue

**Flow:**
1. User triggers intervention (via Shortcut or panic button)
2. HALT check screen appears: "How are you feeling?"
3. User selects state(s): Hungry 🍎, Angry 😠, Lonely 💬, Tired 😴
4. If state selected → Redirect screen with suggestions
5. If "I'm fine, actually" → Continues to reflection step

#### 4. Dopamine Menu ✅ **IMPLEMENTED**

Dopamine Menu is implemented as a tool in the Learning Library and as an intervention step.

**Implementation:**
- `DopamineMenuView` — Main tool view accessible from Learning Library → Tools
- `DopamineMenuSetupView` — Setup/editing interface for customizing activities
- `InterventionDopamineMenuView` — Shows menu during intervention flow
- Integrated into intervention flow when user selects "Just Browsing"
- Activities stored in `UserProfile.dopamineMenuSelectedDefaults` and `dopamineMenuCustomActivities`

**Default Activities:**
- 🚶 Go for a 10-minute walk
- 💬 Text a friend something nice
- 🎨 Make something (draw, cook, craft)
- 🗂️ Organize one drawer
- 📺 Watch one episode of something
- 🧘 Do 5 minutes of stretching
- 📝 Write 3 things you're grateful for
- 🎵 Put on your favorite album

**Features:**
- Users can select from default activities
- Users can add custom activities
- Setup required on first use
- Editable from Settings → Tools → Dopamine Menu
- Shows in intervention flow as alternative to shopping

#### 5. Letter to Future Self

**During Onboarding (after commitment):**
```
"When you're tempted, what should future-you say?"

[Text field with placeholder: "Remember why you started..."]
```

**Resurface during:**
- Shield screen subtitle (if we can fit it)
- Panic button flow
- After a relapse

#### 6. Saved Payment Removal Walkthrough

Guided flow to remove saved cards from common shopping apps. Show during onboarding or in Settings → "Boost Your Defenses".

**For each app they selected:**
```
Amazon:
1. Open Amazon app
2. Tap ☰ → Your Account
3. Tap "Manage payment methods"
4. Remove all cards except one

[I did it! ✓]  [Skip]
```

Cover: Amazon, Target, Walmart, Shein, Temu, Apple Pay, Google Pay, PayPal

#### 7. Gamification System (V2)

**SpendLess Coins:**
- Earn coins for: burying items (10), panic resist (15), daily check-in (5), streak milestones (25-100)
- Spend on: Dashboard themes, goal frames, celebration effects, profile badges

**Achievement Badges:**
| Badge | Requirement |
|-------|-------------|
| First Blood 🪦 | Bury first item |
| Week Warrior 🔥 | 7-day streak |
| Month Master 🏆 | 30-day streak |
| Century Club 💯 | $100 saved |
| Grand Saver 💰 | $1,000 saved |
| Graveyard Keeper ⚰️ | 25 items buried |
| Panic Pro 🆘 | Panic button 10x |
| Pattern Spotter 👁️ | View all dark pattern cards |

**Weekly Challenges:**
- "Resist 5 impulses this week" — 25 coins
- "Use panic button 3x" — 20 coins
- "Bury $100+ worth" — 50 coins

#### 8. Danger Time Auto-Detection (V2)

Track when users most often:
- Trigger blocked apps
- Use panic button
- Add items to waiting list

After 2 weeks of data:
- "You shop most on Sunday evenings. Want extra protection then?"
- Auto-switch to Firm mode during detected danger times
- Send preemptive notification: "Heads up — you're entering your danger zone"

#### 9. Email Unsubscribe Integration (V2)

**Limitation:** Gmail OAuth only. iOS Mail lacks API access.

**Flow:**
1. Connect Gmail account
2. Scan for emails from shopping domains
3. Show list: "Found 23 shopping emails from last 30 days"
4. Let user select which to unsubscribe from
5. Process `List-Unsubscribe` headers

**Privacy:** Process on-device, don't store email content

#### 10. Widget Support (V2)

**Home Screen Widget Options:**
- Streak counter with flame animation
- Goal progress bar
- "Panic" quick-action widget → Opens breathing exercise
- HALT check widget → Quick mood check

---

## Privacy Considerations

### Data That Never Leaves Device
- Browsing history
- Specific apps accessed
- Purchase information
- Goal details

### What We Track (with consent, when implemented)
- Anonymized feature usage
- Crash reports
- Aggregate savings amounts (for social proof)

---

## Future Considerations (V2+)

### Community Features
- Anonymous forum
- Accountability partners
- Shared challenges
- Will require backend

### Detailed Analytics
- Spending trigger analysis
- Time-of-day patterns
- Category insights
- Danger time detection

### Additional Platforms
- iPad support
- Apple Watch (streak glances, panic button complication)
- Widgets (streak, goal progress)

### Apple Intelligence Integration Opportunities

## Some are located here others in the AppleIntelligenceFeatures.md

**Goal Details Screen (Onboarding Screen 8):**
- Use AI to help craft personalized goal descriptions based on selected goal type
- Suggest realistic target amounts based on user's monthly spend estimate
- Generate motivational copy tailored to the specific goal (e.g., "You'll be sipping wine by the Seine" for vacation goals)
- Provide contextual examples and inspiration based on goal type

**Other Potential AI Enhancements:**
- Personalized activity suggestions in panic button flow
- Smart waiting list check-in messages that adapt to user's progress
- Contextual encouragement messages that reference user's specific triggers and goals
- Intelligent goal translation updates ("$79 saved → 2 museum tickets in Paris")

---

## Appendix A: Key Resources

### Essential Reading (Before Writing Any Code)

**Apple WWDC Sessions:**
- "Meet the Screen Time API" (WWDC21): https://developer.apple.com/videos/play/wwdc2021/10123/
- "What's New in Screen Time API" (WWDC22): https://developer.apple.com/videos/play/wwdc2022/110336/

**Best Implementation Guide:**
- "A Developer's Guide to Apple's Screen Time APIs" by Julius Brussee: https://medium.com/@juliusbrussee/a-developers-guide-to-apple-s-screen-time-apis-familycontrols-managedsettings-deviceactivity-e660147367d7

Key insights from this guide:
- FamilyControls handles authorization and what to block
- ManagedSettings enforces the actual blocks
- DeviceActivity controls when blocks activate/deactivate
- You MUST apply for the entitlement for every app target (main app + each extension)

**Additional Tutorials:**
- "Using Screen Time API to block apps for a specified time": http://pedroesli.com/2023-11-13-screen-time-api/
- "Monitoring App Usage using the Screen Time Framework" (Streaks app): https://crunchybagel.com/monitoring-app-usage-using-the-screen-time-api/

**Apple Documentation:**
- FamilyControls: https://developer.apple.com/documentation/familycontrols
- ManagedSettings: https://developer.apple.com/documentation/managedsettings
- DeviceActivity: https://developer.apple.com/documentation/deviceactivity

### Entitlement Request Process

✅ **COMPLETE** — All entitlements approved and active

1. ~~Go to: https://developer.apple.com/contact/request/family-controls-distribution~~ ✅
2. ~~Submit request for EACH target~~ ✅
   - Main app bundle ID ✅
   - DeviceActivityMonitor extension bundle ID ✅
   - ShieldConfiguration extension bundle ID ✅
   - ShieldAction extension bundle ID ✅
3. ~~Provide clear explanation of app purpose~~ ✅
4. ~~Expect 2-6 weeks for approval~~ ✅ **APPROVED**
5. ~~No confirmation email is sent — approval appears in developer portal~~ ✅

**Status:** All entitlements approved. Development and distribution entitlements active for all targets.

**Next Steps (Verification):**
- [ ] Verify Family Controls entitlement is enabled in Xcode for all targets:
  - Main app target → Signing & Capabilities → Add "Family Controls" capability
  - DeviceActivityMonitorExtension target → Add capability
  - ShieldConfigurationExtension target → Add capability
  - ShieldActionExtension target → Add capability
- [ ] Verify App Groups are configured for all targets (required for data sharing)
- [ ] Verify entitlements files (`.entitlements`) include `com.apple.developer.family-controls`
- [ ] Test on physical device to confirm shields are working

### Known API Limitations & Bugs

From one sec app's documentation (https://tutorials.one-sec.app/en/articles/3036354):
- Max 50 app tokens can be shielded at once
- Max 50 named ManagedSettingsStores
- Max 20 DeviceActivity schedules
- FamilyActivityPicker may crash when searching — use dictation or paste instead
- Having Screen Time enabled on multiple devices can cause sync issues
- "Block all" may ignore exemption lists — use iOS Settings > Screen Time > Always Allowed instead

---

## Appendix B: Screen Time API Reference

### Authorization Flow
```swift
import FamilyControls

let center = AuthorizationCenter.shared

Task {
    do {
        try await center.requestAuthorization(for: .individual)
        // Success — can now use FamilyActivityPicker
    } catch {
        // Handle error — show explanation, retry option
    }
}
```

### App Selection
```swift
import SwiftUI
import FamilyControls

struct AppSelectionView: View {
    @State private var selection = FamilyActivitySelection()
    @State private var isPickerPresented = false
    
    var body: some View {
        Button("Select Apps") {
            isPickerPresented = true
        }
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $selection
        )
        .onChange(of: selection) { newValue in
            // Save selection to UserDefaults/SwiftData
            // Selection contains opaque tokens, not app names
        }
    }
}
```

### Applying Shields (Apps + Websites)
```swift
import ManagedSettings

let store = ManagedSettingsStore()

// Block selected apps
store.shield.applications = selection.applicationTokens
store.shield.applicationCategories = .specific(selection.categoryTokens)

// Block shopping websites in Safari/Chrome
store.shield.webDomains = selection.webDomainTokens
store.shield.webDomainCategories = .specific(selection.categoryTokens)

// To remove blocks
store.clearAllSettings()
```

**Note on Web Blocking:**
- `webDomainCategories` blocks entire categories (e.g., all Shopping sites)
- `webDomains` blocks specific domains user selected
- Works in Safari, Chrome, and most browsers that respect Screen Time
- When blocked, shows the same shield UI as blocked apps

### Setting Up Extensions

You need THREE extensions. Add each via File > New > Target:

1. **Device Activity Monitor Extension**
   - Template: "Device Activity Monitor Extension"
   - Responds to schedule start/end events
   - Apply shields when schedule starts

2. **Shield Configuration Extension**
   - Template: "Shield Configuration Extension"  
   - Customize the blocking screen appearance
   - Return ShieldConfiguration (NOT custom SwiftUI views)

3. **Shield Action Extension**
   - Template: "Shield Action Extension"
   - Handle button taps on the shield screen
   - Process user responses (`.close`, `.defer`, `.none`)

### App Groups Setup (Required)

Extensions run in separate processes and need shared data access:

```swift
// 1. Add App Groups capability to ALL targets
// Format: group.com.yourcompany.spendless.data

// 2. Use shared UserDefaults
let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.spendless.data")

// 3. Store FamilyActivitySelection
func saveSelection(_ selection: FamilyActivitySelection) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(selection) {
        sharedDefaults?.set(encoded, forKey: "blockedApps")
    }
}

func loadSelection() -> FamilyActivitySelection? {
    guard let data = sharedDefaults?.data(forKey: "blockedApps") else { return nil }
    return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
}
```

### Shield Configuration Example

```swift
import ManagedSettingsUI
import ManagedSettings

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Read difficulty mode from shared UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
        let difficultyRaw = sharedDefaults?.string(forKey: "difficultyMode") ?? "gentle"
        
        switch difficultyRaw {
        case "lockdown":
            return ShieldConfiguration(
                backgroundColor: .black,
                icon: UIImage(named: "AppIcon"),
                title: ShieldConfiguration.Label(text: "Blocked", color: .white),
                subtitle: ShieldConfiguration.Label(text: "This app is off-limits.", color: .gray),
                primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
                primaryButtonBackgroundColor: .darkGray,
                secondaryButtonLabel: nil
            )
        case "firm":
            return ShieldConfiguration(
                backgroundColor: .systemBackground,
                icon: UIImage(named: "AppIcon"),
                title: ShieldConfiguration.Label(text: "🛑 Stop", color: .systemRed),
                subtitle: ShieldConfiguration.Label(text: "Open SpendLess to continue.", color: .secondaryLabel),
                primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
                primaryButtonBackgroundColor: .systemOrange,
                secondaryButtonLabel: nil
            )
        default: // gentle
            return ShieldConfiguration(
                backgroundColor: .systemBackground,
                icon: UIImage(named: "AppIcon"),
                title: ShieldConfiguration.Label(text: "Pause", color: .label),
                subtitle: ShieldConfiguration.Label(text: "Is this a need or a want?", color: .secondaryLabel),
                primaryButtonLabel: ShieldConfiguration.Label(text: "I'll pass", color: .white),
                primaryButtonBackgroundColor: .systemGreen,
                secondaryButtonLabel: ShieldConfiguration.Label(text: "Let me in", color: .systemBlue)
            )
        }
    }
}
```

### Device Activity Monitor Example

```swift
import DeviceActivity
import ManagedSettings

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Load saved selection and apply shields
        if let selection = loadSelection() {
            store.shield.applications = selection.applicationTokens
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Remove shields when schedule ends
        store.clearAllSettings()
    }
    
    private func loadSelection() -> FamilyActivitySelection? {
        let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
        guard let data = sharedDefaults?.data(forKey: "blockedApps") else { return nil }
        return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    }
}
```

### Testing Notes

- ✅ **Physical device testing in progress** — Screen Time APIs working correctly
- ✅ **FamilyActivityPicker integrated** — Real picker working in onboarding
- ✅ **Extensions tested** — All three extensions functional on device
- Sign in to an iCloud account on test device
- First time opening FamilyActivityPicker may show empty categories — dismiss and reopen
- Test both "individual" authorization (self-control) and "child" authorization (parental) if supporting both
- Shields persist even after app termination — that's expected behavior

### Limitations Summary
- Max 50 app tokens per shield
- Max 50 named ManagedSettingsStores  
- Max 20 DeviceActivity schedules
- API does not work in Simulator — must test on device
- Tokens are opaque — cannot get app bundle IDs or names directly
- Users can always disable via Settings > Screen Time > Apps with Screen Time Access
- **Shield UI is severely limited** — no custom views, no text input, max 2 buttons
- **Cannot open parent app from shield** — must use Shortcuts workaround for rich flows

---

## Key Next Steps

### ✅ Completed (No Longer Blocking)

1. ~~**Request Family Controls Entitlement**~~ ✅ **COMPLETE**
   - Entitlements approved for all targets
   - Main app and all extensions have Family Controls access

2. ~~**Create Actual Extension Targets in Xcode**~~ ✅ **COMPLETE**
   - All three extensions fully implemented and working
   - App Groups configured for data sharing
   - Extensions tested and functional

3. ~~**Test on Physical Device**~~ ✅ **IN PROGRESS**
   - Physical device testing ongoing
   - Screen Time APIs working correctly
   - Full onboarding flow tested with real FamilyActivityPicker

4. ~~**Enable Real Screen Time Integration**~~ ✅ **COMPLETE**
   - Real `FamilyActivityPicker` integrated in onboarding
   - Extensions connected and applying shields
   - Shield screens tested on blocked app open

### Remaining V1 Tasks

5. **Add Paywall & Subscription System** 🔄 **In Progress**
   - ✅ RevenueCat SDK integrated and configured
   - ✅ SubscriptionService created for subscription management
   - ✅ RevenueCat PaywallView implemented (temporary)
   - ✅ Settings integration (upgrade, restore, manage subscription)
   - ✅ Paywall triggers: After onboarding, Settings upgrade button
   - 🔄 Superwall SDK integrated (needs dashboard configuration)
   - 🔄 SuperwallService created (needs RevenueCat adapter refinement)
   - ⏭️ Replace RevenueCat PaywallView with Superwall paywall
   - ⏭️ Dashboard configuration: Products, entitlements, offerings in RevenueCat dashboard
   - ⏭️ Dashboard configuration: Paywall design and events in Superwall dashboard
   - ⏭️ Testing: Purchase flow, restore purchases, subscription status checks

6. **Implement Notification System**
   - Waiting list reminders (Day 2, 4, 6, 7)
   - Streak celebration notifications
   - Weekly summary

7. **Add No-Goal Mode UI**
   - Cash pile visualization
   - "Set a goal for this?" prompts

### Polish & Launch

8. **App Store Preparation**
   - Screenshots and preview video
   - App Store description and metadata
   - Privacy policy and terms of service

9. **Beta Testing**
   - TestFlight distribution
   - Gather feedback on core flows
   - Iterate on friction points

---

## Common Launch Issues & Solutions

### Screen Time API Issues
- **Issue:** Users can't authorize Screen Time
  - **Solution:** Clear instructions in onboarding, support documentation
- **Issue:** Shields not appearing
  - **Solution:** Verify App Groups configuration, check extension logs
- **Issue:** FamilyActivityPicker crashes
  - **Solution:** Known issue - recommend dictation/paste instead of search

### Subscription Issues
- **Issue:** Users can't restore purchases
  - **Solution:** Clear restore button in Settings, RevenueCat restore flow
- **Issue:** Trial not activating
  - **Solution:** Verify RevenueCat configuration, check entitlements

### Onboarding Issues
- **Issue:** High drop-off during onboarding
  - **Solution:** A/B test onboarding length, simplify early screens
- **Issue:** Users skip app selection
  - **Solution:** Emphasize importance, show value before picker

## Resources

### Apple Documentation
- [ ] **App Icon** (1024x1024, all required sizes)
- [ ] **Screenshots** (6.7", 6.5", 5.5" displays)
  - Onboarding flow highlights
  - Dashboard with goal progress
  - Waiting list interface
  - Shield screen (if possible to capture)
  - Learning library cards
- [ ] **App Preview Video** (30 seconds, optional but recommended)
  - Show problem → solution flow
  - Highlight key features (blocking, waiting list, goal tracking)
- [ ] **App Store Description**
  - Subtitle (30 characters max)
  - Description (4000 characters max)
  - Keywords (100 characters max)
  - Promotional text (170 characters, can update without resubmission)
- [ ] **Privacy Policy URL** (required)
- [ ] **Terms of Service URL** (recommended)
- [ ] **Support URL** (required)

#### Legal & Compliance
- [ ] Privacy Policy created and hosted
  - Data collection disclosure
  - Screen Time API usage explanation
  - Third-party services (RevenueCat, Superwall, analytics)
  - User data rights (GDPR, CCPA if applicable)
- [ ] Terms of Service created and hosted
- [ ] App Privacy details completed in App Store Connect
  - Data types collected
  - Data linked to user
  - Data used to track user
  - Data not collected

#### Monetization Setup
- [x] RevenueCat SDK integrated ✅
  - [x] SubscriptionService created ✅
  - [x] API key configuration added ✅
  - [x] Entitlement configured ("Future Selves Pro") ✅
  - [x] RevenueCat PaywallView implemented (temporary) ✅
  - [ ] Products created in App Store Connect (monthly, annual)
  - [ ] Products configured in RevenueCat dashboard
  - [ ] Offerings created in RevenueCat dashboard
  - [ ] Webhooks set up (optional)
- [x] Superwall SDK integrated 🔄
  - [x] SuperwallService created ✅
  - [x] RevenueCat adapter created (needs refinement) 🔄
  - [x] API key configuration added ✅
  - [ ] PaywallView replaced with Superwall (currently using RevenueCat PaywallView)
  - [x] Event triggers set up in code (onboarding_complete, settings_upgrade) ✅
  - [ ] Connect RevenueCat in Superwall dashboard
  - [ ] Paywall templates created (use carousel format showing features)
  - [ ] A/B test variants set up
  - [ ] Paywall events configured in dashboard
- [x] **Paywall Integration (Temporary)** ✅
  - [x] Paywall appears after onboarding (using RevenueCat PaywallView) ✅
  - [x] Settings integration (upgrade, restore, manage) ✅
  - [x] Subscription status checking throughout app ✅
  - [ ] Replace with Superwall paywall for A/B testing
- [ ] **Paywall Messaging Strategy** (Dashboard configuration)
  - "Hey this is going to cost money, we need to earn money to continue building amazing tools. We want you to trial our tool before committing"
  - Show systems and outcomes, not just features
  - Show who they'll become using the app
  - Use carousel format for features they'll get access to
- [ ] Subscription pricing finalized
  - Monthly: $6.99
  - Annual: $39.99 (or equivalent)
  - Trial period duration determined
- [ ] Subscription terms tested end-to-end
  - Trial signup flow
  - Subscription purchase
  - Restore purchases
  - Subscription management

#### Attribution & Analytics Setup
- [ ] **Analytics Platform Configured** (Amplitude or Mixpanel)
  - User journey tracking
  - Conversion funnel analysis
  - Cohort analysis by acquisition source
  - "Where did you hear about us?" tracking
- [ ] **Attribution Tracking**
  - Track which ads/videos users came from
  - Test dozens of ad variations
  - Identify which cohorts convert best
  - Track organic vs. paid acquisition

#### Testing & QA
- [ ] **Internal Testing**
  - All onboarding screens tested
  - App blocking tested on multiple shopping apps
  - Shield screens tested (all difficulty modes)
  - Waiting list flow tested (7-day timer)
  - Graveyard functionality tested
  - Panic button flow tested
  - Goal tracking tested
  - Notification delivery tested
- [ ] **TestFlight Beta**
  - Build uploaded to TestFlight
  - External testers invited (10-50 users)
  - Feedback collection system in place
  - Crash reporting enabled (if using service)
  - Test duration: 2-4 weeks minimum
- [ ] **Edge Cases Tested**
  - No internet connection scenarios
  - App backgrounded during critical flows
  - Screen Time authorization revoked
  - Multiple device scenarios (if applicable)
  - Low storage space scenarios

#### Marketing Preparation

**Content Strategy (Start Immediately)**
- [ ] **Start writing content immediately** — Longer it's up, better Google/LLM indexing
  - Blog posts about shopping compulsion, impulse buying, ADHD and shopping
  - "How to spend less" guides
  - Psychology of shopping addiction content
  - SEO-optimized articles targeting keywords users search for
- [ ] **Create shareable resources**
  - "How to Spend Less Guide" (like Kaizen journal) — link to SpendLess inside
  - TikTok shop videos with guide downloads
  - Free downloadable resources (PDFs, checklists)

**App Store Optimization (ASO) - Critical**
- [ ] **Keyword Research** (Use Sensor Tower + App Store search)
  - Find 2-3 keywords users associate with their future self (breaking compulsive shopping, reducing spending)
  - **MUST search App Store** to see what's currently ranking
  - Goal: Hold #1 ranking for target keywords
- [ ] **Title & Subtitle Optimization**
  - Put right keywords in title and subtitle
  - Test different combinations
  - Ensure keywords match what users search for
- [ ] **Description Optimization**
  - Call out pain points and offer solutions
  - Show aggregate view: "How they see themselves today" vs "What they could look like with SpendLess"
  - Position user as hero for choosing to spend less
  - Include keywords naturally throughout

**Community & Review Strategy**
- [ ] **Pre-launch review preparation**
  - Have users ready to write reviews immediately after launch
  - Identify beta testers who are likely to leave positive reviews
  - Prepare review request messaging (non-pushy)
- [ ] **Reddit & Quora Strategy**
  - Post product to relevant subreddits (r/shoppingaddiction, r/nobuy, r/adhd, etc.)
  - Post to Quora answering questions about shopping addiction
  - Answer authentically when users are looking for competitors
  - Provide value, not just promotion
  - Engagement bait, not rage bait

**Launch Strategy**
- [ ] Launch date selected
- [ ] Press kit prepared (if applicable)
- [ ] Social media accounts ready
- [ ] Launch announcement copy prepared
- [ ] TikTok shop video strategy planned

### Launch Day Checklist

#### App Store Connect
- [ ] Final build uploaded and submitted for review
- [ ] App Store listing finalized
- [ ] Pricing and availability set
- [ ] Release date/time scheduled (or manual release)
- [ ] App review information completed
  - Demo account credentials (if required)
  - Review notes explaining Screen Time API usage
  - Contact information for reviewer questions

#### Technical Monitoring
- [ ] Analytics dashboard set up (if using analytics)
- [ ] Crash reporting monitoring active
- [ ] RevenueCat dashboard monitoring
- [ ] Server/backend monitoring (if applicable)
- [ ] Error tracking alerts configured

#### Support Preparation
- [ ] Support email/contact method ready
- [ ] FAQ document prepared
- [ ] Common issues troubleshooting guide
- [ ] Response templates for common questions

### Post-Launch (First Week)

#### Monitoring
- [ ] Daily review of:
  - App Store reviews and ratings
  - Crash reports
  - RevenueCat subscription metrics
  - User feedback channels
  - Analytics (Amplitude/Mixpanel)
  - **Keyword rankings** (track position changes)
  - **Ad performance** (which ads/videos are converting)
  - **Attribution data** (where users are coming from)
- [ ] Monitor for:
  - Critical bugs
  - User confusion points
  - Paywall conversion rates
  - Onboarding drop-off points
  - **First 5 minutes engagement** (are users seeing value?)
  - **7-day journey completion** (are users progressing through the journey?)

#### Organic Growth Strategy
- [ ] **Start with organic** — See what works organically first
- [ ] **Then scale with paid** — Use paid acquisition to amplify what's working
- [ ] **Create flywheel effect** — Organic + paid acquisition creates momentum
- [ ] **Content marketing**
  - Continue publishing SEO content
  - Answer questions on Reddit/Quora authentically
  - Engage in communities where users need help

#### Quick Response
- [ ] Respond to App Store reviews (especially negative ones)
- [ ] Address critical bugs immediately
- [ ] Update FAQ based on common questions
- [ ] Consider hotfix release if critical issues found

#### Iteration Planning
- [ ] Gather user feedback
- [ ] Identify top feature requests
- [ ] Plan V1.1 update based on real usage data
- [ ] Document lessons learned
- [ ] **Analyze ad performance** — Test dozens of ad variations, identify winners
- [ ] **Optimize onboarding** — This is where users convert (ads get them in, onboarding gets money)
- [ ] **Refine paywall** — Test different messaging, carousel formats, feature presentations

### Launch Metrics to Track

#### User Acquisition
- App Store impressions
- App Store conversion rate (views → installs)
- Organic vs. paid installs
- **Keyword rankings** (track position for target keywords)
- **CPM (Cost Per Mille)** for paid ads
- Attribution by source (which ads/videos drive installs)
- "Where did you hear about us?" responses

#### Engagement
- **Onboarding completion rate** (critical — ads get users in door, onboarding gets them to spend money)
- **First 5 minutes value delivery** (must convey value immediately)
- Daily active users (DAU)
- Weekly active users (WAU)
- Retention rates (Day 1, Day 7, Day 30)
- **7-Day Journey Completion**
  - Day 1: Get set up and identify goals/triggers
  - Day 2: Trial new interventions
  - Day 3: Learn about psychology
  - Day 4: Start leveraging waitlist
  - Day 5: First resisted shopping experience
  - Day 6: Leverage tools for better habits
  - Day 7: Watch waitlist items fade away

#### Monetization
- Trial signup rate
- Trial-to-paid conversion rate
- Monthly recurring revenue (MRR)
- Annual plan adoption rate
- Churn rate
- **Demographics of converting users** (who responds to ads, converts, commits, generates revenue)
- **SMS engagement** (95% of texts read within 5 minutes)

#### Feature Usage
- App blocking usage (shields triggered)
- Waiting list items created
- Graveyard items buried
- Panic button usage
- Goal completion rate

### Ad Strategy & Creative Guidelines

#### Ad Best Practices
- **Clear Intent** — Clearly call out the tool and what it does
- **Differentiator** — What makes SpendLess unique vs. competitors
- **Engagement Bait, Not Rage Bait** — Create curiosity and engagement, not anger
- **Persuasion Hooks** — Use psychological triggers that resonate
- **Headlines** — Strong, clear headlines that communicate value
- **Building Trust** — Show social proof, testimonials, results
- **Strong CTA** — Clear call-to-action

#### Ad Testing Strategy
- **Test dozens of variations** — Don't settle on first ad
- **Experiment with cohorts** — Track which ads drive which user types
- **UGC Ads** — User-generated content performs well
- **Influencer Partnerships** — Consider influencer collaborations
- **TikTok Shop Videos** — Create "How to spend less guide" videos linking to SpendLess

#### Ad Targeting Considerations
- **Who's responding to ads?** (Demographics)
- **Who's converting through ads?** (Conversion analysis)
- **Who's going to commit and generate revenue?** (Revenue attribution)
- Focus paid spend on cohorts that convert and generate revenue

### User Engagement & Retention Strategy

#### GIVE, GIVE, GIVE Model
- **Give value first** — Provide helpful resources before asking for anything
- **Get email or SMS** — After providing value, capture contact info
- **Send helpful resources** — Text/email with helpful content
- **Personalized interventions** — "This intervention might work best for you" based on their profile

#### SMS Strategy (95% read within 5 minutes)
- Use SMS for high-engagement communications
- Send helpful resources via SMS
- Personalized intervention suggestions
- Check-in messages during trial period

#### User Sharing & Virality
- **Shared Goals Feature** — Enable users to share goals with friends/family
- **Share to Waitlist Feature** — Allow users to share items from Amazon/Target directly to waitlist (instead of copying links)
- **Social sharing** — Make it easy to share wins, streaks, goal progress
- **Referral program** — Incentivize users to share the app

### Onboarding Optimization (Critical for Conversion)

#### Onboarding Philosophy
- **"Ads get users in the door, onboarding gets them to spend money"**
- This is the best setup opportunity — make it count
- Must convey value in first 5 minutes

#### Onboarding Strategy
- **Tie users to their questions earlier** — They give you answers, you make them feel seen
- **Call out pain points and offer solutions** — Address their struggles directly
- **Show aggregate view** — "How they see themselves today" vs "What they could look like with SpendLess"
- **Position user as hero** — They're making a brave choice to spend less and hit their goals
- **Trial messaging** — "We want you to trial our tool before committing"

#### 7-Day Journey Framework
Show users the systems and outcomes they'll receive:

- **Day 1:** Get set up and identify your goals and triggers
- **Day 2:** Trial new interventions to find what fits
- **Day 3:** Learn about the psychology of habit formation and shopping compulsion
- **Day 4:** Start leveraging your waitlist
- **Day 5:** Experience your first resisted shopping experience
- **Day 6:** Leverage tools to help your brain build better habits
- **Day 7:** Watch your first waitlist items fade away as you make progress toward your goals


### Screen Time API Issues
- **Issue:** Users can't authorize Screen Time
  - **Solution:** Clear instructions in onboarding, support documentation
- **Issue:** Shields not appearing
  - **Solution:** Verify App Groups configuration, check extension logs
- **Issue:** FamilyActivityPicker crashes
  - **Solution:** Known issue - recommend dictation/paste instead of search

### Subscription Issues
- **Issue:** Users can't restore purchases
  - **Solution:** Clear restore button in Settings, RevenueCat restore flow
- **Issue:** Trial not activating
  - **Solution:** Verify RevenueCat configuration, check entitlements

### Onboarding Issues
- **Issue:** High drop-off during onboarding
  - **Solution:** A/B test onboarding length, simplify early screens
- **Issue:** Users skip app selection
  - **Solution:** Emphasize importance, show value before picker

## Resources

### Apple Documentation
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Family Controls Entitlement](https://developer.apple.com/documentation/familycontrols)

### Third-Party Services
- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [Superwall Documentation](https://docs.superwall.com/)

### Testing Tools
- [TestFlight](https://developer.apple.com/testflight/)
- [App Store Connect Analytics](https://appstoreconnect.apple.com/analytics)

---

*Document Version: 3.0 — Merged implementation guide with Shield API limitations and hybrid approach*