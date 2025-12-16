# Paywall Usage Guide

## Overview

SpendLess uses native StoreKit 2 for subscription management. The custom paywall is built with SwiftUI and matches the app's design system.

## What's Been Set Up

1. **SubscriptionService** (`SpendLess/Services/SubscriptionService.swift`)
   - Native StoreKit 2 implementation
   - Transaction listener for real-time updates
   - Subscription status checking via `Transaction.currentEntitlements`
   - Purchase and restore functionality

2. **Custom PaywallView** (`SpendLess/Views/Settings/PaywallView.swift`)
   - Custom SwiftUI paywall matching app design system
   - Displays monthly and annual subscription options
   - Shows trial information (4-day free trial)
   - Handles purchase flow with loading states
   - Includes restore purchases button

3. **Settings Integration**
   - "Subscription" section in Settings
   - Shows "Upgrade to Pro" button if not subscribed
   - Shows "Pro Member" status with expiration date if subscribed
   - "Restore Purchases" button for non-subscribers
   - "Manage Subscription" button for subscribers

## Product IDs

Configured in `SpendLess/App/Constants.swift`:

```swift
enum ProductIdentifiers {
    static let monthly = "monthly_699_4daytrial"
    static let annual = "monthly_1999_4daytrial"
}
```

These must match the products configured in App Store Connect.

## How to Present the Paywall

### From Settings (Already Done)
The paywall is already integrated in Settings. Users can tap "Upgrade to Pro" to see it.

### From Anywhere in Your App

```swift
@State private var showPaywall = false

var body: some View {
    Button("Upgrade") {
        showPaywall = true
    }
    .sheet(isPresented: $showPaywall) {
        SpendLessPaywallView()
    }
}
```

### Using the Helper Modifier

```swift
@State private var showPaywall = false

var body: some View {
    Button("Upgrade") {
        showPaywall = true
    }
    .presentPaywall(isPresented: $showPaywall)
}
```

## Check Subscription Status

### In Any View

```swift
@Environment(SubscriptionService.self) private var subscriptionService

var body: some View {
    if subscriptionService.hasProAccess {
        // Show premium features
    } else {
        // Show paywall or free tier
        Button("Upgrade") {
            showPaywall = true
        }
    }
}
```

### Via AppState

```swift
@Environment(AppState.self) private var appState

var body: some View {
    if appState.subscriptionService.hasProAccess {
        // Premium content
    }
}
```

## Common Use Cases

### Show Paywall After Onboarding

The app automatically shows the paywall after onboarding completes (configured in `RootView`).

### Gate Premium Features

```swift
struct PremiumFeatureView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var showPaywall = false
    
    var body: some View {
        if subscriptionService.hasProAccess {
            // Premium feature content
        } else {
            VStack {
                Text("This feature requires Pro")
                Button("Upgrade to Pro") {
                    showPaywall = true
                }
            }
            .sheet(isPresented: $showPaywall) {
                SpendLessPaywallView()
            }
        }
    }
}
```

## Subscription Service API

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `hasProAccess` | `Bool` | Whether user has active subscription |
| `isSubscribed` | `Bool` | Whether user is subscribed |
| `isInTrial` | `Bool` | Whether user is in trial period |
| `subscriptionStatus` | `SubscriptionStatus` | Current status enum |
| `expirationDate` | `Date?` | Subscription expiration date |
| `currentProductIdentifier` | `String?` | Active product ID |

### Methods

```swift
// Check subscription status
await subscriptionService.checkSubscriptionStatus()

// Get available products
let products = try await subscriptionService.getAvailableProducts()

// Purchase a product
try await subscriptionService.purchase(product)

// Restore purchases
try await subscriptionService.restorePurchases()
```

## App Store Connect Setup

1. Create subscription products in App Store Connect:
   - `monthly_699_4daytrial` - Monthly at $6.99 with 4-day trial
   - `monthly_1999_4daytrial` - Annual at $19.99 with 4-day trial

2. Configure subscription group "SpendLess Pro"

3. Set up pricing and free trial periods

4. Create sandbox tester accounts for testing

## Testing

### Sandbox Testing

1. Sign out of your Apple ID in Settings → App Store
2. Run the app on a device
3. When prompted to purchase, sign in with sandbox tester account
4. Sandbox purchases complete instantly and renew quickly

### Testing Checklist

- [ ] Subscription status checking works on app launch
- [ ] Purchase flow completes successfully
- [ ] Trial period detection works correctly
- [ ] Restore purchases works on new device
- [ ] Subscription expiration is detected correctly
- [ ] Paywall UI displays correctly with products
- [ ] Error handling works for failed purchases

## Troubleshooting

### Products not loading
- Verify product IDs match App Store Connect exactly
- Check that products are approved and available
- Ensure Paid Applications agreement is signed

### Purchase doesn't complete
- Verify you're using a sandbox tester account
- Check Xcode console for StoreKit errors
- Ensure device is connected to internet

### Subscription status not updating
- Call `checkSubscriptionStatus()` after purchase
- Check that transaction listener is running
- Verify transaction is being finished

### Trial not detected
- Check product configuration in App Store Connect
- Verify introductory offer is set up correctly
