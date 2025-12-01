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
        // Load user's streak and savings from shared defaults
        let currentStreak = sharedDefaults?.integer(forKey: "currentStreak") ?? 0
        let totalSaved = sharedDefaults?.double(forKey: "totalSaved") ?? 0
        let difficultyMode = sharedDefaults?.string(forKey: "difficultyMode") ?? "firm"
        let futureLetterText = sharedDefaults?.string(forKey: "futureLetterText")
        
        // Create subtitle - use letter text in Gentle mode, otherwise use streak/savings
        let subtitleText: String
        if difficultyMode == "gentle", let letterText = futureLetterText, !letterText.isEmpty {
            // Use future letter text in Gentle mode
            subtitleText = letterText
        } else if currentStreak > 0 && totalSaved > 0 {
            subtitleText = "You've been shopping-free for \(currentStreak) days.\nYou've saved $\(Int(totalSaved)) so far."
        } else if currentStreak > 0 {
            subtitleText = "You've been shopping-free for \(currentStreak) days."
        } else {
            subtitleText = "What were you looking for?"
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
                text: "Something Specific",
                color: .white
            ),
            primaryButtonBackgroundColor: SpendLessColors.primary,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Just Browsing",
                color: SpendLessColors.primary
            )
        )
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
private struct SpendLessColors {
    // Primary - Warm terracotta
    static let primary = UIColor(red: 0.89, green: 0.45, blue: 0.36, alpha: 1.0)
    
    // Background
    static let background = UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1.0)
    
    // Text
    static let textPrimary = UIColor(red: 0.20, green: 0.18, blue: 0.16, alpha: 1.0)
    static let textSecondary = UIColor(red: 0.45, green: 0.42, blue: 0.38, alpha: 1.0)
    
    // Secondary - Sage
    static let secondary = UIColor(red: 0.55, green: 0.68, blue: 0.55, alpha: 1.0)
}
