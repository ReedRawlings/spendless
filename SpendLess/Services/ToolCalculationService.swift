//
//  ToolCalculationService.swift
//  SpendLess
//
//  Pure calculation functions for Tools section
//

import Foundation

// MARK: - Tool Calculations

struct ToolCalculationService {
    
    // MARK: - Opportunity Cost Calculator
    
    /// Calculate the future value of money at retirement
    /// - Parameters:
    ///   - amount: The current amount
    ///   - currentAge: User's current age
    ///   - retirementAge: Target retirement age (default 65)
    ///   - annualReturn: Expected annual return rate (default 7%)
    /// - Returns: Future value as Decimal
    static func opportunityCost(
        amount: Decimal,
        currentAge: Int,
        retirementAge: Int = 65,
        annualReturn: Double = 0.07
    ) -> Decimal {
        let years = retirementAge - currentAge
        guard years > 0 else { return amount }
        let multiplier = pow(1 + annualReturn, Double(years))
        return amount * Decimal(multiplier)
    }
    
    /// Calculate the multiplier for opportunity cost
    static func opportunityMultiplier(
        currentAge: Int,
        retirementAge: Int = 65,
        annualReturn: Double = 0.07
    ) -> Double {
        let years = retirementAge - currentAge
        guard years > 0 else { return 1.0 }
        return pow(1 + annualReturn, Double(years))
    }
    
    /// Generate contextual comparisons for future value
    static func comparisons(for futureValue: Decimal) -> [String] {
        var results: [String] = []
        let value = NSDecimalNumber(decimal: futureValue).doubleValue
        
        if value >= 50 { results.append("\(Int(value / 25)) coffee shop visits") }
        if value >= 100 { results.append("\(Int(value / 50)) nice dinners out") }
        if value >= 200 { results.append("\(Int(value / 15)) months of Netflix") }
        if value >= 500 { results.append("A weekend getaway") }
        if value >= 1000 { results.append("A month's groceries") }
        if value >= 5000 { results.append("A used car down payment") }
        
        return Array(results.prefix(3))
    }
    
    // MARK: - Price Per Wear Calculator
    
    /// Calculate cost per use
    static func costPerUse(price: Decimal, estimatedUses: Int) -> Decimal {
        guard estimatedUses > 0 else { return price }
        return price / Decimal(estimatedUses)
    }
    
    /// Generate contextual comparison for cost per use
    static func perUseComparison(costPerUse: Decimal) -> String {
        let cpu = NSDecimalNumber(decimal: costPerUse).doubleValue
        switch cpu {
        case ..<2: return "Less than a cup of coffee each time"
        case 2..<5: return "Like paying for a coffee every time"
        case 5..<10: return "Like paying for a fancy coffee every time"
        case 10..<20: return "Like paying for lunch every time you use it"
        case 20..<50: return "Like paying for dinner every time you use it"
        default: return "Like paying for a night out every time you use it"
        }
    }
    
    /// Calculate uses needed to reach a target cost per use
    static func usesNeededForTarget(price: Decimal, targetCostPerUse: Decimal = 2.0) -> Int {
        guard targetCostPerUse > 0 else { return Int.max }
        return Int(ceil(NSDecimalNumber(decimal: price / targetCostPerUse).doubleValue))
    }
    
    // MARK: - 30x Rule (V2)
    
    /// Evaluate 30x rule score
    static func evaluate30xRule(
        willUse30Times: Bool,
        canMatch5Contexts: Bool,
        hasSpace: Bool
    ) -> ThirtyXResult {
        var score = 0
        if willUse30Times { score += 1 }
        if canMatch5Contexts { score += 1 }
        if hasSpace { score += 1 }
        return ThirtyXResult.from(score: score)
    }
    
    // MARK: - Age Helpers
    
    /// Calculate age from birth year
    static func ageFromBirthYear(_ birthYear: Int) -> Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - birthYear
    }
    
    /// Calculate birth year from age
    static func birthYearFromAge(_ age: Int) -> Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - age
    }
}

// MARK: - Currency Formatting

extension ToolCalculationService {
    
    /// Format decimal as currency string
    static func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$\(amount)"
    }
    
    /// Format decimal with cents
    static func formatCurrencyWithCents(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$\(amount)"
    }
}

