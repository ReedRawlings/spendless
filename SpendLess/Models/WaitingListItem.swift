//
//  WaitingListItem.swift
//  SpendLess
//
//  7-day waiting list item model
//

import Foundation
import SwiftData

@Model
final class WaitingListItem {
    var id: UUID
    var name: String
    var amount: Decimal
    var reason: String?
    var addedAt: Date
    var expiresAt: Date
    var lastCheckinAt: Date?
    var checkinCount: Int
    var category: String? // SpendingCategory raw value
    
    /// Duration in days for the waiting period
    static let waitingPeriodDays: Int = 7
    
    init(
        id: UUID = UUID(),
        name: String,
        amount: Decimal,
        reason: String? = nil,
        addedAt: Date = Date(),
        category: SpendingCategory? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.reason = reason
        self.addedAt = addedAt
        self.expiresAt = Calendar.current.date(
            byAdding: .day,
            value: Self.waitingPeriodDays,
            to: addedAt
        ) ?? addedAt.addingTimeInterval(TimeInterval(Self.waitingPeriodDays * 24 * 60 * 60))
        self.checkinCount = 0
        self.category = category?.rawValue
    }
    
    // MARK: - Computed Properties
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiresAt)
        return max(components.day ?? 0, 0)
    }
    
    var hoursRemaining: Int {
        let components = Calendar.current.dateComponents([.hour], from: Date(), to: expiresAt)
        return max(components.hour ?? 0, 0)
    }
    
    var isExpired: Bool {
        return Date() >= expiresAt
    }
    
    var canBuyGuiltFree: Bool {
        return isExpired
    }
    
    /// Progress through the waiting period (0 to 1)
    var progress: Double {
        let totalDuration = expiresAt.timeIntervalSince(addedAt)
        let elapsed = Date().timeIntervalSince(addedAt)
        return min(max(elapsed / totalDuration, 0), 1)
    }
    
    var spendingCategory: SpendingCategory? {
        guard let category else { return nil }
        return SpendingCategory(rawValue: category)
    }
    
    var daysWaited: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: addedAt, to: Date())
        return max(components.day ?? 0, 0)
    }
    
    /// Formatted time remaining string
    var timeRemainingText: String {
        if daysRemaining > 1 {
            return "\(daysRemaining) days remaining"
        } else if daysRemaining == 1 {
            return "1 day remaining"
        } else if hoursRemaining > 0 {
            return "\(hoursRemaining) hours remaining"
        } else {
            return "Ready to decide!"
        }
    }
    
    // MARK: - Methods
    
    func recordCheckin() {
        checkinCount += 1
        lastCheckinAt = Date()
    }
    
    /// Extend the waiting period by additional days
    func extendWaitingPeriod(days: Int = 2) {
        expiresAt = Calendar.current.date(byAdding: .day, value: days, to: expiresAt) ?? expiresAt
    }
}

// MARK: - Sample Data

extension WaitingListItem {
    static var sampleItems: [WaitingListItem] {
        let item1 = WaitingListItem(
            name: "Wireless earbuds",
            amount: 79,
            reason: "My old ones broke",
            addedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        )
        
        let item2 = WaitingListItem(
            name: "Running shoes",
            amount: 120,
            reason: "Training for a 5K",
            addedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
        )
        
        let item3 = WaitingListItem(
            name: "Decorative throw pillows",
            amount: 45,
            addedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        )
        
        return [item1, item2, item3]
    }
}

