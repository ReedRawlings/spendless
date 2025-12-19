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
    let currentStep: Int
    let totalSteps: Int

    private var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }

    var body: some View {
        HStack(spacing: SpendLessSpacing.sm) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.spendLessBackgroundSecondary)
                        .frame(height: 4)

                    // Gradient fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(progressGradient)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 4)

            // Step count
            Text("\(currentStep)/\(totalSteps)")
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextMuted)
                .monospacedDigit()
        }
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
    @Environment(\.dismiss) private var dismiss
    let step: OnboardingCoordinatorView.OnboardingStep
    let content: Content

    private let totalSteps = OnboardingCoordinatorView.OnboardingStep.allCases.count

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
                // Navigation row: back button + progress bar
                HStack(spacing: SpendLessSpacing.md) {
                    // Back button - simple chevron
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }

                    // Progress bar with step count
                    OnboardingProgressView(
                        currentStep: step.rawValue + 1,
                        totalSteps: totalSteps
                    )
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.top, SpendLessSpacing.sm)
                .padding(.bottom, SpendLessSpacing.sm)

                content
            }
        }
        .navigationBarBackButtonHidden(true)
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

