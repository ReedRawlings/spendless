//
//  CommitmentHelpers.swift
//  SpendLess
//
//  Helper functions for commitment flow copy generation
//

import Foundation

// MARK: - Commitment Text Generation

func generateCommitmentText(goalType: GoalType, goalName: String?) -> String {
    if let name = goalName, !name.isEmpty {
        return "I choose \(name) over clutter.\n\nEvery dollar I don't waste brings me closer."
    } else if goalType != .justStop {
        let goalTypeName: String
        switch goalType {
        case .vacation: goalTypeName = "my dream vacation"
        case .emergency: goalTypeName = "my emergency fund"
        case .debtFree: goalTypeName = "freedom from debt"
        case .downPayment: goalTypeName = "my down payment"
        case .car: goalTypeName = "my car"
        case .bigPurchase: goalTypeName = "what I actually need"
        case .retirement: goalTypeName = "my retirement"
        case .justStop: goalTypeName = "freedom"
        }
        return "I choose \(goalTypeName) over clutter.\n\nEvery dollar I don't waste brings me closer."
    } else {
        return "I choose freedom over stuff.\n\nI will pause before I purchase."
    }
}

// MARK: - Vision Text Generation

func generateVisionText(goalType: GoalType, goalName: String?) -> String {
    switch goalType {
    case .vacation:
        if let name = goalName, !name.isEmpty {
            return "You're finally on \(name)."
        } else {
            return "You're on that trip you've always dreamed about."
        }
    case .debtFree:
        return "You're finally debt-free. That weight is gone."
    case .emergency:
        return "You sleep peacefully, knowing you're protected."
    case .downPayment:
        return "You're unlocking the door to your own home."
    case .car:
        return "You're driving off in your new car."
    case .bigPurchase:
        if let name = goalName, !name.isEmpty {
            return "You finally have \(name)."
        } else {
            return "You finally have what you actually wanted."
        }
    case .retirement:
        return "Your future self is thriving because of today."
    case .justStop:
        return "You're in control. Not the ads. Not the algorithms. You."
    }
}

// MARK: - Future Self Letter Options

struct FutureSelfLetterOption: Identifiable {
    let id: String
    let text: String
    let category: LetterCategory
    
    enum LetterCategory {
        case motivation
        case reminder
        case goalFocused
        case emotional
    }
}

/// Pre-written letter options for users to choose from
func getFutureSelfLetterOptions(goalName: String? = nil) -> [FutureSelfLetterOption] {
    let goalText = goalName ?? "your goal"
    
    return [
        // Motivation-focused
        FutureSelfLetterOption(
            id: "motivation_1",
            text: "Remember why you started. Every 'no' gets you closer to \(goalText).",
            category: .motivation
        ),
        FutureSelfLetterOption(
            id: "motivation_2",
            text: "You're stronger than this urge. The feeling will pass.",
            category: .motivation
        ),
        FutureSelfLetterOption(
            id: "motivation_3",
            text: "Future you will thank present you for this moment of strength.",
            category: .motivation
        ),
        
        // Reminder-focused
        FutureSelfLetterOption(
            id: "reminder_1",
            text: "This feeling is temporary. Your goal is not.",
            category: .reminder
        ),
        FutureSelfLetterOption(
            id: "reminder_2",
            text: "Sales come back. This feeling won't last.",
            category: .reminder
        ),
        FutureSelfLetterOption(
            id: "reminder_3",
            text: "Nothing good comes from impulse shopping. Sleep on it.",
            category: .reminder
        ),
        
        // Goal-focused
        FutureSelfLetterOption(
            id: "goal_1",
            text: "Every dollar you don't spend gets you closer to \(goalText).",
            category: .goalFocused
        ),
        FutureSelfLetterOption(
            id: "goal_2",
            text: "This money could go toward \(goalText) instead.",
            category: .goalFocused
        ),
        FutureSelfLetterOption(
            id: "goal_3",
            text: "Is this purchase worth delaying \(goalText)?",
            category: .goalFocused
        ),
        
        // Emotional
        FutureSelfLetterOption(
            id: "emotional_1",
            text: "Shopping won't fix what's bothering you. Take a breath instead.",
            category: .emotional
        ),
        FutureSelfLetterOption(
            id: "emotional_2",
            text: "Buying things won't make you happy. Call a friend instead.",
            category: .emotional
        ),
        FutureSelfLetterOption(
            id: "emotional_3",
            text: "You're not bored, you're just looking for a dopamine hit. Go for a walk.",
            category: .emotional
        ),
    ]
}

// MARK: - Placeholder Text Generation (Legacy - for fallback)

func generatePlaceholderText(triggers: Set<ShoppingTrigger>, goalName: String? = nil) -> String {
    // Use primary trigger (first trigger) for personalized placeholder
    guard let primaryTrigger = primaryTrigger(from: triggers) else {
        let goalText = goalName ?? "your goal"
        return "Remember why you started. Every 'no' gets you closer to \(goalText)."
    }
    
    switch primaryTrigger {
    case .bored:
        return "Remember: you're not bored, you're just looking for a dopamine hit. Go for a walk instead."
    case .afterStress:
        return "Remember: shopping won't fix what's stressing you out. Take a breath."
    case .sad:
        return "Remember: buying things won't make you happy. Call a friend instead."
    case .lonely:
        return "Remember: shopping won't fill the void. Reach out to someone you care about."
    case .socialMediaAds:
        return "Remember: sales come back. This feeling won't last."
    case .lateNight:
        return "Remember: nothing good comes from 2am shopping. Sleep on it."
    case .sales:
        return "Remember: sales come back. This feeling won't last."
    case .payday:
        return "Remember: this money could go toward your goal instead."
    }
}

// MARK: - Timeframe Formatting

func formatTimeframe(months: Double) -> String {
    if months <= 6 {
        let rounded = Int(months.rounded())
        return "It's \(rounded) month\(rounded == 1 ? "" : "s") from now."
    } else if months <= 12 {
        return "It's a year from now."
    } else {
        let years = Int((months / 12).rounded())
        return "It's \(years) year\(years == 1 ? "" : "s") from now."
    }
}

// MARK: - Date Formatting

func formatCommitmentDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

func daysSince(_ date: Date) -> Int {
    let components = Calendar.current.dateComponents([.day], from: date, to: Date())
    return components.day ?? 0
}

// MARK: - Trigger Display Mapping (for Reflection page)

func displayName(for trigger: ShoppingTrigger) -> String {
    switch trigger {
    case .bored: return "Boredom shopping"
    case .afterStress: return "Stress buying"
    case .sad: return "Emotional spending"
    case .lonely: return "Emotional spending"
    case .socialMediaAds: return "Social media impulses"
    case .lateNight: return "Late night scrolling"
    case .sales: return "FOMO & flash sales"
    case .payday: return "Treating yourself too often"
    }
}

// MARK: - Timing Display Mapping (for Reflection page)

func displayName(for timing: ShoppingTiming) -> String {
    switch timing {
    case .lateNight: return "Late night scrolling"
    case .workBreaks: return "Lunch break browsing"
    case .payday: return "Payday spending sprees"
    }
}

// MARK: - Primary Trigger Detection

func primaryTrigger(from triggers: Set<ShoppingTrigger>) -> ShoppingTrigger? {
    // Return first trigger if available
    return triggers.first
}

