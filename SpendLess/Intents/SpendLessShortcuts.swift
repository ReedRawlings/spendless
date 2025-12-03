//
//  SpendLessShortcuts.swift
//  SpendLess
//
//  Registers all app shortcuts with the system
//

import AppIntents

@available(iOS 16.0, *)
struct SpendLessShortcuts: AppShortcutsProvider {
    
    /// All shortcuts that appear in the Shortcuts app
    static var appShortcuts: [AppShortcut] {
        
        // Breathing Exercise
        AppShortcut(
            intent: BreathingInterventionIntent(),
            phrases: [
                "Start breathing with \(.applicationName)",
                "Breathe with \(.applicationName)",
                "\(.applicationName) breathing exercise"
            ],
            shortTitle: "Breathing Exercise",
            systemImageName: "wind"
        )
        
        // HALT Check
        AppShortcut(
            intent: HALTCheckIntent(),
            phrases: [
                "HALT check with \(.applicationName)",
                "\(.applicationName) HALT check",
                "Am I hungry angry lonely tired with \(.applicationName)"
            ],
            shortTitle: "HALT Check",
            systemImageName: "hand.raised.fill"
        )
        
        // Goal Reminder
        AppShortcut(
            intent: GoalReminderIntent(),
            phrases: [
                "Show my goal in \(.applicationName)",
                "Remind me of my goal with \(.applicationName)",
                "\(.applicationName) goal reminder"
            ],
            shortTitle: "Show My Goal",
            systemImageName: "star.fill"
        )
        
        // Quick Pause
        AppShortcut(
            intent: QuickPauseIntent(),
            phrases: [
                "Quick pause with \(.applicationName)",
                "\(.applicationName) quick pause",
                "Pause before shopping with \(.applicationName)"
            ],
            shortTitle: "Quick Pause",
            systemImageName: "pause.circle.fill"
        )
        
        // Full Intervention
        AppShortcut(
            intent: FullInterventionIntent(),
            phrases: [
                "Full \(.applicationName) intervention",
                "Stop me from shopping with \(.applicationName)",
                "Help me not buy this with \(.applicationName)"
            ],
            shortTitle: "Full Intervention",
            systemImageName: "shield.fill"
        )
        
        // Configurable (shows in Shortcuts with parameter picker)
        AppShortcut(
            intent: ConfigurableInterventionIntent(),
            phrases: [
                "Start \(.applicationName) intervention"
            ],
            shortTitle: "Custom Intervention",
            systemImageName: "slider.horizontal.3"
        )
        
        // User's preferred intervention (uses their settings)
        AppShortcut(
            intent: PreferredInterventionIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Start \(.applicationName)",
                "Help me with \(.applicationName)"
            ],
            shortTitle: "My Intervention",
            systemImageName: "heart.fill"
        )
    }
}

