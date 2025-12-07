# Paywall Usage Guide

## ✅ What's Been Set Up

1. **PaywallView Created** (`SpendLess/Views/Settings/PaywallView.swift`)
   - Uses RevenueCat's built-in `PaywallView` from RevenueCatUI
   - Handles purchase completion, failures, and restore
   - Automatically updates subscription status after purchase

2. **Settings Integration**
   - Added "Subscription" section in Settings
   - Shows "Upgrade to Pro" button if not subscribed
   - Shows "Pro Member" status with expiration date if subscribed
   - "Restore Purchases" button for non-subscribers
   - "Manage Subscription" button for subscribers

## 🚨 Important: Configure Paywall in RevenueCat Dashboard First!

Before the paywall will work, you **must** configure it in the RevenueCat dashboard:

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Navigate to **Paywalls** section
3. Click **+ New Paywall**
4. Configure your paywall design
5. Attach it to your offering (the one named `default`)

Without this step, the paywall will show an error!

## 📱 How to Present the Paywall

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

## 🔒 Check Subscription Status

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

## 🎯 Common Use Cases

### Show Paywall After Onboarding

In your onboarding completion:

```swift
func completeOnboarding() {
    appState.completeOnboarding()
    // Show paywall after onboarding
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        showPaywall = true
    }
}
```

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

## 🔄 Restore Purchases

The restore functionality is already in Settings. Users can tap "Restore Purchases" to restore their subscription on a new device.

## 📝 Next Steps

1. ✅ Configure paywall in RevenueCat dashboard
2. ✅ Test purchase flow in sandbox
3. ✅ Add subscription checks to premium features
4. ✅ Add paywall triggers (after onboarding, feature gates)
5. ✅ Test restore purchases flow

## 🐛 Troubleshooting

### Paywall shows error
- **Solution:** Make sure you've configured a paywall in RevenueCat dashboard and attached it to your offering

### Purchase doesn't complete
- **Solution:** Check that products are properly configured in App Store Connect and RevenueCat
- Verify you're using a sandbox tester account for testing

### Subscription status not updating
- **Solution:** The paywall automatically updates status after purchase. If it doesn't, check RevenueCat logs in dashboard.

