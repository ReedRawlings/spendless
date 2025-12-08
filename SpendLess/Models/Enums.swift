//
//  Enums.swift
//  SpendLess
//
//  Shared enumerations for the app
//

import Foundation

// MARK: - Shopping Triggers

enum ShoppingTrigger: String, CaseIterable, Codable, Identifiable {
    case bored = "When I'm bored"
    case afterStress = "After a stressful day"
    case sad = "When I'm feeling sad"
    case lonely = "When I feel lonely"
    case socialMediaAds = "When I see ads on social media"
    case lateNight = "Late at night"
    case sales = "During sales or \"limited time\" deals"
    case payday = "Payday"
    
    var id: String { rawValue }
    
    var shortLabel: String {
        switch self {
        case .bored: return "Bored"
        case .afterStress: return "After Stress"
        case .sad: return "Sad"
        case .lonely: return "Lonely"
        case .socialMediaAds: return "Social Media Ads"
        case .lateNight: return "Late Night"
        case .sales: return "Sales"
        case .payday: return "Payday"
        }
    }
    
    var icon: String {
        switch self {
        case .bored: return "😴"
        case .afterStress: return "😤"
        case .sad: return "😢"
        case .lonely: return "😔"
        case .socialMediaAds: return "📱"
        case .lateNight: return "🌙"
        case .sales: return "🏷️"
        case .payday: return "💵"
        }
    }
}

// MARK: - Shopping Timing

enum ShoppingTiming: String, CaseIterable, Codable, Identifiable {
    case lateNight = "Late at night"
    case workBreaks = "Work breaks"
    case payday = "Payday"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .lateNight: return "moon.stars"
        case .workBreaks: return "cup.and.saucer"
        case .payday: return "banknote"
        }
    }
}

// MARK: - Graveyard Source

enum GraveyardSource: String, Codable, Identifiable {
    case waitingList = "waitingList"
    case panicButton = "panicButton"
    case blockIntercept = "blockIntercept"
    case manual = "manual"
    case returned = "returned"
    
    var id: String { rawValue }
    
    var displayLabel: String {
        switch self {
        case .waitingList: return "From Waiting List"
        case .panicButton: return "Feeling Tempted"
        case .blockIntercept: return "Block Intercept"
        case .manual: return "Manually Added"
        case .returned: return "Returned"
        }
    }
    
    var icon: String {
        switch self {
        case .waitingList: return "clock.arrow.circlepath"
        case .panicButton: return "exclamationmark.triangle"
        case .blockIntercept: return "hand.raised"
        case .manual: return "plus.circle"
        case .returned: return "arrow.uturn.backward"
        }
    }
}

// MARK: - Monthly Spend Range

enum SpendRange: String, CaseIterable, Codable, Identifiable {
    case low = "$50-100"
    case medium = "$100-250"
    case high = "$250-500"
    case veryHigh = "$500+"
    case unknown = "Honestly, I'm scared to know"
    
    var id: String { rawValue }
    
    /// Monthly estimate for calculations (midpoint of range)
    var monthlyEstimate: Decimal {
        switch self {
        case .low: return 75
        case .medium: return 175
        case .high: return 375
        case .veryHigh: return 750
        case .unknown: return 300 // Conservative estimate
        }
    }
    
    /// Yearly projection
    var yearlyEstimate: Decimal {
        return monthlyEstimate * 12
    }
    
    /// 10-year projection
    var decadeEstimate: Decimal {
        return monthlyEstimate * 12 * 10
    }
}

// MARK: - Goal Type

enum GoalType: String, CaseIterable, Codable, Identifiable {
    case emergency = "An emergency fund"
    case vacation = "A dream vacation"
    case retirement = "Retirement"
    case debtFree = "Freedom from debt"
    case downPayment = "A down payment"
    case car = "A car"
    case bigPurchase = "Something I actually need"
    case justStop = "Just want to stop wasting"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .emergency: return "🏦"
        case .vacation: return "🏝️"
        case .retirement: return "💰"
        case .debtFree: return "💳"
        case .downPayment: return "🏠"
        case .car: return "🚗"
        case .bigPurchase: return "💻"
        case .justStop: return "🤷"
        }
    }
    
    var requiresDetails: Bool {
        return self != .justStop
    }
}

// MARK: - Spending Category

enum SpendingCategory: String, CaseIterable, Codable, Identifiable {
    case clothing = "Clothing"
    case electronics = "Electronics"
    case home = "Home & Decor"
    case beauty = "Beauty"
    case entertainment = "Entertainment"
    case food = "Food & Dining"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt"
        case .electronics: return "laptopcomputer"
        case .home: return "house"
        case .beauty: return "sparkles"
        case .entertainment: return "gamecontroller"
        case .food: return "fork.knife"
        case .other: return "ellipsis.circle"
        }
    }
}

// MARK: - Intercept Outcome

enum InterceptOutcome: String, Codable {
    case resistedBrowsing = "resistedBrowsing"
    case addedToWaitingList = "addedToWaitingList"
    case proceededAfterQuestionnaire = "proceededAfterQuestionnaire"
    case proceededImmediately = "proceededImmediately"
}

// MARK: - Desired Outcome

enum DesiredOutcome: String, CaseIterable, Codable, Identifiable {
    case lessStress = "lessStress"
    case selfControl = "selfControl"
    case clarity = "clarity"
    case guiltFree = "guiltFree"
    case moneyForWhatMatters = "moneyForWhatMatters"
    case confidence = "confidence"
    case breakCycle = "breakCycle"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .lessStress: return "Less financial stress"
        case .selfControl: return "More self-control"
        case .clarity: return "Clarity on what I actually want"
        case .guiltFree: return "Freedom from guilt"
        case .moneyForWhatMatters: return "Money for things that matter"
        case .confidence: return "Confidence in my spending"
        case .breakCycle: return "Breaking the dopamine cycle"
        }
    }
    
    var icon: String {
        switch self {
        case .lessStress: return "🧠"
        case .selfControl: return "💪"
        case .clarity: return "🎯"
        case .guiltFree: return "😌"
        case .moneyForWhatMatters: return "💰"
        case .confidence: return "✨"
        case .breakCycle: return "🛑"
        }
    }
}

// MARK: - HALT State

enum HALTState: String, CaseIterable, Codable, Identifiable {
    case hungry = "hungry"
    case angry = "angry"
    case lonely = "lonely"
    case tired = "tired"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .hungry: return "Hungry"
        case .angry: return "Angry / Stressed"
        case .lonely: return "Lonely"
        case .tired: return "Tired"
        }
    }
    
    var emoji: String {
        switch self {
        case .hungry: return "🍽️"
        case .angry: return "😤"
        case .lonely: return "😔"
        case .tired: return "😴"
        }
    }
    
    var title: String {
        switch self {
        case .hungry: return "You're hungry, not bored."
        case .angry: return "Stress shopping doesn't solve what's bothering you."
        case .lonely: return "Packages aren't company."
        case .tired: return "Tired brains make bad decisions."
        }
    }
    
    var suggestions: [String] {
        switch self {
        case .hungry:
            return [
                "Grab a snack",
                "Drink some water",
                "Step away for 10 minutes"
            ]
        case .angry:
            return [
                "Take 5 deep breaths",
                "Go for a quick walk",
                "Text someone about it"
            ]
        case .lonely:
            return [
                "Text a friend",
                "Call someone you miss",
                "Go somewhere with people"
            ]
        case .tired:
            return [
                "Take a 20-minute nap",
                "Go to bed early tonight",
                "Rest first, decide later"
            ]
        }
    }
}

// MARK: - HALT Check Result

struct HALTCheckResult: Codable {
    let timestamp: Date
    let triggerApp: String?
    let selectedState: HALTState?
    let didRedirect: Bool
    
    init(
        timestamp: Date = Date(),
        triggerApp: String? = nil,
        selectedState: HALTState? = nil,
        didRedirect: Bool = false
    ) {
        self.timestamp = timestamp
        self.triggerApp = triggerApp
        self.selectedState = selectedState
        self.didRedirect = didRedirect
    }
}

// MARK: - Reason Wanted (Why do you want this?)

enum ReasonWanted: String, CaseIterable, Codable, Identifiable {
    case onSale = "onSale"
    case socialMedia = "socialMedia"
    case replacement = "replacement"
    case wantedForAWhile = "wantedForAWhile"
    case treatMyself = "treatMyself"
    case notSure = "notSure"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .onSale: return "It's on sale / good deal"
        case .socialMedia: return "Saw it on social media"
        case .replacement: return "Replaces something I have"
        case .wantedForAWhile: return "Been wanting this for a while"
        case .treatMyself: return "Treat myself / bad day"
        case .notSure: return "Not sure, just want it"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .onSale: return "🏷️"
        case .socialMedia: return "📱"
        case .replacement: return "🔄"
        case .wantedForAWhile: return "⏳"
        case .treatMyself: return "🎁"
        case .notSure: return "🤷"
        case .other: return "✏️"
        }
    }
}

// MARK: - Removal Reason (Why are you burying this?)

enum RemovalReason: String, CaseIterable, Codable, Identifiable {
    case dontWantAnymore = "dontWantAnymore"
    case foundCheaper = "foundCheaper"
    case alreadyHaveSimilar = "alreadyHaveSimilar"
    case cantAfford = "cantAfford"
    case urgePassed = "urgePassed"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .dontWantAnymore: return "Don't want it anymore"
        case .foundCheaper: return "Found a cheaper alternative"
        case .alreadyHaveSimilar: return "Already have something similar"
        case .cantAfford: return "Can't actually afford it"
        case .urgePassed: return "The \"need\" passed"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .dontWantAnymore: return "🚫"
        case .foundCheaper: return "💰"
        case .alreadyHaveSimilar: return "📦"
        case .cantAfford: return "💸"
        case .urgePassed: return "💨"
        case .other: return "✏️"
        }
    }
}

// MARK: - Purchase Feeling (Post-purchase reflection)

enum PurchaseFeeling: String, CaseIterable, Codable, Identifiable {
    case genuineNeed = "genuineNeed"
    case stillImpulsive = "stillImpulsive"
    case inBetween = "inBetween"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .genuineNeed: return "Genuine need"
        case .stillImpulsive: return "Still kind of impulsive"
        case .inBetween: return "Somewhere in between"
        }
    }
    
    var icon: String {
        switch self {
        case .genuineNeed: return "✅"
        case .stillImpulsive: return "🤔"
        case .inBetween: return "🤷"
        }
    }
}

// MARK: - Shield User Action

enum ShieldUserAction: String, Codable {
    case primaryButton = "primaryButton"
    case secondaryButton = "secondaryButton"
    case dismissed = "dismissed"
}

