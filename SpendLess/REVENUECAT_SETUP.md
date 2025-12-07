# RevenueCat Setup Guide

This guide will walk you through setting up RevenueCat for SpendLess subscriptions.

## Prerequisites

- ✅ RevenueCat account created
- ✅ App Store Connect account with your app configured
- ✅ In-App Purchase products created in App Store Connect

---

## Step 1: Add RevenueCat SDK to Your Project

### Via Xcode (Recommended)

1. Open your project in Xcode
2. Select your project in the navigator
3. Select the **SpendLess** target
4. Go to the **Package Dependencies** tab
5. Click the **+** button
6. Enter this URL: `https://github.com/RevenueCat/purchases-ios`
7. Click **Add Package**
8. Select **Up to Next Major Version** and choose the latest version (e.g., `5.0.0`)
9. Make sure **SpendLess** target is checked
10. Click **Add Package**

### Verify Installation

After adding the package, you should see `RevenueCat` in your project's Package Dependencies. The code is already set up to use it!

---

## Step 2: Get Your RevenueCat API Key

1. Log in to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Select your project (or create a new one)
3. Go to **Project Settings** → **API Keys**
4. Copy the **Public API Key** (starts with `appl_` or `goog_`)
5. **Important:** Use the PUBLIC key, not the secret key

---

## Step 3: Add API Key to Your Project

1. Open `SpendLess/App/Constants.swift`
2. Find the line: `static let revenueCatAPIKey = "YOUR_REVENUECAT_API_KEY_HERE"`
3. Replace `YOUR_REVENUECAT_API_KEY_HERE` with your actual API key:

```swift
static let revenueCatAPIKey = "appl_YOUR_ACTUAL_KEY_HERE"
```

**Security Note:** For production, consider using environment variables or a build configuration to avoid committing the key to git. For now, this is fine for development.

---

## Step 4: Configure Your App in RevenueCat Dashboard

### 4.1 Add Your iOS App

1. In RevenueCat dashboard, go to **Apps**
2. Click **+ New App**
3. Enter your app details:
   - **Name:** SpendLess
   - **Bundle ID:** `Future-Selves.SpendLess` (or your actual bundle ID)
   - **Platform:** iOS
4. Click **Create**

### 4.2 Connect App Store Connect

1. In your app settings, go to **App Store Connect**
2. Click **Connect App Store Connect**
3. Follow the prompts to authenticate with Apple
4. Select your app from App Store Connect
5. RevenueCat will sync your in-app purchases

---

## Step 5: Create Products in App Store Connect

If you haven't already, create your subscription products:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Features** → **In-App Purchases**
4. Click **+** to create a new subscription
5. Create two subscription groups:

### Subscription Group: "SpendLess Pro"

#### Product 1: Monthly Subscription
- **Product ID:** `spendless_pro_monthly`
- **Type:** Auto-Renewable Subscription
- **Price:** $6.99/month (or your chosen price)
- **Duration:** 1 Month
- **Free Trial:** Optional (e.g., 7 days)

#### Product 2: Annual Subscription
- **Product ID:** `spendless_pro_annual`
- **Type:** Auto-Renewable Subscription
- **Price:** $39.99/year (or your chosen price)
- **Duration:** 1 Year
- **Free Trial:** Optional (e.g., 7 days)

**Important:** Save these Product IDs - you'll need them in RevenueCat!

---

## Step 6: Configure Products in RevenueCat

### 6.1 Create Entitlement

1. In RevenueCat dashboard, go to **Entitlements**
2. Click **+ New Entitlement**
3. Name it: `pro`
4. Click **Create**

This entitlement will be used to check if a user has active subscription access.

### 6.2 Create Products

1. Go to **Products**
2. Click **+ New Product**
3. For each subscription:
   - **Product ID:** Use the same ID from App Store Connect (e.g., `spendless_pro_monthly`)
   - **Store:** App Store
   - **Type:** Subscription
   - Click **Create**

### 6.3 Create Offering

1. Go to **Offerings**
2. Click **+ New Offering**
3. Name it: `default` (this is the default offering name the code expects)
4. Add your products:
   - Add `spendless_pro_monthly` package
   - Add `spendless_pro_annual` package
5. **Attach Entitlement:**
   - For each package, attach the `pro` entitlement
6. Click **Save**

**Note:** The code looks for an offering named `default`. If you use a different name, you'll need to update `SubscriptionService.swift`.

---

## Step 7: Test Your Integration

### 7.1 Test in Sandbox

1. In Xcode, run your app on a device or simulator
2. Make sure you're signed in with a **Sandbox Tester** account (not your regular Apple ID)
3. Create a sandbox tester in App Store Connect:
   - Go to **Users and Access** → **Sandbox Testers**
   - Create a test account
4. Sign out of your regular Apple ID in Settings → App Store
5. When prompted during purchase, sign in with your sandbox tester account

### 7.2 Verify Subscription Status

The app will automatically check subscription status on launch. You can verify it's working by:

1. Check the console logs for RevenueCat messages
2. The `SubscriptionService` will update `isSubscribed` and `hasProAccess` properties
3. You can access subscription status via `appState.subscriptionService.isSubscribed`

---

## Step 8: Implement Paywall UI

The subscription service is ready to use! Now you need to create your paywall UI. Here's how to use the service:

```swift
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var packages: [Package] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
                Text("Error: \(error)")
            } else {
                // Display packages
                ForEach(packages, id: \.identifier) { package in
                    PackageRow(package: package)
                }
            }
        }
        .task {
            await loadPackages()
        }
    }
    
    func loadPackages() async {
        do {
            packages = try await subscriptionService.getAvailablePackages()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func purchase(_ package: Package) async {
        do {
            _ = try await subscriptionService.purchase(package)
            // Purchase successful - dismiss paywall
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

---

## Step 9: Check Subscription Status Throughout Your App

You can check subscription status anywhere in your app:

```swift
@Environment(SubscriptionService.self) private var subscriptionService

var body: some View {
    if subscriptionService.hasProAccess {
        // Show premium features
    } else {
        // Show paywall or free tier
    }
}
```

Or access via AppState:

```swift
@Environment(AppState.self) private var appState

var body: some View {
    if appState.subscriptionService.hasProAccess {
        // Premium content
    }
}
```

---

## Step 10: Restore Purchases

Add a "Restore Purchases" button in your Settings:

```swift
Button("Restore Purchases") {
    Task {
        do {
            try await subscriptionService.restorePurchases()
            // Show success message
        } catch {
            // Show error message
        }
    }
}
```

---

## Common Issues & Solutions

### Issue: "No offering available"
- **Solution:** Make sure you've created an offering named `default` in RevenueCat dashboard
- Check that products are attached to the offering
- Verify products are approved in App Store Connect

### Issue: "Purchase failed" in sandbox
- **Solution:** Make sure you're using a sandbox tester account
- Verify the product IDs match exactly between App Store Connect and RevenueCat
- Check that products are in "Ready to Submit" status in App Store Connect

### Issue: Subscription status not updating
- **Solution:** Check that the entitlement is properly attached to products
- Verify the entitlement name is `pro` (or update the code to match)
- Check RevenueCat logs in the dashboard

### Issue: API key errors
- **Solution:** Verify you're using the PUBLIC API key (not secret)
- Make sure the key is correctly set in `Constants.swift`
- Check that the key matches your project in RevenueCat dashboard

---

## Next Steps

1. ✅ RevenueCat SDK added
2. ✅ API key configured
3. ✅ Products created in App Store Connect
4. ✅ Products configured in RevenueCat
5. ✅ Entitlement created and attached
6. ✅ Offering created
7. ⏭️ Create paywall UI (you can use Superwall later for A/B testing)
8. ⏭️ Add subscription checks to premium features
9. ⏭️ Test end-to-end purchase flow
10. ⏭️ Test restore purchases flow

---

## Additional Resources

- [RevenueCat iOS Documentation](https://docs.revenuecat.com/docs/ios)
- [RevenueCat iOS SDK Reference](https://www.revenuecat.com/docs/ios)
- [Testing Subscriptions Guide](https://docs.revenuecat.com/docs/testing-subscriptions)
- [RevenueCat Dashboard](https://app.revenuecat.com)

---

## Support

If you run into issues:
1. Check RevenueCat dashboard logs
2. Review Xcode console for RevenueCat messages
3. Check [RevenueCat Status Page](https://status.revenuecat.com)
4. Review RevenueCat documentation linked above

Good luck! 🚀

