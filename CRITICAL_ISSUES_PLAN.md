# Critical Issues Resolution Plan

## Executive Summary

This document outlines the plan to address **HIGH PRIORITY** and **CRITICAL** issues identified in the SpendLess codebase. These issues pose risks of data loss, silent failures, and incorrect behavior in production.

---

## Priority 1: Critical Data Integrity Issues

### 1.1 Silent Error Handling (15+ locations)
**Severity:** HIGH  
**Risk:** Data loss - users may think data was saved when it wasn't

**Problem:**
- Multiple `modelContext.save()` calls use `try?` which silently swallows errors
- No user feedback when saves fail
- No logging for debugging

**Locations:**
- `AppState.swift`: 5 locations
- `DashboardView.swift`: 1 location
- `WaitingListView.swift`: 4 locations
- `GraveyardView.swift`: 1 location
- `SettingsView.swift`: 3 locations
- Plus 5+ more in other views

**Solution:**
1. Create a helper extension on `ModelContext` with proper error handling
2. Replace all `try? modelContext.save()` with the helper
3. Add logging for failures
4. Consider user-facing error messages for critical saves

**Implementation:**
```swift
extension ModelContext {
    func saveWithErrorHandling() {
        do {
            try save()
        } catch {
            print("❌ Failed to save model context: \(error)")
            // Optionally: show user alert for critical saves
        }
    }
}
```

---

### 1.2 No Singleton Enforcement for Models
**Severity:** HIGH  
**Risk:** Data corruption - multiple UserProfile/Streak records can exist

**Problem:**
- `UserProfile` and `Streak` should be singletons but have no uniqueness constraints
- Code assumes `.first` will get the correct record
- Race conditions possible in `getOrCreateProfile()` and `getOrCreateStreak()`

**Solution:**
1. Add `@Attribute(.unique)` to a unique identifier field in both models
2. Use a constant ID (e.g., UUID.zero or a fixed UUID) for singleton instances
3. Update `getOrCreateProfile()` and `getOrCreateStreak()` to use the unique constraint

**Implementation:**
- Add `@Attribute(.unique)` to `UserProfile.id` and `Streak.id`
- Create a constant singleton ID: `static let singletonID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!`
- Update fetch logic to use this ID

**Note:** This requires a migration strategy if existing data exists.

---

### 1.3 Hard-Coded String Predicate
**Severity:** HIGH  
**Risk:** Silent data corruption if enum rawValue changes

**Problem:**
- `WaitingListView.swift:17` uses hardcoded string `"waitingList"` in predicate
- If `GraveyardSource.waitingList.rawValue` changes, predicate silently fails

**Solution:**
- Replace with `GraveyardSource.waitingList.rawValue`

**Implementation:**
```swift
@Query(filter: #Predicate<GraveyardItem> { $0.sourceRaw == GraveyardSource.waitingList.rawValue })
```

---

### 1.4 N+1 Query Pattern
**Severity:** HIGH  
**Risk:** Performance degradation, unnecessary memory usage

**Problem:**
- `DashboardView.swift` loads ALL goals then filters in memory
- Should use database-level filtering

**Solution:**
- Add predicate to `@Query` to filter at database level

**Implementation:**
```swift
@Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]
```

---

### 1.5 UserDefaults Instance Created Every Access
**Severity:** HIGH  
**Risk:** Race conditions, performance issues

**Problem:**
- `WidgetDataService.swift` creates new `UserDefaults` instance on every access
- Concurrent calls could race

**Solution:**
- Cache as stored property (lazy initialization)

**Implementation:**
```swift
private lazy var sharedDefaults: UserDefaults? = {
    UserDefaults(suiteName: suiteName)
}()
```

---

## Priority 2: Code Quality Improvements

### 2.1 Extract App Group ID Constant
**Severity:** MEDIUM  
**Risk:** Maintenance burden, typos

**Problem:**
- `"group.com.spendless.data"` duplicated in 10+ locations
- Risk of typos causing silent failures

**Solution:**
- Create shared constant in a new `AppConstants.swift` file
- Replace all occurrences

**Implementation:**
```swift
enum AppConstants {
    static let appGroupIdentifier = "group.com.spendless.data"
}
```

---

## Implementation Order

1. **Fix UserDefaults caching** (Quick win, low risk)
2. **Fix hard-coded string predicate** (Quick fix, low risk)
3. **Fix N+1 query pattern** (Quick fix, low risk)
4. **Extract App Group ID constant** (Refactoring, medium risk)
5. **Add singleton enforcement** (Requires migration consideration, high risk)
6. **Fix silent error handling** (Many locations, medium risk)

---

## Testing Strategy

After each fix:
1. Verify app builds successfully
2. Test affected functionality manually
3. Check for any runtime warnings/errors
4. Verify data persistence still works

For singleton enforcement:
- Test with existing data
- Verify no duplicate records created
- Test `getOrCreate` methods work correctly

---

## Notes

- Some issues (like decimal precision loss) are marked as MEDIUM and can be deferred
- The singleton enforcement may require a data migration strategy
- Error handling improvements should be done incrementally to avoid breaking changes
