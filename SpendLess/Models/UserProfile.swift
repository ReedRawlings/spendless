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
    var difficultyModeRaw: String // DifficultyMode raw value
    var isPro: Bool
    
    // Feature data
    var futureLetterText: String?
    var signatureImageData: Data? // Commitment signature
    
    // State
    var onboardingCompletedAt: Date?
    var createdAt: Date
    
    // Screen Time (stored as encoded data since we can't store opaque tokens directly)
    var blockedAppCount: Int
    var hasScreenTimeAuth: Bool
    
    init(
        id: UUID = UUID(),
        triggers: [ShoppingTrigger] = [],
        timings: [ShoppingTiming] = [],
        estimatedSpend: SpendRange = .medium,
        goalType: GoalType? = nil,
        difficultyMode: DifficultyMode = .firm,
        isPro: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.triggersRaw = triggers.map { $0.rawValue }
        self.timingsRaw = timings.map { $0.rawValue }
        self.estimatedSpendRaw = estimatedSpend.rawValue
        self.goalTypeRaw = goalType?.rawValue
        self.difficultyModeRaw = difficultyMode.rawValue
        self.isPro = isPro
        self.createdAt = createdAt
        self.blockedAppCount = 0
        self.hasScreenTimeAuth = false
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
    
    var difficultyMode: DifficultyMode {
        get { DifficultyMode(rawValue: difficultyModeRaw) ?? .firm }
        set { difficultyModeRaw = newValue.rawValue }
    }
    
    var hasCompletedOnboarding: Bool {
        return onboardingCompletedAt != nil
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
            timings: [.lateNight, .socialMedia],
            estimatedSpend: .high,
            goalType: .vacation,
            difficultyMode: .firm
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

