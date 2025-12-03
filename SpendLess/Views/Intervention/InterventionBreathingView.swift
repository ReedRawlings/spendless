//
//  InterventionBreathingView.swift
//  SpendLess
//
//  Breathing exercise for intervention flow
//

import SwiftUI

struct InterventionBreathingView: View {
    let onComplete: () -> Void
    
    @State private var breathPhase: BreathPhase = .inhale
    @State private var circleScale: CGFloat = 0.5
    @State private var cyclesCompleted = 0
    @State private var secondsRemaining = 4
    @State private var isActive = true
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let totalCycles = 2 // Complete 2 full breath cycles
    
    enum BreathPhase: String {
        case inhale = "Breathe in..."
        case hold = "Hold..."
        case exhale = "Breathe out..."
    }
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Header
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Let's pause")
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("Take a moment before you shop")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer()
            
            // Animated breathing circle
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
                VStack(spacing: SpendLessSpacing.xs) {
                    Text(breathPhase.rawValue)
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("\(secondsRemaining)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .monospacedDigit()
                }
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
            
            Spacer()
            
            // Skip option (after first cycle)
            VStack(spacing: SpendLessSpacing.md) {
                if cyclesCompleted >= 1 {
                    PrimaryButton("I'm ready") {
                        isActive = false
                        onComplete()
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Text(cyclesCompleted >= 1 ? "Feeling calmer?" : "Take a moment to pause")
                    .font(SpendLessFont.subheadline)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
            .padding(.bottom, SpendLessSpacing.xxl)
            .opacity(appeared ? 1 : 0)
        }
        .padding(.horizontal, SpendLessSpacing.lg)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            startBreathingCycle()
        }
        .onDisappear {
            isActive = false
        }
    }
    
    private var currentPhaseDuration: Int {
        switch breathPhase {
        case .inhale: return 4
        case .hold: return 4
        case .exhale: return 4
        }
    }
    
    private func startBreathingCycle() {
        guard isActive else { return }
        
        // Reset
        breathPhase = .inhale
        circleScale = 0.5
        secondsRemaining = 4
        
        // Animate inhale
        let inhaleDuration = reduceMotion ? 0.3 : 4.0
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            circleScale = 1.0
        }
        
        startCountdown(duration: reduceMotion ? 1 : 4) {
            guard self.isActive else { return }
            
            // Hold phase
            self.breathPhase = .hold
            self.secondsRemaining = self.reduceMotion ? 1 : 4
            
            self.startCountdown(duration: self.reduceMotion ? 1 : 4) {
                guard self.isActive else { return }
                
                // Exhale phase
                self.breathPhase = .exhale
                self.secondsRemaining = self.reduceMotion ? 1 : 4
                
                let exhaleDuration = self.reduceMotion ? 0.3 : 4.0
                withAnimation(.easeInOut(duration: exhaleDuration)) {
                    self.circleScale = 0.5
                }
                
                self.startCountdown(duration: self.reduceMotion ? 1 : 4) {
                    // Cycle complete
                    self.cyclesCompleted += 1
                    
                    if self.cyclesCompleted < self.totalCycles {
                        self.startBreathingCycle()
                    } else {
                        self.onComplete()
                    }
                }
            }
        }
    }
    
    private func startCountdown(duration: Int, completion: @escaping () -> Void) {
        guard isActive else { return }
        secondsRemaining = duration
        
        func tick() {
            guard isActive else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guard self.isActive else { return }
                self.secondsRemaining -= 1
                if self.secondsRemaining > 0 {
                    tick()
                } else {
                    completion()
                }
            }
        }
        tick()
    }
}

// MARK: - Preview

#Preview {
    InterventionBreathingView {
        print("Complete!")
    }
}

