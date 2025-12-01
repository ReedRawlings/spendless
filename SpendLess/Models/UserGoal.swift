//
//  UserGoal.swift
//  SpendLess
//
//  Core goal tracking model
//

import Foundation
import SwiftData

@Model
final class UserGoal {
    var id: UUID
    var name: String
    var targetAmount: Decimal
    var savedAmount: Decimal
    var imageData: Data?
    var createdAt: Date
    var goalType: String // Stored as raw value of GoalType
    var isActive: Bool
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Decimal,
        savedAmount: Decimal = 0,
        imageData: Data? = nil,
        createdAt: Date = Date(),
        goalType: GoalType = .justStop,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.savedAmount = savedAmount
        self.imageData = imageData
        self.createdAt = createdAt
        self.goalType = goalType.rawValue
        self.isActive = isActive
    }
    
    // MARK: - Computed Properties
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        let progress = (savedAmount as NSDecimalNumber).doubleValue / (targetAmount as NSDecimalNumber).doubleValue
        return min(max(progress, 0), 1)
    }
    
    var progressPercentage: Int {
        return Int(progress * 100)
    }
    
    var remainingAmount: Decimal {
        return max(targetAmount - savedAmount, 0)
    }
    
    var isCompleted: Bool {
        return savedAmount >= targetAmount
    }
    
    var type: GoalType {
        return GoalType(rawValue: goalType) ?? .justStop
    }
    
    // MARK: - Methods
    
    func addSavings(_ amount: Decimal) {
        savedAmount += amount
        if isCompleted && completedAt == nil {
            completedAt = Date()
        }
    }
    
    func resetSavings() {
        savedAmount = 0
        completedAt = nil
    }
    
    /// Translates savings into meaningful equivalents based on goal
    func savingsTranslation(for amount: Decimal) -> String? {
        guard !name.isEmpty else { return nil }
        
        // Calculate what percentage this amount represents
        guard targetAmount > 0 else { return nil }
        let percentage = (amount as NSDecimalNumber).doubleValue / (targetAmount as NSDecimalNumber).doubleValue * 100
        
        if percentage >= 1 {
            return String(format: "+%.0f%% closer to \(name)", percentage)
        }
        return nil
    }
}

// MARK: - Sample Data

extension UserGoal {
    static var sampleGoal: UserGoal {
        UserGoal(
            name: "Trip to Paris",
            targetAmount: 4500,
            savedAmount: 1247,
            goalType: .vacation
        )
    }
    
    static var emptyGoal: UserGoal {
        UserGoal(
            name: "",
            targetAmount: 0,
            goalType: .justStop
        )
    }
}

