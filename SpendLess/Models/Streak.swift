//
//  Streak.swift
//  SpendLess
//
//  Streak tracking model
//

import Foundation
import SwiftData

@Model
final class Streak {
    var currentDays: Int
    var longestDays: Int
    var lastImpulseDate: Date?
    var startDate: Date
    var graceUsedThisWeek: Bool
    var lastGraceUsedAt: Date?
    
    /// Milestone days for celebrations
    static let milestones: [Int] = [7, 14, 30, 60, 90, 180, 365]
    
    init(
        currentDays: Int = 0,
        longestDays: Int = 0,
        lastImpulseDate: Date? = nil,
        startDate: Date = Date(),
        graceUsedThisWeek: Bool = false
    ) {
        self.currentDays = currentDays
        self.longestDays = longestDays
        self.lastImpulseDate = lastImpulseDate
        self.startDate = startDate
        self.graceUsedThisWeek = graceUsedThisWeek
    }
    
    // MARK: - Computed Properties
    
    var isActive: Bool {
        return currentDays > 0
    }
    
    /// Check if we've hit a milestone today
    var isAtMilestone: Bool {
        return Self.milestones.contains(currentDays)
    }
    
    /// Get the next milestone to aim for
    var nextMilestone: Int? {
        return Self.milestones.first { $0 > currentDays }
    }
    
    /// Days until next milestone
    var daysUntilNextMilestone: Int? {
        guard let next = nextMilestone else { return nil }
        return next - currentDays
    }
    
    /// Can use grace period (hasn't used one this week)
    var canUseGrace: Bool {
        if !graceUsedThisWeek { return true }
        
        // Check if it's been a week since last grace use
        guard let lastGrace = lastGraceUsedAt else { return true }
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return lastGrace < weekAgo
    }
    
    /// Formatted streak display
    var displayText: String {
        if currentDays == 0 {
            return "Start your streak!"
        } else if currentDays == 1 {
            return "1 day streak"
        } else {
            return "\(currentDays) day streak"
        }
    }
    
    /// Celebration message for current streak
    var celebrationMessage: String? {
        switch currentDays {
        case 7:
            return "One week strong! 💪"
        case 14:
            return "Two weeks! Most people can't go 14 hours."
        case 30:
            return "A whole month! You're unstoppable."
        case 60:
            return "60 days! You've built a real habit."
        case 90:
            return "90 days! This is who you are now."
        case 180:
            return "Half a year of self-control! 🎉"
        case 365:
            return "ONE YEAR! You're a legend."
        default:
            return nil
        }
    }
    
    // MARK: - Methods
    
    /// Increment the streak by one day
    func incrementDay() {
        currentDays += 1
        if currentDays > longestDays {
            longestDays = currentDays
        }
    }
    
    /// Break the streak (relapse)
    func breakStreak() {
        lastImpulseDate = Date()
        currentDays = 0
        startDate = Date()
    }
    
    /// Use grace period to preserve streak
    func useGracePeriod() {
        guard canUseGrace else { return }
        graceUsedThisWeek = true
        lastGraceUsedAt = Date()
    }
    
    /// Reset the weekly grace period flag (call at start of new week)
    func resetWeeklyGrace() {
        if let lastGrace = lastGraceUsedAt {
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            if lastGrace < weekAgo {
                graceUsedThisWeek = false
            }
        }
    }
    
    /// Update streak based on current date (call daily)
    func updateStreak() {
        // This would be called to ensure streak is current
        // In a real app, this would check against app usage data
        resetWeeklyGrace()
    }
}

// MARK: - Sample Data

extension Streak {
    static var sampleStreak: Streak {
        Streak(
            currentDays: 18,
            longestDays: 23,
            startDate: Calendar.current.date(byAdding: .day, value: -18, to: Date()) ?? Date()
        )
    }
    
    static var newStreak: Streak {
        Streak()
    }
    
    static var milestoneStreak: Streak {
        Streak(
            currentDays: 14,
            longestDays: 14
        )
    }
}

