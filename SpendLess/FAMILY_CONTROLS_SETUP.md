# Family Controls Setup - CRITICAL

## The Problem
If SpendLess doesn't appear in Settings > Screen Time, the main app target is missing the Family Controls entitlement.

## Solution: Add Entitlements to Main App

### Step 1: Add Entitlements File to Xcode Project

1. In Xcode, right-click on the `SpendLess` folder in the Project Navigator
2. Select "Add Files to SpendLess..."
3. Navigate to and select: `SpendLess/SpendLess.entitlements`
4. Make sure "Copy items if needed" is **UNCHECKED** (file already exists)
5. Make sure "Add to targets: SpendLess" is **CHECKED**
6. Click "Add"

### Step 2: Configure Build Settings

1. Select the **SpendLess** project in the Project Navigator
2. Select the **SpendLess** target (not the extensions)
3. Go to the **Build Settings** tab
4. Search for "Code Signing Entitlements"
5. Set the value to: `SpendLess/SpendLess.entitlements`

### Step 3: Add Family Controls Capability

1. With the **SpendLess** target selected, go to the **Signing & Capabilities** tab
2. Click **+ Capability**
3. Search for and add **"Family Controls"**
4. This should automatically add the entitlement

### Step 4: Verify App Groups

1. Still in **Signing & Capabilities** for the **SpendLess** target
2. Make sure **App Groups** capability is added
3. Verify the group `group.com.spendless.data` is checked

### Step 5: Request Entitlement from Apple

**CRITICAL:** Even with the entitlement file, you must request approval from Apple:

1. Go to: https://developer.apple.com/contact/request/family-controls-distribution
2. Submit a request for bundle ID: `Future-Selves.SpendLess`
3. Explain: "SpendLess is a self-control app that helps users block shopping apps to reduce impulse spending. Users voluntarily choose which apps to block."
4. Wait 2-6 weeks for approval

**Note:** Development entitlement works immediately for testing on your own devices. Distribution entitlement is required for TestFlight and App Store.

### Step 6: Verify Setup

After adding the entitlement and requesting approval:

1. Clean build folder: Product > Clean Build Folder (Shift+Cmd+K)
2. Build and run on a **physical device** (not simulator)
3. Go to Settings > Screen Time
4. You should now see **SpendLess** listed
5. Tap it and toggle on "Allow Family Controls"

### Troubleshooting

**Still not showing in Screen Time?**
- Make sure you're testing on a physical device (not simulator)
- Make sure you've requested the entitlement from Apple
- Check that the entitlements file is properly referenced in build settings
- Try deleting the app and reinstalling
- Check Console.app for entitlement errors

**Authorization prompt not appearing?**
- Make sure the main app has the Family Controls entitlement
- Check that `AuthorizationCenter.shared.requestAuthorization(for: .individual)` is being called
- Verify the app is signed with a development or distribution certificate that has the entitlement

## Current Status

✅ Extensions have entitlements:
- DeviceActivityMonitorExtension ✅
- ShieldConfigurationExtension ✅
- ShieldActionExtension ✅

❌ Main app missing:
- SpendLess.entitlements file created but needs to be added to Xcode project
- Family Controls capability needs to be added in Xcode
- Entitlement needs to be requested from Apple

