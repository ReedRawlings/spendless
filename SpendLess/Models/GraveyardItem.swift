//
//  GraveyardItem.swift
//  SpendLess
//
//  Resisted/buried purchase model
//

import Foundation
import SwiftData

@Model
final class GraveyardItem {
    var id: UUID
    var name: String
    var amount: Decimal
    var buriedAt: Date
    var originalReason: String?
    var sourceRaw: String // GraveyardSource raw value
    var category: String? // SpendingCategory raw value
    
    // New fields for removal reason capture
    var removalReasonRaw: String? // RemovalReason raw value
    var removalReasonNote: String? // Custom note when "Other" is selected
    
    // Track original waiting list data for analytics
    var originalAddedAt: Date? // When item was originally added to waiting list
    var daysWaitedBeforeBurial: Int? // How many days the item waited
    
    init(
        id: UUID = UUID(),
        name: String,
        amount: Decimal,
        buriedAt: Date = Date(),
        originalReason: String? = nil,
        source: GraveyardSource,
        category: SpendingCategory? = nil,
        removalReason: RemovalReason? = nil,
        removalReasonNote: String? = nil,
        originalAddedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.buriedAt = buriedAt
        self.originalReason = originalReason
        self.sourceRaw = source.rawValue
        self.category = category?.rawValue
        self.removalReasonRaw = removalReason?.rawValue
        self.removalReasonNote = removalReasonNote
        self.originalAddedAt = originalAddedAt
        
        // Calculate days waited if we have the original add date
        if let originalAddedAt {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: originalAddedAt, to: buriedAt)
            self.daysWaitedBeforeBurial = components.day
        } else {
            self.daysWaitedBeforeBurial = nil
        }
    }
    
    // MARK: - Computed Properties
    
    var source: GraveyardSource {
        return GraveyardSource(rawValue: sourceRaw) ?? .manual
    }
    
    var spendingCategory: SpendingCategory? {
        guard let category else { return nil }
        return SpendingCategory(rawValue: category)
    }
    
    var removalReason: RemovalReason? {
        guard let removalReasonRaw else { return nil }
        return RemovalReason(rawValue: removalReasonRaw)
    }
    
    /// Display text for the removal reason
    var removalReasonDisplayText: String? {
        if let removalReason {
            if removalReason == .other, let note = removalReasonNote, !note.isEmpty {
                return note
            }
            return removalReason.displayName
        }
        return nil
    }
    
    var isReturn: Bool {
        return source == .returned
    }
    
    var daysSinceBuried: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: buriedAt, to: Date())
        return components.day ?? 0
    }
    
    var buriedTimeAgoText: String {
        let days = daysSinceBuried
        if days == 0 {
            return "Buried today"
        } else if days == 1 {
            return "Buried yesterday"
        } else {
            return "Buried \(days) days ago"
        }
    }
    
    /// Icon for display based on item name
    var displayIcon: String {
        let nameLower = name.lowercased()
        
        if nameLower.contains("shoe") || nameLower.contains("sneaker") {
            return "👟"
        } else if nameLower.contains("dress") || nameLower.contains("shirt") || nameLower.contains("clothes") {
            return "👗"
        } else if nameLower.contains("headphone") || nameLower.contains("earbud") || nameLower.contains("airpod") {
            return "🎧"
        } else if nameLower.contains("phone") || nameLower.contains("iphone") {
            return "📱"
        } else if nameLower.contains("laptop") || nameLower.contains("computer") || nameLower.contains("macbook") {
            return "💻"
        } else if nameLower.contains("bag") || nameLower.contains("purse") {
            return "👜"
        } else if nameLower.contains("watch") {
            return "⌚"
        } else if nameLower.contains("makeup") || nameLower.contains("lipstick") || nameLower.contains("beauty") {
            return "💄"
        } else if nameLower.contains("pillow") || nameLower.contains("decor") || nameLower.contains("furniture") {
            return "🛋️"
        } else if nameLower.contains("book") {
            return "📚"
        } else if nameLower.contains("game") || nameLower.contains("playstation") || nameLower.contains("xbox") {
            return "🎮"
        } else {
            return "📦"
        }
    }
}

// MARK: - Convenience Initializer from WaitingListItem

extension GraveyardItem {
    convenience init(
        from waitingListItem: WaitingListItem,
        source: GraveyardSource = .waitingList,
        removalReason: RemovalReason? = nil,
        removalReasonNote: String? = nil
    ) {
        self.init(
            name: waitingListItem.name,
            amount: waitingListItem.amount,
            originalReason: waitingListItem.reasonDisplayText,
            source: source,
            category: waitingListItem.spendingCategory,
            removalReason: removalReason,
            removalReasonNote: removalReasonNote,
            originalAddedAt: waitingListItem.addedAt
        )
    }
}

// MARK: - Sample Data

extension GraveyardItem {
    static var sampleItems: [GraveyardItem] {
        [
            GraveyardItem(
                name: "Sony headphones",
                amount: 249,
                buriedAt: Calendar.current.date(byAdding: .day, value: -34, to: Date()) ?? Date(),
                originalReason: "I already have headphones",
                source: .waitingList,
                category: .electronics
            ),
            GraveyardItem(
                name: "Floral dress",
                amount: 47,
                buriedAt: Calendar.current.date(byAdding: .day, value: -21, to: Date()) ?? Date(),
                originalReason: "Don't even remember this",
                source: .panicButton,
                category: .clothing
            ),
            GraveyardItem(
                name: "Throw pillows",
                amount: 89,
                buriedAt: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
                source: .blockIntercept,
                category: .home
            ),
            GraveyardItem(
                name: "That impulse buy dress",
                amount: 67,
                buriedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                originalReason: "Realized I have 3 just like it",
                source: .returned,
                category: .clothing
            )
        ]
    }
}

