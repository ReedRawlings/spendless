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
    @State private var selectedCategory: String?
    @State private var showCategoryView = false
    @Namespace private var cardNamespace
    
    private var allCategories: [String] {
        cardService.getAllCategories()
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
        .navigationDestination(isPresented: $showCategoryView) {
            CategoryLessonsView(category: selectedCategory ?? "")
        }
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
            Text("Lessons")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("Explore lessons organized by category")
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
            ForEach(allCategories, id: \.self) { category in
                CategoryRow(
                    category: category,
                    cardService: cardService
                ) {
                    selectedCategory = category
                    showCategoryView = true
                }
            }
        }
    }
}

// MARK: - Category Display Name Helper

extension String {
    var categoryDisplayName: String {
        switch self {
        case "dark-patterns": return "Dark Patterns"
        case "behavioral-psychology": return "Behavioral Psychology"
        case "psychological-mechanisms": return "Psychological Mechanisms"
        case "digital-wellness": return "Digital Wellness"
        case "adhd-specific": return "ADHD Specific"
        case "recovery": return "Recovery"
        default:
            // Fallback: capitalize and replace hyphens with spaces
            return self.replacingOccurrences(of: "-", with: " ")
                .split(separator: " ")
                .map { $0.capitalized }
                .joined(separator: " ")
        }
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: String
    let cardService: LearningCardService
    let action: () -> Void
    
    @State private var isPressed = false
    
    private var stats: (total: Int, completed: Int) {
        cardService.getCategoryStats(category)
    }
    
    var body: some View {
        Button(action: {
            HapticFeedback.buttonTap()
            action()
        }) {
            HStack(spacing: SpendLessSpacing.md) {
                // Category icon/indicator
                VStack {
                    Text("📚")
                        .font(.system(size: 32))
                }
                .frame(width: 60, height: 60)
                .background(Color.spendLessBackgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                
                // Content
                VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                    Text(category.categoryDisplayName)
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("\(stats.completed)/\(stats.total) lessons completed")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
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
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
}

// MARK: - Category Lessons View

struct CategoryLessonsView: View {
    let category: String
    @State private var cardService = LearningCardService.shared
    @State private var selectedCard: DarkPatternCard?
    @State private var showCardStack = false
    
    private var categoryCards: [DarkPatternCard] {
        cardService.getCardsByCategory(category)
    }
    
    private var stats: (total: Int, completed: Int) {
        cardService.getCategoryStats(category)
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
                        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                            Text(category.categoryDisplayName)
                                .font(SpendLessFont.title2)
                                .foregroundStyle(Color.spendLessTextPrimary)
                            
                            Text("\(stats.completed)/\(stats.total) lessons completed")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Progress summary
                        Card {
                            VStack(spacing: SpendLessSpacing.sm) {
                                HStack {
                                    Text("Progress")
                                        .font(SpendLessFont.headline)
                                        .foregroundStyle(Color.spendLessTextPrimary)
                                    
                                    Spacer()
                                    
                                    Text("\(stats.completed)/\(stats.total)")
                                        .font(SpendLessFont.headline)
                                        .foregroundStyle(Color.spendLessPrimary)
                                }
                                
                                let progress = stats.total > 0 ? Double(stats.completed) / Double(stats.total) : 0.0
                                ProgressBar(progress: progress)
                            }
                        }
                        
                        // Lessons list
                        VStack(spacing: SpendLessSpacing.sm) {
                            ForEach(categoryCards) { card in
                LessonRow(card: card) {
                    selectedCard = card
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showCardStack = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(SpendLessSpacing.md)
                }
                .zIndex(0)
            }
        }
        .navigationTitle(showCardStack ? (selectedCard?.name ?? "") : category.categoryDisplayName)
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

// MARK: - Preview

#Preview {
    NavigationStack {
        LessonsListView()
    }
    .environment(AppState.shared)
}

