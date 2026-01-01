//
//  NoBuyDayEntry.swift
//  SpendLess
//
//  Individual day entry for NoBuy challenge tracking
//

import Foundation
import SwiftData

@Model
final class NoBuyDayEntry {
    var id: UUID
    var challengeID: UUID
    var date: Date
    var didMakePurchase: Bool
    var checkedInAt: Date
    var triggerNote: String?

    /// Pool of emojis for successful days (displayed on calendar)
    static let successEmojis = ["sparkles", "star.fill", "heart.fill", "checkmark.circle.fill", "flame.fill"]

    init(
        id: UUID = UUID(),
        challengeID: UUID,
        date: Date,
        didMakePurchase: Bool,
        checkedInAt: Date = Date(),
        triggerNote: String? = nil
    ) {
        self.id = id
        self.challengeID = challengeID
        self.date = Calendar.current.startOfDay(for: date)
        self.didMakePurchase = didMakePurchase
        self.checkedInAt = checkedInAt
        self.triggerNote = triggerNote
    }

    // MARK: - Computed Properties

    var isSuccess: Bool {
        return !didMakePurchase
    }

    /// Get a consistent emoji for this entry based on its id
    var successEmoji: String {
        // Use the UUID to get a consistent but pseudo-random emoji
        let hash = id.hashValue
        let index = abs(hash) % Self.successEmojis.count
        return Self.successEmojis[index]
    }

    /// Formatted date display
    var dateDisplayText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    /// Day of month for calendar display
    var dayOfMonth: Int {
        return Calendar.current.component(.day, from: date)
    }

    /// Check if this entry is for today
    var isToday: Bool {
        return Calendar.current.isDateInToday(date)
    }

    /// Check if this entry is for yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(date)
    }
}

// MARK: - Helper Extensions

extension Array where Element == NoBuyDayEntry {
    /// Find entry for a specific date
    func entry(for date: Date) -> NoBuyDayEntry? {
        let calendar = Calendar.current
        return first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// Get entries for a specific month
    func entries(for month: Date) -> [NoBuyDayEntry] {
        let calendar = Calendar.current
        return filter { entry in
            calendar.isDate(entry.date, equalTo: month, toGranularity: .month)
        }
    }

    /// Count successful days
    var successCount: Int {
        return filter { $0.isSuccess }.count
    }

    /// Count missed days
    var missedCount: Int {
        return filter { !$0.isSuccess }.count
    }

    /// Calculate current streak (consecutive successful days from most recent)
    var currentStreak: Int {
        let sortedByDate = sorted { $0.date > $1.date }
        var streak = 0
        for entry in sortedByDate {
            if entry.isSuccess {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    /// Get longest streak of successful days
    var longestStreak: Int {
        let sortedByDate = sorted { $0.date < $1.date }
        var longest = 0
        var current = 0
        for entry in sortedByDate {
            if entry.isSuccess {
                current += 1
                longest = Swift.max(longest, current)
            } else {
                current = 0
            }
        }
        return longest
    }
}
