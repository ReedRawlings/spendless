//
//  WaitingListHelpers.swift
//  SpendLess
//
//  Helper functions for Waiting List statistics and real-life equivalents
//

import Foundation

// MARK: - Real-Life Equivalents

/// Converts an amount to a relatable real-life equivalent
/// Uses contextual comparisons based on amount thresholds
func realLifeEquivalent(for amount: Decimal) -> String {
    let doubleAmount = NSDecimalNumber(decimal: amount).doubleValue
    
    // Pick one comparison contextually based on amount
    if doubleAmount < 10 {
        let coffees = max(1, Int(round(doubleAmount / 5)))
        return coffees == 1 ? "1 coffee" : "\(coffees) coffees"
    } else if doubleAmount < 30 {
        let lunches = max(1, Int(round(doubleAmount / 15)))
        return lunches == 1 ? "1 lunch out" : "\(lunches) lunches out"
    } else if doubleAmount < 75 {
        let weeks = max(1, Int(round(doubleAmount / 50)))
        return weeks == 1 ? "1 week of groceries" : "\(weeks) weeks of groceries"
    } else if doubleAmount < 150 {
        let dinners = max(1, Int(round(doubleAmount / 100)))
        return dinners == 1 ? "1 nice dinner for two" : "\(dinners) nice dinners"
    } else {
        let getaways = max(1, Int(round(doubleAmount / 200)))
        return getaways == 1 ? "1 weekend getaway" : "\(getaways) weekend getaways"
    }
}

// MARK: - Waiting List Statistics

struct WaitingListStats {
    let totalValueWaiting: Decimal
    let itemCount: Int
    let purchaseRate: Double? // nil if no data
    let averageWaitDaysBuy: Int? // nil if no purchases
    let averageWaitDaysBury: Int? // nil if no burials
    let totalBuried: Int
    let totalPurchased: Int
    
    var purchaseRateText: String? {
        guard let rate = purchaseRate else { return nil }
        return "\(Int(round(rate * 100)))%"
    }
    
    var hasEnoughDataForStats: Bool {
        return totalBuried + totalPurchased > 0
    }
}

/// Calculates waiting list statistics from current items and graveyard history
/// - Parameters:
///   - waitingItems: Current items in the waiting list
///   - graveyardItems: Items that have been buried (from waiting list source)
///   - purchasedItems: Items that were purchased (tracked separately)
/// - Returns: WaitingListStats with calculated values
func calculateWaitingListStats(
    waitingItems: [WaitingListItem],
    graveyardItems: [GraveyardItem],
    purchasedItems: [PurchasedWaitingListItem] = []
) -> WaitingListStats {
    // Total value of items currently waiting
    let totalValue = waitingItems.reduce(Decimal.zero) { $0 + $1.amount }
    
    // Filter graveyard items that came from waiting list
    let buriedFromWaitingList = graveyardItems.filter { $0.source == .waitingList }
    let totalBuried = buriedFromWaitingList.count
    let totalPurchased = purchasedItems.count
    
    // Calculate purchase rate: bought / (bought + buried)
    let totalDecisions = totalBuried + totalPurchased
    let purchaseRate: Double? = totalDecisions > 0 
        ? Double(totalPurchased) / Double(totalDecisions) 
        : nil
    
    // Calculate average wait time for buried items
    let buryWaitDays = buriedFromWaitingList.compactMap { $0.daysWaitedBeforeBurial }
    let averageWaitDaysBury: Int? = buryWaitDays.isEmpty 
        ? nil 
        : buryWaitDays.reduce(0, +) / buryWaitDays.count
    
    // Calculate average wait time for purchased items
    let buyWaitDays = purchasedItems.map { $0.daysWaited }
    let averageWaitDaysBuy: Int? = buyWaitDays.isEmpty 
        ? nil 
        : buyWaitDays.reduce(0, +) / buyWaitDays.count
    
    return WaitingListStats(
        totalValueWaiting: totalValue,
        itemCount: waitingItems.count,
        purchaseRate: purchaseRate,
        averageWaitDaysBuy: averageWaitDaysBuy,
        averageWaitDaysBury: averageWaitDaysBury,
        totalBuried: totalBuried,
        totalPurchased: totalPurchased
    )
}

// MARK: - Purchased Item Tracking

/// Lightweight model to track purchased waiting list items for analytics
/// This is separate from GraveyardItem since purchases shouldn't go to graveyard
struct PurchasedWaitingListItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let amount: Decimal
    let addedAt: Date
    let purchasedAt: Date
    let purchaseReasonRaw: String? // PurchaseReason raw value
    
    var daysWaited: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: addedAt, to: purchasedAt)
        return max(components.day ?? 0, 0)
    }
    
    var purchaseReason: PurchaseReason? {
        guard let raw = purchaseReasonRaw else { return nil }
        return PurchaseReason(rawValue: raw)
    }
    
    /// Legacy property for backward compatibility
    var reflection: PurchaseFeeling? {
        // Try to map PurchaseReason back to PurchaseFeeling if needed
        guard let reason = purchaseReason else { return nil }
        switch reason {
        case .genuineNeed: return .genuineNeed
        case .stillImpulsive: return .stillImpulsive
        case .supportsGoal, .wellReflected, .plannedBudgeted, .addsRealValue: return .genuineNeed
        }
    }
    
    init(from item: WaitingListItem, reason: PurchaseReason? = nil) {
        self.id = item.id
        self.name = item.name
        self.amount = item.amount
        self.addedAt = item.addedAt
        self.purchasedAt = item.purchasedAt ?? Date()
        self.purchaseReasonRaw = reason?.rawValue ?? item.purchaseReason?.rawValue
    }
}

// MARK: - Purchased Items Storage

/// Service for persisting purchased items for analytics
/// Uses UserDefaults for simplicity (could be migrated to SwiftData later)
class PurchasedItemsStore {
    static let shared = PurchasedItemsStore()
    
    private let key = "purchasedWaitingListItems"
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    var items: [PurchasedWaitingListItem] {
        guard let data = defaults.data(forKey: key),
              let items = try? JSONDecoder().decode([PurchasedWaitingListItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func add(_ item: PurchasedWaitingListItem) {
        var current = items
        current.append(item)
        save(current)
    }
    
    private func save(_ items: [PurchasedWaitingListItem]) {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
    }
    
    /// Clear all purchased items (for testing/reset)
    func clear() {
        defaults.removeObject(forKey: key)
    }
}

// TODO: Integrate cost-per-use calculator from Tools section

