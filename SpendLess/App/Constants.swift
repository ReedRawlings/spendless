//
//  Constants.swift
//  SpendLess
//
//  Shared constants used across the app
//

import Foundation

/// App-wide constants
enum AppConstants {
    /// App Group identifier used for sharing data between the main app, widgets, and extensions
    /// This MUST match the App Group ID configured in:
    /// - SpendLess.entitlements
    /// - PanicButtonWidgetExtension.entitlements
    /// - All extension entitlements
    static let appGroupID = "group.com.spendless.data"

    /// UserDefaults keys used across the app
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let interventionStyle = "interventionStyle"
        static let targetAmount = "targetAmount"
        static let goalName = "goalName"
        static let streakDays = "streakDays"
        static let totalSaved = "totalSaved"
    }
    
    // MARK: - RevenueCat Configuration
    
    /// RevenueCat API Key
    /// TODO: Replace with your actual API key from RevenueCat dashboard
    /// Get it from: https://app.revenuecat.com → Your Project → API Keys
    /// Use the PUBLIC API KEY (not the secret key)
    static let revenueCatAPIKey = "test_dHhQzsfzdWSbSvAhLnDMNgnBkDk"
    
    // MARK: - Superwall Configuration
    
    /// Superwall API Key
    /// TODO: Replace with your actual API key from Superwall dashboard
    /// Get it from: https://app.superwall.com → Settings → API Keys
    static let superwallAPIKey = "pk_JLjJY-Q1WZ9bvb68Gs8If"
    
    // MARK: - ConvertKit Configuration
    
    /// ConvertKit API Key
    /// TODO: Replace with your actual API key from ConvertKit dashboard
    /// Get it from: https://app.convertkit.com → Settings → Advanced → API Secret
    /// Note: Use the API Secret (not the API Key) for form subscriptions
    static let convertKitAPIKey = "YOUR_CONVERTKIT_API_KEY"
    
    /// ConvertKit Form ID
    /// TODO: Replace with your actual Form ID
    /// Get it from: https://app.convertkit.com → Forms → Select your form → Settings → Form ID
    static let convertKitFormID = "YOUR_FORM_ID"
}
