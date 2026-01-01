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
    
    // MARK: - StoreKit Product Identifiers
    
    /// Product identifiers for App Store subscriptions
    enum ProductIdentifiers {
        /// Monthly subscription with 4-day trial ($6.99/month)
        static let monthly = "monthly_699_4daytrial"
        /// Annual subscription with 4-day trial ($19.99/year)
        static let annual = "monthly_1999_4daytrial"
        
        /// All product identifiers for fetching from App Store
        static let all: Set<String> = [monthly, annual]
    }

    // MARK: - Screenshot Mode Configuration
    
    /// Set to true to enable screenshot demo mode with fake/seeded data for App Store screenshots
    /// IMPORTANT: Set to false before shipping to production
    /// This flag injects optimized ASO keywords and demo data into views
    static let isScreenshotMode = false
    
    // MARK: - MailerLite Configuration

    /// Cloudflare Worker endpoint for MailerLite subscription
    /// The Worker proxies requests to MailerLite API, keeping the API key secure server-side
    static var mailerLiteWorkerURL: String {
        // Can be overridden via Info.plist with MAILERLITE_WORKER_URL key
        Bundle.main.object(forInfoDictionaryKey: "MAILERLITE_WORKER_URL") as? String ?? "https://mailerlitetoken.rawlingreed.workers.dev"
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

    // MARK: - NoBuy Challenge Notifications

    /// Notification category identifier for NoBuy daily check-in
    static let noBuyCheckinNotificationCategory = "NOBUY_CHECKIN"

    /// Notification identifier prefix for NoBuy challenge
    static let noBuyNotificationPrefix = "nobuyChallenge"

    /// Notification action identifiers for NoBuy challenge
    enum NoBuyChallengeNotificationActions {
        static let checkIn = "CHECK_IN_NOW"
        static let remindLater = "REMIND_LATER"
    }

    /// UserDefaults keys for NoBuy notification preferences
    enum NoBuyChallengePreferenceKeys {
        static let dailyReminderEnabled = "noBuyDailyReminderEnabled"
        static let reminderHour = "noBuyReminderHour"
    }
}
