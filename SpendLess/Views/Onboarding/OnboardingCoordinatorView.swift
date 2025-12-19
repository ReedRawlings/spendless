//
//  OnboardingCoordinatorView.swift
//  SpendLess
//
//  Onboarding flow coordinator - 13 screens (streamlined flow)
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
        case aboutYou
        case theCost
        case psychology
        case futureYou
        case yourGoal
        case howItWorks
        case firstResist
        case stayCommitted
        case screenTimeAccess
        case blockApps
        case ready
        case paywall

        var progress: Double {
            Double(rawValue + 1) / Double(Self.allCases.count)
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            OnboardingWelcomeView {
                navigateTo(.aboutYou)
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
            OnboardingWelcomeView { navigateTo(.aboutYou) }

        case .aboutYou:
            OnboardingContainer(step: .aboutYou) {
                AboutYouView { navigateTo(.theCost) }
            }

        case .theCost:
            OnboardingContainer(step: .theCost) {
                TheCostView { navigateTo(.psychology) }
            }

        case .psychology:
            PsychologyView { navigateTo(.futureYou) }

        case .futureYou:
            FutureYouView { navigateTo(.yourGoal) }

        case .yourGoal:
            OnboardingContainer(step: .yourGoal) {
                YourGoalView { navigateTo(.howItWorks) }
            }

        case .howItWorks:
            OnboardingContainer(step: .howItWorks) {
                HowItWorksSimpleView { navigateTo(.firstResist) }
            }

        case .firstResist:
            OnboardingContainer(step: .firstResist) {
                FirstResistView { navigateTo(.stayCommitted) }
            }

        case .stayCommitted:
            OnboardingContainer(step: .stayCommitted) {
                StayCommittedView { navigateTo(.screenTimeAccess) }
            }

        case .screenTimeAccess:
            OnboardingPermissionView { navigateTo(.blockApps) }

        case .blockApps:
            OnboardingAppSelectionView { navigateTo(.ready) }

        case .ready:
            OnboardingContainer(step: .ready) {
                ReadyView { navigateTo(.paywall) }
            }

        case .paywall:
            SpendLessPaywallView(onComplete: {
                completeOnboarding()
            })
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

