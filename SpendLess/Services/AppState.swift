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
    
    // MARK: - Screen Time State
    var isScreenTimeAuthorized: Bool = false
    var blockedAppCount: Int = 0
    
    // MARK: - Deep Linking
    var pendingDeepLink: String? = nil
    
    // MARK: - Subscription State
    var subscriptionService = SubscriptionService.shared
    var shouldShowPaywallAfterOnboarding: Bool = false
    
    // MARK: - Temporary Onboarding State
    var onboardingTriggers: Set<ShoppingTrigger> = []
    var onboardingTimings: Set<ShoppingTiming> = []
    var onboardingSpendRange: SpendRange = .medium
    var onboardingGoalType: GoalType = .justStop
    var onboardingGoalName: String = ""
    var onboardingGoalAmount: Decimal = 0
    var onboardingGoalImageData: Data?
    var onboardingDesiredOutcomes: Set<DesiredOutcome> = []
    var onboardingSignatureData: Data?
    var onboardingFutureLetterText: String?
    var onboardingCommitmentDate: Date?
    
    // MARK: - Initialization
    private init() {
        loadFromUserDefaults()
    }
    
    // MARK: - User Defaults Keys
    private enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isScreenTimeAuthorized = "isScreenTimeAuthorized"
        static let blockedAppCount = "blockedAppCount"
        static let hasShownPaywallAfterOnboarding = "hasShownPaywallAfterOnboarding"
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
    
    // MARK: - Paywall After Onboarding
    
    func hasShownPaywallAfterOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasShownPaywallAfterOnboarding)
    }
    
    func markPaywallShownAfterOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasShownPaywallAfterOnboarding)
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
        onboardingDesiredOutcomes = []
        onboardingSignatureData = nil
        onboardingFutureLetterText = nil
        onboardingCommitmentDate = nil
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
    
    /// Get or create user profile (singleton pattern)
    func getOrCreateProfile(from context: ModelContext) -> UserProfile {
        // Use the singleton ID to ensure uniqueness
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate<UserProfile> { $0.id == UserProfile.singletonID }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        
        // Create new profile with singleton ID
        let newProfile = UserProfile(id: UserProfile.singletonID)
        context.insert(newProfile)
        return newProfile
    }
    
    /// Get or create streak (singleton pattern)
    func getOrCreateStreak(from context: ModelContext) -> Streak {
        // Use the singleton ID to ensure uniqueness
        let descriptor = FetchDescriptor<Streak>(
            predicate: #Predicate<Streak> { $0.id == Streak.singletonID }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        
        // Create new streak with singleton ID
        let newStreak = Streak(id: Streak.singletonID)
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
        profile.desiredOutcomes = onboardingDesiredOutcomes
        profile.signatureImageData = onboardingSignatureData
        profile.futureLetterText = onboardingFutureLetterText
        profile.commitmentDate = onboardingCommitmentDate ?? Date()
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
        
        // Sync futureLetterText to App Groups for Shield extension
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        if let letterText = onboardingFutureLetterText, !letterText.isEmpty {
            sharedDefaults?.set(letterText, forKey: "futureLetterText")
        } else {
            // Generate default if empty
            let defaultText = generatePlaceholderText(triggers: onboardingTriggers)
            sharedDefaults?.set(defaultText, forKey: "futureLetterText")
        }
        
        // Sync blocked apps selection (already saved by ScreenTimeManager)
        // The selection is saved when user picks apps in onboarding
        
        // Save and complete
        if !context.saveSafely() {
            // Log error but continue - user has already completed onboarding
            print("⚠️ Warning: Failed to save onboarding data")
        }
        
        // Sync widget data
        syncWidgetData(context: context)
        
        completeOnboarding()
        clearOnboardingState()
        
        // Trigger paywall after onboarding (only if not already shown)
        if !hasShownPaywallAfterOnboarding() {
            shouldShowPaywallAfterOnboarding = true
        }
    }
    
    /// Sync streak and savings data to App Groups for shield display
    func syncStreakAndSavingsToAppGroups(context: ModelContext) {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        
        // Sync streak
        let streak = getOrCreateStreak(from: context)
        sharedDefaults?.set(streak.currentDays, forKey: "currentStreak")
        
        // Sync total saved
        let totalSaved = calculateTotalSaved(from: context)
        sharedDefaults?.set((totalSaved as NSDecimalNumber).doubleValue, forKey: "totalSaved")
        
        // Also sync widget data
        syncWidgetData(context: context)
    }
    
    /// Sync all data to widgets
    func syncWidgetData(context: ModelContext) {
        let profile = try? context.fetch(FetchDescriptor<UserProfile>()).first
        let goal = getCurrentGoal(from: context)
        let streak = try? context.fetch(FetchDescriptor<Streak>()).first
        let totalSaved = calculateTotalSaved(from: context)
        
        WidgetDataService.shared.syncAllData(
            profile: profile,
            goal: goal,
            streak: streak,
            totalSaved: totalSaved
        )
    }
}

