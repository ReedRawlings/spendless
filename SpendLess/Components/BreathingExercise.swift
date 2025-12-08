//
//  BreathingExercise.swift
//  SpendLess
//
//  Breathing exercise with animated circle
//

import SwiftUI

struct BreathingExercise: View {
    let duration: TimeInterval // Total exercise duration
    let onComplete: () -> Void
    
    @State private var phase: BreathingPhase = .inhale
    @State private var timeRemaining: TimeInterval
    @State private var circleScale: CGFloat = 0.5
    @State private var isActive = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // 4-7-8 breathing pattern
    private let inhaleTime: TimeInterval = 4
    private let holdTime: TimeInterval = 7
    private let exhaleTime: TimeInterval = 8
    
    init(duration: TimeInterval = 60, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.onComplete = onComplete
        self._timeRemaining = State(initialValue: duration)
    }
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            // Title
            Text("Take a breath")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            // Time remaining
            Text(formatTime(timeRemaining))
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextSecondary)
                .monospacedDigit()
            
            Spacer()
            
            // Breathing circle
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.spendLessSecondaryLight, lineWidth: 3)
                    .frame(width: 200, height: 200)
                
                // Animated breathing circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.spendLessSecondary.opacity(0.7),
                                Color.spendLessSecondary.opacity(0.3)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200 * circleScale, height: 200 * circleScale)
                
                // Phase instruction
                Text(phase.instruction)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
            }
            
            Spacer()
            
            // Skip button
            TextButton("Skip", icon: "forward.fill") {
                isActive = false
                onComplete()
            }
        }
        .padding(SpendLessSpacing.xl)
        .onAppear {
            startBreathingCycle()
            startTimer()
        }
        .onDisappear {
            isActive = false
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard isActive else {
                timer.invalidate()
                return
            }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                onComplete()
            }
        }
    }
    
    // MARK: - Breathing Cycle
    
    private func startBreathingCycle() {
        guard isActive else { return }
        
        // Start with inhale
        phase = .inhale
        animateCircle(scale: 1.0, duration: reduceMotion ? 0.3 : inhaleTime) {
            guard self.isActive else { return }
            
            // Hold
            self.phase = .hold
            DispatchQueue.main.asyncAfter(deadline: .now() + self.holdTime) {
                guard self.isActive else { return }
                
                // Exhale
                self.phase = .exhale
                self.animateCircle(scale: 0.5, duration: self.reduceMotion ? 0.3 : self.exhaleTime) {
                    // Restart cycle
                    self.startBreathingCycle()
                }
            }
        }
    }
    
    private func animateCircle(scale: CGFloat, duration: TimeInterval, completion: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: duration)) {
            circleScale = scale
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion()
        }
    }
    
    // MARK: - Formatting
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Breathing Phase

enum BreathingPhase {
    case inhale
    case hold
    case exhale
    
    var instruction: String {
        switch self {
        case .inhale: return "Breathe in..."
        case .hold: return "Hold..."
        case .exhale: return "Breathe out..."
        }
    }
}

// MARK: - Quick Breathing (shorter version for feeling tempted flow)

struct QuickBreathingExercise: View {
    let onComplete: () -> Void
    
    @State private var breathCount = 0
    @State private var circleScale: CGFloat = 0.5
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let totalBreaths = 3
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Text("Take \(totalBreaths - breathCount) deep breaths")
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            ZStack {
                Circle()
                    .stroke(Color.spendLessPrimaryLight, lineWidth: 3)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .fill(Color.spendLessPrimary.opacity(0.5))
                    .frame(width: 150 * circleScale, height: 150 * circleScale)
            }
            
            Text(isAnimating ? "Breathe out" : "Breathe in")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
        .onAppear {
            startBreathing()
        }
    }
    
    private func startBreathing() {
        guard breathCount < totalBreaths else {
            onComplete()
            return
        }
        
        // Inhale
        isAnimating = false
        withAnimation(.easeInOut(duration: reduceMotion ? 0.3 : 2)) {
            circleScale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.5 : 2)) {
            // Exhale
            self.isAnimating = true
            withAnimation(.easeInOut(duration: self.reduceMotion ? 0.3 : 2)) {
                self.circleScale = 0.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.reduceMotion ? 0.5 : 2)) {
                self.breathCount += 1
                self.startBreathing()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        BreathingExercise(duration: 30) {
            print("Complete!")
        }
    }
    .background(Color.spendLessBackground)
}

#Preview("Quick Breathing") {
    QuickBreathingExercise {
        print("Done!")
    }
    .padding()
    .background(Color.spendLessBackground)
}

