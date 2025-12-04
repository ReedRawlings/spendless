//
//  CurrencyHelpers.swift
//  SpendLess
//
//  Shared currency formatting utilities
//

import Foundation

/// Shared currency formatter that is reused across the app
/// Creates the formatter once and caches it for performance
enum CurrencyFormatter {
    /// Cached formatter for currency without cents (e.g., "$100")
    private static let noCentsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// Cached formatter for currency with cents (e.g., "$100.50")
    private static let withCentsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    /// Formats a Decimal amount as currency without cents
    /// - Parameter amount: The amount to format
    /// - Returns: Formatted string (e.g., "$100")
    static func format(_ amount: Decimal) -> String {
        noCentsFormatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }

    /// Formats a Decimal amount as currency with cents
    /// - Parameter amount: The amount to format
    /// - Returns: Formatted string (e.g., "$100.50")
    static func formatWithCents(_ amount: Decimal) -> String {
        withCentsFormatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Global Convenience Functions

/// Formats a Decimal amount as currency without cents
/// - Parameter amount: The amount to format
/// - Returns: Formatted string (e.g., "$100")
func formatCurrency(_ amount: Decimal) -> String {
    CurrencyFormatter.format(amount)
}

/// Formats a Decimal amount as currency with cents
/// - Parameter amount: The amount to format
/// - Returns: Formatted string (e.g., "$100.50")
func formatCurrencyWithCents(_ amount: Decimal) -> String {
    CurrencyFormatter.formatWithCents(amount)
}
