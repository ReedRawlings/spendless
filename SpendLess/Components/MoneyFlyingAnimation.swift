//
//  MoneyFlyingAnimation.swift
//  SpendLess
//
//  Animation of money/coins flying toward goal
//

import SwiftUI

struct MoneyFlyingAnimation: View {
    @Binding var isAnimating: Bool
    let amount: Decimal
    let startPosition: CGPoint
    let endPosition: CGPoint
    let onComplete: (() -> Void)?
    
    @State private var coins: [FlyingCoin] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(
        isAnimating: Binding<Bool>,
        amount: Decimal,
        startPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 100),
        endPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: 200),
        onComplete: (() -> Void)? = nil
    ) {
        self._isAnimating = isAnimating
        self.amount = amount
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            ForEach(coins) { coin in
                FlyingCoinView(coin: coin)
            }
        }
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        guard !reduceMotion else {
            // For reduced motion, just call completion immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
                onComplete?()
            }
            return
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        
        // Create coins based on amount
        let coinCount = min(Int((amount as NSDecimalNumber).intValue / 10) + 1, 15)
        
        coins = (0..<coinCount).map { index in
            FlyingCoin(
                startPosition: CGPoint(
                    x: startPosition.x + CGFloat.random(in: -30...30),
                    y: startPosition.y
                ),
                endPosition: CGPoint(
                    x: endPosition.x + CGFloat.random(in: -20...20),
                    y: endPosition.y
                ),
                delay: Double(index) * 0.05
            )
        }
        
        // Trigger haptics for each coin
        for index in 0..<coinCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                generator.impactOccurred()
            }
        }
        
        // Complete after animation
        let totalDuration = 0.6 + Double(coinCount) * 0.05
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            coins = []
            isAnimating = false
            onComplete?()
        }
    }
}

// MARK: - Flying Coin Model

struct FlyingCoin: Identifiable {
    let id = UUID()
    let startPosition: CGPoint
    let endPosition: CGPoint
    let delay: Double
    let rotation: Double = Double.random(in: 0...360)
}

// MARK: - Flying Coin View

struct FlyingCoinView: View {
    let coin: FlyingCoin
    
    @State private var position: CGPoint
    @State private var scale: CGFloat = 1.2
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    init(coin: FlyingCoin) {
        self.coin = coin
        self._position = State(initialValue: coin.startPosition)
    }
    
    var body: some View {
        Text("💰")
            .font(.system(size: 30))
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                animateCoin()
            }
    }
    
    private func animateCoin() {
        // Fade in
        withAnimation(.easeOut(duration: 0.1).delay(coin.delay)) {
            opacity = 1
        }
        
        // Move to target with curve
        withAnimation(.easeInOut(duration: 0.5).delay(coin.delay)) {
            position = coin.endPosition
            rotation = coin.rotation + 180
            scale = 0.8
        }
        
        // Fade out at end
        withAnimation(.easeIn(duration: 0.15).delay(coin.delay + 0.45)) {
            opacity = 0
            scale = 1.5
        }
    }
}

// MARK: - Money Increment Animation

struct MoneyIncrementView: View {
    let amount: Decimal
    @State private var displayedAmount: Double = 0
    @State private var isVisible = false
    
    var body: some View {
        Text("+\(formatCurrency(Decimal(displayedAmount)))")
            .font(SpendLessFont.title2)
            .foregroundStyle(Color.spendLessGold)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? -20 : 0)
            .onAppear {
                animateIncrement()
            }
    }
    
    private func animateIncrement() {
        let targetValue = (amount as NSDecimalNumber).doubleValue
        
        withAnimation(.easeOut(duration: 0.3)) {
            isVisible = true
        }
        
        // Animate the number counting up
        let steps = 20
        let increment = targetValue / Double(steps)
        
        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.03) {
                displayedAmount = min(increment * Double(step), targetValue)
            }
        }
        
        // Fade out
        withAnimation(.easeIn(duration: 0.5).delay(1.0)) {
            isVisible = false
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

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var isAnimating = false
        
        var body: some View {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack {
                    // Target area
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.spendLessSecondaryLight)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("🎯")
                                .font(.largeTitle)
                        )
                    
                    Spacer()
                    
                    Button("Fly Money!") {
                        isAnimating = true
                    }
                    .padding()
                }
                
                MoneyFlyingAnimation(
                    isAnimating: $isAnimating,
                    amount: 79,
                    startPosition: CGPoint(x: 200, y: 600),
                    endPosition: CGPoint(x: 200, y: 150)
                )
            }
        }
    }
    
    return PreviewWrapper()
}

