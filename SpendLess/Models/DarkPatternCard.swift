//
//  DarkPatternCard.swift
//  SpendLess
//
//  Dark pattern education card model
//

import Foundation

struct DarkPatternCard: Identifiable, Equatable {
    let id: UUID
    let sortOrder: Int
    let icon: String
    let name: String
    let tactic: String
    let explanation: String
    let reframe: String
    var learnedAt: Date?
    let cooldownDuration: Int // Days before resurfacing
    
    init(
        id: UUID = UUID(),
        sortOrder: Int,
        icon: String,
        name: String,
        tactic: String,
        explanation: String,
        reframe: String,
        learnedAt: Date? = nil,
        cooldownDuration: Int = 14
    ) {
        self.id = id
        self.sortOrder = sortOrder
        self.icon = icon
        self.name = name
        self.tactic = tactic
        self.explanation = explanation
        self.reframe = reframe
        self.learnedAt = learnedAt
        self.cooldownDuration = cooldownDuration
    }
    
    // MARK: - Computed Properties
    
    var isLearned: Bool {
        learnedAt != nil
    }
    
    var isInCooldown: Bool {
        guard let learnedAt else { return false }
        let daysSinceLearned = Calendar.current.dateComponents([.day], from: learnedAt, to: Date()).day ?? 0
        return daysSinceLearned < cooldownDuration
    }
    
    var isAvailable: Bool {
        !isLearned || !isInCooldown
    }
    
    // MARK: - Equatable
    
    static func == (lhs: DarkPatternCard, rhs: DarkPatternCard) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Example Card Data

extension DarkPatternCard {
    /// Example card: Fake Urgency
    /// This demonstrates the full structure of a dark pattern education card
    static let fakeUrgency = DarkPatternCard(
        sortOrder: 1,
        icon: "⏰",
        name: "Fake Urgency",
        tactic: "\"Sale ends in 2 hours!\"",
        explanation: """
        Countdown timers trigger your brain's loss aversion instinct. We're wired to fear missing out more than we value gaining something.

        The reality? These timers often reset automatically. The same "24-hour sale" runs every week. If a deal is real, it'll still be there tomorrow.

        Retailers know that urgency bypasses your rational thinking. When you feel rushed, you don't have time to ask "Do I actually need this?"
        """,
        reframe: "Would I want this if there was no timer?"
    )
    
    // MARK: - All Cards
    // NOTE: For V1, we're only implementing one example card.
    // Future: Add more cards here, and later migrate to SwiftData for persistence.
    // Future: Cards will be grouped by category (urgency tactics, social proof, pricing tricks, etc.)
    
    static let allCards: [DarkPatternCard] = [
        fakeUrgency
        // Future cards to add:
        // - Fake Scarcity ("Only 3 left!")
        // - Social Proof Pressure ("47 people viewing this")
        // - Confirm Shaming ("No thanks, I hate deals")
        // - Hidden Cost Threshold ("Free shipping at $50!")
        // - Fake Anchoring ("Was $200, now $79!")
        // - Friction Removal ("Buy Now™")
        // - Infinite Scroll
        // - Cart Abandonment Guilt ("Your cart misses you 🥺")
        // - Algorithmic Targeting ("Picked just for you!")
        // - Loyalty Traps ("You're 50 points from Gold!")
        // - Subscription Creep ("Subscribe & save 15%")
    ]
}

