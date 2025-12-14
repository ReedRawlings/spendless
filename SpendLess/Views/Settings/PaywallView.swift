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

    @State private var offering: Offering?
    @State private var isLoading = true
    @State private var loadError: Error?

    var body: some View {
        Group {
            if isLoading {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let offering = offering {
                // Show paywall with the fetched offering
                PaywallView(offering: offering)
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
            } else {
                // Fallback UI when offerings couldn't be loaded
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text("Unable to Load Subscription Options")
                        .font(.headline)

                    Text("Please check your internet connection and try again. If the problem persists, you can access subscription options from Settings.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button("Try Again") {
                        Task {
                            await loadOffering()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Continue to App") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .task {
            await loadOffering()
        }
    }

    /// Fetch the offering from RevenueCat
    private func loadOffering() async {
        isLoading = true
        loadError = nil

        do {
            let offerings = try await Purchases.shared.offerings()

            // First try to get our specific offering
            if let specificOffering = offerings.offering(identifier: SubscriptionService.offeringIdentifier) {
                print("✅ PaywallView: Loaded offering '\(SubscriptionService.offeringIdentifier)'")
                self.offering = specificOffering
            }
            // Fall back to current offering if available
            else if let currentOffering = offerings.current {
                print("✅ PaywallView: Using current offering '\(currentOffering.identifier)'")
                self.offering = currentOffering
            }
            // No offerings available
            else {
                print("⚠️ PaywallView: No offerings available")
                print("   Available offerings: \(offerings.all.keys.joined(separator: ", "))")
                self.offering = nil
            }
        } catch {
            print("❌ PaywallView: Failed to load offerings: \(error)")
            self.loadError = error
            self.offering = nil
        }

        isLoading = false
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

