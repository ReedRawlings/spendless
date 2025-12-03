//
//  FlipCard.swift
//  SpendLess
//
//  Reusable 3D flip card component for educational content
//

import SwiftUI

struct FlipCard<Front: View, Back: View>: View {
    let front: Front
    let back: Back
    @Binding var isFlipped: Bool
    let isCompleted: Bool
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    init(
        isFlipped: Binding<Bool>,
        isCompleted: Bool = false,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._isFlipped = isFlipped
        self.isCompleted = isCompleted
        self.front = front()
        self.back = back()
    }
    
    var body: some View {
        ZStack {
            // Front of card
            front
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .opacity(rotation < 90 ? 1 : 0)
            
            // Back of card
            back
                .rotation3DEffect(
                    .degrees(rotation - 180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .opacity(rotation >= 90 ? 1 : 0)
        }
        .scaleEffect(scale)
        .opacity(isCompleted ? 0.6 : 1.0)
        .onChange(of: isFlipped) { _, newValue in
            flipCard(to: newValue)
        }
    }
    
    private func flipCard(to flipped: Bool) {
        let targetRotation = flipped ? 180.0 : 0.0
        
        // Check for reduced motion preference
        if UIAccessibility.isReduceMotionEnabled {
            rotation = targetRotation
            return
        }
        
        // Animate scale down at midpoint, then back up
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            rotation = targetRotation
        }
        
        // Scale dip at midpoint for depth effect
        withAnimation(.easeInOut(duration: 0.2)) {
            scale = 0.95
        }
        
        withAnimation(.easeInOut(duration: 0.2).delay(0.2)) {
            scale = 1.0
        }
    }
}

// MARK: - Tap to Flip Modifier

struct TapToFlipModifier: ViewModifier {
    @Binding var isFlipped: Bool
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                isFlipped.toggle()
            }
    }
}

extension View {
    func tapToFlip(_ isFlipped: Binding<Bool>) -> some View {
        modifier(TapToFlipModifier(isFlipped: isFlipped))
    }
}

// MARK: - Preview

#Preview("Flip Card") {
    struct PreviewWrapper: View {
        @State private var isFlipped = false
        
        var body: some View {
            VStack(spacing: 20) {
                FlipCard(isFlipped: $isFlipped) {
                    // Front
                    VStack(spacing: SpendLessSpacing.md) {
                        Text("⏰")
                            .font(.system(size: 60))
                        
                        Text("FAKE URGENCY")
                            .font(SpendLessFont.title2)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        Text("\"Sale ends in 2 hours!\"")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .italic()
                        
                        Text("Tap to learn more")
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextMuted)
                            .padding(.top, SpendLessSpacing.lg)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(SpendLessSpacing.xl)
                    .background(Color.spendLessCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
                    .spendLessShadow(SpendLessShadow.cardShadow)
                } back: {
                    // Back
                    VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                        Text("WHY IT WORKS")
                            .font(SpendLessFont.headline)
                            .foregroundStyle(Color.spendLessPrimary)
                        
                        Text("Countdown timers trigger your brain's loss aversion instinct.")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        Text("NEXT TIME YOU SEE THIS")
                            .font(SpendLessFont.headline)
                            .foregroundStyle(Color.spendLessPrimary)
                            .padding(.top, SpendLessSpacing.sm)
                        
                        Text("Would I want this if there was no timer?")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .italic()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SpendLessSpacing.xl)
                    .background(Color.spendLessCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
                    .spendLessShadow(SpendLessShadow.cardShadow)
                }
                .tapToFlip($isFlipped)
                
                Button(isFlipped ? "Show Front" : "Show Back") {
                    isFlipped.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color.spendLessBackground)
        }
    }
    
    return PreviewWrapper()
}

