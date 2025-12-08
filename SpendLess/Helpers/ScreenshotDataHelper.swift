//
//  ScreenshotDataHelper.swift
//  SpendLess
//
//  Helper for screenshot demo mode - provides fake/seeded data for App Store screenshots
//  This file should be deleted or the flag disabled after screenshots are captured
//

import Foundation
import SwiftData

/// Helper class for screenshot demo mode data
/// Only used when AppConstants.isScreenshotMode is true
struct ScreenshotDataHelper {
    
    // MARK: - Dashboard Data
    
    static let dashboardTotalSaved: Decimal = 347
    static let dashboardSavingsLabel = "saved from impulse buys"
    static let dashboardSavingsDescription = "Money you didn't spend on things you didn't need"
    static let dashboardStreakLabel = "Impulse-Free Streak"
    static let dashboardStreakValue = 23
    static let dashboardThisWeekValue: Decimal = 89
    static let dashboardResistedValue = 7
    static let feelingTemptedSubhead = "Urge to shop?"
    
    // MARK: - Goal Data (Optional - for goal card)
    
    static let goalName = "Paris Trip"
    static let goalTargetAmount: Decimal = 3000
    static let goalSavedAmount: Decimal = 1740
    static let goalProgressPercentage: Int = 58
    
    // MARK: - Waiting List Data
    
    static let waitingListTotal: Decimal = 247
    static let waitingListItemCount = 4
    static let waitingListBuyRate = "12% buy rate"
    
    /// Seeded waiting list items for screenshot mode
    /// These match the PRD specifications exactly
    static func screenshotWaitingListItems() -> [WaitingListItem] {
        let calendar = Calendar.current
        let now = Date()
        
        let item1 = WaitingListItem(
            name: "Amazon - Wireless Earbuds",
            amount: 79,
            reason: "It's on sale / good deal",
            addedAt: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
            reasonWanted: .onSale
        )
        item1.pricePerWearEstimate = 12 // For "$6.58 per use (12 uses)"
        
        let item2 = WaitingListItem(
            name: "Sephora - Skincare Set",
            amount: 65,
            reason: "Retail therapy",
            addedAt: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
            reasonWanted: .treatMyself
        )
        item2.pricePerWearEstimate = 30 // For "$2.17 per use (30 uses)"
        
        let item3 = WaitingListItem(
            name: "Target - Throw Pillows",
            amount: 54,
            reason: "Home refresh",
            addedAt: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
            reasonWanted: .wantedForAWhile
        )
        item3.pricePerWearEstimate = 365 // For "$0.15 per use (365 uses)"
        
        let item4 = WaitingListItem(
            name: "Shein - Summer Dress",
            amount: 49,
            reason: "TikTok find",
            addedAt: calendar.date(byAdding: .day, value: -6, to: now) ?? now,
            reasonWanted: .socialMedia
        )
        item4.pricePerWearEstimate = 10 // For "$4.90 per use (10 uses)"
        
        return [item1, item2, item3, item4]
    }
    
    /// Returns the PRD-specified real-life equivalent for screenshot items
    /// These override the dynamic calculation for screenshot mode
    static func screenshotEquivalent(for itemName: String) -> String? {
        switch itemName {
        case "Amazon - Wireless Earbuds":
            return "3 lunches out"
        case "Sephora - Skincare Set":
            return "1 month of streaming"
        case "Target - Throw Pillows":
            return "2 movie tickets"
        case "Shein - Summer Dress":
            return "nice dinner out"
        default:
            return nil
        }
    }
    
    // MARK: - Learn Section Data
    
    static let learnPageTitle = "Learn to Stop Impulse Spending"
    
    struct LearnCard {
        let title: String
        let subtitle: String
    }
    
    static let learnCards: [LearnCard] = [
        LearnCard(
            title: "Dopamine",
            subtitle: "Why you can't stop buying"
        ),
        LearnCard(
            title: "Mindful",
            subtitle: "Curated episodes"
        ),
        LearnCard(
            title: "Habits",
            subtitle: "Tips that actually work"
        ),
        LearnCard(
            title: "Self Control",
            subtitle: "Calculators & exercises"
        )
    ]
}

