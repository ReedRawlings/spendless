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
    
    // MARK: - 30x Rule
    
    /// Evaluate 30x rule from three answers
    static func evaluate30xRule(
        usage: ThirtyXAnswer,
        versatility: ThirtyXAnswer,
        practicality: ThirtyXAnswer
    ) -> ThirtyXResult {
        return ThirtyXResult.evaluate(
            usage: usage,
            versatility: versatility,
            practicality: practicality
        )
    }
    
    /// Calculate cost per use at 30 uses
    static func costPerUseAt30(price: Decimal) -> Decimal {
        return price / 30
    }
    
    // MARK: - Life Energy Calculator
    
    /// Calculate life energy hours for a given amount
    /// - Parameters:
    ///   - amount: The purchase amount
    ///   - hourlyWage: User's true hourly wage
    /// - Returns: Hours of life the purchase costs
    static func lifeEnergyHours(amount: Decimal, hourlyWage: Decimal) -> Decimal {
        guard hourlyWage > 0 else { return 0 }
        return amount / hourlyWage
    }
    
    /// Calculate true hourly wage (discretionary hourly wage after cost of living)
    /// - Parameters:
    ///   - takeHome: Take-home pay per paycheck (after taxes)
    ///   - frequency: How often user is paid
    ///   - hoursPerWeek: Total hours worked per week
    ///   - housing: Monthly housing costs (rent/mortgage)
    ///   - food: Monthly food & groceries
    ///   - utilities: Monthly utilities & phone
    ///   - transportation: Monthly transportation costs
    ///   - insurance: Monthly insurance costs
    ///   - debt: Monthly debt payments
    /// - Returns: True hourly wage (discretionary income per hour) as Decimal, or nil if discretionary <= 0
    static func trueHourlyWage(
        takeHome: Decimal,
        frequency: PayFrequency,
        hoursPerWeek: Int,
        housing: Decimal = 0,
        food: Decimal = 0,
        utilities: Decimal = 0,
        transportation: Decimal = 0,
        insurance: Decimal = 0,
        debt: Decimal = 0
    ) -> Decimal? {
        // Convert pay to monthly
        let monthlyTakeHome = takeHome * frequency.monthlyMultiplier
        
        // Calculate monthly work hours (weeks per month average = 4.33)
        let monthlyWorkHours = Decimal(hoursPerWeek) * Decimal(string: "4.33")!
        guard monthlyWorkHours > 0 else { return nil }
        
        // Calculate cost of living
        let costOfLiving = housing + food + utilities + transportation + insurance + debt
        
        // Calculate discretionary income
        let discretionary = monthlyTakeHome - costOfLiving
        
        // Return nil if discretionary income is zero or negative
        guard discretionary > 0 else { return nil }
        
        // Calculate true hourly wage (discretionary per hour)
        return discretionary / monthlyWorkHours
    }
    
    /// Format life energy hours for display
    static func formatLifeEnergyHours(_ hours: Decimal) -> String {
        let hoursDouble = NSDecimalNumber(decimal: hours).doubleValue
        if hoursDouble < 1 {
            let minutes = Int(hoursDouble * 60)
            return "\(minutes) min"
        } else if hoursDouble < 10 {
            return String(format: "%.1f hrs", hoursDouble)
        } else {
            return "\(Int(hoursDouble)) hrs"
        }
    }
    
    /// Generate comparisons for life energy hours
    static func lifeEnergyComparisons(hours: Decimal) -> [String] {
        var results: [String] = []
        let hoursDouble = NSDecimalNumber(decimal: hours).doubleValue
        
        if hoursDouble >= 1 {
            results.append("\(Int(hoursDouble)) episodes of your favorite show")
        }
        if hoursDouble >= 2 {
            results.append("\(Int(hoursDouble / 2)) movie nights")
        }
        if hoursDouble >= 4 {
            results.append("Half a workday")
        }
        if hoursDouble >= 8 {
            results.append("A full workday")
        }
        if hoursDouble >= 16 {
            results.append("Two workdays")
        }
        if hoursDouble >= 40 {
            results.append("A full work week")
        }
        
        return Array(results.prefix(3))
    }
    
    // MARK: - Spending Audit Calculations
    
    /// Calculate annualized value from total and years
    static func annualizedValue(total: Decimal, years: Int) -> Decimal {
        guard years > 0 else { return total }
        return total / Decimal(years)
    }
    
    /// Calculate usage percentage
    static func usagePercentage(used: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return (used * 100) / total
    }
    
    /// Generate value comparisons for spending audit
    static func valueComparisons(amount: Decimal) -> [String] {
        var results: [String] = []
        let value = NSDecimalNumber(decimal: amount).doubleValue
        
        switch value {
        case ..<100:
            results.append("A nice dinner out")
            results.append("A month of coffee")
        case 100..<300:
            results.append("A new phone case + accessories")
            results.append("Several nice meals")
        case 300..<500:
            results.append("A weekend trip")
            results.append("A new gadget")
        case 500..<1000:
            results.append("A vacation")
            results.append("A month's car payment")
        case 1000..<2000:
            results.append("2 months of groceries")
            results.append("A designer item")
            results.append("A weekend getaway")
        default:
            results.append("A month's rent")
            results.append("A significant investment")
            results.append("Multiple vacations")
        }
        
        return Array(results.prefix(3))
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

