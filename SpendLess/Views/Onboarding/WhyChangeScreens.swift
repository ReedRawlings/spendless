//
//  WhyChangeScreens.swift
//  SpendLess
//
//  5 emotional onboarding screens that communicate the cost of compulsive shopping
//  Emotional journey: Pain (terracotta) → Hope (sage green)
//

import SwiftUI

// MARK: - Shared Screen Template

struct WhyChangeScreen: View {
    let backgroundColor: Color
    let animationName: String
    let headline: String
    let bodyText: AttributedString
    var animationHeight: CGFloat = 200
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: SpendLessSpacing.lg) {
                Spacer()
                
                // Lottie Animation
                LottieAnimationView(animationName: animationName)
                    .frame(height: animationHeight)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true) // Decorative, not informational
                
                // Headline
                Text(headline)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SpendLessSpacing.xl)
                
                // Body with bold phrases
                Text(bodyText)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, SpendLessSpacing.xl)
                
                Spacer()
                
                // Progress dots
                WhyChangeProgressDots(currentIndex: progressIndex(for: animationName))
                    .padding(.bottom, SpendLessSpacing.sm)
                
                // Next button - white on dark background
                WhyChangeNextButton {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(headline). \(String(bodyText.characters))")
        .accessibilityAddTraits(.isStaticText)
        .navigationBarBackButtonHidden(false)
    }
    
    private func progressIndex(for animation: String) -> Int {
        switch animation {
        case "starSad": return 0
        case "hamster": return 1
        case "theftcard": return 2
        case "futureSelf": return 3
        case "brain": return 4
        default: return 0
        }
    }
}

// MARK: - Progress Dots

struct WhyChangeProgressDots: View {
    let currentIndex: Int
    let total: Int = 5
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Next Button (White on dark backgrounds)

struct WhyChangeNextButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.xs) {
                Text("Next")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(Color.spendLessPrimaryDark)
            .padding(.horizontal, SpendLessSpacing.xl)
            .padding(.vertical, SpendLessSpacing.md)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(Color.white)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Screen 1: The High That Disappears

struct WhyChange1View: View {
    let onContinue: () -> Void
    
    var body: some View {
        WhyChangeScreen(
            backgroundColor: .spendLessPrimaryDark,
            animationName: "starSad",
            headline: "The excitement ends at checkout",
            bodyText: whyChange1Body(),
            onContinue: onContinue
        )
    }
    
    private func whyChange1Body() -> AttributedString {
        var text = AttributedString("You felt the rush browsing. The thrill of finding it. Then you bought it and... nothing. The high ")
        
        var bold = AttributedString("disappears the moment you click purchase")
        bold.font = .system(size: 17, weight: .semibold, design: .rounded)
        
        let end = AttributedString(". So you chase the next one.")
        
        text.append(bold)
        text.append(end)
        return text
    }
}

// MARK: - Screen 2: Not About the Stuff

struct WhyChange2View: View {
    let onContinue: () -> Void
    
    var body: some View {
        WhyChangeScreen(
            backgroundColor: .spendLessPrimaryDark,
            animationName: "hamster",
            headline: "You're not shopping for things",
            bodyText: whyChange2Body(),
            onContinue: onContinue
        )
    }
    
    private func whyChange2Body() -> AttributedString {
        var text = AttributedString("You're shopping because you're ")
        
        var bold1 = AttributedString("bored, stressed, or lonely")
        bold1.font = .system(size: 17, weight: .semibold, design: .rounded)
        
        let mid = AttributedString("—and your brain learned this is the fastest fix. But it's treating the symptom, not the cause.")
        
        text.append(bold1)
        text.append(mid)
        return text
    }
}

// MARK: - Screen 3: Dark Patterns

struct WhyChange3View: View {
    let onContinue: () -> Void
    
    var body: some View {
        WhyChangeScreen(
            backgroundColor: .spendLessPrimary,
            animationName: "theftcard",
            headline: "Your brain vs. billion-dollar algorithms",
            bodyText: whyChange3Body(),
            onContinue: onContinue
        )
    }
    
    private func whyChange3Body() -> AttributedString {
        var text = AttributedString("One-click buying. \"Only 3 left!\" Fake countdown timers. These aren't features—they're ")
        
        var bold = AttributedString("traps built by psychologists")
        bold.font = .system(size: 17, weight: .semibold, design: .rounded)
        
        let end = AttributedString(" to bypass your rational mind.")
        
        text.append(bold)
        text.append(end)
        return text
    }
}

// MARK: - Screen 4: Future Self

struct WhyChange4View: View {
    let onContinue: () -> Void
    
    var body: some View {
        WhyChangeScreen(
            backgroundColor: .spendLessSecondary,
            animationName: "futureSelf",
            headline: "Future you is counting on you",
            bodyText: whyChange4Body(),
            onContinue: onContinue
        )
    }
    
    private func whyChange4Body() -> AttributedString {
        var text = AttributedString("That trip. That debt paid off. That breathing room. ")
        
        var bold = AttributedString("Future you wants those things.")
        bold.font = .system(size: 17, weight: .semibold, design: .rounded)
        
        let end = AttributedString(" But every impulse buy steals from her. She's not abstract—she's you, soon.")
        
        text.append(bold)
        text.append(end)
        return text
    }
}

// MARK: - Screen 5: Brain Reset

struct WhyChange5View: View {
    let onContinue: () -> Void
    
    var body: some View {
        WhyChangeScreen(
            backgroundColor: .spendLessSecondary,
            animationName: "brain",
            headline: "This isn't about willpower",
            bodyText: whyChange5Body(),
            onContinue: onContinue
        )
    }
    
    private func whyChange5Body() -> AttributedString {
        var text = AttributedString("It's a ")
        
        var bold1 = AttributedString("dopamine problem")
        bold1.font = .system(size: 17, weight: .semibold, design: .rounded)
        
        let mid = AttributedString(", not a character flaw. And dopamine systems can heal. By pausing before purchases, you can rewire the cycle and start ")
        
        var bold2 = AttributedString("wanting less")
        bold2.font = .system(size: 17, weight: .semibold, design: .rounded)
        
        let end = AttributedString(".")
        
        text.append(bold1)
        text.append(mid)
        text.append(bold2)
        text.append(end)
        return text
    }
}

// MARK: - Previews

#Preview("WhyChange1 - Checkout") {
    WhyChange1View {}
}

#Preview("WhyChange2 - Not About Stuff") {
    WhyChange2View {}
}

#Preview("WhyChange3 - Dark Patterns") {
    WhyChange3View {}
}

#Preview("WhyChange4 - Future Self") {
    WhyChange4View {}
}

#Preview("WhyChange5 - Brain Reset") {
    WhyChange5View {}
}

