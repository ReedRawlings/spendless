# SpendLess Critical Issues Report

## Summary

Code architecture review completed on 2025-12-04. Identified and fixed critical issues that could cause crashes or data loss in production.

---

## Fixed Issues

### 1. Production Database Reset Code
**File:** `SpendLess/App/SpendLessApp.swift:34-65`
**Severity:** CRITICAL
**Status:** FIXED

**Problem:** When SwiftData migration failed, the app would silently delete the entire database and recreate it. This code was intended for development but ran in all builds.

**Fix:** Wrapped the database reset logic in `#if DEBUG ... #else ... #endif`. In release builds, the app now crashes cleanly with `fatalError` instead of silently deleting user data.

**Note:** Before shipping to production, implement proper SwiftData schema versioning. A TODO comment was added as a reminder.

---

### 2. Memory Leak in Breathing Animation
**File:** `SpendLess/Views/Intervention/InterventionBreathingView.swift`
**Severity:** CRITICAL
**Status:** FIXED

**Problem:** Nested `DispatchQueue.main.asyncAfter` closures with strong `self` captures could continue executing after the view was dismissed, causing memory leaks and potential crashes.

**Fix:** Refactored to use `async/await` with a cancellable `Task`:
- Added `@State private var breathingTask: Task<Void, Never>?`
- Task is cancelled in `onDisappear` and when user taps "I'm ready"
- `Task.sleep(for:)` throws `CancellationError` when cancelled, allowing clean exit

---

### 3. Indentation Error in CommitmentDetailView
**File:** `SpendLess/Views/Settings/CommitmentDetailView.swift:209-224`
**Severity:** LOW (code quality)
**Status:** FIXED

**Problem:** The `saveRenewal()` function had incorrect indentation that made the code structure confusing (closing brace was at 8 spaces instead of 4).

**Fix:** Corrected indentation to match Swift conventions.

---

### 4. DispatchQueue Pattern in InterventionManager
**File:** `SpendLess/Services/InterventionManager.swift:283-298`
**Severity:** MEDIUM
**Status:** FIXED

**Problem:** Used `DispatchQueue.main.asyncAfter` for state reset after animation. While this is a singleton (so no deallocation risk), the pattern was inconsistent with modern Swift concurrency.

**Fix:** Refactored to use `Task` with `Task.sleep(for:)` for consistency with the breathing animation fix.

---

## Known Issues (Not Yet Fixed)

### HIGH SEVERITY

#### Silent Error Handling with try?
**Files:** Multiple (15+ locations)
**Severity:** HIGH
**Status:** NOT FIXED

Many `modelContext.save()` calls use `try?` which silently swallows errors. Users may think data was saved when it wasn't.

**Locations:**
- `AppState.swift:117-121, 124-128, 131-137, 209, 236-240`
- `DashboardView.swift:597`
- `WaitingListView.swift:207, 230, 245, 517`
- `GraveyardView.swift:394`
- `SettingsView.swift:312, 340, 423`

**Recommendation:** Add proper error handling with user feedback or at minimum logging.

---

#### No Singleton Enforcement for Models
**Files:** `UserProfile`, `Streak` models
**Severity:** HIGH
**Status:** NOT FIXED

**Problem:** Models that should be singleton (UserProfile, Streak) have no uniqueness constraints. Code assumes `.first` will get the correct record, but duplicates can exist.

**Locations:**
- `DashboardView.swift:33, 37` - uses `streaks.first`, `profiles.first`
- `AppState.swift:140-148` - `getOrCreateProfile()` has no race condition protection

**Recommendation:** Add `@Attribute(.unique)` to these models or implement proper singleton pattern.

---

#### Hard-Coded String Predicates
**File:** `WaitingListView.swift:17`
**Severity:** HIGH
**Status:** NOT FIXED

```swift
@Query(filter: #Predicate<GraveyardItem> { $0.sourceRaw == "waitingList" })
```

**Problem:** Uses hardcoded string instead of enum rawValue. If `GraveyardSource.waitingList.rawValue` changes, predicate silently returns wrong results.

**Recommendation:** Use a constant or the enum's rawValue directly.

---

#### N+1 Query Pattern
**File:** `DashboardView.swift:16-19`
**Severity:** HIGH
**Status:** NOT FIXED

```swift
@Query private var goals: [UserGoal]  // Loads ALL goals
private var currentGoal: UserGoal? { goals.first { $0.isActive } }  // Filters in memory
```

**Problem:** All records loaded into memory even when only one is needed.

**Recommendation:** Add predicate to @Query: `@Query(filter: #Predicate<UserGoal> { $0.isActive })`

---

#### UserDefaults Instance Created Every Access
**File:** `WidgetDataService.swift:27-29`
**Severity:** HIGH
**Status:** NOT FIXED

```swift
private var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: suiteName)  // NEW instance every time
}
```

**Problem:** Creates new UserDefaults instance on every access. Concurrent calls could race.

**Recommendation:** Cache the UserDefaults instance as a stored property.

---

### MEDIUM SEVERITY

#### Decimal Precision Loss in Financial Calculations
**Files:** `InterventionManager.swift:318-319`, `WidgetDataService.swift:63, 92`, `ToolCalculationService.swift:23-32`
**Severity:** MEDIUM
**Status:** NOT FIXED

```swift
sharedDefaults?.set(current + NSDecimalNumber(decimal: amount).doubleValue, ...)
```

**Problem:** Converting Decimal → Double → String loses precision. $99.99 can become $99.98 over multiple operations.

**Recommendation:** Use Decimal throughout for all financial calculations. Store as String in UserDefaults if needed.

---

#### Hard-Coded App Group ID (DRY Violation)
**Files:** 10+ locations
**Severity:** MEDIUM
**Status:** NOT FIXED

The string `"group.com.spendless.data"` is duplicated in:
- `AppState.swift:196, 220`
- `ScreenTimeManager.swift:177, 202, 242`
- `InterventionManager.swift:74`
- `WidgetDataService.swift`
- `SpendLessApp.swift:171`
- `DashboardView.swift:192`
- `SettingsView.swift:266`
- `CommitmentDetailView.swift:216`

**Recommendation:** Extract to a constant in a shared file.

---

#### Hard-Coded Default Values
**Files:** `InterventionManager.swift:341-342`, `UserProfile.swift:125-128`
**Severity:** MEDIUM
**Status:** NOT FIXED

```swift
// InterventionManager.swift
var targetAmount: Double {
    sharedDefaults?.double(forKey: "targetAmount") ?? 1000  // Magic number
}

// UserProfile.swift
var currentAge: Int {
    guard let birthYear else { return 30 }  // Silent default
}
```

**Problem:** Magic numbers with no explanation. Users may see incorrect data.

---

#### Multiple Sheet Presentation Ambiguity
**File:** `WaitingListView.swift:71-80`
**Severity:** MEDIUM
**Status:** NOT FIXED

```swift
.sheet(item: $itemToBury) { ... }
.sheet(item: $itemToBuy) { ... }
```

**Problem:** If both `itemToBury` and `itemToBuy` are set simultaneously, behavior is undefined.

**Recommendation:** Use a single enum-based state for sheet presentation.

---

#### Duplicate formatCurrency() Functions
**Files:** `DashboardView.swift:155-161`, `WaitingListView.swift:363-369`, others
**Severity:** MEDIUM
**Status:** NOT FIXED

Same helper function duplicated in multiple views.

**Recommendation:** Create shared utility in Helpers folder.

---

#### No Async Cleanup in Multiple Components
**Files:** `DashboardView.swift:452, 605`, `MoneyFlyingAnimation`, `CelebrationOverlay`
**Severity:** MEDIUM
**Status:** NOT FIXED

`DispatchQueue.main.asyncAfter` calls with no cancellation mechanism.

**Recommendation:** Use Task pattern like we did for breathing animation.

---

### LOW SEVERITY

#### Placeholder URLs in Settings
**File:** `SettingsView.swift:145, 149, 153`
**Severity:** LOW
**Status:** DEFERRED (per user request)

URLs point to `example.com`. Should be updated to `yourfutureself.is` before release.

---

#### Deprecated API Usage
**File:** `LearningLibraryView.swift:74`
**Severity:** LOW
**Status:** NOT FIXED

```swift
.navigationBarHidden(true)  // Deprecated in iOS 16+
```

**Recommendation:** Use `.toolbar(.hidden)` instead.

---

#### Hard-Coded UI Dimensions
**Files:** `DashboardView.swift:304-306`, `InterventionBreathingView.swift:53, 68`, `InterventionCelebrationView.swift:66, 80`
**Severity:** LOW
**Status:** NOT FIXED

```swift
startPosition: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 200)
Circle().frame(width: 200, height: 200)
```

**Problem:** Won't handle landscape, iPad, or Dynamic Island properly.

**Recommendation:** Use GeometryReader or relative sizing.

---

#### Missing Accessibility Labels
**Files:** Throughout codebase
**Severity:** LOW
**Status:** NOT FIXED

Emoji text without `accessibilityLabel()`:
- `DashboardView.swift:96` (🔥)
- `WaitingListView.swift:90` (⏳)
- `InterventionCelebrationView.swift` (various)

---

#### Inconsistent UserDefaults.synchronize()
**Files:** `SpendLessApp.swift:179` vs others
**Severity:** LOW
**Status:** NOT FIXED

Some places call `.synchronize()` explicitly, others rely on automatic sync.

---

#### Computed Property Performance
**File:** `DarkPatternCard.swift:49-52`
**Severity:** LOW
**Status:** NOT FIXED

```swift
var isInCooldown: Bool {
    guard let learnedAt else { return false }
    let daysSinceLearned = Calendar.current.dateComponents([.day], from: learnedAt, to: Date()).day ?? 0
    return daysSinceLearned < cooldownDuration
}
```

**Problem:** Calculates date components on every access.

---

#### Silent JSON Encoding Failures
**File:** `LearningCardService.swift:109-111`
**Severity:** LOW
**Status:** NOT FIXED

```swift
if let encoded = try? JSONEncoder().encode(learnedData) {
    UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.learnedCards)
}
// If encoding fails, nothing is saved - silently fails
```

---

## SwiftData Model Issues

### No Model Relationships Defined
**Files:** All model files
**Severity:** MEDIUM
**Status:** NOT FIXED

No inverse relationships or cascade delete rules defined between:
- `UserProfile` ↔ `Streak`
- `UserProfile` ↔ `UserGoal`
- `WaitingListItem` → `GraveyardItem` (implicit via `originalAddedAt`)

**Problem:** No referential integrity. Orphaned records possible.

---

### Missing Indexes on Query Fields
**Files:** `GraveyardItem`, `WaitingListItem`, `Streak`
**Severity:** LOW
**Status:** NOT FIXED

Frequently filtered/sorted fields have no `@Attribute` index:
- `GraveyardItem.buriedAt`
- `WaitingListItem.expiresAt`, `addedAt`

---

### String-Based Enum Storage Pattern
**Files:** All models using enums
**Severity:** MEDIUM
**Status:** NOT FIXED

All enums stored as raw strings with silent fallback:
```swift
var source: GraveyardSource {
    return GraveyardSource(rawValue: sourceRaw) ?? .manual  // Silent fallback!
}
```

**Risk:** If rawValue changes, data becomes invalid and silently defaults.

---

### Purchased Items in UserDefaults Instead of SwiftData
**File:** `WaitingListHelpers.swift:137-169`
**Severity:** LOW
**Status:** NOT FIXED

`PurchasedItemsStore` uses UserDefaults while other data uses SwiftData. Inconsistent storage.

---

## False Positives from Initial Analysis

The following issues were flagged but determined to be non-issues:

1. **"Missing realLifeEquivalent function"** - Function exists as a global in `WaitingListHelpers.swift:14`
2. **"Syntax error in CommitmentDetailView"** - Was just an indentation issue, not a syntax error
3. **"Race condition in InterventionManager"** - Since it's a singleton, there's no deallocation risk (but we fixed it anyway for consistency)

---

## Recommendations by Priority

### Before TestFlight/App Store Release
1. Remove or replace `#if DEBUG` database reset with proper schema migrations
2. Update placeholder URLs to real `yourfutureself.is` URLs
3. Add error handling for `modelContext.save()` calls
4. Fix N+1 query patterns in DashboardView
5. Cache UserDefaults instance in WidgetDataService

### Code Quality (When Time Permits)
1. Extract `"group.com.spendless.data"` to a constant
2. Create shared `formatCurrency()` utility
3. Add SwiftData model relationships and indexes
4. Use enum-based sheet state in WaitingListView
5. Replace remaining `asyncAfter` calls with Task pattern

### Nice to Have
1. Add accessibility labels throughout
2. Use Decimal for all financial calculations
3. Add unit tests for financial calculations
4. Migrate PurchasedItemsStore to SwiftData
