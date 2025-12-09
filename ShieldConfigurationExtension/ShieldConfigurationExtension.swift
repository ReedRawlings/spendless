//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Extension that provides custom UI for the shield/blocking screen
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import Foundation

/// Extension that provides custom UI for the shield/blocking screen
nonisolated class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    // App group for shared data
    let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
    
    // MARK: - Shield Configuration
    
    /// Configure the shield for a blocked application
    nonisolated override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Extract app name for analytics
        let appName = application.localizedDisplayName ?? "Unknown App"
        
        // Load user's streak and savings from shared defaults
        let currentStreak = sharedDefaults?.integer(forKey: "currentStreak") ?? 0
        // Read as String for precision (with fallback for legacy Double values)
        let totalSavedString = sharedDefaults?.string(forKey: "totalSaved") ?? "0"
        let totalSaved = Decimal(string: totalSavedString) ?? Decimal(sharedDefaults?.double(forKey: "totalSaved") ?? 0)
        let futureLetterText = sharedDefaults?.string(forKey: "futureLetterText")
        
        // Log shield appearance for analytics
        logShieldAppearance(appName: appName, currentStreak: currentStreak)
        
        // Create subtitle - prefer future letter text if available, otherwise show streak/savings
        let subtitleText: String
        if let letterText = futureLetterText, !letterText.isEmpty {
            subtitleText = letterText
        } else if currentStreak > 0 && totalSaved > 0 {
            subtitleText = "You've been shopping-free for \(currentStreak) days.\nYou've saved $\(NSDecimalNumber(decimal: totalSaved).intValue) so far.\n\nNeed access? You can unlock for 10 minutes."
        } else if currentStreak > 0 {
            subtitleText = "You've been shopping-free for \(currentStreak) days.\n\nNeed access? You can unlock for 10 minutes."
        } else {
            subtitleText = "What were you looking for?\n\nNeed access? You can unlock for 10 minutes."
        }
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: SpendLessColors.background,
            icon: nil, // Will use default icon
            title: ShieldConfiguration.Label(
                text: "HOLD ON",
                color: SpendLessColors.primary
            ),
            subtitle: ShieldConfiguration.Label(
                text: subtitleText,
                color: SpendLessColors.textSecondary
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Access for 10 min",
                color: .white
            ),
            primaryButtonBackgroundColor: SpendLessColors.primary,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Stay Protected",
                color: SpendLessColors.primary
            )
        )
    }
    
    // MARK: - Analytics Logging
    
    /// Log shield appearance (minimal implementation for extension)
    private func logShieldAppearance(appName: String, currentStreak: Int) {
        // Check if analytics is enabled
        let analyticsEnabled = sharedDefaults?.bool(forKey: "analyticsEnabled") ?? true
        guard analyticsEnabled else { return }
        
        // Calculate days since last bypass
        let daysSinceLastBypass: Int?
        if let lastBypassTimestamp = sharedDefaults?.object(forKey: "lastBypassTimestamp") as? Date {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: lastBypassTimestamp, to: Date()).day
            daysSinceLastBypass = days
        } else {
            daysSinceLastBypass = nil
        }
        
        // Create partial event (will be completed in ShieldActionExtension)
        let eventData: [String: Any] = [
            "id": UUID().uuidString,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "appName": appName,
            "currentStreak": currentStreak,
            "daysSinceLastBypass": daysSinceLastBypass as Any
        ]
        
        // Store as JSON string for main app to process
        if let jsonData = try? JSONSerialization.data(withJSONObject: eventData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            sharedDefaults?.set(jsonString, forKey: "partialShieldEvent")
            sharedDefaults?.synchronize()
        }
    }
    
    /// Configure the shield for a blocked application category
    nonisolated override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Use same configuration as individual apps
        return configuration(shielding: application)
    }
    
    /// Configure the shield for a blocked web domain
    nonisolated override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: SpendLessColors.background,
            title: ShieldConfiguration.Label(
                text: "HOLD ON",
                color: SpendLessColors.primary
            ),
            subtitle: ShieldConfiguration.Label(
                text: "This shopping site is blocked.",
                color: SpendLessColors.textSecondary
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "I Need This",
                color: .white
            ),
            primaryButtonBackgroundColor: SpendLessColors.primary,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Leave",
                color: SpendLessColors.primary
            )
        )
    }
    
    /// Configure the shield for a blocked web domain category
    nonisolated override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return configuration(shielding: webDomain)
    }
}

// MARK: - SpendLess Colors for Extensions

/// Color palette for use in extensions (UIColor since extensions can't use SwiftUI Color)
/// Colors adapt to light and dark mode
private struct SpendLessColors {
    // Primary - Warm terracotta
    static let primary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.95, green: 0.65, blue: 0.58, alpha: 1.0)
        default:
            return UIColor(red: 0.89, green: 0.45, blue: 0.36, alpha: 1.0)
        }
    }
    
    // Background
    static let background = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.12, green: 0.10, blue: 0.09, alpha: 1.0)
        default:
            return UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1.0)
        }
    }
    
    // Text
    static let textPrimary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1.0)
        default:
            return UIColor(red: 0.20, green: 0.18, blue: 0.16, alpha: 1.0)
        }
    }
    
    static let textSecondary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.75, green: 0.72, blue: 0.68, alpha: 1.0)
        default:
            return UIColor(red: 0.45, green: 0.42, blue: 0.38, alpha: 1.0)
        }
    }
    
    // Secondary - Sage
    static let secondary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.65, green: 0.78, blue: 0.65, alpha: 1.0)
        default:
            return UIColor(red: 0.55, green: 0.68, blue: 0.55, alpha: 1.0)
        }
    }
}
