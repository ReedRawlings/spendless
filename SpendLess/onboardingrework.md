# SpendLess Onboarding Restructure Plan

## Overview

Reduce onboarding from 25 screens to 13 screens.

**Goals:**
- Faster time-to-value
- Better emotional arc (pain → hope → action)
- Lead magnet email capture instead of signature commitment
- First waitlist item added during onboarding (activation)
- Consistent UX between onboarding and in-app experience
- Paywall at end for conversion
- Make sure formatting stays consistent for fonts, containers, and the like

---

## New 13-Screen Flow

| # | Step Enum Case | Screen Name | Status |
|---|----------------|-------------|--------|
| 1 | `welcome` | Welcome | KEEP existing |
| 2 | `aboutYou` | About You | NEW - triggers + spend input |
| 3 | `theCost` | The Cost | NEW - animated impact reveal only |
| 4 | `psychology` | The Psychology | NEW - consolidate WhyChange |
| 5 | `futureYou` | Future You | NEW - hope/future self |
| 6 | `yourGoal` | Your Goal | NEW - combine selection + details |
| 7 | `howItWorks` | How It Works | SIMPLIFY existing |
| 8 | `firstResist` | Your First Resist | REPURPOSE waitlistIntro |
| 9 | `stayCommitted` | Stay Committed | NEW - lead magnet |
| 10 | `screenTimeAccess` | Screen Time Access | KEEP existing |
| 11 | `blockApps` | Block Apps | KEEP existing |
| 12 | `ready` | Ready | NEW - notifications + shortcuts + summary |
| 13 | `paywall` | Paywall | KEEP existing (SpendLessPaywallView) |

---

## Screens Being Removed

These screens are cut entirely or merged into other screens:

| Old Screen | Disposition |
|------------|-------------|
| `behaviors` | Merged → `aboutYou` |
| `timing` | CUT (low value) |
| `problemApps` | CUT (already disabled) |
| `psychologyIntro` | CUT (unnecessary preamble) |
| `whyChange1` | Merged → `psychology` |
| `whyChange2` | CUT |
| `whyChange3` | CUT |
| `whyChange4` | Merged → `futureYou` |
| `whyChange5` | Merged → `psychology` |
| `monthlySpend` | Merged → `aboutYou` |
| `impactVisualization` | Merged → `theCost` |
| `goalSelection` | Merged → `yourGoal` |
| `goalDetails` | Merged → `yourGoal` |
| `desiredOutcomes` | CUT (low value) |
| `waitlistExplanation` | CUT (merged into howItWorks) |
| `waitlistIntro` | Repurposed → `firstResist` |
| `commitment` | REPLACED by `stayCommitted` |
| `leadMagnet` | Moved → `stayCommitted` |
| `permissionExplanation` | Renamed → `screenTimeAccess` |
| `appSelection` | Renamed → `blockApps` |
| `websiteBlocking` | CUT (move to settings later) |
| `selectionConfirmation` | CUT (unnecessary) |
| `notificationPermission` | Merged → `ready` |
| `howItWorks` (old carousel) | Simplified → `howItWorks` |
| `shortcutsSetup` | Merged → `ready` |

---

## Files to Modify

### OnboardingCoordinatorView.swift

Update the `OnboardingStep` enum:

```swift
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case aboutYou
    case theCost
    case psychology
    case futureYou
    case yourGoal
    case howItWorks
    case firstResist
    case stayCommitted
    case screenTimeAccess
    case blockApps
    case ready
    case paywall
}
```

Update `destinationView(for:)` to route to new screens.

**Paywall Routing:**
```swift
case .paywall:
    SpendLessPaywallView(onComplete: {
        appState.finalizeOnboarding(context: modelContext)
    })
```

The paywall's `onComplete` closure should be called when:
- User purchases successfully
- User restores successfully  
- User dismisses the paywall (X button)

All paths lead to `finalizeOnboarding()` - the paywall is a soft gate, not a hard requirement.

---

## Files to Delete (After Migration Complete)

- `WhyChangeScreens.swift` - entire file
- `ShortcutsSetupView.swift` - entire file
- From `OnboardingScreens.swift`, remove:
  - `OnboardingBehaviorsView`
  - `OnboardingTimingView`
  - `OnboardingProblemAppsView`
  - `OnboardingMonthlySpendView`
  - `OnboardingImpactView`
  - `OnboardingGoalSelectionView`
  - `OnboardingGoalDetailsView`
  - `OnboardingDesiredOutcomesView`
  - `OnboardingWaitlistIntroView`
- From `OnboardingScreens2.swift`, remove:
  - `OnboardingCommitmentView`
  - `SignatureSheetView`
  - `SignatureCanvasRepresentable`
  - `OnboardingWebsiteBlockingView`
  - `OnboardingConfirmationView`
  - `OnboardingNotificationPermissionView`
  - `OnboardingHowItWorksView`

## Files to Keep (Modify for Onboarding)

- `SpendLess/Views/Settings/PaywallView.swift` → `SpendLessPaywallView`
  - Add optional `onComplete` callback for onboarding context
  - When shown in onboarding: call `onComplete` on dismiss/purchase
  - When shown from Settings: use existing `dismiss()` behavior

---

## Files to Create

Create new file: `OnboardingScreensConsolidated.swift`

This file will contain:
- `AboutYouView`
- `TheCostView`
- `PsychologyView`
- `FutureYouView`
- `YourGoalView`
- `HowItWorksSimpleView`
- `FirstResistView`
- `StayCommittedView`
- `ReadyView`

Note: `SpendLessPaywallView` already exists in `PaywallView.swift` - just needs minor modification for onboarding context (add `onComplete` callback).

---

## Screen-by-Screen Specifications

---

### Screen 1: Welcome (KEEP AS-IS)

**File:** `OnboardingScreens.swift` → `OnboardingWelcomeView`

**Changes:** None

---

### Screen 2: About You (NEW)

**Purpose:** Collect triggers and monthly spend on one screen

**Layout:**
```
[Progress bar]

"Let's understand your patterns"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Section 1:
"What triggers you to shop?"
[Multi-select chips - ShoppingTrigger.allCases]
- Use compact chip styling
- All visible, scrollable if needed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Section 2:
"How much do you spend on impulse purchases each month?"
"Be honest — no judgment"
[Single-select cards - SpendRange.allCases]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Continue] button
- Disabled until spend range selected
- Triggers can be empty (optional)
```

**Data:**
- `appState.onboardingTriggers: Set<ShoppingTrigger>` (existing)
- `appState.onboardingSpendRange: SpendRange` (existing)

**Notes:**
- Scrollable screen
- Section 1 chips should be compact (smaller padding than current SelectionCards)
- Section 2 uses existing SelectionCard style
- Continue enabled when spend range is selected (triggers optional)

---

### Screen 3: The Cost (NEW)

**Purpose:** Pure emotional reveal - no input, just impact animation

**Layout:**
```
[Progress bar]

[Spacer]

"If you're spending ~$[MONTHLY]/month on things you don't need..."

[$YEARLY]           ← Animate counting up from 0
"per year"

[$DECADE]           ← Animate counting up from 0
"over 10 years"

"What could YOU do with that?"  ← Fade in after numbers finish

[Spacer]

[Let's change that] button  ← Appears after animation completes
```

**Animation Sequence:**
1. Screen appears with headline
2. After 0.3s: yearly number counts up over 1.5s
3. Simultaneously: decade number counts up
4. After count completes + 0.2s: "What could YOU do with that?" fades in
5. After 0.3s: button fades in with haptic feedback

**Data:**
- Reads from `appState.onboardingSpendRange` (set on previous screen)
- Uses `.monthlyEstimate`, `.yearlyEstimate`, `.decadeEstimate` computed properties

**Notes:**
- Reuse animation logic from existing `OnboardingImpactView`
- Large typography for the dollar amounts (use `SpendLessFont.largeTitle`)
- Primary color for yearly, gold color for decade

---

### Screen 4: The Psychology (NEW)

**Purpose:** One powerful screen explaining the dopamine problem

**Layout:**
```
[Dark background - spendLessPrimaryDark]

[Lottie animation: "brain"]
- Height: 200
- Centered

"This isn't about willpower"
- White text
- Title font

"Shopping addiction is a dopamine problem, not a character 
flaw. Your brain learned that buying = quick relief.

But here's the good news: dopamine systems heal. By 
pausing before purchases, you start wanting less—not 
just resisting more."
- White text, 0.9 opacity
- Body font, centered
- Line spacing: 4

[Progress dots: ● ○]  (1 of 2)

[Next] button - white background, dark text
```

**Notes:**
- Use `WhyChangeScreen` styling pattern (dark bg, white text)
- Pull copy from existing `whyChange5Body()` but simplify
- Progress dots indicate 2 psychology screens total

---

### Screen 5: Future You (NEW)

**Purpose:** Pivot from problem to hope - emotional bridge to goal-setting

**Layout:**
```
[Dark background - spendLessSecondary]

[Lottie animation: "futureSelf"]
- Height: 200
- Centered

"Future you is counting on you"
- White text
- Title font

"That trip. That debt paid off. That breathing room. 
Future you wants those things.

Every impulse buy steals from them. But every time 
you resist? That's a gift to yourself."
- White text, 0.9 opacity
- Body font, centered
- Line spacing: 4

[Progress dots: ○ ●]  (2 of 2)

[Next] button - white background, dark text
```

**Notes:**
- Continue the dark background visual language
- This screen should feel hopeful, not guilt-inducing
- Leads directly into goal setting

---

### Screen 6: Your Goal (NEW)

**Purpose:** Goal type selection + details on one dynamic screen

**Layout - Initial State:**
```
[Progress bar]

"What would you rather have?"
"Pick something to work toward"

[Scrollable goal type cards - GoalType.allCases]
- Each shows icon + title
- Single select
```

**Layout - After Goal Type Selected (if requiresDetails == true):**
```
[Progress bar]

"What would you rather have?"
[Selected goal card - highlighted, others collapse/hide]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Animated section appears:]

"[Goal type] means..."

[MeaningChip] "🛡️ A real safety net"
[MeaningChip] "😮‍💨 Breathing room when life happens"
[MeaningChip] "😴 Sleeping without money anxiety"
- Tapping a chip fills it into the text field below

"Or in your words..."
[Text field for custom goal name]
- Placeholder varies by goal type

[Currency field: "How much will make you feel secure?"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Continue] button
- Disabled until name + amount filled
```

**Layout - After Goal Type Selected (if requiresDetails == false, e.g. justStop):**
```
[Progress bar]

"What would you rather have?"
[Selected goal card - highlighted]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💰

"That's okay!"

"We'll track how much you save and you can 
set a goal later if you want."

[Continue] button - enabled immediately
```

**Data:**
- `appState.onboardingGoalType: GoalType` (existing)
- `appState.onboardingGoalName: String` (existing)
- `appState.onboardingGoalAmount: Decimal` (existing)

**Components to Reuse:**
- `GoalSpecificContent` helper struct
- `MeaningChip` component
- `CurrencyTextField` component
- `SpendLessTextField` component

**Animation:**
- When goal type selected: other cards fade out or collapse
- Detail section animates in with spring animation
- MeaningChips stagger in (0.2s delay each)

---

### Screen 7: How It Works (SIMPLIFIED)

**Purpose:** Simple explanation of the waitlist concept before they try it

**Layout:**
```
[Progress bar]

"How SpendLess works"

[3 steps - vertical stack with icons]

┌─────────────────────────────────┐
│ 🛑  PAUSE                       │
│ When you want to buy something, │
│ add it to your waiting list     │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ ⏳  WAIT                        │
│ Give it 7 days.                 │
│ Most urges don't survive.       │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ ✅  DECIDE                      │
│ Still want it? Buy guilt-free.  │
│ Don't? Bury it and celebrate.   │
└─────────────────────────────────┘

"Let's try it now."

[Continue] button
```

**Notes:**
- No carousel or TabView - static content
- Simple card styling for each step
- Sets up the next screen (first resist)

---

### Screen 8: Your First Resist (NEW)

**Purpose:** Add first waitlist item during onboarding - matches in-app experience exactly

**Layout:**
```
[Progress bar]

"What did you resist?"

"When you want to buy something, add it here instead."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Text field: "What is it?"]
- Placeholder: "e.g., Wireless earbuds"

[Row - two fields side by side:]
  [Currency field: "How much?"]
  [Number field: "Number of wears?"]
    - Placeholder: "e.g., 50"
    - Numeric keyboard

[Dropdown: "Why do you want it? (optional)"]
- Tapping opens ReasonWantedPicker sheet
- Shows selected reason with icon when chosen

[If reason == .other:]
  [Text field: "Tell us more"]
  - Animated appearance

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"If you still want it in 7 days, you can buy it guilt-free."

[Add to Waiting List] button
- Icon: "clock"
- Disabled until name AND price filled

[Skip for now] link
- Plain text button, muted color
```

**Success State (after adding):**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅

"Added to your waitlist!"

"You'll see it on your dashboard."

[Continue] button
```

**Data Model:**
Creates `WaitingListItem` with:
- `name: String` (required)
- `amount: Decimal` (required)
- `pricePerWearEstimate: Int?` (optional)
- `reasonWanted: ReasonWanted?` (optional)
- `reasonWantedNote: String?` (if reason == .other)

**Components to Reuse:**
- `SpendLessTextField`
- `CurrencyTextField`
- `ReasonWantedPicker` (sheet)

**Notes:**
- This MUST match the in-app `AddToWaitingListSheet` experience
- Reuse the same components and validation logic
- Save to modelContext on submit
- Haptic feedback on success

---

### Screen 9: Stay Committed (Reuse - Lead Magnet)
- Reference to current lead magnet viewand logic flow


### Screen 10: Screen Time Access (KEEP)

**File:** `OnboardingScreens2.swift` → `OnboardingPermissionView`

**Changes:**
- Update step enum reference from `.permissionExplanation` to `.screenTimeAccess`
- No other changes needed

---

### Screen 11: Block Apps (KEEP)

**File:** `OnboardingScreens2.swift` → `OnboardingAppSelectionView`

**Changes:**
- Update step enum reference from `.appSelection` to `.blockApps`
- On continue: navigate directly to `.ready` (no confirmation screen)

---

### Screen 12: Ready (NEW)

**Purpose:** Final screen combining summary, notifications, shortcuts CTA, and launch

**Layout:**
```
[Progress bar - 100% complete]

"You're all set! 🎉"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Summary Card]
┌─────────────────────────────────┐
│ ✓ [X] apps blocked              │  ← from ScreenTimeManager.blockedAppCount
│ ✓ Goal: [name] — $[amount]      │  ← from appState, hide if justStop
│ ✓ First item: [name]            │  ← only if they added one
└─────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Notifications Section]
"Stay on track"
"Get reminders and celebrate your wins."

[If not yet granted:]
  [Enable Notifications] button (secondary style)
  
[If already granted:]
  ✓ Notifications enabled
  - Green checkmark, muted text

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Shortcuts Section - Optional]
"Want richer interventions?"
"Breathing exercises and reflection prompts when you're tempted."

[Set Up Shortcuts] button (secondary style)
- Opens sheet with setup instructions
- Or links to shortcuts:// URL

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Start Using SpendLess] primary button
- Navigates to paywall screen (NOT completeOnboarding)
```

**Notifications Logic:**
```swift
// Check current status
let settings = await UNUserNotificationCenter.current().notificationSettings()

switch settings.authorizationStatus {
case .authorized, .provisional:
    // Show "Notifications enabled" state
case .notDetermined:
    // Show "Enable Notifications" button
    // On tap: request permission, update UI
case .denied:
    // Show "Enable in Settings" with link to settings
}
```

**Shortcuts Section:**
- Check UserDefaults for `shortcutsSetupComplete`
- If not complete: show CTA button
- Button can either:
  - Open a sheet with step-by-step instructions (simplified from current ShortcutsSetupView)
  - Or just open `shortcuts://` and trust user to figure it out

**Summary Card Logic:**
- Apps blocked: `ScreenTimeManager.shared.blockedAppCount`
- Goal: show if `appState.onboardingGoalType.requiresDetails && appState.onboardingGoalAmount > 0`
- First item: query modelContext for WaitingListItem, show if exists

---

### Screen 13: Paywall (KEEP EXISTING)

**File:** `SpendLess/Views/Settings/PaywallView.swift` → `SpendLessPaywallView`

**Purpose:** Convert user to paid subscription before entering the app

**Changes Needed:**
1. Add to onboarding flow (currently only in Settings)
2. Modify dismiss behavior for onboarding context
3. Add `onComplete` callback for onboarding flow

**Layout (existing - no changes to design):**
```
[X close button - top right]

✨ (sparkles icon)

"You're ready to take control"

"Unlock all the tools to break the cycle 
and start saving for what matters."

┌─────────────────────────────────┐
│ Benefits list:                  │
│ ✓ Block shopping apps           │
│ ✓ 7-day waiting list            │
│ ✓ Track progress toward goals   │
│ ✓ Breathing exercises           │
└─────────────────────────────────┘

[Annual option - selected by default, "Save 50%"]
[Monthly option]

[Start Free Trial] button

"Try free for 3 days, then $X/period"

[Restore Purchases] link
"Cancel anytime. No questions asked."
```

**Onboarding-Specific Behavior:**

Create a wrapper or modify the view to handle onboarding context:

```swift
// Option 1: Wrapper view
struct OnboardingPaywallView: View {
    let onComplete: () -> Void  // Called after purchase OR dismiss
    
    var body: some View {
        SpendLessPaywallView(onComplete: onComplete)
    }
}

// Option 2: Add parameter to existing view
struct SpendLessPaywallView: View {
    var onComplete: (() -> Void)?  // nil when shown from Settings
    
    // In dismiss/purchase success:
    if let onComplete {
        onComplete()
    } else {
        dismiss()
    }
}
```

**Flow Logic:**
- User can dismiss paywall (X button) → still completes onboarding (free tier)
- User purchases → completes onboarding (pro tier)
- User restores → completes onboarding (if active subscription found)

**After Paywall:**
- Call `appState.finalizeOnboarding(context: modelContext)`
- User enters main app

**Notes:**
- Don't gate onboarding completion on purchase - let free users through
- The paywall is a "soft gate" - prominent but skippable
- Track whether user saw paywall for later prompts

---

## AppState Changes

### Add New Properties:

```swift
// Lead magnet
var onboardingEmail: String = ""
var leadMagnetCompleted: Bool = false
```

### Remove Deprecated Properties:

```swift
// These are no longer used - remove or mark deprecated
var onboardingSignatureData: Data?        // Remove - no signature
var onboardingCommitmentDate: Date?       // Remove - no signature
var onboardingFutureLetterText: String?   // Remove - no letter selection
var onboardingDesiredOutcomes: Set<DesiredOutcome>  // Remove - screen cut
var onboardingTimings: Set<ShoppingTiming>  // Remove - screen cut
```

### Keep These:

```swift
var onboardingTriggers: Set<ShoppingTrigger>  // Keep - used in About You
var onboardingSpendRange: SpendRange          // Keep - used in About You
var onboardingGoalType: GoalType              // Keep - used in Your Goal
var onboardingGoalName: String                // Keep - used in Your Goal
var onboardingGoalAmount: Decimal             // Keep - used in Your Goal
```

---

## Model Changes

### Remove DesiredOutcome Enum (if not used elsewhere)

Check if `DesiredOutcome` is used anywhere outside onboarding. If not, it can be removed.

### Remove ShoppingTiming Enum (if not used elsewhere)

Check if `ShoppingTiming` is used anywhere outside onboarding. If not, it can be removed.

---

## Migration Steps

### Phase 1: Build New Screens
1. Create `OnboardingScreensConsolidated.swift`
2. Implement all 9 new views (screens 2-9, 12)
3. Test each screen individually with previews

### Phase 2: Update Coordinator
1. Update `OnboardingStep` enum in `OnboardingCoordinatorView.swift`
2. Update `destinationView(for:)` switch statement
3. Test full flow navigation

### Phase 3: Update AppState
1. Add new properties (`onboardingEmail`, `leadMagnetCompleted`)
2. Keep old properties temporarily for compilation
3. Test data flow through new screens

### Phase 4: Cleanup
1. Remove old screen views from `OnboardingScreens.swift`
2. Remove old screen views from `OnboardingScreens2.swift`
3. Delete `WhyChangeScreens.swift`
4. Delete `ShortcutsSetupView.swift`
5. Remove deprecated AppState properties
6. Remove unused enums if applicable

### Phase 5: Polish
1. Test complete flow end-to-end
2. Verify animations are smooth
3. Test on older devices
4. Verify all data persists correctly
5. Test edge cases (skip flows, permission denied, etc.)

---

## Testing Checklist

### Happy Path
- [ ] Complete flow with all inputs filled
- [ ] First resist item appears on dashboard after onboarding
- [ ] Goal data displays correctly on dashboard
- [ ] Blocked apps are actually blocked
- [ ] Email is saved (check UserDefaults)
- [ ] Paywall displays correctly with subscription options
- [ ] Purchase flow works end-to-end

### Skip Paths
- [ ] Skip triggers (continue with none selected)
- [ ] Skip first resist item
- [ ] Skip email/lead magnet
- [ ] Skip notifications
- [ ] Skip shortcuts
- [ ] Dismiss paywall (X button) → still completes onboarding

### Permissions
- [ ] Screen Time already authorized → skips permission screen
- [ ] Screen Time denied → shows error with settings link
- [ ] Notifications denied → shows "Enable in Settings" option

### Paywall
- [ ] Products load correctly from StoreKit
- [ ] Annual selected by default
- [ ] Monthly option selectable
- [ ] Purchase succeeds → completes onboarding
- [ ] Purchase cancelled → stays on paywall
- [ ] Restore works for existing subscribers
- [ ] Dismiss (X) → completes onboarding as free user

### Edge Cases
- [ ] Back navigation works on all screens
- [ ] Progress bar accurate throughout
- [ ] Keyboard dismisses properly
- [ ] Goal type "Just stop shopping" flow (no details required)
- [ ] Very long goal names don't break layout
- [ ] Very large amounts format correctly

### Devices
- [ ] iPhone SE (small screen)
- [ ] iPhone 15 Pro Max (large screen)
- [ ] iPad (if supported)
- [ ] iOS 17 minimum

---

## Future Enhancements (Out of Scope)

These are NOT part of this restructure but noted for later:

1. **Lead magnet backend** - Actually send emails (requires backend work)
2. **Website blocking prompt** - Add as post-onboarding prompt on Day 2-3
3. **A/B test lead magnet** - Try different offers (PDF vs email series)
4. **Onboarding analytics** - Track completion funnel, drop-off points
5. **Personalized recommendations** - Use trigger data to suggest apps to block

---

## Summary

| Metric | Before | After |
|--------|--------|-------|
| Total screens | 25 | 13 |
| Input screens | 8 | 4 |
| Emotional/sales screens | 7 | 3 |
| Setup/permission screens | 6 | 3 |
| Conversion screens | 1 | 1 |
| Activation (first item) | Yes | Yes |
| Email capture | Buried | Prominent |
| Signature commitment | Yes | No |
| Paywall | End | End |
| Estimated completion time | 5-7 min | 2-3 min |
