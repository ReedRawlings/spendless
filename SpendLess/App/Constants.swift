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
    
    // MARK: - Debug Configuration
    
    /// Set to true to use RevenueCat's built-in PaywallView instead of Superwall
    /// Useful for testing purchase flow before Superwall dashboard is configured
    /// Set to false for production or when Superwall is fully configured
    static let useRevenueCatPaywallForTesting = false
    
    // MARK: - Screenshot Mode Configuration
    
    /// Set to true to enable screenshot demo mode with fake/seeded data for App Store screenshots
    /// IMPORTANT: Set to false before shipping to production
    /// This flag injects optimized ASO keywords and demo data into views
    static let isScreenshotMode = false
    
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
    
    // MARK: - Shield & Temporary Access
    
    /// DeviceActivity name for temporary access sessions
    static let temporaryAccessActivityName = "temporaryAccess"
    
    /// Notification category identifier for shield restoration
    static let shieldRestoreNotificationCategory = "SHIELD_RESTORE"
    
    /// Notification identifier for shield restoration
    static let shieldRestoreNotificationID = "shieldRestore"
    
    /// App Group keys for session management
    enum SessionKeys {
        static let pendingLiveActivityStart = "pendingLiveActivityStart"
        static let pendingLiveActivityEnd = "pendingLiveActivityEnd"
        static let sessionStartRequest = "sessionStartRequest"
    }
    
    /// Temporary access duration in minutes
    static let temporaryAccessDurationMinutes: Int = 10
    
    // MARK: - Waiting List Notifications
    
    /// Notification category identifier for waiting list check-ins (Day 3)
    static let waitingListCheckinNotificationCategory = "WAITING_LIST_CHECKIN"
    
    /// Notification identifier prefix for waiting list notifications
    static let waitingListNotificationPrefix = "waitingList"
    
    /// Notification action identifiers for waiting list
    enum WaitingListNotificationActions {
        static let keepOnList = "KEEP_ON_LIST"
        static let buryIt = "BURY_IT"
    }
    
    /// UserDefaults keys for notification preferences
    enum NotificationPreferenceKeys {
        static let waitingListRemindersEnabled = "waitingListRemindersEnabled"
    }
    
    /// UserDefaults keys for pending waiting list actions (from background notifications)
    enum PendingWaitingListActionKeys {
        /// Prefix for pending action keys: pendingWaitingListAction-{itemID}
        static let prefix = "pendingWaitingListAction"
    }
}
