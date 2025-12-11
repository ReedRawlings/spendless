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

    /// RevenueCat API Key - reads from Info.plist (populated by xcconfig)
    /// Setup: Copy Config/Template.xcconfig to Config/Debug.xcconfig and Config/Release.xcconfig
    /// Add your keys there. The xcconfig files are gitignored.
    static var revenueCatAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String ?? "YOUR_REVENUECAT_API_KEY_HERE"
    }

    // MARK: - Superwall Configuration

    /// Superwall API Key - reads from Info.plist (populated by xcconfig)
    static var superwallAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "SUPERWALL_API_KEY") as? String ?? "YOUR_SUPERWALL_API_KEY_HERE"
    }
    
    // MARK: - Paywall Configuration

    /// Set to true to use RevenueCat's built-in PaywallView instead of Superwall
    static let useRevenueCatPaywall = true
    
    // MARK: - Screenshot Mode Configuration
    
    /// Set to true to enable screenshot demo mode with fake/seeded data for App Store screenshots
    /// IMPORTANT: Set to false before shipping to production
    /// This flag injects optimized ASO keywords and demo data into views
    static let isScreenshotMode = false
    
    // MARK: - ConvertKit Configuration

    /// ConvertKit API Key - reads from Info.plist (populated by xcconfig)
    static var convertKitAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "CONVERTKIT_API_KEY") as? String ?? "YOUR_CONVERTKIT_API_KEY_HERE"
    }

    /// ConvertKit Form ID - reads from Info.plist (populated by xcconfig)
    static var convertKitFormID: String {
        Bundle.main.object(forInfoDictionaryKey: "CONVERTKIT_FORM_ID") as? String ?? "YOUR_CONVERTKIT_FORM_ID_HERE"
    }
    
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
