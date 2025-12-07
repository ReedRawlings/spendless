//
//  SubscriptionService.swift
//  SpendLess
//
//  RevenueCat subscription management service
//

import Foundation
import RevenueCat
import SwiftUI

@MainActor
@Observable
class SubscriptionService: NSObject {
    
    // MARK: - Constants
    
    /// Entitlement identifier configured in RevenueCat dashboard
    static let entitlementIdentifier = "Future Selves Pro"
    
    // MARK: - Singleton
    
    static let shared = SubscriptionService()
    
    // MARK: - State
    
    /// Whether the user has an active subscription
    var isSubscribed: Bool = false
    
    /// Whether the user is in a trial period
    var isInTrial: Bool = false
    
    /// Current subscription status
    var subscriptionStatus: SubscriptionStatus = .unknown
    
    /// Current entitlement status
    var hasProAccess: Bool = false
    
    /// Current customer info (for debugging)
    var customerInfo: CustomerInfo?
    
    /// Error state
    var lastError: Error?
    
    // MARK: - Subscription Status
    
    enum SubscriptionStatus {
        case unknown
        case subscribed
        case trial
        case expired
        case notSubscribed
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        // Don't access Purchases.shared here - it hasn't been configured yet
        // Delegate will be set in configure() method after configuration
    }
    
    // MARK: - Configuration
    
    /// Configure RevenueCat with API key
    /// Call this in app initialization
    func configure(apiKey: String) {
        Purchases.logLevel = .debug // Change to .info or .warn for production
        Purchases.configure(withAPIKey: apiKey)
        
        // Set delegate AFTER configuration
        Purchases.shared.delegate = self
        
        // NOTE: Subscription status check is deferred to avoid Apple ID prompt during onboarding
        // Status will be checked lazily when needed (e.g., when Settings view appears)
    }
    
    // MARK: - Subscription Status Checks
    
    /// Check current subscription status
    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            self.customerInfo = customerInfo
            updateSubscriptionState(from: customerInfo)
        } catch {
            print("❌ Error fetching customer info: \(error)")
            self.lastError = error
        }
    }
    
    /// Update local state from CustomerInfo
    private func updateSubscriptionState(from customerInfo: CustomerInfo) {
        // Check for "Future Selves Pro" entitlement configured in RevenueCat dashboard
        hasProAccess = customerInfo.entitlements.all[Self.entitlementIdentifier]?.isActive == true
        
        // Determine subscription status
        if hasProAccess {
            let entitlement = customerInfo.entitlements.all[Self.entitlementIdentifier]
            isInTrial = entitlement?.willRenew == true && entitlement?.periodType == .trial
            isSubscribed = true
            subscriptionStatus = isInTrial ? .trial : .subscribed
        } else {
            isSubscribed = false
            isInTrial = false
            
            // Check if subscription expired
            if customerInfo.entitlements.all[Self.entitlementIdentifier]?.isActive == false {
                subscriptionStatus = .expired
            } else {
                subscriptionStatus = .notSubscribed
            }
        }
    }
    
    // MARK: - Purchase Flow
    
    /// Get available packages (monthly, annual, etc.)
    func getAvailablePackages() async throws -> [Package] {
        let offerings = try await Purchases.shared.offerings()
        guard let currentOffering = offerings.current else {
            throw SubscriptionError.noOfferingAvailable
        }
        return currentOffering.availablePackages
    }
    
    /// Purchase a package
    func purchase(_ package: Package) async throws -> CustomerInfo {
        let (_, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
        
        // If user cancelled, throw a specific error
        if userCancelled {
            throw SubscriptionError.purchaseFailed("Purchase was cancelled")
        }
        
        // Update state
        self.customerInfo = customerInfo
        updateSubscriptionState(from: customerInfo)
        
        return customerInfo
    }
    
    /// Restore purchases
    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        self.customerInfo = customerInfo
        updateSubscriptionState(from: customerInfo)
    }
    
    // MARK: - Subscription Management
    
    /// Check if user can make purchases
    var canMakePurchases: Bool {
        return Purchases.canMakePayments()
    }
    
    /// Get current subscription expiration date
    var expirationDate: Date? {
        return customerInfo?.entitlements.all[Self.entitlementIdentifier]?.expirationDate
    }
    
    /// Get current subscription product identifier
    var currentProductIdentifier: String? {
        return customerInfo?.entitlements.all[Self.entitlementIdentifier]?.productIdentifier
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionService: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            self.customerInfo = customerInfo
            self.updateSubscriptionState(from: customerInfo)
        }
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case noOfferingAvailable
    case purchaseFailed(String)
    case restoreFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noOfferingAvailable:
            return "No subscription packages are currently available."
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        }
    }
}

