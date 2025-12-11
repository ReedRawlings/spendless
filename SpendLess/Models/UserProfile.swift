//
//  UserProfile.swift
//  SpendLess
//
//  User profile and preferences model
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    
    // Onboarding responses
    var triggersRaw: [String] // ShoppingTrigger raw values
    var timingsRaw: [String] // ShoppingTiming raw values
    var estimatedSpendRaw: String // SpendRange raw value
    var goalTypeRaw: String? // GoalType raw value
    
    // Settings
    var isPro: Bool
    
    // Feature data
    var futureLetterText: String?
    var signatureImageData: Data? // Commitment signature
    var commitmentDate: Date?
    var desiredOutcomesRaw: [String] // DesiredOutcome raw values
    
    // State
    var onboardingCompletedAt: Date?
    var createdAt: Date
    
    // Screen Time (stored as encoded data since we can't store opaque tokens directly)
    var blockedAppCount: Int
    var hasScreenTimeAuth: Bool
    
    // Tools - Dopamine Menu
    var dopamineMenuSelectedDefaultsRaw: [String] // DopamineActivity raw values
    var dopamineMenuCustomActivities: [String]? // Custom activities (optional feature)
    
    // Tools - Opportunity Cost
    var birthYear: Int? // For opportunity cost calculator
    
    // Tools - Life Energy Calculator
    var takeHomePay: Decimal?
    var payFrequencyRaw: String? // PayFrequency raw value
    var hoursWorkedPerWeek: Int?
    
    // Cost of living (monthly estimates)
    var monthlyHousing: Decimal?
    var monthlyFood: Decimal?
    var monthlyUtilities: Decimal?
    var monthlyTransportation: Decimal?
    var monthlyInsurance: Decimal?
    var monthlyDebt: Decimal?
    
    // Lead Magnet / Email Collection
    var leadMagnetEmailCollected: Bool
    var leadMagnetEmailAddress: String?
    var leadMagnetOptedIntoMarketing: Bool
    var leadMagnetCollectedAt: Date?
    var leadMagnetSourceRaw: String? // LeadMagnetSource raw value
    
    init(
        id: UUID = UUID(),
        triggers: [ShoppingTrigger] = [],
        timings: [ShoppingTiming] = [],
        estimatedSpend: SpendRange = .medium,
        goalType: GoalType? = nil,
        isPro: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.triggersRaw = triggers.map { $0.rawValue }
        self.timingsRaw = timings.map { $0.rawValue }
        self.estimatedSpendRaw = estimatedSpend.rawValue
        self.goalTypeRaw = goalType?.rawValue
        self.isPro = isPro
        self.createdAt = createdAt
        self.desiredOutcomesRaw = []
        self.blockedAppCount = 0
        self.hasScreenTimeAuth = false
        self.dopamineMenuSelectedDefaultsRaw = []
        self.dopamineMenuCustomActivities = nil
        self.birthYear = nil
        self.takeHomePay = nil
        self.payFrequencyRaw = nil
        self.hoursWorkedPerWeek = nil
        self.monthlyHousing = nil
        self.monthlyFood = nil
        self.monthlyUtilities = nil
        self.monthlyTransportation = nil
        self.monthlyInsurance = nil
        self.monthlyDebt = nil
        self.leadMagnetEmailCollected = false
        self.leadMagnetEmailAddress = nil
        self.leadMagnetOptedIntoMarketing = false
        self.leadMagnetCollectedAt = nil
        self.leadMagnetSourceRaw = nil
    }
    
    // MARK: - Computed Properties
    
    var triggers: [ShoppingTrigger] {
        get { triggersRaw.compactMap { ShoppingTrigger(rawValue: $0) } }
        set { triggersRaw = newValue.map { $0.rawValue } }
    }
    
    var timings: [ShoppingTiming] {
        get { timingsRaw.compactMap { ShoppingTiming(rawValue: $0) } }
        set { timingsRaw = newValue.map { $0.rawValue } }
    }
    
    var estimatedSpend: SpendRange {
        get { SpendRange(rawValue: estimatedSpendRaw) ?? .medium }
        set { estimatedSpendRaw = newValue.rawValue }
    }
    
    var goalType: GoalType? {
        get { goalTypeRaw.flatMap { GoalType(rawValue: $0) } }
        set { goalTypeRaw = newValue?.rawValue }
    }
    
    var desiredOutcomes: Set<DesiredOutcome> {
        get { Set(desiredOutcomesRaw.compactMap { DesiredOutcome(rawValue: $0) }) }
        set { desiredOutcomesRaw = newValue.map { $0.rawValue } }
    }
    
    var hasCompletedOnboarding: Bool {
        return onboardingCompletedAt != nil
    }
    
    var daysSinceCommitment: Int? {
        guard let date = commitmentDate else { return nil }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day
    }
    
    // MARK: - Dopamine Menu
    
    var dopamineMenuSelectedDefaults: Set<DopamineActivity> {
        get { Set(dopamineMenuSelectedDefaultsRaw.compactMap { DopamineActivity(rawValue: $0) }) }
        set { dopamineMenuSelectedDefaultsRaw = newValue.map { $0.rawValue } }
    }
    
    /// Combined list of all dopamine menu activities (defaults + custom)
    var dopamineMenuActivities: [String] {
        let defaults = dopamineMenuSelectedDefaults.map { $0.rawValue }
        let custom = dopamineMenuCustomActivities ?? []
        return defaults + custom
    }
    
    var hasDopamineMenuSetup: Bool {
        return !dopamineMenuSelectedDefaultsRaw.isEmpty || !(dopamineMenuCustomActivities?.isEmpty ?? true)
    }
    
    // MARK: - Age Helpers
    
    var currentAge: Int {
        guard let birthYear else { return 30 } // Default to 30 if not set
        return ToolCalculationService.ageFromBirthYear(birthYear)
    }
    
    // MARK: - Life Energy Calculator
    
    var payFrequency: PayFrequency? {
        get { payFrequencyRaw.flatMap { PayFrequency(rawValue: $0) } }
        set { payFrequencyRaw = newValue?.rawValue }
    }
    
    /// Monthly take-home pay (calculated from paycheck and frequency)
    var monthlyTakeHome: Decimal? {
        guard let pay = takeHomePay, let freq = payFrequency else { return nil }
        return pay * freq.monthlyMultiplier
    }
    
    /// Monthly work hours (calculated from hours per week)
    var monthlyWorkHours: Decimal? {
        guard let hours = hoursWorkedPerWeek else { return nil }
        return Decimal(hours) * Decimal(4.33)
    }
    
    /// True hourly wage (discretionary income per hour after cost of living)
    var trueHourlyWage: Decimal? {
        guard let income = monthlyTakeHome,
              let hours = monthlyWorkHours else { return nil }
        
        let housing = monthlyHousing ?? 0
        let food = monthlyFood ?? 0
        let utilities = monthlyUtilities ?? 0
        let transport = monthlyTransportation ?? 0
        let insurance = monthlyInsurance ?? 0
        let debt = monthlyDebt ?? 0
        let costOfLiving = housing + food + utilities + transport + insurance + debt
        
        let discretionary = income - costOfLiving
        guard discretionary > 0 else { return nil }
        
        return discretionary / hours
    }
    
    var hasConfiguredLifeEnergy: Bool {
        takeHomePay != nil && payFrequency != nil && hoursWorkedPerWeek != nil
    }
    
    /// Calculate life energy hours for a given amount
    func lifeEnergyHours(for amount: Decimal) -> Decimal? {
        guard let wage = trueHourlyWage, wage > 0 else { return nil }
        return amount / wage
    }
    
    // MARK: - Lead Magnet
    
    var leadMagnetSource: LeadMagnetSource? {
        get { leadMagnetSourceRaw.flatMap { LeadMagnetSource(rawValue: $0) } }
        set { leadMagnetSourceRaw = newValue?.rawValue }
    }
    
    // MARK: - Methods
    
    func completeOnboarding() {
        onboardingCompletedAt = Date()
    }
    
    func resetOnboarding() {
        onboardingCompletedAt = nil
    }
}

// MARK: - Sample Data

extension UserProfile {
    static var sampleProfile: UserProfile {
        let profile = UserProfile(
            triggers: [.bored, .sales, .afterStress],
            timings: [.lateNight, .workBreaks],
            estimatedSpend: .high,
            goalType: .vacation
        )
        profile.onboardingCompletedAt = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        profile.blockedAppCount = 8
        profile.hasScreenTimeAuth = true
        return profile
    }
    
    static var newProfile: UserProfile {
        UserProfile()
    }
}

// MARK: - Pay Frequency Enum

enum PayFrequency: String, CaseIterable, Codable, Identifiable {
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .biweekly: return "Biweekly"
        case .monthly: return "Monthly"
        }
    }
    
    /// Multiplier to convert pay to monthly amount
    var monthlyMultiplier: Decimal {
        switch self {
        case .weekly: return Decimal(string: "4.33") ?? 4.33
        case .biweekly: return Decimal(string: "2.17") ?? 2.17
        case .monthly: return 1
        }
    }
}

