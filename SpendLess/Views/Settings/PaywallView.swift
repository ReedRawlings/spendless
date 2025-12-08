//
//  PaywallView.swift
//  SpendLess
//
//  RevenueCat PaywallView wrapper for testing
//  Use this when Superwall isn't configured in the dashboard
//

import SwiftUI
import RevenueCatUI
import RevenueCat

/// A simple paywall view using RevenueCat's built-in UI
/// Use this for testing when Superwall dashboard isn't configured
struct SpendLessPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionService.self) private var subscriptionService
    
    var body: some View {
        PaywallView()
            .onPurchaseCompleted { customerInfo in
                print("✅ PaywallView: Purchase completed!")
                print("   Active entitlements: \(customerInfo.entitlements.active.keys.joined(separator: ", "))")
                
                // Check if our entitlement is now active
                if customerInfo.entitlements.all[SubscriptionService.entitlementIdentifier]?.isActive == true {
                    print("🎉 PaywallView: \(SubscriptionService.entitlementIdentifier) is now ACTIVE")
                }
                
                dismiss()
            }
            .onRestoreCompleted { customerInfo in
                print("✅ PaywallView: Restore completed!")
                print("   Active entitlements: \(customerInfo.entitlements.active.keys.joined(separator: ", "))")
                
                if customerInfo.entitlements.all[SubscriptionService.entitlementIdentifier]?.isActive == true {
                    print("🎉 PaywallView: \(SubscriptionService.entitlementIdentifier) restored and ACTIVE")
                    dismiss()
                }
            }
    }
}

/// View modifier to present the paywall as a sheet
struct PaywallModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                SpendLessPaywallView()
            }
    }
}

extension View {
    /// Present the SpendLess paywall as a sheet
    func presentPaywall(isPresented: Binding<Bool>) -> some View {
        modifier(PaywallModifier(isPresented: isPresented))
    }
}

#Preview {
    SpendLessPaywallView()
}

