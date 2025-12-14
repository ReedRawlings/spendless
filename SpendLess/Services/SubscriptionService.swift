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
    
    /// Offering identifier for SpendLess subscription
    static let offeringIdentifier = "ofrngaaa4b9888c"
    
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
    
    /// Whether Purchases has been configured
    private var isConfigured: Bool = false
    
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
    /// If a Cloudflare Worker URL is configured, fetches the API key from the worker first
    /// Otherwise, uses the provided API key directly
    /// Call this in app initialization
    func configure(apiKey: String) {
        // Check if we should fetch from Cloudflare Worker
        if let workerURL = AppConstants.revenueCatWorkerURL {
            print("🔐 Fetching RevenueCat API key from Cloudflare Worker...")
            Task {
                do {
                    let fetchedKey = try await fetchAPIKeyFromWorker(workerURL: workerURL)
                    await configureWithKey(fetchedKey)
                } catch {
                    print("⚠️ Failed to fetch API key from worker: \(error)")
                    print("⚠️ Falling back to direct API key...")
                    // Fall back to direct key if worker fetch fails
                    await configureWithKey(apiKey)
                }
            }
        } else {
            // Use direct API key
            Task {
                await configureWithKey(apiKey)
            }
        }
    }
    
    /// Internal method to configure RevenueCat with a specific API key
    private func configureWithKey(_ apiKey: String) {
        // Validate API key
        guard !apiKey.isEmpty && apiKey != "YOUR_REVENUECAT_API_KEY_HERE" else {
            print("⚠️ RevenueCat API key not configured. Please add your API key to Constants.swift")
            print("⚠️ Purchases will not be configured. Some features may not work.")
            return
        }
        
        // Prevent double configuration
        guard !isConfigured else {
            print("⚠️ RevenueCat already configured. Skipping.")
            return
        }
        
        // Detect Test Store vs Production
        let isTestStore = apiKey.hasPrefix("test_")
        let environment = isTestStore ? "Test Store" : "Production"
        
        print("🔧 RevenueCat Configuration:")
        print("   Environment: \(environment)")
        print("   API Key: \(apiKey.prefix(10))...\(apiKey.suffix(4))")
        print("   Entitlement Identifier: \(Self.entitlementIdentifier)")
        
        Purchases.logLevel = .debug // Change to .info or .warn for production
        Purchases.configure(withAPIKey: apiKey)
        isConfigured = true
        
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
    
    /// Fetch RevenueCat API key from Cloudflare Worker
    /// - Parameter workerURL: The Cloudflare Worker endpoint URL
    /// - Returns: The API key string
    private func fetchAPIKeyFromWorker(workerURL: String) async throws -> String {
        guard let url = URL(string: workerURL) else {
            throw SubscriptionError.invalidWorkerURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SubscriptionError.serverError
        }
        
        guard httpResponse.statusCode == 200 else {
            print("❌ RevenueCat Worker error: Status \(httpResponse.statusCode)")
            throw SubscriptionError.serverError
        }
        
        // Parse response - expect JSON with "api_key" field
        struct APIKeyResponse: Codable {
            let api_key: String
        }
        
        do {
            let result = try JSONDecoder().decode(APIKeyResponse.self, from: data)
            print("✅ Successfully fetched API key from Cloudflare Worker")
            return result.api_key
        } catch {
            print("❌ Failed to decode API key response: \(error)")
            throw SubscriptionError.serverError
        }
    }
    
    /// Check if Purchases is configured before accessing it
    private func ensureConfigured() throws {
        guard isConfigured else {
            throw SubscriptionError.notConfigured
        }
    }
    
    /// Verify Test Store setup and log configuration status
    func verifyTestStoreSetup() async {
        print("🔍 Verifying Test Store Setup...")
        
        do {
            try ensureConfigured()
            // Attempt to fetch offerings
            let offerings = try await Purchases.shared.offerings()
            
            if let offering = offerings.offering(identifier: Self.offeringIdentifier) {
                print("✅ Offering 'SpendLess' Found: \(offering.identifier)")
                print("   Available Packages: \(offering.availablePackages.count)")
                
                for (index, package) in offering.availablePackages.enumerated() {
                    print("   Package \(index + 1):")
                    print("     Identifier: \(package.identifier)")
                    print("     Product ID: \(package.storeProduct.productIdentifier)")
                    print("     Localized Price: \(package.storeProduct.localizedPriceString)")
                }
            } else {
                print("⚠️ Offering '\(Self.offeringIdentifier)' not found. Make sure:")
                print("   1. The offering ID '\(Self.offeringIdentifier)' exists in RevenueCat dashboard")
                print("   2. Products are added to the offering")
                print("   Available offerings: \(offerings.all.keys.joined(separator: ", "))")
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
            try ensureConfigured()
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
        try ensureConfigured()
        print("📦 Fetching available packages from Test Store...")
        
        let offerings = try await Purchases.shared.offerings()
        
        print("   Total Offerings: \(offerings.all.count)")
        print("   Offering Keys: \(offerings.all.keys.joined(separator: ", "))")
        
        guard let offering = offerings.offering(identifier: Self.offeringIdentifier) else {
            print("❌ Offering '\(Self.offeringIdentifier)' not found!")
            print("   Available offerings: \(offerings.all.keys.joined(separator: ", "))")
            print("   Make sure the offering ID '\(Self.offeringIdentifier)' exists in RevenueCat dashboard")
            throw SubscriptionError.noOfferingAvailable
        }
        
        print("✅ Offering 'SpendLess': \(offering.identifier)")
        print("   Available Packages: \(offering.availablePackages.count)")
        
        for (index, package) in offering.availablePackages.enumerated() {
            print("   Package \(index + 1):")
            print("     Identifier: \(package.identifier)")
            print("     Product ID: \(package.storeProduct.productIdentifier)")
            print("     Localized Title: \(package.storeProduct.localizedTitle)")
            print("     Localized Price: \(package.storeProduct.localizedPriceString)")
        }
        
        return offering.availablePackages
    }
    
    /// Purchase a package
    func purchase(_ package: Package) async throws -> CustomerInfo {
        try ensureConfigured()
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
        try ensureConfigured()
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
        guard isConfigured else { return false }
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
        }
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case noOfferingAvailable
    case purchaseFailed(String)
    case restoreFailed(String)
    case notConfigured
    case invalidWorkerURL
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .noOfferingAvailable:
            return "No subscription packages are currently available."
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        case .notConfigured:
            return "RevenueCat has not been configured. Please configure your API key in Constants.swift"
        case .invalidWorkerURL:
            return "Invalid Cloudflare Worker URL"
        case .serverError:
            return "Server error while fetching API key"
        }
    }
}

private struct TimeoutError: Error {
    let localizedDescription = "Operation timed out"
}

