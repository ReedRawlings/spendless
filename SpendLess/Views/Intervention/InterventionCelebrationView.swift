//
//  InterventionCelebrationView.swift
//  SpendLess
//
//  Celebration screen after resisting a purchase - focuses on habit building
//

import SwiftUI

struct InterventionCelebrationView: View {
    let isHALTRedirect: Bool
    let onComplete: () -> Void
    
    @State private var showConfetti = false
    @State private var textOpacity = 0.0
    @State private var iconScale = 0.5
    @State private var messageScale = 0.5
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Rotating encouraging messages
    private let messages = [
        "You're building a better habit!",
        "Every pause is progress.",
        "You chose yourself today.",
        "That's how habits are made.",
        "You're stronger than the urge."
    ]
    
    // HALT redirect specific message
    private let haltMessage = "Good call. You've got this. 💪"
    
    @State private var currentMessage: String = ""
    
    init(isHALTRedirect: Bool = false, onComplete: @escaping () -> Void) {
        self.isHALTRedirect = isHALTRedirect
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Confetti layer
            if showConfetti && !reduceMotion {
                InterventionConfettiView()
            }
            
            // Content
            VStack(spacing: SpendLessSpacing.xl) {
                Spacer()
                
                // Success icon with warm gold accent
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.spendLessGold.opacity(0.3),
                                    Color.spendLessGold.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.spendLessGold.opacity(0.2),
                                    Color.spendLessSecondary.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.spendLessGold, Color.spendLessGoldDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(iconScale)
                
                // Main message
                VStack(spacing: SpendLessSpacing.md) {
                    Text("You did it!")
                        .font(SpendLessFont.largeTitle)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text(currentMessage)
                        .font(SpendLessFont.title3)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SpendLessSpacing.lg)
                }
                .scaleEffect(messageScale)
                .opacity(textOpacity)
                
                // Encouraging subtext
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("Shopping Resisted")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessSecondary)
                        .padding(.horizontal, SpendLessSpacing.md)
                        .padding(.vertical, SpendLessSpacing.sm)
                        .background(
                            Capsule()
                                .fill(Color.spendLessSecondary.opacity(0.15))
                        )
                }
                .opacity(textOpacity)
                .padding(.top, SpendLessSpacing.sm)
                
                Spacer()
                
                // Continue button
                PrimaryButton("Continue") {
                    onComplete()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xxl)
                .opacity(textOpacity)
            }
        }
        .onAppear {
            currentMessage = isHALTRedirect ? haltMessage : (messages.randomElement() ?? messages[0])
            triggerCelebration()
        }
    }
    
    private func triggerCelebration() {
        // Haptic feedback - success pattern
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Delayed haptic for extra celebration feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
        
        // Animate elements with spring
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showConfetti = true
            iconScale = 1.0
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            messageScale = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
            textOpacity = 1.0
        }
    }
}

// MARK: - Confetti View

struct InterventionConfettiView: View {
    @State private var particles: [InterventionConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles) { particle in
                Rectangle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .rotationEffect(.degrees(particle.rotation))
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            spawnConfetti()
        }
    }
    
    private func spawnConfetti() {
        let screenWidth = UIScreen.main.bounds.width
        let colors: [Color] = [
            Color.spendLessPrimary,
            Color.spendLessGold,
            Color.spendLessSecondary,
            Color.spendLessPrimaryLight,
            Color.spendLessGoldLight
        ]
        
        particles = (0..<50).map { _ in
            InterventionConfettiParticle(
                color: colors.randomElement() ?? Color.spendLessPrimary,
                x: CGFloat.random(in: 0...screenWidth),
                y: -20,
                size: CGFloat.random(in: 8...14),
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
        }
        
        // Animate each particle
        for i in particles.indices {
            let delay = Double.random(in: 0...0.3)
            let duration = Double.random(in: 2...4)
            let targetY = UIScreen.main.bounds.height + 100
            let targetRotation = particles[i].rotation + Double.random(in: 360...720)
            
            withAnimation(.easeOut(duration: duration).delay(delay)) {
                particles[i].y = targetY
                particles[i].rotation = targetRotation
            }
            
            withAnimation(.easeIn(duration: duration * 0.5).delay(delay + duration * 0.5)) {
                particles[i].opacity = 0
            }
        }
    }
}

struct InterventionConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var rotation: Double
    var opacity: Double
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        InterventionCelebrationView {
            print("Complete!")
        }
        
        InterventionCelebrationView(isHALTRedirect: true) {
            print("HALT Complete!")
        }
    }
}

