//
//  GoalProgressView.swift
//  SpendLess
//
//  Visual goal display with image and progress
//

import SwiftUI

struct GoalProgressView: View {
    let goal: UserGoal?
    let totalSaved: Decimal
    let showFullView: Bool
    let isMinimized: Bool
    let onSetGoal: (() -> Void)?

    init(goal: UserGoal?, totalSaved: Decimal = 0, showFullView: Bool = true, isMinimized: Bool = false, onSetGoal: (() -> Void)? = nil) {
        self.goal = goal
        self.totalSaved = totalSaved
        self.showFullView = showFullView
        self.isMinimized = isMinimized
        self.onSetGoal = onSetGoal
    }

    var body: some View {
        if let goal {
            if isMinimized {
                MinimizedGoalView(goal: goal)
            } else {
                GoalWithTargetView(goal: goal, showFullView: showFullView)
            }
        } else {
            if isMinimized {
                MinimizedCashView(totalSaved: totalSaved)
            } else {
                CashPileView(totalSaved: totalSaved, showFullView: showFullView, onSetGoal: onSetGoal)
            }
        }
    }
}

// MARK: - Minimized Goal View (for NoBuy Challenge mode)

private struct MinimizedGoalView: View {
    let goal: UserGoal

    var body: some View {
        HStack(spacing: SpendLessSpacing.sm) {
            // Small icon
            GoalIconView(goalType: goal.type, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.name.isEmpty ? goal.type.rawValue : goal.name)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .lineLimit(1)

                HStack(spacing: SpendLessSpacing.xs) {
                    Text(formatCurrency(goal.savedAmount))
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessPrimary)

                    Text("of \(formatCurrency(goal.targetAmount))")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
            }

            Spacer()

            // Mini progress indicator
            ZStack {
                Circle()
                    .stroke(Color.spendLessTextMuted.opacity(0.2), lineWidth: 3)

                Circle()
                    .trim(from: 0, to: CGFloat(goal.progress))
                    .stroke(Color.spendLessSecondary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(goal.progressPercentage)%")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            .frame(width: 40, height: 40)
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
        .spendLessShadow(SpendLessShadow.subtleShadow)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Minimized Cash View (for NoBuy Challenge mode, no goal)

private struct MinimizedCashView: View {
    let totalSaved: Decimal

    var body: some View {
        HStack(spacing: SpendLessSpacing.sm) {
            Text("💰")
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text("Total Saved")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)

                Text(formatCurrency(totalSaved))
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessPrimary)
            }

            Spacer()
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
        .spendLessShadow(SpendLessShadow.subtleShadow)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Goal With Target

private struct GoalWithTargetView: View {
    let goal: UserGoal
    let showFullView: Bool
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.md) {
            // Goal image or icon
            if let imageData = goal.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: showFullView ? 180 : 100)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                            .stroke(Color.spendLessGold.opacity(0.3), lineWidth: 2)
                    )
            } else {
                GoalIconView(goalType: goal.type, size: showFullView ? 100 : 60)
            }
            
            // Goal type (main title) - in screenshot mode, prefer goal name if it's "Paris Trip"
            if AppConstants.isScreenshotMode && goal.name == ScreenshotDataHelper.goalName {
                Text("✈️ \(goal.name)")
                    .font(showFullView ? SpendLessFont.title2 : SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)
            } else {
                Text(goal.type.rawValue)
                    .font(showFullView ? SpendLessFont.title2 : SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)
                
                // Goal "why" (subtitle) - only show if it exists and is different from the goal type
                if !goal.name.isEmpty && goal.name != goal.type.rawValue {
                    Text(goal.name)
                        .font(showFullView ? SpendLessFont.body : SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, SpendLessSpacing.xxs)
                }
            }
            
            if showFullView {
                // Progress bar
                GoalProgressBar(savedAmount: goal.savedAmount, targetAmount: goal.targetAmount)
                
                // Progress percentage
                Text("\(goal.progressPercentage)% there")
                    .font(SpendLessFont.subheadline)
                    .foregroundStyle(Color.spendLessSecondary)
                
                // Motivational message
                if let message = motivationalMessage {
                    Text(message)
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.top, SpendLessSpacing.xs)
                }
            } else {
                // Compact progress display
                HStack {
                    Text(formatCurrency(goal.savedAmount))
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessPrimary)
                    Text("/")
                        .foregroundStyle(Color.spendLessTextMuted)
                    Text(formatCurrency(goal.targetAmount))
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
            }
        }
        .padding(SpendLessSpacing.lg)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
        .spendLessShadow(SpendLessShadow.cardShadow)
    }
    
    private var motivationalMessage: String? {
        let percentage = goal.progressPercentage
        
        if percentage >= 100 {
            return "You did it! 🎉"
        } else if percentage >= 75 {
            return "Almost there! Keep going!"
        } else if percentage >= 50 {
            return "Halfway to \(goal.type.rawValue)!"
        } else if percentage >= 25 {
            return "Great progress! Every dollar counts."
        } else if percentage > 0 {
            return "You're on your way!"
        } else {
            return "Your journey to \(goal.type.rawValue) starts now."
        }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Cash Pile View (No Goal Mode)

private struct CashPileView: View {
    let totalSaved: Decimal
    let showFullView: Bool
    let onSetGoal: (() -> Void)?
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.md) {
            // Cash pile visualization
            ZStack {
                ForEach(0..<min(Int((totalSaved as NSDecimalNumber).intValue / 100) + 1, 5), id: \.self) { index in
                    Text("💰")
                        .font(.system(size: showFullView ? 50 : 30))
                        .offset(
                            x: CGFloat(index - 2) * (showFullView ? 15 : 8),
                            y: CGFloat(index % 2) * (showFullView ? -10 : -5)
                        )
                }
            }
            .frame(height: showFullView ? 80 : 50)
            
            // Amount
            Text(formatCurrency(totalSaved))
                .font(showFullView ? SpendLessFont.largeTitle : SpendLessFont.title2)
                .foregroundStyle(Color.spendLessPrimary)
            
            Text(AppConstants.isScreenshotMode ? ScreenshotDataHelper.dashboardSavingsLabel : "kept in your pocket")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            if showFullView {
                Text(AppConstants.isScreenshotMode ? ScreenshotDataHelper.dashboardSavingsDescription : "Money you didn't waste on things you didn't need")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
                    .multilineTextAlignment(.center)
                
                // Suggest setting a goal
                if let onSetGoal = onSetGoal {
                    SecondaryButton("Set a goal for this?", icon: "arrow.right") {
                        onSetGoal()
                    }
                    .padding(.top, SpendLessSpacing.sm)
                }
            }
        }
        .padding(SpendLessSpacing.lg)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
        .spendLessShadow(SpendLessShadow.cardShadow)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Goal Icon View

struct GoalIconView: View {
    let goalType: GoalType
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.spendLessGoldLight, Color.spendLessGold.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            IconView(goalType.icon, font: .system(size: size * 0.5))
        }
    }
}

// MARK: - Preview

#Preview("With Goal") {
    VStack(spacing: 20) {
        GoalProgressView(
            goal: UserGoal(
                name: "Trip to Japan",
                targetAmount: 5000,
                savedAmount: 2500,
                goalType: .vacation
            )
        )
        GoalProgressView(
            goal: UserGoal(
                name: "Trip to Japan",
                targetAmount: 5000,
                savedAmount: 2500,
                goalType: .vacation
            ),
            showFullView: false
        )
    }
    .padding()
    .background(Color.spendLessBackground)
}

#Preview("No Goal") {
    VStack(spacing: 20) {
        GoalProgressView(goal: nil, totalSaved: 2847)
        GoalProgressView(goal: nil, totalSaved: 500, showFullView: false)
    }
    .padding()
    .background(Color.spendLessBackground)
}

#Preview("Minimized") {
    VStack(spacing: 20) {
        GoalProgressView(
            goal: UserGoal(
                name: "Trip to Japan",
                targetAmount: 5000,
                savedAmount: 2500,
                goalType: .vacation
            ),
            isMinimized: true
        )
        GoalProgressView(goal: nil, totalSaved: 2847, isMinimized: true)
    }
    .padding()
    .background(Color.spendLessBackground)
}

