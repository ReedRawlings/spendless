# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SpendLess is an iOS app that helps users overcome compulsive shopping by blocking shopping apps and providing behavioral interventions. It uses Apple's Screen Time APIs (Family Controls, Managed Settings, Device Activity) to shield apps and presents mindfulness-based interventions when users try to access blocked apps.

**Target audience:** Women aged 22-45 dealing with impulse spending
**Design philosophy:** Warm and supportive, never clinical or punishing. Celebrations over punishment—make resisting purchases feel as rewarding as making them.

## Build Commands

This is an Xcode project. Build and run from Xcode or use:
```bash
xcodebuild -scheme SpendLess -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Important:** Must test on a physical device for Screen Time/Family Controls features. Simulator cannot test shield functionality.

## Architecture

### App Structure

```
SpendLess/
├── App/              # Entry point (SpendLessApp.swift), Constants
├── Models/           # SwiftData models (@Model classes)
├── Services/         # Singletons managing app functionality
├── Views/            # SwiftUI views organized by feature
├── Components/       # Reusable UI components
├── Theme/            # Design system (Theme.swift)
├── Helpers/          # Utility functions
└── Extensions/       # Screen Time extension code (shared location)
```

### Screen Time Extensions (Separate Targets)

- **DeviceActivityMonitorExtension** - Monitors device activity schedules
- **ShieldActionExtension** - Handles user taps on shield overlay
- **ShieldConfigurationExtension** - Customizes shield appearance
- **PanicButtonWidget** - Home screen widget and Control Center toggle

All extensions share data via App Groups (`group.com.spendless.data`).

### Key Services (Singletons)

| Service | Purpose |
|---------|---------|
| `AppState` | Global observable state, onboarding data, deep linking |
| `ScreenTimeManager` | Family Controls authorization, app selection, shield management |
| `InterventionManager` | Intervention flow state machine (breathing → HALT → reflection → celebration) |
| `ShieldSessionManager` | Temporary access sessions with Live Activities |
| `SubscriptionService` | StoreKit 2 subscription management |
| `NotificationManager` | Local notifications for waiting list reminders |

### Data Flow

1. **Main App ↔ Extensions:** Data shared via `UserDefaults(suiteName: AppConstants.appGroupID)`
2. **Shield triggers intervention:** Extension sets `interventionTriggered` flag, main app checks on `scenePhase` active
3. **SwiftData models:** `UserGoal`, `WaitingListItem`, `GraveyardItem`, `Streak`, `UserProfile`

### Intervention Flow

The intervention system is a state machine in `InterventionManager`:
```
breathing → reflection → (logItem OR dopamineMenu) → celebration
                    ↓
              haltCheck → haltRedirect → celebration
```

Types: `.breathing`, `.haltCheck`, `.goalReminder`, `.quickPause`, `.fullFlow`

## Design System

All UI uses the design system in `Theme.swift`:

- **Colors:** `Color.spendLessPrimary` (terracotta), `.spendLessSecondary` (sage), `.spendLessGold` (celebrations)
- **Typography:** `SpendLessFont.title`, `.body`, `.caption` (SF Pro Rounded)
- **Spacing:** `SpendLessSpacing.xs` through `.xxxl`
- **Radius:** `SpendLessRadius.sm` through `.full`

## API Keys Configuration

API keys use xcconfig files. Copy `Config/Template.xcconfig` to `Config/Debug.xcconfig` and `Config/Release.xcconfig`. The only external service is a Cloudflare Worker for MailerLite email collection.

Subscription product IDs are in `AppConstants.ProductIdentifiers`.

## Screen Time / Family Controls

**Critical:** Requires entitlement from Apple for App Store distribution. Development entitlement works for personal testing.

- Authorization: `AuthorizationCenter.shared.requestAuthorization(for: .individual)`
- App selection: `FamilyActivitySelection` stored in App Groups
- Shields: Applied via `ManagedSettingsStore`
- Temporary access: 10-minute sessions managed by `ShieldSessionManager`

## SwiftData Models

Models use `@Model` macro. The schema includes:
- `UserGoal` - Savings goal with target amount and progress
- `WaitingListItem` - 7-day waiting period items
- `GraveyardItem` - Items user resisted buying (celebration/analytics)
- `Streak` - Current days streak
- `UserProfile` - Triggers, timings, commitment letter
- `NoBuyChallenge` - NoBuy challenge tracking with rules and stats
- `NoBuyDayEntry` - Daily check-in entries for NoBuy challenges

### SwiftData Migration Rules (CRITICAL)

**When adding new properties to existing @Model classes, you MUST follow these rules to avoid data loss:**

```swift
// ✅ SAFE - Always provide default values
var newProperty: Bool = false
var newCount: Int = 0
var newName: String = ""
var newDate: Date = Date()

// ✅ SAFE - Or make properties optional
var newProperty: Bool?
var newDate: Date?

// ❌ UNSAFE - Will crash if existing data exists
var newProperty: Bool
var newCount: Int
```

**Why:** SwiftData performs lightweight migrations automatically, but it cannot infer values for new non-optional properties without defaults. If existing records exist, the app will crash with `SwiftDataError.loadIssueModelContainer`.

**Checklist before adding model properties:**
1. Does it have a default value? → Safe
2. Is it optional (`Type?`)? → Safe
3. Neither? → **Will crash and cause data loss**

For complex migrations (renaming, transforming data), use `VersionedSchema` and `SchemaMigrationPlan`.

## Dependencies

- **Lottie** (SPM) - Celebration animations
- Native frameworks: FamilyControls, ManagedSettings, DeviceActivity, StoreKit, SwiftData
