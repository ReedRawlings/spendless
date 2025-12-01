//
//  AppState.swift
//  SpendLess
//
//  Global app state management using @Observable
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class AppState {
    // MARK: - Singleton
    static let shared = AppState()
    
    // MARK: - State
    var hasCompletedOnboarding: Bool = false
    var isShowingCelebration: Bool = false
    var celebrationAmount: Decimal = 0
    var celebrationMessage: String = ""
    
    // MARK: - Screen Time State (stub)
    var isScreenTimeAuthorized: Bool = false
    var blockedAppCount: Int = 0
    
    // MARK: - Temporary Onboarding State
    var onboardingTriggers: Set<ShoppingTrigger> = []
    var onboardingTimings: Set<ShoppingTiming> = []
    var onboardingSpendRange: SpendRange = .medium
    var onboardingGoalType: GoalType = .justStop
    var onboardingGoalName: String = ""
    var onboardingGoalAmount: Decimal = 0
    var onboardingGoalImageData: Data?
    var onboardingDifficultyMode: DifficultyMode = .firm
    var onboardingSignatureData: Data?
    
    // MARK: - Initialization
    private init() {
        loadFromUserDefaults()
    }
    
    // MARK: - User Defaults Keys
    private enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isScreenTimeAuthorized = "isScreenTimeAuthorized"
        static let blockedAppCount = "blockedAppCount"
    }
    
    // MARK: - Persistence
    
    private func loadFromUserDefaults() {
        let defaults = UserDefaults.standard
        hasCompletedOnboarding = defaults.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        isScreenTimeAuthorized = defaults.bool(forKey: UserDefaultsKeys.isScreenTimeAuthorized)
        blockedAppCount = defaults.integer(forKey: UserDefaultsKeys.blockedAppCount)
    }
    
    func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(hasCompletedOnboarding, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        defaults.set(isScreenTimeAuthorized, forKey: UserDefaultsKeys.isScreenTimeAuthorized)
        defaults.set(blockedAppCount, forKey: UserDefaultsKeys.blockedAppCount)
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveToUserDefaults()
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        clearOnboardingState()
        saveToUserDefaults()
    }
    
    func clearOnboardingState() {
        onboardingTriggers = []
        onboardingTimings = []
        onboardingSpendRange = .medium
        onboardingGoalType = .justStop
        onboardingGoalName = ""
        onboardingGoalAmount = 0
        onboardingGoalImageData = nil
        onboardingDifficultyMode = .firm
        onboardingSignatureData = nil
    }
    
    // MARK: - Celebrations
    
    func showCelebration(amount: Decimal, message: String) {
        celebrationAmount = amount
        celebrationMessage = message
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isShowingCelebration = true
        }
    }
    
    func dismissCelebration() {
        withAnimation(.easeOut(duration: 0.3)) {
            isShowingCelebration = false
        }
    }
    
    // MARK: - Helper Methods
    
    /// Calculate total saved from all graveyard items
    func calculateTotalSaved(from context: ModelContext) -> Decimal {
        let descriptor = FetchDescriptor<GraveyardItem>()
        guard let items = try? context.fetch(descriptor) else { return 0 }
        return items.reduce(0) { $0 + $1.amount }
    }
    
    /// Get active waiting list items count
    func activeWaitingListCount(from context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<WaitingListItem>()
        guard let items = try? context.fetch(descriptor) else { return 0 }
        return items.filter { !$0.isExpired }.count
    }
    
    /// Get current goal if exists
    func getCurrentGoal(from context: ModelContext) -> UserGoal? {
        var descriptor = FetchDescriptor<UserGoal>(
            predicate: #Predicate { $0.isActive }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
    
    /// Get or create user profile
    func getOrCreateProfile(from context: ModelContext) -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        
        let newProfile = UserProfile()
        context.insert(newProfile)
        return newProfile
    }
    
    /// Get or create streak
    func getOrCreateStreak(from context: ModelContext) -> Streak {
        let descriptor = FetchDescriptor<Streak>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        
        let newStreak = Streak()
        context.insert(newStreak)
        return newStreak
    }
}

// MARK: - SwiftData Helpers

extension AppState {
    /// Create all required data after onboarding completes
    func finalizeOnboarding(context: ModelContext) {
        // Create or update profile
        let profile = getOrCreateProfile(from: context)
        profile.triggers = Array(onboardingTriggers)
        profile.timings = Array(onboardingTimings)
        profile.estimatedSpend = onboardingSpendRange
        profile.goalType = onboardingGoalType
        profile.difficultyMode = onboardingDifficultyMode
        profile.signatureImageData = onboardingSignatureData
        profile.completeOnboarding()
        
        // Create goal if needed
        if onboardingGoalType.requiresDetails && !onboardingGoalName.isEmpty {
            let goal = UserGoal(
                name: onboardingGoalName,
                targetAmount: onboardingGoalAmount,
                imageData: onboardingGoalImageData,
                goalType: onboardingGoalType
            )
            context.insert(goal)
        }
        
        // Create streak
        let _ = getOrCreateStreak(from: context)
        
        // Save and complete
        try? context.save()
        completeOnboarding()
        clearOnboardingState()
    }
}

