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
        
        isConfigured = true
        print("✅ Superwall configured successfully")
    }
    
    // MARK: - Paywall Presentation
    
    /// Register a paywall placement (triggers paywall if configured in dashboard)
    func register(event: String, params: [String: Any]? = nil) {
        // Configure lazily when first needed
        configureIfNeeded()
        
        guard isConfigured else {
            print("⚠️ Superwall not configured. API key not set.")
            return
        }
        
        print("📱 Superwall: Registering event '\(event)'")
        if let params = params {
            Superwall.shared.register(placement: event, params: params)
        } else {
            Superwall.shared.register(placement: event)
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
            print("✅ Superwall: Transaction completed")
            // Subscription status will be updated by RevenueCat delegate
            
        case .transactionFail:
            print("❌ Superwall: Transaction failed")
            
        case .subscriptionStart:
            print("✅ Superwall: Subscription started")
            
        case .paywallClose:
            print("📱 Superwall: Paywall closed")
            
        case .paywallOpen:
            print("📱 Superwall: Paywall opened")
            
        default:
            break
        }
    }
}

// MARK: - RevenueCat Adapter

/// Adapter to connect Superwall with RevenueCat
class RevenueCatAdapter: PurchaseController {
    func purchase(product: SuperwallKit.StoreProduct) async -> PurchaseResult {
        do {
            // Get the RevenueCat package for this product
            let offerings = try await Purchases.shared.offerings()
            guard let currentOffering = offerings.current else {
                return .failed(NSError(domain: "SuperwallService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No offering available"]))
            }
            
            // Find the package that matches this product
            let package = currentOffering.availablePackages.first { package in
                package.storeProduct.productIdentifier == product.productIdentifier
            }
            
            guard let package = package else {
                return .failed(NSError(domain: "SuperwallService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Package not found for product"]))
            }
            
            // Purchase through RevenueCat
            // RevenueCat's purchase returns: (transaction, customerInfo, userCancelled)
            let (_, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
            
            // Check if user cancelled
            if userCancelled {
                return .cancelled
            }
            
            // Verify purchase was successful by checking customer info
            guard customerInfo.entitlements.all[SubscriptionService.entitlementIdentifier]?.isActive == true else {
                return .failed(NSError(domain: "SuperwallService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Purchase completed but entitlement not active"]))
            }
            
            // Return success
            return .purchased
        } catch {
            return .failed(error)
        }
    }
    
    func restorePurchases() async -> RestorationResult {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            // Check if user has active entitlement
            let hasAccess = customerInfo.entitlements.all[SubscriptionService.entitlementIdentifier]?.isActive == true
            return hasAccess ? .restored : .failed(NSError(domain: "SuperwallService", code: 4, userInfo: [NSLocalizedDescriptionKey: "No active subscription found"]))
        } catch {
            return .failed(error)
        }
    }
}

