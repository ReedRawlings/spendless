//
//  InterventionQuickPauseView.swift
//  SpendLess
//
//  Quick 5-second pause countdown for intervention flow
//

import SwiftUI

struct InterventionQuickPauseView: View {
    let onComplete: (Bool) -> Void
    
    @State private var countdown = 5
    @State private var isCountingDown = true
    @State private var circleProgress: CGFloat = 0
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Countdown circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.spendLessBackgroundSecondary, lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: circleProgress)
                    .stroke(
                        Color.spendLessPrimary,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                // Countdown number or checkmark
                if isCountingDown {
                    Text("\(countdown)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.spendLessPrimary)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(Color.spendLessSecondary)
                }
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
            
            // Message
            VStack(spacing: SpendLessSpacing.xs) {
                Text(isCountingDown ? "Take a moment..." : "Ready to decide")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text(isCountingDown
                     ? "Do you really need to open this app?"
                     : "What would you like to do?")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            .opacity(appeared ? 1 : 0)
            
            Spacer()
            
            // Buttons (only show after countdown)
            if !isCountingDown {
                VStack(spacing: SpendLessSpacing.md) {
                    PrimaryButton("No, I'm good") {
                        onComplete(true)
                    }
                    
                    SecondaryButton("Let me in") {
                        onComplete(false)
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            Spacer()
                .frame(height: SpendLessSpacing.xxl)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
            startCountdown()
        }
    }
    
    private func startCountdown() {
        guard !reduceMotion else {
            // Skip countdown for reduced motion
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isCountingDown = false
                }
            }
            return
        }
        
        // Animate circle
        withAnimation(.linear(duration: 5)) {
            circleProgress = 1.0
        }
        
        // Countdown timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            } else {
                timer.invalidate()
                
                // Success haptic
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isCountingDown = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    InterventionQuickPauseView { resisted in
        print("Resisted: \(resisted)")
    }
}

