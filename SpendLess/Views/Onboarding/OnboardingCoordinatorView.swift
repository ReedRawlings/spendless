//
//  OnboardingCoordinatorView.swift
//  SpendLess
//
//  Onboarding flow coordinator - 14 screens
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
        case monthlySpend
        case impactVisualization
        case goalSelection
        case goalDetails
        case commitment
        case permissionExplanation
        case appSelection
        case websiteBlocking
        case selectionConfirmation
        case howItWorks
        case difficultyMode
        
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
            OnboardingTimingView { navigateTo(.problemApps) }
        case .problemApps:
            OnboardingProblemAppsView { navigateTo(.monthlySpend) }
        case .monthlySpend:
            OnboardingMonthlySpendView { navigateTo(.impactVisualization) }
        case .impactVisualization:
            OnboardingImpactView { navigateTo(.goalSelection) }
        case .goalSelection:
            OnboardingGoalSelectionView { navigateTo(.goalDetails) }
        case .goalDetails:
            OnboardingGoalDetailsView { navigateTo(.commitment) }
        case .commitment:
            OnboardingCommitmentView { navigateTo(.permissionExplanation) }
        case .permissionExplanation:
            OnboardingPermissionView { navigateTo(.appSelection) }
        case .appSelection:
            OnboardingAppSelectionView { navigateTo(.websiteBlocking) }
        case .websiteBlocking:
            OnboardingWebsiteBlockingView { navigateTo(.selectionConfirmation) }
        case .selectionConfirmation:
            OnboardingConfirmationView { navigateTo(.howItWorks) }
        case .howItWorks:
            OnboardingHowItWorksView { navigateTo(.difficultyMode) }
        case .difficultyMode:
            OnboardingDifficultyModeView { completeOnboarding() }
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
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.spendLessBackgroundSecondary)
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.spendLessPrimary)
                    .frame(width: geometry.size.width * progress, height: 4)
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: 4)
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
            Color.spendLessBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                OnboardingProgressView(progress: step.progress)
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.top, SpendLessSpacing.sm)
                
                content
            }
        }
        .navigationBarBackButtonHidden(false)
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

