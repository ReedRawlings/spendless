//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  SETUP INSTRUCTIONS:
//  1. In Xcode, go to File > New > Target
//  2. Select "Shield Configuration Extension"
//  3. Name it "ShieldConfigurationExtension"
//  4. Add the FamilyControls entitlement to this target
//  5. Add App Groups capability with identifier: group.com.spendless.data
//  6. Copy this code into the generated extension file
//
//  NOTE: This is a template file. The actual extension must be created
//  through Xcode and requires the com.apple.developer.family-controls entitlement.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

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
        let futureLetterText = sharedDefaults?.string(forKey: "futureLetterText")
        
        // Create subtitle - prefer future letter text if available, otherwise show streak/savings
        let subtitleText: String
        if let letterText = futureLetterText, !letterText.isEmpty {
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
/// Colors adapt to light and dark mode
private nonisolated struct SpendLessColors {
    // Primary - Warm terracotta
    nonisolated static let primary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.95, green: 0.65, blue: 0.58, alpha: 1.0)
        default:
            return UIColor(red: 0.89, green: 0.45, blue: 0.36, alpha: 1.0)
        }
    }
    
    // Background
    nonisolated static let background = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.12, green: 0.10, blue: 0.09, alpha: 1.0)
        default:
            return UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1.0)
        }
    }
    
    // Text
    nonisolated static let textPrimary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1.0)
        default:
            return UIColor(red: 0.20, green: 0.18, blue: 0.16, alpha: 1.0)
        }
    }
    
    nonisolated static let textSecondary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.75, green: 0.72, blue: 0.68, alpha: 1.0)
        default:
            return UIColor(red: 0.45, green: 0.42, blue: 0.38, alpha: 1.0)
        }
    }
    
    // Secondary - Sage
    nonisolated static let secondary = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.65, green: 0.78, blue: 0.65, alpha: 1.0)
        default:
            return UIColor(red: 0.55, green: 0.68, blue: 0.55, alpha: 1.0)
        }
    }
}

