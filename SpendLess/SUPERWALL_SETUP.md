# Superwall Setup Guide

This guide will walk you through setting up Superwall for SpendLess paywall A/B testing and management.

## Prerequisites

- ✅ RevenueCat account configured and working
- ✅ Superwall account created
- ✅ RevenueCat products and entitlements set up

---

## Step 1: Add Superwall SDK to Your Project

### Via Xcode (Recommended)

1. Open your project in Xcode
2. Select your project in the navigator
3. Select the **SpendLess** target
4. Go to the **Package Dependencies** tab
5. Click the **+** button
6. Enter this URL: `https://github.com/superwall-me/superwall-ios`
7. Click **Add Package**
8. Select **Up to Next Major Version** and choose the latest version
9. Make sure **SpendLess** target is checked
10. Click **Add Package**

### Verify Installation

After adding the package, you should see `SuperwallKit` in your project's Package Dependencies. The code is already set up to use it!

---

## Step 2: Get Your Superwall API Key

1. Log in to [Superwall Dashboard](https://app.superwall.com)
2. Go to **Settings** → **API Keys**
3. Copy your **API Key**
4. **Important:** Keep this key secure

---

## Step 3: Add API Key to Your Project

1. Open `SpendLess/App/Constants.swift`
2. Find the line: `static let superwallAPIKey = "YOUR_SUPERWALL_API_KEY_HERE"`
3. Replace `YOUR_SUPERWALL_API_KEY_HERE` with your actual API key:

```swift
static let superwallAPIKey = "pk_YOUR_ACTUAL_KEY_HERE"
```

**Security Note:** For production, consider using environment variables or a build configuration to avoid committing the key to git.

---

## Step 4: Configure Superwall Dashboard

### 4.1 Connect RevenueCat

1. In Superwall dashboard, go to **Settings** → **Integrations**
2. Find **RevenueCat** and click **Connect**
3. Enter your RevenueCat API key (the same one used in the app)
4. Superwall will sync your products and entitlements from RevenueCat

### 4.2 Create Your First Paywall

1. Go to **Paywalls** in Superwall dashboard
2. Click **+ New Paywall**
3. Choose a template or start from scratch
4. **Important:** Use a carousel format showing features (as mentioned in your strategy)
5. Design your paywall with:
   - Your app's branding
   - Feature highlights
   - Pricing display (monthly/annual)
   - Clear call-to-action buttons

### 4.3 Configure Paywall Events

Superwall uses events to trigger paywalls. The code is set up to trigger these events:

- `onboarding_complete` - Triggered after onboarding finishes
- `settings_upgrade` - Triggered when user taps "Upgrade to Pro" in Settings

1. In Superwall dashboard, go to **Events**
2. Create these events if they don't exist:
   - `onboarding_complete`
   - `settings_upgrade`
3. Attach your paywall to these events

### 4.4 Set Up A/B Tests (Optional but Recommended)

1. In your paywall settings, click **Create A/B Test**
2. Create variants with different:
   - Messaging
   - Pricing display
   - Feature highlights
   - Button text/colors
3. Set traffic allocation (e.g., 50/50)
4. Superwall will automatically track conversions

---

## Step 5: Test Your Integration

### 5.1 Test in Development

1. Run your app in Xcode
2. Complete onboarding - paywall should appear automatically
3. Go to Settings → "Upgrade to Pro" - paywall should appear
4. Test purchase flow (use sandbox account)

### 5.2 Verify Events Are Firing

1. In Superwall dashboard, go to **Analytics** → **Events**
2. You should see events being registered when:
   - Onboarding completes
   - User taps upgrade button

---

## How It Works

### Event-Based Triggers

The app triggers Superwall events, which then show paywalls based on your dashboard configuration:

```swift
// Trigger paywall after onboarding
superwallService.register(event: "onboarding_complete")

// Trigger paywall from settings
superwallService.register(event: "settings_upgrade")
```

### RevenueCat Integration

Superwall uses RevenueCat for actual purchases:
- Superwall handles the paywall UI and A/B testing
- RevenueCat handles subscription management
- The `RevenueCatAdapter` connects them together

### Automatic Presentation

Superwall presents paywalls modally on its own - you don't need to manage sheets or navigation. Just register the event and Superwall handles the rest.

---

## Custom Events

You can trigger paywalls from anywhere in your app:

```swift
@Environment(SuperwallService.self) private var superwallService

// Simple event
superwallService.register(event: "feature_locked")

// Event with parameters
superwallService.register(
    event: "premium_feature_accessed",
    params: ["feature": "advanced_analytics"]
)
```

Then configure these events in Superwall dashboard to show paywalls.

---

## A/B Testing Strategy

Based on your implementation plan, here are suggested A/B tests:

### Test 1: Messaging
- **Variant A:** "Hey this is going to cost money, we need to earn money to continue building amazing tools. We want you to trial our tool before committing"
- **Variant B:** More feature-focused messaging

### Test 2: Value Proposition
- **Variant A:** Show systems and outcomes
- **Variant B:** Show who they'll become using the app

### Test 3: Pricing Display
- **Variant A:** Emphasize monthly price
- **Variant B:** Emphasize annual savings

---

## Next Steps

1. ✅ Add Superwall SDK
2. ✅ Configure API key
3. ✅ Connect RevenueCat in Superwall dashboard
4. ✅ Create paywall design
5. ✅ Set up events
6. ⏭️ Create A/B test variants
7. ⏭️ Test purchase flow
8. ⏭️ Monitor analytics and optimize

---

## Troubleshooting

### Paywall doesn't appear
- **Solution:** Check that the event is registered in Superwall dashboard
- Verify the event name matches exactly (case-sensitive)
- Check Superwall logs in dashboard

### Purchase doesn't work
- **Solution:** Verify RevenueCat integration in Superwall dashboard
- Check that products are synced from RevenueCat
- Ensure RevenueCat adapter is properly configured

### Events not firing
- **Solution:** Check that Superwall is configured with API key
- Verify events are created in Superwall dashboard
- Check Xcode console for Superwall messages

---

## Resources

- [Superwall iOS Documentation](https://docs.superwall.com/docs/ios)
- [Superwall Dashboard](https://app.superwall.com)
- [Superwall A/B Testing Guide](https://docs.superwall.com/docs/ab-testing)

---

## Support

If you run into issues:
1. Check Superwall dashboard logs
2. Review Xcode console for Superwall messages
3. Check [Superwall Status Page](https://status.superwall.com)
4. Review Superwall documentation linked above

Good luck! 🚀

