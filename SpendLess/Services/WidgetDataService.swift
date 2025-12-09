//
//  WidgetDataService.swift
//  SpendLess
//
//  Syncs app data to the widget via App Groups
//

import Foundation
import WidgetKit

/// Service to sync data between the main app and widgets
final class WidgetDataService {
    static let shared = WidgetDataService()

    private let suiteName = AppConstants.appGroupID

    private enum Keys {
        static let futureLetterText = "futureLetterText"
        static let goalName = "goalName"
        static let goalProgress = "goalProgress"
        static let totalSaved = "totalSaved"
        static let streakDays = "streakDays"
        static let commitmentDate = "commitmentDate"
        static let userName = "userName"
    }

    /// Cached UserDefaults instance - created once to avoid race conditions from repeated instantiation
    private let sharedDefaults: UserDefaults?

    private init() {
        self.sharedDefaults = UserDefaults(suiteName: suiteName)
    }
    
    // MARK: - Sync Methods
    
    /// Updates all widget data and refreshes the widget timeline
    func syncAllData(
        profile: UserProfile?,
        goal: UserGoal?,
        streak: Streak?,
        totalSaved: Decimal
    ) {
        guard let defaults = sharedDefaults else { return }
        
        // Sync profile data
        if let profile = profile {
            defaults.set(profile.futureLetterText, forKey: Keys.futureLetterText)
            defaults.set(profile.commitmentDate, forKey: Keys.commitmentDate)
        }
        
        // Sync goal data
        if let goal = goal {
            defaults.set(goal.name, forKey: Keys.goalName)
            defaults.set(goal.progress, forKey: Keys.goalProgress)
        } else {
            defaults.removeObject(forKey: Keys.goalName)
            defaults.set(0.0, forKey: Keys.goalProgress)
        }
        
        // Sync streak data
        defaults.set(streak?.currentDays ?? 0, forKey: Keys.streakDays)
        
        // Sync total saved (store as String to preserve Decimal precision)
        defaults.set("\(totalSaved)", forKey: Keys.totalSaved)
        
        // Refresh widget timeline
        refreshWidgets()
    }
    
    /// Updates just the streak days
    func syncStreakDays(_ days: Int) {
        sharedDefaults?.set(days, forKey: Keys.streakDays)
        refreshWidgets()
    }
    
    /// Updates the future letter text
    func syncFutureLetterText(_ text: String?) {
        sharedDefaults?.set(text, forKey: Keys.futureLetterText)
        refreshWidgets()
    }
    
    /// Updates goal progress
    func syncGoalProgress(name: String?, progress: Double) {
        guard let defaults = sharedDefaults else { return }
        defaults.set(name, forKey: Keys.goalName)
        defaults.set(progress, forKey: Keys.goalProgress)
        refreshWidgets()
    }
    
    /// Updates total saved amount
    func syncTotalSaved(_ amount: Decimal) {
        // Store as String to preserve Decimal precision
        sharedDefaults?.set("\(amount)", forKey: Keys.totalSaved)
        refreshWidgets()
    }
    
    /// Updates commitment date
    func syncCommitmentDate(_ date: Date?) {
        sharedDefaults?.set(date, forKey: Keys.commitmentDate)
        refreshWidgets()
    }
    
    // MARK: - Widget Refresh
    
    /// Triggers a refresh of all SpendLess widgets
    func refreshWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "PanicButtonWidget")
    }
    
    /// Reloads all widgets
    func reloadAllWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

