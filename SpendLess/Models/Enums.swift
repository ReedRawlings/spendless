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
    case workBreaks = "During work breaks"
    case afterStress = "After a stressful day"
    case socialMedia = "When I see ads on social media"
    case payday = "Payday"
    case bored = "When I'm bored"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .lateNight: return "moon.stars"
        case .workBreaks: return "cup.and.saucer"
        case .afterStress: return "figure.walk"
        case .socialMedia: return "iphone"
        case .payday: return "banknote"
        case .bored: return "face.dashed"
        }
    }
}

// MARK: - Difficulty Mode

enum DifficultyMode: String, CaseIterable, Codable, Identifiable {
    case gentle = "gentle"
    case firm = "firm"
    case lockdown = "lockdown"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .gentle: return "Gentle"
        case .firm: return "Firm"
        case .lockdown: return "Lockdown"
        }
    }
    
    var icon: String {
        switch self {
        case .gentle: return "🌱"
        case .firm: return "💪"
        case .lockdown: return "🔒"
        }
    }
    
    var description: String {
        switch self {
        case .gentle:
            return "Remind me, but let me through"
        case .firm:
            return "Make me wait"
        case .lockdown:
            return "Don't let me in"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .gentle:
            return "A pause and a question before you can open blocked apps."
        case .firm:
            return "5-minute breathing exercise before you can access apps."
        case .lockdown:
            return "Apps are blocked. Period. (Can only be changed from Settings)"
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
        case .panicButton: return "Panic Button"
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

