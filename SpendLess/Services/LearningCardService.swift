//
//  LearningCardService.swift
//  SpendLess
//
//  Service for managing dark pattern education cards
//

import Foundation

/// Service for managing dark pattern education cards
/// For V1, cards are stored in static data. Future versions will migrate to SwiftData.
@Observable
final class LearningCardService {
    
    // MARK: - Singleton
    static let shared = LearningCardService()
    
    // MARK: - State
    
    /// All cards with their current learned state
    private(set) var cards: [DarkPatternCard]
    
    // MARK: - UserDefaults Keys
    
    private enum UserDefaultsKeys {
        static let learnedCards = "learnedCardsData"
    }
    
    // MARK: - Initialization
    
    private init() {
        // Start with all cards from static data
        cards = DarkPatternCard.allCards
        
        // Load learned state from UserDefaults
        loadLearnedState()
    }
    
    // MARK: - Public Methods
    
    /// Get all cards sorted by original order
    /// NOTE: Future enhancement - group cards by category when we have more cards
    func getAllCards() -> [DarkPatternCard] {
        cards.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Get cards that are available to learn (not learned, or out of cooldown)
    func getAvailableCards() -> [DarkPatternCard] {
        cards.filter { $0.isAvailable }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Get cards that have been learned
    func getLearnedCards() -> [DarkPatternCard] {
        cards.filter { $0.isLearned }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Get the count of completed cards
    var completedCount: Int {
        cards.filter { $0.isLearned }.count
    }
    
    /// Get total card count
    var totalCount: Int {
        cards.count
    }
    
    /// Get progress as a fraction (0.0 to 1.0)
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    /// Check if all cards have been learned
    var allCardsCompleted: Bool {
        completedCount == totalCount
    }
    
    /// Mark a card as learned
    func markCardAsLearned(_ card: DarkPatternCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].learnedAt = Date()
        saveLearnedState()
    }
    
    /// Reset a card's learned state (for testing/review)
    func resetCard(_ card: DarkPatternCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].learnedAt = nil
        saveLearnedState()
    }
    
    /// Reset all cards (for testing)
    func resetAllCards() {
        for index in cards.indices {
            cards[index].learnedAt = nil
        }
        saveLearnedState()
    }
    
    // MARK: - Persistence
    
    private func saveLearnedState() {
        // Save learned dates keyed by card ID
        var learnedData: [String: Date] = [:]
        for card in cards where card.isLearned {
            learnedData[card.id.uuidString] = card.learnedAt
        }
        
        if let encoded = try? JSONEncoder().encode(learnedData) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.learnedCards)
        }
    }
    
    private func loadLearnedState() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.learnedCards),
              let learnedData = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return
        }
        
        // Apply learned dates to cards
        for index in cards.indices {
            if let learnedDate = learnedData[cards[index].id.uuidString] {
                cards[index].learnedAt = learnedDate
            }
        }
    }
}

