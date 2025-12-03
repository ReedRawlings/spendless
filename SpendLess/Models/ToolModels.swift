//
//  ToolModels.swift
//  SpendLess
//
//  Data models for Tools section calculations and results
//

import Foundation

// MARK: - Tool Types

enum ToolType: String, Codable, CaseIterable, Identifiable {
    case dopamineMenu
    case opportunityCost
    case pricePerWear
    case thirtyXRule
    case spendingAudit
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .dopamineMenu: return "Dopamine Menu"
        case .opportunityCost: return "Opportunity Cost"
        case .pricePerWear: return "Price Per Wear"
        case .thirtyXRule: return "30x Rule Check"
        case .spendingAudit: return "Spending Audit"
        }
    }
    
    var icon: String {
        switch self {
        case .dopamineMenu: return "🎯"
        case .opportunityCost: return "📈"
        case .pricePerWear: return "👗"
        case .thirtyXRule: return "🔢"
        case .spendingAudit: return "📊"
        }
    }
    
    var description: String {
        switch self {
        case .dopamineMenu: return "Healthy alternatives when urges hit"
        case .opportunityCost: return "See what money could become"
        case .pricePerWear: return "Calculate true cost per use"
        case .thirtyXRule: return "Quick purchase decision test"
        case .spendingAudit: return "Audit your recurring spending"
        }
    }
    
    var isV1: Bool {
        switch self {
        case .dopamineMenu, .opportunityCost, .pricePerWear:
            return true
        case .thirtyXRule, .spendingAudit:
            return false
        }
    }
}

enum ToolOutcome: String, Codable {
    case addedToWaitingList
    case buried
    case dismissed
    case activitySelected // dopamine menu
}

// MARK: - Opportunity Cost Result

struct OpportunityCostResult {
    let originalAmount: Decimal
    let futureValue: Decimal
    let yearsToRetirement: Int
    let multiplier: Double
    let timestamp: Date
    
    init(
        originalAmount: Decimal,
        futureValue: Decimal,
        yearsToRetirement: Int,
        multiplier: Double,
        timestamp: Date = Date()
    ) {
        self.originalAmount = originalAmount
        self.futureValue = futureValue
        self.yearsToRetirement = yearsToRetirement
        self.multiplier = multiplier
        self.timestamp = timestamp
    }
}

// MARK: - Price Per Wear Result

struct PricePerWearResult {
    let price: Decimal
    let estimatedUses: Int
    
    var costPerUse: Decimal {
        guard estimatedUses > 0 else { return price }
        return price / Decimal(estimatedUses)
    }
    
    var verdict: PricePerWearVerdict {
        let cpu = NSDecimalNumber(decimal: costPerUse).doubleValue
        switch cpu {
        case ..<1: return .greatValue
        case 1..<3: return .solidInvestment
        case 3..<5: return .reasonable
        case 5..<10: return .gettingExpensive
        default: return .basicallyARental
        }
    }
    
    var usesNeededForTarget: Int {
        // Uses needed to get under $2/use
        let target: Decimal = 2.0
        return Int(ceil(NSDecimalNumber(decimal: price / target).doubleValue))
    }
}

enum PricePerWearVerdict: String, CaseIterable {
    case greatValue
    case solidInvestment
    case reasonable
    case gettingExpensive
    case basicallyARental
    
    var message: String {
        switch self {
        case .greatValue: return "Great value—you'll get your money's worth"
        case .solidInvestment: return "Solid investment if you love it"
        case .reasonable: return "Reasonable, but be honest about usage"
        case .gettingExpensive: return "Getting expensive—are you sure?"
        case .basicallyARental: return "This is basically a rental"
        }
    }
    
    var emoji: String {
        switch self {
        case .greatValue: return "✅"
        case .solidInvestment: return "👍"
        case .reasonable: return "🤔"
        case .gettingExpensive: return "😬"
        case .basicallyARental: return "🚨"
        }
    }
}

// MARK: - 30x Rule Result (V2)

enum ThirtyXResult {
    case likelyWorthwhile  // 3/3
    case proceedWithCaution // 2/3
    case probablySkip       // 0-1/3
    
    var message: String {
        switch self {
        case .likelyWorthwhile: return "This passes the test. If you still want it in 7 days, go for it."
        case .proceedWithCaution: return "Borderline. The waiting list will help you decide."
        case .probablySkip: return "Probably skip this one."
        }
    }
    
    var emoji: String {
        switch self {
        case .likelyWorthwhile: return "✅"
        case .proceedWithCaution: return "🤔"
        case .probablySkip: return "🚨"
        }
    }
    
    static func from(score: Int) -> ThirtyXResult {
        switch score {
        case 3: return .likelyWorthwhile
        case 2: return .proceedWithCaution
        default: return .probablySkip
        }
    }
}

