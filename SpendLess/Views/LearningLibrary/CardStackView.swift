//
//  CardStackView.swift
//  SpendLess
//
//  Card stack view for learning dark pattern cards with flip animations
//

import SwiftUI

struct CardStackView: View {
    @Environment(\.dismiss) private var environmentDismiss
    @State private var cardService = LearningCardService.shared
    
    let startingCard: DarkPatternCard?
    let onDismiss: (() -> Void)?
    
    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1
    @State private var showCompletion: Bool = false
    
    init(startingCard: DarkPatternCard? = nil, onDismiss: (() -> Void)? = nil) {
        self.startingCard = startingCard
        self.onDismiss = onDismiss
    }
    
    private func dismiss() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            environmentDismiss()
        }
    }
    
    private var availableCards: [DarkPatternCard] {
        cardService.getAvailableCards()
    }
    
    private var allCards: [DarkPatternCard] {
        cardService.getAllCards()
    }
    
    private var isReviewMode: Bool {
        cardService.allCardsCompleted
    }
    
    private var cardsToUse: [DarkPatternCard] {
        isReviewMode ? allCards : availableCards
    }
    
    private var currentCard: DarkPatternCard? {
        guard currentIndex < cardsToUse.count else { return nil }
        return cardsToUse[currentIndex]
    }
    
    private var totalCards: Int {
        cardsToUse.count
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            if showCompletion {
                completionView
            } else if let card = currentCard {
                VStack {
                    Spacer()
                    // Card
                    cardView(card)
                        .offset(x: cardOffset)
                        .opacity(cardOpacity)
                    Spacer()
                }
                .padding(SpendLessSpacing.md)
            } else {
                // No cards available
                noCardsView
            }
        }
        .onAppear {
            // Find the index of the starting card if provided
            if let startingCard = startingCard {
                if let index = cardsToUse.firstIndex(where: { $0.id == startingCard.id }) {
                    currentIndex = index
                    // Start with card flipped (showing back) when coming from list
                    isFlipped = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Card View
    
    @ViewBuilder
    private func cardView(_ card: DarkPatternCard) -> some View {
        // If coming from list (startingCard provided), show back directly
        if startingCard != nil {
            cardBack(card)
        } else {
            // Otherwise, use flip card with tap gesture
            FlipCard(
                isFlipped: $isFlipped,
                isCompleted: card.isLearned
            ) {
                // Front of card
                cardFront(card)
            } back: {
                // Back of card
                cardBack(card)
            }
            .onTapGesture {
                if !isFlipped {
                    withAnimation {
                        isFlipped = true
                    }
                }
            }
        }
    }
    
    // MARK: - Card Front
    
    private func cardFront(_ card: DarkPatternCard) -> some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Spacer()
            
            // Icon
            Text(card.icon)
                .font(.system(size: 80))
            
            // Name
            Text(card.name.uppercased())
                .font(SpendLessFont.title)
                .foregroundStyle(Color.spendLessTextPrimary)
                .multilineTextAlignment(.center)
            
            // Tactic example
            Text(card.tactic)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            
            // Tap hint
            HStack(spacing: SpendLessSpacing.xs) {
                Image(systemName: "hand.tap")
                    .font(.caption)
                Text("Tap to learn more")
                    .font(SpendLessFont.caption)
            }
            .foregroundStyle(Color.spendLessTextMuted)
            .padding(.bottom, SpendLessSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(SpendLessSpacing.xl)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
        .spendLessShadow(SpendLessShadow.cardShadow)
    }
    
    // MARK: - Card Back
    
    private func cardBack(_ card: DarkPatternCard) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpendLessSpacing.lg) {
                // Why It Works Section
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    Text("WHY IT WORKS")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessPrimary)
                    
                    Text(card.explanation)
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .lineSpacing(4)
                }
                
                // Reframe Section
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    Text("NEXT TIME YOU SEE THIS")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessPrimary)
                    
                    Text(card.reframe)
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .italic()
                }
                
                // Reduced spacing before button
                Spacer(minLength: SpendLessSpacing.sm)
                
                // Confirmation button (only show if not in review mode or card not learned)
                if !isReviewMode || !card.isLearned {
                    PrimaryButton("I understand") {
                        confirmUnderstanding(card)
                    }
                } else {
                    // Review mode - show reviewed state
                    HStack {
                        Spacer()
                        HStack(spacing: SpendLessSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.spendLessSuccess)
                            Text("Already learned")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                        Spacer()
                    }
                    
                    // Next card button in review mode
                    if currentIndex < totalCards - 1 {
                        SecondaryButton("Next Card", icon: "arrow.right") {
                            goToNextCard()
                        }
                    }
                }
            }
            .padding(SpendLessSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
        .spendLessShadow(SpendLessShadow.cardShadow)
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            Text("🏆")
                .font(.system(size: 80))
            
            Text("Well done!")
                .font(SpendLessFont.largeTitle)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("You've learned all the dark patterns.\nYou're now armed against their tricks.")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            PrimaryButton("Done") {
                dismiss()
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .padding(SpendLessSpacing.md)
    }
    
    // MARK: - No Cards View
    
    private var noCardsView: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Spacer()
            
            Text("📚")
                .font(.system(size: 60))
            
            Text("All caught up!")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("You've completed all available lessons.\nCheck back later for new content.")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            SecondaryButton("Go Back") {
                dismiss()
            }
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .padding(SpendLessSpacing.md)
    }
    
    // MARK: - Actions
    
    private func confirmUnderstanding(_ card: DarkPatternCard) {
        // Mark card as learned
        cardService.markCardAsLearned(card)
        
        // Success haptic
        HapticFeedback.celebration()
        
        // Animate to next card
        goToNextCard()
    }
    
    private func goToNextCard() {
        // Check if this was the last card
        if currentIndex >= cardsToUse.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                showCompletion = true
            }
            return
        }
        
        // Animate current card out
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = -UIScreen.main.bounds.width
            cardOpacity = 0
        }
        
        // After animation, reset and show next card
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            isFlipped = false
            cardOffset = UIScreen.main.bounds.width
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                cardOffset = 0
                cardOpacity = 1
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CardStackView()
    }
    .environment(AppState.shared)
}

