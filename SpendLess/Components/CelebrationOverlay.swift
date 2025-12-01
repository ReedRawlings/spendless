//
//  CelebrationOverlay.swift
//  SpendLess
//
//  Confetti and celebration animations
//

import SwiftUI

struct CelebrationOverlay: View {
    @Binding var isShowing: Bool
    let amount: Decimal?
    let message: String
    let onDismiss: (() -> Void)?
    
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var showContent = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(
        isShowing: Binding<Bool>,
        amount: Decimal? = nil,
        message: String,
        onDismiss: (() -> Void)? = nil
    ) {
        self._isShowing = isShowing
        self.amount = amount
        self.message = message
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Confetti layer
            if !reduceMotion {
                ForEach(confettiPieces) { piece in
                    ConfettiView(piece: piece)
                }
            }
            
            // Content card
            VStack(spacing: SpendLessSpacing.lg) {
                // Celebration emoji
                Text("🎉")
                    .font(.system(size: 60))
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                
                // Amount saved
                if let amount {
                    VStack(spacing: SpendLessSpacing.xxs) {
                        Text("You didn't spend")
                            .font(SpendLessFont.subheadline)
                            .foregroundStyle(Color.spendLessTextSecondary)
                        
                        Text(formatCurrency(amount))
                            .font(SpendLessFont.largeTitle)
                            .foregroundStyle(Color.spendLessPrimary)
                    }
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)
                }
                
                // Message
                Text(message)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                
                // Continue button
                PrimaryButton("Continue") {
                    dismiss()
                }
                .padding(.top, SpendLessSpacing.sm)
                .opacity(showContent ? 1 : 0)
            }
            .padding(SpendLessSpacing.xl)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
            .padding(.horizontal, SpendLessSpacing.lg)
            .scaleEffect(showContent ? 1 : 0.9)
        }
        .onAppear {
            triggerCelebration()
        }
    }
    
    private func triggerCelebration() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Spawn confetti
        if !reduceMotion {
            spawnConfetti()
        }
        
        // Animate content
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            showContent = true
        }
    }
    
    private func spawnConfetti() {
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(
                color: [
                    Color.spendLessPrimary,
                    Color.spendLessGold,
                    Color.spendLessSecondary,
                    Color.spendLessPrimaryLight,
                    Color.spendLessGoldLight
                ].randomElement()!,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                startY: -20,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2)
            )
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            showContent = false
            isShowing = false
        }
        onDismiss?()
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Confetti Piece

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let startY: CGFloat
    let rotation: Double
    let scale: CGFloat
}

struct ConfettiView: View {
    let piece: ConfettiPiece
    
    @State private var y: CGFloat = -20
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10 * piece.scale, height: 10 * piece.scale)
            .rotationEffect(.degrees(rotation))
            .position(x: piece.x, y: y)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 2...4))) {
                    y = UIScreen.main.bounds.height + 100
                    rotation = piece.rotation + Double.random(in: 360...720)
                }
                withAnimation(.easeIn(duration: 3).delay(1)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Simple Confetti Burst

struct ConfettiBurst: View {
    @Binding var trigger: Bool
    @State private var particles: [ConfettiParticle] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(particle.offset)
                    .opacity(particle.opacity)
            }
        }
        .onChange(of: trigger) { _, newValue in
            if newValue && !reduceMotion {
                burst()
            }
        }
    }
    
    private func burst() {
        particles = (0..<30).map { _ in
            ConfettiParticle()
        }
        
        for i in particles.indices {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 50...150)
            let targetOffset = CGSize(
                width: cos(angle) * distance,
                height: sin(angle) * distance - 50 // bias upward
            )
            
            withAnimation(.easeOut(duration: 0.8)) {
                particles[i].offset = targetOffset
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                particles[i].opacity = 0
            }
        }
        
        // Reset trigger after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            trigger = false
            particles = []
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var offset: CGSize = .zero
    var opacity: Double = 1
    
    init() {
        self.color = [
            Color.spendLessPrimary,
            Color.spendLessGold,
            Color.spendLessSecondary,
            Color.spendLessPrimaryLight
        ].randomElement()!
        self.size = CGFloat.random(in: 6...12)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var showCelebration = true
        @State private var burstTrigger = false
        
        var body: some View {
            ZStack {
                VStack {
                    Button("Show Celebration") {
                        showCelebration = true
                    }
                    
                    Button("Burst!") {
                        burstTrigger = true
                    }
                    .overlay {
                        ConfettiBurst(trigger: $burstTrigger)
                    }
                }
                
                if showCelebration {
                    CelebrationOverlay(
                        isShowing: $showCelebration,
                        amount: 79,
                        message: "That's 2 museum tickets in Paris!"
                    )
                }
            }
        }
    }
    
    return PreviewWrapper()
}

