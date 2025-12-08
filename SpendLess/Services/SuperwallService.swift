//
//  SuperwallService.swift
//  SpendLess
//
//  Superwall paywall service - handles paywall presentation and A/B testing
//

import Foundation
import SuperwallKit
import RevenueCat
import SwiftUI

@MainActor
@Observable
final class SuperwallService {
    
    // MARK: - Singleton
    
    static let shared = SuperwallService()
    
    // MARK: - State
    
    /// Whether Superwall is configured
    var isConfigured: Bool = false
    
    /// Store the API key for lazy configuration
    private var apiKey: String?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Configuration
    
    /// Store the API key for later configuration
    /// Call this in app initialization - does NOT trigger StoreKit
    func setAPIKey(_ apiKey: String) {
        self.apiKey = apiKey
        print("✅ Superwall API key stored (will configure lazily when needed)")
    }
    
    /// Actually configure Superwall - only called when about to show paywall
    /// This triggers StoreKit, so we defer it until necessary
    private func configureIfNeeded() {
        guard !isConfigured, let apiKey = apiKey else { return }
        
        // Configure Superwall with RevenueCat adapter
        let adapter = RevenueCatAdapter()
        Superwall.configure(
            apiKey: apiKey,
            purchaseController: adapter
        )
        
        // Set delegate
        Superwall.shared.delegate = self
        
        // Set initial subscription status based on current RevenueCat state
        updateSuperwallSubscriptionStatus()
        
        isConfigured = true
        print("✅ Superwall configured successfully")
    }
    
    /// Update Superwall's subscription status based on RevenueCat state
    /// This should be called whenever subscription status changes
    func updateSuperwallSubscriptionStatus() {
        let subscriptionService = SubscriptionService.shared
        
        if subscriptionService.hasProAccess {
            // User has active subscription - set status to active with empty entitlements set
            // (Superwall will use RevenueCat adapter to check actual entitlements)
            Superwall.shared.subscriptionStatus = .active([])
            print("📱 Superwall: Subscription status set to active")
        } else {
            // User doesn't have subscription - set to inactive
            Superwall.shared.subscriptionStatus = .inactive
            print("📱 Superwall: Subscription status set to inactive")
        }
    }
    
    // MARK: - Paywall Presentation
    
    /// Register a paywall placement (triggers paywall if configured in dashboard)
    func register(event: String, params: [String: Any]? = nil) {
        print("📱 Superwall: register() called with event '\(event)'")
        
        // Configure lazily when first needed
        configureIfNeeded()
        
        guard isConfigured else {
            print("⚠️ Superwall not configured. API key not set.")
            return
        }
        
        print("📱 Superwall: SDK is configured ✅")
        print("📱 Superwall: Current subscription status - hasProAccess: \(SubscriptionService.shared.hasProAccess)")
        print("📱 Superwall: Current subscriptionStatus = \(Superwall.shared.subscriptionStatus)")
            
        // Update Superwall subscription status (use current cached value, don't wait for network)
                updateSuperwallSubscriptionStatus()
                
                if SubscriptionService.shared.hasProAccess {
                    print("⚠️ Superwall: User already has Pro access, paywall may not show")
        } else {
            print("📱 Superwall: User does NOT have Pro access - proceeding with paywall")
                }
                
        print("📱 Superwall: About to call Superwall.shared.register(placement: '\(event)')")
        
        // Register the event/placement - let Superwall handle subscription checks internally
                if let params = params {
                    Superwall.shared.register(placement: event, params: params)
                } else {
                    Superwall.shared.register(placement: event)
                }
                
        print("📱 Superwall: Event '\(event)' registered!")
        print("   ⚠️ If no paywall appears, check Superwall dashboard to ensure:")
        print("   1. Placement '\(event)' exists in dashboard")
        print("   2. A paywall is attached to this placement")
        print("   3. The campaign is ACTIVE (not paused)")
        print("   4. Products are configured and synced from RevenueCat")
        print("   5. For simulator testing, you may need to configure StoreKit")
        
        // Check subscription status in background (non-blocking)
        Task {
            await SubscriptionService.shared.checkSubscriptionStatus()
            await MainActor.run {
                updateSuperwallSubscriptionStatus()
                print("📱 Superwall: Subscription status updated in background")
            }
        }
    }
    
    /// Present a paywall by identifier
    func presentPaywall(identifier: String) {
        // Configure lazily when first needed
        configureIfNeeded()
        
        guard isConfigured else {
            print("⚠️ Superwall not configured. API key not set.")
            return
        }
        
        // Use register with specific paywall identifier
        Superwall.shared.register(placement: identifier)
    }
    
    /// Present the default paywall
    func presentDefaultPaywall() {
        // Configure lazily when first needed
        configureIfNeeded()
        
        guard isConfigured else {
            print("⚠️ Superwall not configured. API key not set.")
            return
        }
        
        print("📱 Superwall: Presenting default paywall")
        // Register default placement to trigger paywall
        Superwall.shared.register(placement: "default")
    }
}

// MARK: - SuperwallDelegate

extension SuperwallService: SuperwallDelegate {
    func handleSuperwallEvent(_ eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .transactionComplete:
            print("✅ Superwall Event: Transaction completed")
            // Subscription status will be updated by RevenueCat delegate
            
        case .transactionFail:
            print("❌ Superwall Event: Transaction failed")
            
        case .subscriptionStart:
            print("✅ Superwall Event: Subscription started")
            
        case .paywallClose:
            print("📱 Superwall Event: Paywall closed")
            
        case .paywallOpen:
            print("📱 Superwall Event: Paywall opened - UI should be visible!")
            
        case .paywallDecline:
            print("📱 Superwall Event: Paywall declined by user")
            
        case .paywallPresentationRequest(let status, let reason):
            // This event tells us what Superwall decided to do
            print("📱 Superwall Event: Paywall presentation request")
            print("   Status: \(status)")
            
            // Log helpful messages based on status
            switch status {
            case .presentation:
                print("   ✅ Will present paywall")
            case .noPresentation:
                print("   ⚠️ Will NOT present paywall")
                if let reason = reason {
                    print("   Reason: \(String(describing: reason))")
                } else {
                    print("   Reason: (none provided)")
                }
            default:
                print("   Status: \(status)")
            }
            
        default:
            print("📱 Superwall Event: \(eventInfo.event)")
        }
    }
}

// MARK: - RevenueCat Adapter

/// Adapter to connect Superwall with RevenueCat
class RevenueCatAdapter: PurchaseController {
    
    func purchase(product: SuperwallKit.StoreProduct) async -> PurchaseResult {
        print("🔄 RevenueCatAdapter: Purchase initiated from Superwall")
        print("   Product ID: \(product.productIdentifier)")
        
        do {
            // Get the RevenueCat package for this product
            print("   Fetching offerings from RevenueCat...")
            let offerings = try await Purchases.shared.offerings()
            guard let currentOffering = offerings.current else {
                print("❌ RevenueCatAdapter: No current offering found")
                return .failed(NSError(domain: "SuperwallService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No offering available"]))
            }
            
            print("   ✅ Current offering found: \(currentOffering.identifier)")
            print("   Available packages: \(currentOffering.availablePackages.count)")
            
            // Find the package that matches this product
            let package = currentOffering.availablePackages.first { package in
                package.storeProduct.productIdentifier == product.productIdentifier
            }
            
            guard let package = package else {
                print("❌ RevenueCatAdapter: Package not found for product \(product.productIdentifier)")
                print("   Available package IDs: \(currentOffering.availablePackages.map { $0.storeProduct.productIdentifier }.joined(separator: ", "))")
                return .failed(NSError(domain: "SuperwallService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Package not found for product"]))
            }
            
            print("   ✅ Matching package found: \(package.identifier)")
            print("   Package Title: \(package.storeProduct.localizedTitle)")
            print("   Package Price: \(package.storeProduct.localizedPriceString)")
            print("   Proceeding with purchase through RevenueCat Test Store...")
            
            // Purchase through RevenueCat
            // RevenueCat's purchase returns: (transaction, customerInfo, userCancelled)
            let (transaction, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
            
            // Check if user cancelled
            if userCancelled {
                print("🚫 RevenueCatAdapter: Purchase cancelled by user")
                return .cancelled
            }
            
            print("   ✅ Purchase transaction completed")
            if let transaction = transaction {
                print("   Transaction ID: \(transaction.transactionIdentifier)")
            }
            
            // Verify purchase was successful by checking customer info
            let entitlement = customerInfo.entitlements.all[SubscriptionService.entitlementIdentifier]
            print("   Checking entitlement '\(SubscriptionService.entitlementIdentifier)'...")
            
            guard let entitlement = entitlement, entitlement.isActive == true else {
                print("❌ RevenueCatAdapter: Purchase completed but entitlement '\(SubscriptionService.entitlementIdentifier)' is not active")
                print("   Active entitlements: \(customerInfo.entitlements.active.keys.joined(separator: ", "))")
                return .failed(NSError(domain: "SuperwallService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Purchase completed but entitlement not active"]))
            }
            
            print("   ✅ Entitlement is ACTIVE")
            print("   Product Identifier: \(entitlement.productIdentifier)")
            if let expirationDate = entitlement.expirationDate {
                print("   Expiration Date: \(expirationDate)")
            }
            print("🎉 RevenueCatAdapter: Purchase successful - returning .purchased")
            
            // Return success
            return .purchased
        } catch {
            print("❌ RevenueCatAdapter: Purchase failed with error: \(error)")
            return .failed(error)
        }
    }
    
    func restorePurchases() async -> RestorationResult {
        print("🔄 RevenueCatAdapter: Restore purchases initiated from Superwall")
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            print("   ✅ Restore purchases completed")
            
            // Check if user has active entitlement
            let entitlement = customerInfo.entitlements.all[SubscriptionService.entitlementIdentifier]
            let hasAccess = entitlement?.isActive == true
            
            if hasAccess {
                print("   ✅ Active entitlement '\(SubscriptionService.entitlementIdentifier)' found")
                if let productId = entitlement?.productIdentifier {
                    print("   Product ID: \(productId)")
                }
                return .restored
            } else {
                print("   ❌ No active entitlement '\(SubscriptionService.entitlementIdentifier)' found")
                print("   Active entitlements: \(customerInfo.entitlements.active.keys.joined(separator: ", "))")
                return .failed(NSError(domain: "SuperwallService", code: 4, userInfo: [NSLocalizedDescriptionKey: "No active subscription found"]))
            }
        } catch {
            print("❌ RevenueCatAdapter: Restore purchases failed with error: \(error)")
            return .failed(error)
        }
    }
}

