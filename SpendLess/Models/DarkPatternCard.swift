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
    
    /// Dopamine Menu Framework
    static let dopamineMenu = DarkPatternCard(
        sortOrder: 2,
        icon: "📋",
        name: "Dopamine Menu",
        tactic: "\"I'll just browse for a minute...\"",
        explanation: """
        Shopping gives you a quick dopamine hit, but it's not the only way to feel good. The Dopamine Menu is a pre-made list of non-shopping activities that give you that same satisfying feeling.

        When you feel the urge to shop, you must try at least one thing from your menu first. This creates a pause between the impulse and the action, giving your rational brain time to catch up.

        The key is having your menu ready before you need it. Write it down, keep it accessible. When the shopping urge hits, you're not trying to think of alternatives—you're choosing from options you've already curated.
        """,
        reframe: "What's on my dopamine menu today? (Walk with a podcast, bake something, play music, dance, snuggle a pet, sit in the sun...)"
    )
    
    /// Frictionless vs Effortful Dopamine
    static let frictionlessDopamine = DarkPatternCard(
        sortOrder: 3,
        icon: "⚡",
        name: "Frictionless vs Effortful Dopamine",
        tactic: "\"One-click purchase\"",
        explanation: """
        Dopamine is the "do it again" chemical, not happiness. There's a crucial difference between frictionless dopamine (one-click shopping, endless scrolling) and effortful dopamine (activities that require work).

        Frictionless dopamine is like a potato chip—easy, addictive, but ultimately unsatisfying. Effortful dopamine is like a loaded baked potato—it takes more work, but it's deeply satisfying and doesn't leave you wanting more.

        Retailers remove all friction to make shopping effortless. But you can add friction back: force yourself to drive to the store, try it on, pay cash. By the time you've done all that, the desire often passes. The effort itself becomes the filter.
        """,
        reframe: "Can I add friction to this purchase? Or choose an effortful dopamine activity instead?"
    )
    
    // MARK: - All Cards
    // NOTE: For V1, we're only implementing one example card.
    // Future: Add more cards here, and later migrate to SwiftData for persistence.
    // Future: Cards will be grouped by category (urgency tactics, social proof, pricing tricks, etc.)
    
    static let allCards: [DarkPatternCard] = [
        fakeUrgency,
        dopamineMenu,
        frictionlessDopamine
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

