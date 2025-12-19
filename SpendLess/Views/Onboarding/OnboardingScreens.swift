//
//  OnboardingScreens.swift
//  SpendLess
//
//  Core onboarding screens (welcome) and shared components
//

import SwiftUI
import SwiftData

// MARK: - Screen 1: Welcome

struct OnboardingWelcomeView: View {
    let onContinue: () -> Void

    @State private var iconVisible = false
    @State private var headlineVisible = false
    @State private var subtitleVisible = false
    @State private var buttonVisible = false
    @State private var hasAnimated = false

    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()

            VStack(spacing: SpendLessSpacing.xl) {
                Spacer()

                // Illustration
                LottieAnimationView(animationName: "cart")
                    .frame(height: 300)
                    .opacity(iconVisible ? 1 : 0)
                    .scaleEffect(iconVisible ? 1 : 0.8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: iconVisible)

                VStack(spacing: SpendLessSpacing.md) {
                    Text("Your impulse shopping stops here.")
                        .font(SpendLessFont.title)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(headlineVisible ? 1 : 0)
                        .offset(y: headlineVisible ? 0 : 10)
                        .animation(.easeOut(duration: 0.4), value: headlineVisible)

                    Text("We'll help you pause, resist, and save for what actually matters.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(subtitleVisible ? 1 : 0)
                        .offset(y: subtitleVisible ? 0 : 10)
                        .animation(.easeOut(duration: 0.4), value: subtitleVisible)
                }
                .padding(.horizontal, SpendLessSpacing.lg)

                Spacer()

                PrimaryButton("Start fresh", icon: "arrow.right") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
                .opacity(buttonVisible ? 1 : 0)
                .scaleEffect(buttonVisible ? 1 : 0.95)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: buttonVisible)
            }
        }
        .onAppear {
            guard !hasAnimated else { return }
            hasAnimated = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                iconVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                headlineVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                subtitleVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                buttonVisible = true
            }
        }
    }
}

// MARK: - Meaning Chip Component

struct MeaningChip: View {
    let icon: String
    let text: String
    let isVisible: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: SpendLessSpacing.sm) {
                Text(icon)
                    .font(.title3)

                Text(text)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)

                Spacer()
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(Color.spendLessPrimary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
    }
}

// MARK: - Goal-Specific Content Helper

struct GoalSpecificContent {
    let introText: String
    let meaningPhrases: [(icon: String, text: String)]
    let amountLabel: String
    let placeholder: String

    static func content(for goalType: GoalType, goalName: String = "") -> GoalSpecificContent {
        switch goalType {
        case .emergency:
            return GoalSpecificContent(
                introText: "An emergency fund means...",
                meaningPhrases: [
                    ("🛡️", "A real safety net"),
                    ("😮‍💨", "Breathing room when life happens"),
                    ("😴", "Sleeping without money anxiety")
                ],
                amountLabel: "How much will make you feel secure?",
                placeholder: "e.g., \"Never panicking about bills\""
            )
        case .vacation:
            return GoalSpecificContent(
                introText: goalName.isEmpty ? "A dream vacation means..." : "A trip to \(goalName) means...",
                meaningPhrases: [
                    ("✨", "Experiences over things"),
                    ("📸", "Memories you'll actually keep"),
                    ("🎯", "Finally doing that thing you keep saying you'll do")
                ],
                amountLabel: "What's your trip budget?",
                placeholder: "e.g., \"Making memories that last\""
            )
        case .debtFree:
            return GoalSpecificContent(
                introText: "Being debt free means...",
                meaningPhrases: [
                    ("💵", "Your paycheck is actually yours"),
                    ("😌", "No more \"minimum payment\" dread"),
                    ("🆓", "Freedom to say yes to what matters")
                ],
                amountLabel: "How much are you paying off?",
                placeholder: "e.g., \"Financial freedom\""
            )
        case .downPayment, .car, .bigPurchase:
            return GoalSpecificContent(
                introText: goalName.isEmpty ? "Saving for this means..." : "Saving for \(goalName) means...",
                meaningPhrases: [
                    ("💰", "Buying it outright, no interest"),
                    ("😊", "The satisfaction of earning it"),
                    ("🎉", "No buyer's remorse, just pride")
                ],
                amountLabel: "How much do you need?",
                placeholder: "e.g., \"Buying it the right way\""
            )
        case .retirement:
            return GoalSpecificContent(
                introText: "Retirement means...",
                meaningPhrases: [
                    ("🌴", "Freedom to choose how you spend your time"),
                    ("💎", "Security for your future self"),
                    ("🎯", "Living life on your terms")
                ],
                amountLabel: "What's your retirement goal?",
                placeholder: "e.g., \"Financial independence\""
            )
        case .justStop:
            return GoalSpecificContent(
                introText: "Keeping your money means...",
                meaningPhrases: [
                    ("🛑", "Stuff stops owning you"),
                    ("🙏", "Your future self will thank you"),
                    ("💪", "Spending on purpose, not impulse")
                ],
                amountLabel: "What's your first savings target?",
                placeholder: "e.g., \"Breaking the cycle\""
            )
        }
    }
}

// MARK: - Preview

#Preview("Welcome") {
    OnboardingWelcomeView(onContinue: {})
}
