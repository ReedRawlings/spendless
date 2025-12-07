//
//  InterventionIntents.swift
//  SpendLess
//
//  App Intents for iOS Shortcuts integration
//

import AppIntents
import SwiftUI

// MARK: - Breathing Exercise Intent

/// Breathing exercise intervention
@available(iOS 16.0, *)
struct BreathingInterventionIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Breathing Exercise"
    
    static var description = IntentDescription(
        "Opens SpendLess with a calming breathing exercise to help you pause before impulse shopping.",
        categoryName: "Wellness"
    )
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.set(true, forKey: "interventionTriggered")
        sharedDefaults?.set(InterventionType.breathing.rawValue, forKey: "interventionType")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "interventionTimestamp")
        return .result()
    }
}

// MARK: - HALT Check Intent

/// HALT check intervention
@available(iOS 16.0, *)
struct HALTCheckIntent: AppIntent {
    
    static var title: LocalizedStringResource = "HALT Check"
    
    static var description = IntentDescription(
        "Opens SpendLess to check if you're Hungry, Angry, Lonely, or Tired — common triggers for impulse shopping.",
        categoryName: "Wellness"
    )
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.set(true, forKey: "interventionTriggered")
        sharedDefaults?.set(InterventionType.haltCheck.rawValue, forKey: "interventionType")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "interventionTimestamp")
        return .result()
    }
}

// MARK: - Goal Reminder Intent

/// Goal reminder intervention
@available(iOS 16.0, *)
struct GoalReminderIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Show My Goal"
    
    static var description = IntentDescription(
        "Opens SpendLess to remind you of your savings goal and commitment.",
        categoryName: "Wellness"
    )
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.set(true, forKey: "interventionTriggered")
        sharedDefaults?.set(InterventionType.goalReminder.rawValue, forKey: "interventionType")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "interventionTimestamp")
        return .result()
    }
}

// MARK: - Quick Pause Intent

/// Quick 5-second pause
@available(iOS 16.0, *)
struct QuickPauseIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Quick Pause"
    
    static var description = IntentDescription(
        "A simple 5-second pause to reconsider before opening a shopping app.",
        categoryName: "Wellness"
    )
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.set(true, forKey: "interventionTriggered")
        sharedDefaults?.set(InterventionType.quickPause.rawValue, forKey: "interventionType")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "interventionTimestamp")
        return .result()
    }
}

// MARK: - Full Intervention Intent

/// Full intervention flow (breathing + reflection + logging)
@available(iOS 16.0, *)
struct FullInterventionIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Full Intervention"
    
    static var description = IntentDescription(
        "The complete SpendLess experience: breathing exercise, reflection, and optional item logging.",
        categoryName: "Wellness"
    )
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.set(true, forKey: "interventionTriggered")
        sharedDefaults?.set(InterventionType.fullFlow.rawValue, forKey: "interventionType")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "interventionTimestamp")
        return .result()
    }
}

// MARK: - Configurable Intent

/// A single intent where users can choose the intervention type as a parameter
@available(iOS 16.0, *)
struct ConfigurableInterventionIntent: AppIntent {
    
    static var title: LocalizedStringResource = "SpendLess Intervention"
    
    static var description = IntentDescription(
        "Opens SpendLess with your chosen intervention style.",
        categoryName: "Wellness"
    )
    
    @Parameter(title: "Intervention Style", description: "Choose how you want to pause")
    var style: InterventionType
    
    static var parameterSummary: some ParameterSummary {
        Summary("Start \(\.$style) intervention")
    }
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.set(true, forKey: "interventionTriggered")
        sharedDefaults?.set(style.rawValue, forKey: "interventionType")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "interventionTimestamp")
        return .result()
    }
}


