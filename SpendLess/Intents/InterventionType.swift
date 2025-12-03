//
//  InterventionType.swift
//  SpendLess
//
//  Defines the different intervention experiences users can choose
//

import AppIntents

/// The different intervention experiences users can choose from
@available(iOS 16.0, *)
enum InterventionType: String, AppEnum, CaseIterable {
    case breathing = "breathing"
    case haltCheck = "halt"
    case goalReminder = "goal"
    case quickPause = "quick"
    case fullFlow = "full"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Intervention Type"
    
    static var caseDisplayRepresentations: [InterventionType: DisplayRepresentation] = [
        .breathing: DisplayRepresentation(
            title: "Breathing Exercise",
            subtitle: "A calming 30-second breathing exercise",
            image: .init(systemName: "wind")
        ),
        .haltCheck: DisplayRepresentation(
            title: "HALT Check",
            subtitle: "Are you Hungry, Angry, Lonely, or Tired?",
            image: .init(systemName: "hand.raised.fill")
        ),
        .goalReminder: DisplayRepresentation(
            title: "Goal Reminder",
            subtitle: "See your goal and commitment",
            image: .init(systemName: "star.fill")
        ),
        .quickPause: DisplayRepresentation(
            title: "Quick Pause",
            subtitle: "A simple 5-second pause to reconsider",
            image: .init(systemName: "pause.circle.fill")
        ),
        .fullFlow: DisplayRepresentation(
            title: "Full Intervention",
            subtitle: "Breathing + reflection + item logging",
            image: .init(systemName: "shield.fill")
        )
    ]
    
    // MARK: - Display Properties
    
    var title: String {
        switch self {
        case .breathing: return "Breathing Exercise"
        case .haltCheck: return "HALT Check"
        case .goalReminder: return "Goal Reminder"
        case .quickPause: return "Quick Pause"
        case .fullFlow: return "Full Experience"
        }
    }
    
    var description: String {
        switch self {
        case .breathing:
            return "A calming 30-second breathing exercise to reset your mind"
        case .haltCheck:
            return "Check if you're Hungry, Angry, Lonely, or Tired"
        case .goalReminder:
            return "See your goal and commitment to stay motivated"
        case .quickPause:
            return "A simple 5-second pause — fast but effective"
        case .fullFlow:
            return "Breathing + reflection + item logging (most effective)"
        }
    }
    
    var emoji: String {
        switch self {
        case .breathing: return "🌬️"
        case .haltCheck: return "✋"
        case .goalReminder: return "🎯"
        case .quickPause: return "⏸️"
        case .fullFlow: return "🛡️"
        }
    }
    
    var systemImage: String {
        switch self {
        case .breathing: return "wind"
        case .haltCheck: return "hand.raised.fill"
        case .goalReminder: return "star.fill"
        case .quickPause: return "pause.circle.fill"
        case .fullFlow: return "shield.fill"
        }
    }
    
    var recommendation: String? {
        switch self {
        case .fullFlow: return "Most effective"
        case .quickPause: return "Fastest"
        case .haltCheck: return "Best for emotional shopping"
        default: return nil
        }
    }
}

// MARK: - Non-iOS 16 Fallback

/// Fallback enum for iOS 15 and earlier
enum InterventionTypeCompat: String, CaseIterable {
    case breathing = "breathing"
    case haltCheck = "halt"
    case goalReminder = "goal"
    case quickPause = "quick"
    case fullFlow = "full"
    
    var title: String {
        switch self {
        case .breathing: return "Breathing Exercise"
        case .haltCheck: return "HALT Check"
        case .goalReminder: return "Goal Reminder"
        case .quickPause: return "Quick Pause"
        case .fullFlow: return "Full Experience"
        }
    }
    
    var description: String {
        switch self {
        case .breathing:
            return "A calming 30-second breathing exercise to reset your mind"
        case .haltCheck:
            return "Check if you're Hungry, Angry, Lonely, or Tired"
        case .goalReminder:
            return "See your goal and commitment to stay motivated"
        case .quickPause:
            return "A simple 5-second pause — fast but effective"
        case .fullFlow:
            return "Breathing + reflection + item logging (most effective)"
        }
    }
    
    var emoji: String {
        switch self {
        case .breathing: return "🌬️"
        case .haltCheck: return "✋"
        case .goalReminder: return "🎯"
        case .quickPause: return "⏸️"
        case .fullFlow: return "🛡️"
        }
    }
    
    var systemImage: String {
        switch self {
        case .breathing: return "wind"
        case .haltCheck: return "hand.raised.fill"
        case .goalReminder: return "star.fill"
        case .quickPause: return "pause.circle.fill"
        case .fullFlow: return "shield.fill"
        }
    }
    
    var recommendation: String? {
        switch self {
        case .fullFlow: return "Most effective"
        case .quickPause: return "Fastest"
        case .haltCheck: return "Best for emotional shopping"
        default: return nil
        }
    }
}

