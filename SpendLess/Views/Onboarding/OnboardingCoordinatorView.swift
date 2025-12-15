//
//  OnboardingCoordinatorView.swift
//  SpendLess
//
//  Onboarding flow coordinator - 25 screens (includes 5 Why Change screens)
//

import SwiftUI
import SwiftData

struct OnboardingCoordinatorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentStep: OnboardingStep = .welcome
    @State private var navigationPath = NavigationPath()
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case behaviors
        case timing
        case problemApps
        // Psychology intro
        case psychologyIntro
        // Why Change screens (emotional journey: pain → hope)
        case whyChange1
        case whyChange2
        case whyChange3
        case whyChange4
        case whyChange5
        // Continue flow
        case monthlySpend
        case impactVisualization
        case goalSelection
        case goalDetails
        case desiredOutcomes
        case waitlistExplanation
        case waitlistIntro
        case commitment
        case leadMagnet
        case permissionExplanation
        case appSelection
        case websiteBlocking
        case selectionConfirmation
        case notificationPermission
        case howItWorks
        case shortcutsSetup
        
        var progress: Double {
            Double(rawValue + 1) / Double(Self.allCases.count)
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            OnboardingWelcomeView {
                navigateTo(.behaviors)
            }
            .navigationDestination(for: OnboardingStep.self) { step in
                destinationView(for: step)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            OnboardingWelcomeView { navigateTo(.behaviors) }
        case .behaviors:
            OnboardingBehaviorsView { navigateTo(.timing) }
        case .timing:
            OnboardingTimingView { navigateTo(.psychologyIntro) }
        case .problemApps:
            OnboardingProblemAppsView { navigateTo(.psychologyIntro) } // Disabled but kept for future use
        case .psychologyIntro:
            PsychologyIntroView { navigateTo(.whyChange1) }
        // Why Change screens
        case .whyChange1:
            WhyChange1View { navigateTo(.whyChange2) }
        case .whyChange2:
            WhyChange2View { navigateTo(.whyChange3) }
        case .whyChange3:
            WhyChange3View { navigateTo(.whyChange4) }
        case .whyChange4:
            WhyChange4View { navigateTo(.whyChange5) }
        case .whyChange5:
            WhyChange5View { navigateTo(.monthlySpend) }
        case .monthlySpend:
            OnboardingMonthlySpendView { navigateTo(.impactVisualization) }
        case .impactVisualization:
            OnboardingImpactView { navigateTo(.goalSelection) }
        case .goalSelection:
            OnboardingGoalSelectionView { navigateTo(.goalDetails) }
        case .goalDetails:
            OnboardingGoalDetailsView { navigateTo(.desiredOutcomes) }
        case .desiredOutcomes:
            OnboardingDesiredOutcomesView { navigateTo(.waitlistExplanation) }
        case .waitlistExplanation:
            WaitlistExplanationView { navigateTo(.waitlistIntro) }
        case .waitlistIntro:
            OnboardingWaitlistIntroView { navigateTo(.commitment) }
        case .commitment:
            OnboardingCommitmentView { navigateTo(.leadMagnet) }
        case .leadMagnet:
            OnboardingContainer(step: .leadMagnet) {
                LeadMagnetView(
                    source: .onboarding,
                    onComplete: { navigateTo(.permissionExplanation) },
                    onSkip: { navigateTo(.permissionExplanation) }
                )
            }
        case .permissionExplanation:
            OnboardingPermissionView { navigateTo(.appSelection) }
        case .appSelection:
            OnboardingAppSelectionView { navigateTo(.websiteBlocking) }
        case .websiteBlocking:
            OnboardingWebsiteBlockingView { navigateTo(.selectionConfirmation) }
        case .selectionConfirmation:
            OnboardingConfirmationView { navigateTo(.notificationPermission) }
        case .notificationPermission:
            OnboardingNotificationPermissionView { navigateTo(.howItWorks) }
        case .howItWorks:
            OnboardingHowItWorksView { navigateTo(.shortcutsSetup) }
        case .shortcutsSetup:
            ShortcutsSetupView(
                onComplete: { completeOnboarding() },
                onSkip: { completeOnboarding() }
            )
        }
    }
    
    private func navigateTo(_ step: OnboardingStep) {
        currentStep = step
        navigationPath.append(step)
    }
    
    private func completeOnboarding() {
        appState.finalizeOnboarding(context: modelContext)
    }
}

// MARK: - Progress Indicator

struct OnboardingProgressView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.spendLessBackgroundSecondary)
                    .frame(height: 4)
                
                // Gradient fill that warms as progress increases
                RoundedRectangle(cornerRadius: 2)
                    .fill(progressGradient)
                    .frame(width: geometry.size.width * progress, height: 4)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                
                // Optional: glowing leading edge
                if progress > 0 && progress < 1 {
                    Circle()
                        .fill(Color.spendLessPrimary)
                        .frame(width: 6, height: 6)
                        .blur(radius: 2)
                        .offset(x: geometry.size.width * progress - 3)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
        }
        .frame(height: 4)
    }
    
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.spendLessPrimary.opacity(0.7),
                Color.spendLessPrimary
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Onboarding Container

struct OnboardingContainer<Content: View>: View {
    let step: OnboardingCoordinatorView.OnboardingStep
    let content: Content
    
    init(step: OnboardingCoordinatorView.OnboardingStep, @ViewBuilder content: () -> Content) {
        self.step = step
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Layered warm gradient background
            LinearGradient(
                stops: [
                    .init(color: Color.spendLessBackground, location: 0),
                    .init(color: Color.spendLessBackground.opacity(0.97), location: 0.5),
                    .init(color: Color.warmSand, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                OnboardingProgressView(progress: step.progress)
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.top, SpendLessSpacing.sm)
                
                content
            }
        }
        .navigationBarBackButtonHidden(false)
        .hideKeyboardOnTap()
    }
}

// MARK: - Preview

#Preview {
    OnboardingCoordinatorView()
        .environment(AppState.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self
        ], inMemory: true)
}

