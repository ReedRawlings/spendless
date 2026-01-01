//
//  NoBuyChallenge.swift
//  SpendLess
//
//  NoBuy Challenge tracking model
//

import Foundation
import SwiftData

@Model
final class NoBuyChallenge {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var durationTypeRaw: String
    var isActive: Bool
    var createdAt: Date
    var completedAt: Date?

    // Rules configuration
    var offLimitCategoriesRaw: [String]
    var customRules: [String]?

    // Statistics (updated via entries)
    var successfulDays: Int
    var missedDays: Int

    // Support tracking - whether we've shown support sheet after hitting threshold
    var hasShownSupportForCurrentThreshold: Bool = false

    /// Milestone days for celebrations
    static let milestones: [Int] = [7, 14, 30, 60, 90, 180, 365]

    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        durationType: ChallengeDuration,
        offLimitCategories: [NoBuyCategory] = [],
        customRules: [String]? = nil
    ) {
        self.id = id
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.endDate = Calendar.current.date(byAdding: .day, value: durationType.days, to: Calendar.current.startOfDay(for: startDate)) ?? startDate
        self.durationTypeRaw = durationType.rawValue
        self.isActive = true
        self.createdAt = Date()
        self.offLimitCategoriesRaw = offLimitCategories.map { $0.rawValue }
        self.customRules = customRules
        self.successfulDays = 0
        self.missedDays = 0
        self.hasShownSupportForCurrentThreshold = false
    }

    // MARK: - Computed Properties

    var durationType: ChallengeDuration {
        get { ChallengeDuration(rawValue: durationTypeRaw) ?? .oneMonth }
        set { durationTypeRaw = newValue.rawValue }
    }

    var offLimitCategories: [NoBuyCategory] {
        get { offLimitCategoriesRaw.compactMap { NoBuyCategory(rawValue: $0) } }
        set { offLimitCategoriesRaw = newValue.map { $0.rawValue } }
    }

    var totalDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? durationType.days
    }

    var daysElapsed: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)
        let components = calendar.dateComponents([.day], from: start, to: today)
        return max(0, min(components.day ?? 0, totalDays))
    }

    var daysRemaining: Int {
        return max(0, totalDays - daysElapsed)
    }

    var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(daysElapsed) / Double(totalDays)
    }

    var isCompleted: Bool {
        return Date() >= endDate
    }

    var successRate: Double {
        let totalCheckedIn = successfulDays + missedDays
        guard totalCheckedIn > 0 else { return 0 }
        return Double(successfulDays) / Double(totalCheckedIn)
    }

    /// The miss threshold for this challenge's duration
    var missThreshold: Int {
        durationType.missThreshold
    }

    /// Whether the user has reached the miss threshold
    var hasReachedMissThreshold: Bool {
        missedDays >= missThreshold
    }

    /// Whether we should show support (threshold reached and not shown yet)
    var shouldShowSupport: Bool {
        hasReachedMissThreshold && !hasShownSupportForCurrentThreshold
    }

    /// How many misses until threshold
    var missesUntilThreshold: Int {
        max(0, missThreshold - missedDays)
    }

    /// Check if we've hit a milestone based on successful days
    var isAtMilestone: Bool {
        return Self.milestones.contains(successfulDays)
    }

    /// Get the next milestone to aim for
    var nextMilestone: Int? {
        return Self.milestones.first { $0 > successfulDays }
    }

    /// Days until next milestone
    var daysUntilNextMilestone: Int? {
        guard let next = nextMilestone else { return nil }
        return next - successfulDays
    }

    /// Display text for current progress
    var displayText: String {
        if successfulDays == 0 {
            return "Start your challenge!"
        } else if successfulDays == 1 {
            return "1 no-buy day"
        } else {
            return "\(successfulDays) no-buy days"
        }
    }

    /// Celebration message for current successful days
    var celebrationMessage: String? {
        switch successfulDays {
        case 7:
            return "One week of mindful spending!"
        case 14:
            return "Two weeks strong!"
        case 30:
            return "A whole month! You're doing amazing."
        case 60:
            return "60 days! Real change is happening."
        case 90:
            return "90 days! This is who you are now."
        case 180:
            return "Half a year of intentional living!"
        case 365:
            return "ONE YEAR! You're incredible."
        default:
            return nil
        }
    }

    // MARK: - Methods

    /// Record a successful no-spend day
    func recordSuccess() {
        successfulDays += 1
    }

    /// Record a missed day (made a purchase)
    func recordMiss() {
        missedDays += 1
    }

    /// Mark that we've shown support for this threshold level
    func markSupportShown() {
        hasShownSupportForCurrentThreshold = true
    }

    /// Pause the challenge (deactivate but don't complete)
    func pause() {
        isActive = false
    }

    /// Reset the challenge - start fresh from today
    func reset() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        startDate = today
        endDate = calendar.date(byAdding: .day, value: durationType.days, to: today) ?? today
        successfulDays = 0
        missedDays = 0
        hasShownSupportForCurrentThreshold = false
    }

    /// Complete the challenge
    func complete() {
        isActive = false
        completedAt = Date()
    }

    /// Check if a date is within the challenge period
    func isDateInChallenge(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let checkDate = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        return checkDate >= start && checkDate < end
    }

    /// Check if today needs a check-in
    func needsCheckInToday(existingEntries: [NoBuyDayEntry]) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Don't need check-in if challenge hasn't started or is over
        guard isDateInChallenge(today) else { return false }

        // Check if we already have an entry for today
        let hasEntryForToday = existingEntries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: today)
        }

        return !hasEntryForToday
    }
}
