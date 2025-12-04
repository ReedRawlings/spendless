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
}
