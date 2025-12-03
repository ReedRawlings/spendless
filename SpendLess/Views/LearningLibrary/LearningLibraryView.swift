//
//  LearningLibraryView.swift
//  SpendLess
//
//  Learning Library tab - educational content about shopping manipulation tactics
//

import SwiftUI

struct LearningLibraryView: View {
    @State private var cardService = LearningCardService.shared
    @State private var showLessonsList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title
                    Text("Get Educated")
                        .font(SpendLessFont.largeTitle)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, SpendLessSpacing.lg)
                        .padding(.top, SpendLessSpacing.xl)
                        .padding(.bottom, SpendLessSpacing.lg)
                    
                    // Grid of 4 squares
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: SpendLessSpacing.md),
                        GridItem(.flexible(), spacing: SpendLessSpacing.md)
                    ], spacing: SpendLessSpacing.md) {
                        // Learn - Active
                        EducationSquareCard(
                            title: "Learn",
                            animationName: "brain",
                            isEnabled: true
                        ) {
                            HapticFeedback.buttonTap()
                            showLessonsList = true
                        }
                        
                        // Podcasts - Coming Soon
                        EducationSquareCard(
                            title: "Podcasts",
                            animationName: "podcast",
                            isEnabled: false
                        ) {}
                        
                        // Articles - Coming Soon
                        EducationSquareCard(
                            title: "Articles",
                            animationName: "pencil",
                            isEnabled: false
                        ) {}
                        
                        // Tools - Coming Soon
                        EducationSquareCard(
                            title: "Tools",
                            animationName: "tool",
                            isEnabled: false
                        ) {}
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showLessonsList) {
                LessonsListView()
            }
        }
    }
}

// MARK: - Education Square Card

struct EducationSquareCard: View {
    let title: String
    let animationName: String
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if isEnabled {
                HapticFeedback.buttonTap()
                action()
            }
        }) {
            VStack(spacing: SpendLessSpacing.md) {
                // Lottie animation
                LottieAnimationView(animationName: animationName)
                    .frame(height: 120)
                    .opacity(isEnabled ? 1.0 : 0.5)
                
                // Title
                Text(title)
                    .font(SpendLessFont.title3)
                    .foregroundStyle(isEnabled ? Color.spendLessTextPrimary : Color.spendLessTextMuted)
                
                // Coming soon badge
                if !isEnabled {
                    Text("Soon")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .padding(SpendLessSpacing.xl)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
            .spendLessShadow(SpendLessShadow.cardShadow)
            .opacity(isEnabled ? 1.0 : 0.7)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        .disabled(!isEnabled)
    }
}

// MARK: - Preview

#Preview {
    LearningLibraryView()
        .environment(AppState.shared)
}
