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

### Placeholder URLs in Settings
**File:** `SpendLess/Views/Settings/SettingsView.swift:145, 149, 153`
**Severity:** LOW
**Status:** DEFERRED (per user request)

The privacy policy, terms of service, and contact URLs point to `example.com`. These should be updated to `yourfutureself.is` before release.

---

### Silent Error Handling with try?
**Files:** Multiple (15+ locations)
**Severity:** MEDIUM
**Status:** NOT FIXED

Many `modelContext.save()` calls use `try?` which silently swallows errors. Consider adding proper error handling/logging for production.

**Example locations:**
- `DashboardView.swift:597`
- `WaitingListView.swift:207, 230, 245`
- `SettingsView.swift:312, 340`

---

### Hard-Coded App Group ID (DRY Violation)
**Files:** Multiple
**Severity:** LOW
**Status:** NOT FIXED

The string `"group.com.spendless.data"` is duplicated in 10+ files. Consider extracting to a constant.

---

### Decimal Precision in Financial Calculations
**Files:** `InterventionManager.swift`, `WidgetDataService.swift`, `ToolCalculationService.swift`
**Severity:** MEDIUM
**Status:** NOT FIXED

Some calculations convert `Decimal` to `Double` and back, which can lose precision over time. For a financial app, consider using `Decimal` throughout.

---

## False Positives from Initial Analysis

The following issues were flagged but determined to be non-issues:

1. **"Missing realLifeEquivalent function"** - Function exists as a global in `WaitingListHelpers.swift:14`
2. **"Syntax error in CommitmentDetailView"** - Was just an indentation issue, not a syntax error
3. **"Race condition in InterventionManager"** - Since it's a singleton, there's no deallocation risk (but we fixed it anyway for consistency)

---

## Recommendations for Future

1. **Before TestFlight/App Store release:**
   - Remove or replace the `#if DEBUG` database reset code with proper schema migrations
   - Update placeholder URLs to real `yourfutureself.is` URLs
   - Add error handling for `modelContext.save()` calls

2. **Code quality improvements:**
   - Extract `"group.com.spendless.data"` to a constant
   - Consider creating a shared `formatCurrency()` utility
   - Add SwiftData model relationships and indexes

3. **Testing:**
   - Add unit tests for financial calculations
   - Test schema migration scenarios before adding users
