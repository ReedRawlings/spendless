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
    @State private var showToolsList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title
                    Text(AppConstants.isScreenshotMode ? ScreenshotDataHelper.learnPageTitle : "Get Educated")
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
                            title: AppConstants.isScreenshotMode ? ScreenshotDataHelper.learnCards[0].title : "Learn",
                            subtitle: AppConstants.isScreenshotMode ? ScreenshotDataHelper.learnCards[0].subtitle : nil,
                            animationName: "brain",
                            isEnabled: true
                        ) {
                            HapticFeedback.buttonTap()
                            showLessonsList = true
                        }
                        
                        // Podcasts - Coming Soon
                        EducationSquareCard(
                            title: AppConstants.isScreenshotMode ? ScreenshotDataHelper.learnCards[1].title : "Podcasts",
                            subtitle: AppConstants.isScreenshotMode ? ScreenshotDataHelper.learnCards[1].subtitle : nil,
                            animationName: "podcast",
                            isEnabled: false
                        ) {}
                        
                        // Articles - Coming Soon
                        EducationSquareCard(
                            title: AppConstants.isScreenshotMode ? ScreenshotDataHelper.learnCards[2].title : "Articles",
                            subtitle: AppConstants.isScreenshotMode ? ScreenshotDataHelper.learnCards[2].subtitle : nil,
                            animationName: "pencil",
                            isEnabled: false
                        ) {}
                        
                        // Tools - Active
                        EducationSquareCard(
                            title: AppConstants.isScreenshotMode ? ScreenshotDataHelper.learnCards[3].title : "Tools",
                            subtitle: AppConstants.isScreenshotMode ? ScreenshotDataHelper.learnCards[3].subtitle : nil,
                            animationName: "tool",
                            isEnabled: true
                        ) {
                            HapticFeedback.buttonTap()
                            showToolsList = true
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    
                    Spacer()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showLessonsList) {
                LessonsListView()
            }
            .navigationDestination(isPresented: $showToolsList) {
                ToolsListView()
            }
        }
    }
}

// MARK: - Education Square Card

struct EducationSquareCard: View {
    let title: String
    let subtitle: String?
    let animationName: String
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(title: String, subtitle: String? = nil, animationName: String, isEnabled: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.animationName = animationName
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                HapticFeedback.buttonTap()
                action()
            }
        }) {
            VStack(spacing: SpendLessSpacing.sm) {
                // Lottie animation - reduce size slightly in screenshot mode to make room for text
                LottieAnimationView(animationName: animationName)
                    .frame(height: AppConstants.isScreenshotMode ? 100 : 120)
                    .opacity(isEnabled ? 1.0 : 0.5)
                
                // Title - allow wrapping for screenshot mode keywords
                Text(title)
                    .font(AppConstants.isScreenshotMode ? SpendLessFont.headline : SpendLessFont.title3)
                    .foregroundStyle(isEnabled ? Color.spendLessTextPrimary : Color.spendLessTextMuted)
                    .multilineTextAlignment(.center)
                    .lineLimit(AppConstants.isScreenshotMode ? 3 : 2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, SpendLessSpacing.xs)
                
                // Subtitle (for screenshot mode)
                if let subtitle {
                    Text(subtitle)
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, SpendLessSpacing.xs)
                }
                
                // Coming soon badge
                if !isEnabled && subtitle == nil {
                    Text("Soon")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .padding(AppConstants.isScreenshotMode ? SpendLessSpacing.md : SpendLessSpacing.xl)
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
