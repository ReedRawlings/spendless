# Screen Time Extension Setup Guide

SpendLess requires three app extensions to implement Screen Time blocking functionality. These extensions run in separate processes and require the Family Controls entitlement.

## Prerequisites

1. **Apple Developer Account** - Required for requesting entitlements
2. **Family Controls Entitlement** - Must be requested from Apple (2-6 week approval)
3. **Physical iOS Device** - Screen Time APIs don't work in Simulator

## Requesting the Entitlement

1. Go to: https://developer.apple.com/contact/request/family-controls-distribution
2. Submit requests for ALL targets:
   - `com.spendless.app` (main app)
   - `com.spendless.app.DeviceActivityMonitorExtension`
   - `com.spendless.app.ShieldConfigurationExtension`
   - `com.spendless.app.ShieldActionExtension`
3. Provide clear explanation of app purpose
4. Wait 2-6 weeks for approval

> **Note:** Development entitlement works immediately for testing on your own devices. Distribution entitlement is required for TestFlight and App Store.

## Creating the Extensions

### 1. DeviceActivityMonitorExtension

**Purpose:** Responds to schedule events (start/end) to apply/remove shields

**Steps:**
1. In Xcode: File → New → Target
2. Select "Device Activity Monitor Extension"
3. Name: `DeviceActivityMonitorExtension`
4. Bundle ID: `com.spendless.app.DeviceActivityMonitorExtension`

**Capabilities:**
- Add "Family Controls" capability
- Add "App Groups" with identifier: `group.com.spendless.data`

### 2. ShieldConfigurationExtension

**Purpose:** Customizes the blocking screen appearance

**Steps:**
1. In Xcode: File → New → Target
2. Select "Shield Configuration Extension"
3. Name: `ShieldConfigurationExtension`
4. Bundle ID: `com.spendless.app.ShieldConfigurationExtension`

**Capabilities:**
- Add "Family Controls" capability
- Add "App Groups" with identifier: `group.com.spendless.data`

### 3. ShieldActionExtension

**Purpose:** Handles user button taps on the blocking screen

**Steps:**
1. In Xcode: File → New → Target
2. Select "Shield Action Extension"
3. Name: `ShieldActionExtension`
4. Bundle ID: `com.spendless.app.ShieldActionExtension`

**Capabilities:**
- Add "Family Controls" capability
- Add "App Groups" with identifier: `group.com.spendless.data`

## App Groups Configuration

All targets (main app + 3 extensions) must share data via App Groups:

1. Add "App Groups" capability to each target
2. Use the same group identifier: `group.com.spendless.data`
3. Access shared data:

```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")

// Save data
sharedDefaults?.set(value, forKey: "key")

// Read data
let value = sharedDefaults?.string(forKey: "key")
```

## Data Sharing Between App and Extensions

### Main App → Extensions
- `blockedApps`: Encoded FamilyActivitySelection
- `difficultyMode`: String ("gentle", "firm", "lockdown")
- `totalSaved`: Double
- `currentStreak`: Int

### Extensions → Main App
- `pendingIntercepts`: Array of intercept events
- `pendingDeepLink`: URL string for deep linking
- `lastExtensionEvent`: Debug logging

## Testing

1. **Build to physical device** - Simulator won't work
2. **Sign in to iCloud** on test device
3. **First FamilyActivityPicker** may show empty - dismiss and reopen
4. **Shields persist** even after app termination (expected)

## Known Limitations

- Max 50 app tokens per shield
- Max 50 named ManagedSettingsStores
- Max 20 DeviceActivity schedules
- Tokens are opaque - cannot get app bundle IDs
- Users can always disable via Settings → Screen Time

## Debugging

Check extension logs in Console.app:
1. Connect device to Mac
2. Open Console.app
3. Filter by process name (e.g., "DeviceActivityMonitor")

## Resources

- [WWDC21: Meet the Screen Time API](https://developer.apple.com/videos/play/wwdc2021/10123/)
- [WWDC22: What's New in Screen Time API](https://developer.apple.com/videos/play/wwdc2022/110336/)
- [Apple FamilyControls Documentation](https://developer.apple.com/documentation/familycontrols)
- [Apple ManagedSettings Documentation](https://developer.apple.com/documentation/managedsettings)
- [Julius Brussee's Implementation Guide](https://medium.com/@juliusbrussee/a-developers-guide-to-apple-s-screen-time-apis)

