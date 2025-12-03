//
//  LessonsListView.swift
//  SpendLess
//
//  List view showing all available lessons
//

import SwiftUI

// MARK: - Custom Transition

extension AnyTransition {
    static var flipAndExpand: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: FlipExpandModifier(rotation: 90, scale: 0.3, opacity: 0),
                identity: FlipExpandModifier(rotation: 0, scale: 1, opacity: 1)
            ),
            removal: .modifier(
                active: FlipExpandModifier(rotation: -90, scale: 0.3, opacity: 0),
                identity: FlipExpandModifier(rotation: 0, scale: 1, opacity: 1)
            )
        )
    }
}

struct FlipExpandModifier: ViewModifier {
    let rotation: Double
    let scale: CGFloat
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .scaleEffect(scale)
            .opacity(opacity)
    }
}

struct LessonsListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cardService = LearningCardService.shared
    @State private var selectedCard: DarkPatternCard?
    @State private var showCardStack = false
    @Namespace private var cardNamespace
    
    private var allCards: [DarkPatternCard] {
        cardService.getAllCards()
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            if showCardStack {
                if let selectedCard {
                    CardStackView(startingCard: selectedCard, onDismiss: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCardStack = false
                        }
                    })
                    .transition(.flipAndExpand)
                    .zIndex(1)
                } else {
                    CardStackView(onDismiss: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCardStack = false
                        }
                    })
                    .transition(.flipAndExpand)
                    .zIndex(1)
                }
            } else {
                ScrollView {
                    VStack(spacing: SpendLessSpacing.md) {
                        // Header
                        header
                        
                        // Progress summary
                        progressSummary
                        
                        // Lessons list
                        lessonsList
                    }
                    .padding(SpendLessSpacing.md)
                }
                .zIndex(0)
            }
        }
        .navigationTitle(showCardStack ? (selectedCard?.name ?? "") : "Lessons")
        .navigationBarTitleDisplayMode(showCardStack ? .inline : .large)
        .navigationBarBackButtonHidden(showCardStack)
        .toolbar {
            if showCardStack {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCardStack = false
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.spendLessPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            Text("Dark Patterns")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("Learn to recognize the tricks retailers use")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Progress Summary
    
    private var progressSummary: some View {
        Card {
            VStack(spacing: SpendLessSpacing.sm) {
                HStack {
                    Text("Progress")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Spacer()
                    
                    Text("\(cardService.completedCount)/\(cardService.totalCount)")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessPrimary)
                }
                
                ProgressBar(progress: cardService.progress)
            }
        }
    }
    
    // MARK: - Lessons List
    
    private var lessonsList: some View {
        VStack(spacing: SpendLessSpacing.sm) {
            ForEach(allCards) { card in
                LessonRow(card: card) {
                    selectedCard = card
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showCardStack = true
                    }
                }
            }
        }
    }
}

// MARK: - Lesson Row

struct LessonRow: View {
    let card: DarkPatternCard
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticFeedback.buttonTap()
            action()
        }) {
            HStack(spacing: SpendLessSpacing.md) {
                // Icon
                Text(card.icon)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color.spendLessBackgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    .opacity(card.isLearned ? 0.6 : 1.0)
                
                // Content
                VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                    HStack {
                        Text(card.name)
                            .font(SpendLessFont.bodyBold)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        if card.isLearned {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.spendLessSuccess)
                        }
                    }
                    
                    Text(card.tactic)
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
            .spendLessShadow(SpendLessShadow.subtleShadow)
            .opacity(card.isLearned ? 0.6 : 1.0)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LessonsListView()
    }
    .environment(AppState.shared)
}

