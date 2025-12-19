//
//  SubscriptionService.swift
//  SpendLess
//
//  Native StoreKit 2 subscription management service
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
@Observable
class SubscriptionService {
    
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
    
    /// Error state
    var lastError: Error?
    
    /// Current subscription expiration date
    var expirationDate: Date?
    
    /// Current subscription product identifier
    var currentProductIdentifier: String?
    
    /// Available products fetched from App Store
    private(set) var availableProducts: [Product] = []
    
    /// Transaction listener task
    private var transactionListenerTask: Task<Void, Never>?
    
    // MARK: - Subscription Status
    
    enum SubscriptionStatus {
        case unknown
        case subscribed
        case trial
        case expired
        case notSubscribed
    }
    
    // MARK: - Initialization
    
    private init() {
        // Configuration will be done via configure() method
    }
    
    // MARK: - Configuration
    
    /// Configure StoreKit and start listening for transactions
    /// Call this in app initialization
    func configure() async {
        // Start listening for transaction updates
        startTransactionListener()

        // Fetch available products
        await fetchProducts()
    }

    /// Start listening for transaction updates
    private func startTransactionListener() {
        transactionListenerTask = Task(priority: .background) { [weak self] in
            for await update in StoreKit.Transaction.updates {
                await self?.handleTransactionUpdate(update)
            }
        }
    }
    
    /// Stop transaction listener
    func stopListening() {
        transactionListenerTask?.cancel()
        transactionListenerTask = nil
    }
    
    /// Handle transaction updates
    private func handleTransactionUpdate(_ result: VerificationResult<StoreKit.Transaction>) async {
        do {
            let transaction = try checkVerified(result)

            // Check if this is one of our subscription products
            if AppConstants.ProductIdentifiers.all.contains(transaction.productID) {
                // Update subscription status
                await checkSubscriptionStatus()

                // Finish the transaction
                await transaction.finish()
            }
        } catch {
            // Transaction verification failed
        }
    }
    
    /// Fetch available products from App Store
    private func fetchProducts() async {
        do {
            let products = try await Product.products(for: AppConstants.ProductIdentifiers.all)
            availableProducts = products.sorted { p1, p2 in
                // Sort by price (monthly first, then annual)
                p1.price < p2.price
            }
        } catch {
            lastError = error
        }
    }
    
    // MARK: - Transaction Verification
    
    /// Verify a transaction result
    /// - Parameter result: The verification result from StoreKit
    /// - Returns: The verified transaction
    /// - Throws: SubscriptionError.failedVerification if verification fails
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let transaction):
            return transaction
        }
    }
    
    // MARK: - Subscription Status Checks
    
    /// Check current subscription status
    func checkSubscriptionStatus() async {
        var foundActiveSubscription = false
        var latestTransaction: StoreKit.Transaction?
        var foundExpirationDate: Date?
        var foundIsInTrial = false
        var foundProductID: String?

        // Check current entitlements
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if this is one of our subscription products
                if AppConstants.ProductIdentifiers.all.contains(transaction.productID) {
                    // Check if subscription is still active (not expired)
                    if let expiration = transaction.expirationDate {
                        if expiration > Date() {
                            foundActiveSubscription = true
                            foundExpirationDate = expiration
                            foundProductID = transaction.productID

                            // Check if in trial period using the offer property (iOS 17.2+)
                            if let offer = transaction.offer {
                                if offer.type == .introductory {
                                    foundIsInTrial = true
                                }
                            }

                            // Keep track of the latest transaction
                            if latestTransaction == nil ||
                               (transaction.purchaseDate > latestTransaction!.purchaseDate) {
                                latestTransaction = transaction
                            }
                        }
                    }
                }
            } catch {
                lastError = error
            }
        }

        // Update state
        hasProAccess = foundActiveSubscription
        isSubscribed = foundActiveSubscription
        isInTrial = foundIsInTrial
        expirationDate = foundExpirationDate
        currentProductIdentifier = foundProductID

        // Determine subscription status
        if foundActiveSubscription {
            subscriptionStatus = foundIsInTrial ? .trial : .subscribed
        } else {
            subscriptionStatus = .notSubscribed
        }
    }
    
    // MARK: - Purchase Flow
    
    /// Get available products (monthly, annual, etc.)
    func getAvailableProducts() async throws -> [Product] {
        // Re-fetch if empty
        if availableProducts.isEmpty {
            await fetchProducts()
        }

        guard !availableProducts.isEmpty else {
            throw SubscriptionError.noProductsAvailable
        }

        return availableProducts
    }
    
    /// Purchase a product
    /// - Parameter product: The StoreKit Product to purchase
    /// - Returns: The verified transaction
    @discardableResult
    func purchase(_ product: Product) async throws -> StoreKit.Transaction {
        // Attempt purchase
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // Update subscription status
            await checkSubscriptionStatus()

            // Finish the transaction
            await transaction.finish()

            return transaction

        case .userCancelled:
            throw SubscriptionError.purchaseCancelled

        case .pending:
            throw SubscriptionError.purchasePending

        @unknown default:
            throw SubscriptionError.purchaseFailed("Unknown purchase result")
        }
    }
    
    /// Restore purchases
    func restorePurchases() async throws {
        // Sync with App Store
        try await AppStore.sync()

        // Check all transactions
        var foundActiveSubscription = false

        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if this is one of our subscription products
                if AppConstants.ProductIdentifiers.all.contains(transaction.productID) {
                    // Check if still active
                    if let expiration = transaction.expirationDate, expiration > Date() {
                        foundActiveSubscription = true
                    }
                }

                // Finish the transaction
                await transaction.finish()
            } catch {
                // Transaction verification failed
            }
        }

        // Update status
        await checkSubscriptionStatus()

        if !foundActiveSubscription {
            throw SubscriptionError.noActiveSubscriptionToRestore
        }
    }
    
    // MARK: - Helpers
    
    /// Check if user can make purchases
    var canMakePurchases: Bool {
        return AppStore.canMakePayments
    }
    
    /// Get product by identifier
    func product(for identifier: String) -> Product? {
        return availableProducts.first { $0.id == identifier }
    }
    
    /// Get monthly product
    var monthlyProduct: Product? {
        return product(for: AppConstants.ProductIdentifiers.monthly)
    }
    
    /// Get annual product
    var annualProduct: Product? {
        return product(for: AppConstants.ProductIdentifiers.annual)
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case noProductsAvailable
    case purchaseFailed(String)
    case purchaseCancelled
    case purchasePending
    case restoreFailed(String)
    case failedVerification
    case noActiveSubscriptionToRestore
    
    var errorDescription: String? {
        switch self {
        case .noProductsAvailable:
            return "No subscription products are currently available. Please try again later."
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .purchaseCancelled:
            return "Purchase was cancelled."
        case .purchasePending:
            return "Purchase is pending approval."
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        case .failedVerification:
            return "Transaction verification failed. Please contact support."
        case .noActiveSubscriptionToRestore:
            return "No active subscription found to restore."
        }
    }
}
