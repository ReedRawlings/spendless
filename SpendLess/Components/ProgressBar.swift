//
//  ProgressBar.swift
//  SpendLess
//
//  Animated progress bar with warm styling
//

import SwiftUI

struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let height: CGFloat
    let showPercentage: Bool
    let animate: Bool
    
    init(
        progress: Double,
        height: CGFloat = 12,
        showPercentage: Bool = false,
        animate: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.height = height
        self.showPercentage = showPercentage
        self.animate = animate
    }
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(alignment: .trailing, spacing: SpendLessSpacing.xxs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.spendLessBackgroundSecondary)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(SpendLessGradient.progress)
                        .frame(width: geometry.size.width * animatedProgress)
                }
            }
            .frame(height: height)
            
            if showPercentage {
                Text("\(Int(animatedProgress * 100))%")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
        }
        .onAppear {
            if animate {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    animatedProgress = progress
                }
            } else {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            if animate {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    animatedProgress = newValue
                }
            } else {
                animatedProgress = newValue
            }
        }
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

// MARK: - Goal Progress Bar (specialized for goal tracking)

struct GoalProgressBar: View {
    let savedAmount: Decimal
    let targetAmount: Decimal
    
    private var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return (savedAmount as NSDecimalNumber).doubleValue / (targetAmount as NSDecimalNumber).doubleValue
    }
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xs) {
            ProgressBar(progress: progress, height: 16)
            
            HStack {
                Text(formatCurrency(savedAmount))
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessPrimary)
                
                Spacer()
                
                Text(formatCurrency(targetAmount))
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
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

// MARK: - Countdown Progress Bar (for waiting list)

struct CountdownProgressBar: View {
    let progress: Double // How far through the waiting period (0 = just added, 1 = ready)
    let daysRemaining: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.spendLessBackgroundSecondary)
                    
                    // Progress fill (inverted - fills as time passes)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            
            Text(daysRemainingText)
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextMuted)
        }
    }
    
    private var progressColor: Color {
        if progress >= 1 {
            return Color.spendLessGold
        } else if progress >= 0.8 {
            return Color.spendLessGold.opacity(0.8)
        } else {
            return Color.spendLessSecondary
        }
    }
    
    private var daysRemainingText: String {
        if daysRemaining <= 0 {
            return "Ready to decide!"
        } else if daysRemaining == 1 {
            return "1 day remaining"
        } else {
            return "\(daysRemaining) days remaining"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Basic Progress")
                .font(SpendLessFont.headline)
            ProgressBar(progress: 0.65)
            ProgressBar(progress: 0.65, showPercentage: true)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Goal Progress")
                .font(SpendLessFont.headline)
            GoalProgressBar(savedAmount: 1247, targetAmount: 4500)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Countdown Progress")
                .font(SpendLessFont.headline)
            CountdownProgressBar(progress: 0.3, daysRemaining: 5)
            CountdownProgressBar(progress: 0.8, daysRemaining: 1)
            CountdownProgressBar(progress: 1.0, daysRemaining: 0)
        }
    }
    .padding()
    .background(Color.spendLessBackground)
}

