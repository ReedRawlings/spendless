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
        // Detect Test Store vs Production
        let isTestStore = apiKey.hasPrefix("test_")
        let environment = isTestStore ? "Test Store" : "Production"
        
        print("🔧 RevenueCat Configuration:")
        print("   Environment: \(environment)")
        print("   API Key: \(apiKey.prefix(10))...\(apiKey.suffix(4))")
        print("   Entitlement Identifier: \(Self.entitlementIdentifier)")
        
        Purchases.logLevel = .debug // Change to .info or .warn for production
        Purchases.configure(withAPIKey: apiKey)
        
        // Set delegate AFTER configuration
        Purchases.shared.delegate = self
        
        // Verify Test Store setup if using Test Store
        if isTestStore {
            Task {
                await verifyTestStoreSetup()
            }
        }
        
        // NOTE: Subscription status check is deferred to avoid Apple ID prompt during onboarding
        // Status will be checked lazily when needed (e.g., when Settings view appears)
    }
    
    /// Verify Test Store setup and log configuration status
    func verifyTestStoreSetup() async {
        print("🔍 Verifying Test Store Setup...")
        
        do {
            // Attempt to fetch offerings
            let offerings = try await Purchases.shared.offerings()
            
            if let currentOffering = offerings.current {
                print("✅ Current Offering Found: \(currentOffering.identifier)")
                print("   Available Packages: \(currentOffering.availablePackages.count)")
                
                for (index, package) in currentOffering.availablePackages.enumerated() {
                    print("   Package \(index + 1):")
                    print("     Identifier: \(package.identifier)")
                    print("     Product ID: \(package.storeProduct.productIdentifier)")
                    print("     Localized Price: \(package.storeProduct.localizedPriceString)")
                }
            } else {
                print("⚠️ No current offering found. Make sure:")
                print("   1. An offering named 'default' exists in RevenueCat dashboard")
                print("   2. The offering is set as 'Current Offering'")
                print("   3. Test products are added to the offering")
            }
            
            // Check entitlement identifier
            let customerInfo = try await Purchases.shared.customerInfo()
            let entitlementExists = customerInfo.entitlements.all.keys.contains(Self.entitlementIdentifier)
            
            if entitlementExists {
                print("✅ Entitlement '\(Self.entitlementIdentifier)' exists in system")
                let entitlement = customerInfo.entitlements.all[Self.entitlementIdentifier]
                if let entitlement = entitlement {
                    print("   Current Status: \(entitlement.isActive ? "Active" : "Inactive")")
                } else {
                    print("   Current Status: Not yet used")
                }
            } else {
                print("⚠️ Entitlement '\(Self.entitlementIdentifier)' not found in customer info")
                print("   (This is normal if user hasn't purchased yet)")
                print("   Verify entitlement name matches exactly in RevenueCat dashboard")
            }
            
        } catch {
            print("❌ Error verifying Test Store setup: \(error)")
            self.lastError = error
        }
    }
    
    /// Log full customer info for debugging
    func logCustomerInfo(_ customerInfo: CustomerInfo) {
        print("📋 Customer Info:")
        print("   Active Entitlements: \(customerInfo.entitlements.active.count)")
        print("   All Entitlements: \(customerInfo.entitlements.all.keys.joined(separator: ", "))")
        
        if let entitlement = customerInfo.entitlements.all[Self.entitlementIdentifier] {
            print("   '\(Self.entitlementIdentifier)' Entitlement:")
            print("     Active: \(entitlement.isActive)")
            print("     Will Renew: \(entitlement.willRenew)")
            print("     Period Type: \(entitlement.periodType)")
            print("     Product Identifier: \(entitlement.productIdentifier)")
            if let expirationDate = entitlement.expirationDate {
                print("     Expiration Date: \(expirationDate)")
            }
        } else {
            print("   '\(Self.entitlementIdentifier)' Entitlement: Not found")
        }
        
        print("   Active Subscriptions: \(customerInfo.activeSubscriptions.joined(separator: ", "))")
    }
    
    // MARK: - Subscription Status Checks
    
    /// Check current subscription status
    func checkSubscriptionStatus() async {
        print("🔍 Checking subscription status...")
        do {
            print("   📡 Fetching customerInfo from RevenueCat...")
            // Add timeout to prevent hanging
            let customerInfo = try await withTimeout(seconds: 10) {
                try await Purchases.shared.customerInfo()
            }
            print("   ✅ CustomerInfo received")
            self.customerInfo = customerInfo
            logCustomerInfo(customerInfo)
            updateSubscriptionState(from: customerInfo)
            print("   ✅ Subscription status updated")
            print("   Result: hasProAccess = \(hasProAccess), status = \(subscriptionStatus)")
        } catch {
            print("❌ Error fetching customer info: \(error)")
            self.lastError = error
            // Continue anyway - assume user doesn't have access
            print("   ⚠️ Assuming user does NOT have Pro access due to error")
            hasProAccess = false
            subscriptionStatus = .unknown
        }
        print("🔍 Subscription status check COMPLETE")
    }
    
    /// Helper to add timeout to async operations
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError()
            }
            group.cancelAll()
            return result
        }
    }
    
    /// Update local state from CustomerInfo
    private func updateSubscriptionState(from customerInfo: CustomerInfo) {
        // Check for "Future Selves Pro" entitlement configured in RevenueCat dashboard
        let entitlement = customerInfo.entitlements.all[Self.entitlementIdentifier]
        let previousAccess = hasProAccess
        
        hasProAccess = entitlement?.isActive == true
        
        // Log entitlement status change
        if previousAccess != hasProAccess {
            print("🔄 Entitlement Status Changed:")
            print("   Previous: \(previousAccess ? "Active" : "Inactive")")
            print("   Current: \(hasProAccess ? "Active" : "Inactive")")
        }
        
        // Determine subscription status
        if hasProAccess {
            if let entitlement = entitlement {
                isInTrial = entitlement.willRenew && entitlement.periodType == .trial
            } else {
                isInTrial = false
            }
            isSubscribed = true
            subscriptionStatus = isInTrial ? .trial : .subscribed
            
            if let productId = entitlement?.productIdentifier {
                print("✅ Pro Access Active - Product: \(productId)")
            }
        } else {
            isSubscribed = false
            isInTrial = false
            
            // Check if subscription expired
            if entitlement?.isActive == false {
                subscriptionStatus = .expired
                print("⏰ Subscription Expired")
            } else {
                subscriptionStatus = .notSubscribed
            }
        }
    }
    
    // MARK: - Purchase Flow
    
    /// Get available packages (monthly, annual, etc.)
    func getAvailablePackages() async throws -> [Package] {
        print("📦 Fetching available packages from Test Store...")
        
        let offerings = try await Purchases.shared.offerings()
        
        print("   Total Offerings: \(offerings.all.count)")
        print("   Offering Keys: \(offerings.all.keys.joined(separator: ", "))")
        
        guard let currentOffering = offerings.current else {
            print("❌ No current offering found!")
            print("   Available offerings: \(offerings.all.keys.joined(separator: ", "))")
            print("   Make sure an offering is set as 'Current Offering' in RevenueCat dashboard")
            throw SubscriptionError.noOfferingAvailable
        }
        
        print("✅ Current Offering: \(currentOffering.identifier)")
        print("   Available Packages: \(currentOffering.availablePackages.count)")
        
        for (index, package) in currentOffering.availablePackages.enumerated() {
            print("   Package \(index + 1):")
            print("     Identifier: \(package.identifier)")
            print("     Product ID: \(package.storeProduct.productIdentifier)")
            print("     Localized Title: \(package.storeProduct.localizedTitle)")
            print("     Localized Price: \(package.storeProduct.localizedPriceString)")
        }
        
        return currentOffering.availablePackages
    }
    
    /// Purchase a package
    func purchase(_ package: Package) async throws -> CustomerInfo {
        print("💳 Starting purchase flow...")
        print("   Package: \(package.identifier)")
        print("   Product ID: \(package.storeProduct.productIdentifier)")
        print("   Price: \(package.storeProduct.localizedPriceString)")
        
        let (transaction, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
        
        // If user cancelled, throw a specific error
        if userCancelled {
            print("🚫 Purchase cancelled by user")
            throw SubscriptionError.purchaseFailed("Purchase was cancelled")
        }
        
        print("✅ Purchase completed!")
        if let transaction = transaction {
            print("   Transaction ID: \(transaction.transactionIdentifier)")
        }
        
        // Update state
        self.customerInfo = customerInfo
        logCustomerInfo(customerInfo)
        updateSubscriptionState(from: customerInfo)
        
        // Verify entitlement was activated
        if hasProAccess {
            print("🎉 Entitlement '\(Self.entitlementIdentifier)' is now ACTIVE")
            if let productId = currentProductIdentifier {
                print("   Granting Product: \(productId)")
            }
        } else {
            print("⚠️ Purchase completed but entitlement is not active")
            print("   This may indicate a configuration issue in RevenueCat dashboard")
        }
        
        return customerInfo
    }
    
    /// Restore purchases
    func restorePurchases() async throws {
        print("🔄 Restoring purchases...")
        let customerInfo = try await Purchases.shared.restorePurchases()
        self.customerInfo = customerInfo
        logCustomerInfo(customerInfo)
        updateSubscriptionState(from: customerInfo)
        
        if hasProAccess {
            print("✅ Purchases restored - Pro Access Active")
        } else {
            print("ℹ️ No active subscriptions found to restore")
        }
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
            print("📢 RevenueCat Delegate: Customer info updated")
            self.customerInfo = customerInfo
            
            // Log entitlement changes
            let entitlement = customerInfo.entitlements.all[Self.entitlementIdentifier]
            if let entitlement = entitlement {
                print("   Entitlement '\(Self.entitlementIdentifier)':")
                print("     Active: \(entitlement.isActive)")
                print("     Product ID: \(entitlement.productIdentifier)")
                if let expirationDate = entitlement.expirationDate {
                    print("     Expiration: \(expirationDate)")
                }
                if entitlement.isActive {
                    print("     ✅ User now has Pro Access")
                } else {
                    print("     ❌ User does not have Pro Access")
                }
            }
            
            self.updateSubscriptionState(from: customerInfo)
            
            // Update Superwall subscription status when RevenueCat status changes
            if SuperwallService.shared.isConfigured {
                SuperwallService.shared.updateSuperwallSubscriptionStatus()
            }
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

private struct TimeoutError: Error {
    let localizedDescription = "Operation timed out"
}

