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
    /// Unique identifier to ensure singleton pattern
    /// Using a constant UUID ensures only one UserProfile record exists
    @Attribute(.unique) var id: UUID
    
    /// Singleton identifier - all UserProfile records should use this ID
    static let singletonID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    
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
    
    init(
        id: UUID = UserProfile.singletonID,
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

