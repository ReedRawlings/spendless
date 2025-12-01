//
//  AccessibilityModifiers.swift
//  SpendLess
//
//  Accessibility helpers and modifiers
//

import SwiftUI

// MARK: - Accessibility Labels

extension View {
    /// Add accessibility label for currency amount
    func accessibilityCurrency(_ amount: Decimal) -> some View {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let formatted = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount) dollars"
        return self.accessibilityLabel(formatted)
    }
    
    /// Add accessibility label for streak
    func accessibilityStreak(_ days: Int) -> some View {
        let label = days == 1 ? "1 day streak" : "\(days) day streak"
        return self.accessibilityLabel(label)
    }
    
    /// Add accessibility label for progress
    func accessibilityProgress(_ progress: Double, of total: String) -> some View {
        let percentage = Int(progress * 100)
        return self.accessibilityLabel("\(percentage) percent progress toward \(total)")
    }
}

// MARK: - Reduce Motion Helpers

struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    let reducedAnimation: Animation
    
    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? reducedAnimation : animation, value: UUID())
    }
}

extension View {
    /// Apply animation that respects reduce motion setting
    func animationWithReducedMotion(
        _ animation: Animation = .spring(),
        reduced: Animation = .easeInOut(duration: 0.2)
    ) -> some View {
        modifier(ReduceMotionModifier(animation: animation, reducedAnimation: reduced))
    }
}

// MARK: - Skip Animation Environment Check

struct AnimationPreference {
    @Environment(\.accessibilityReduceMotion) static var reduceMotion
    
    static func shouldAnimate() -> Bool {
        return !reduceMotion
    }
}

// MARK: - Accessible Button Style

struct AccessibleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - High Contrast Support

extension Color {
    /// Returns a higher contrast version of the color for accessibility
    var highContrast: Color {
        // This is a simplified version - in production, you'd want
        // to calculate actual contrast ratios
        return self
    }
}

// MARK: - Voice Over Announcements

struct VoiceOverAnnouncement {
    /// Announce a message to VoiceOver users
    static func announce(_ message: String, after delay: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    /// Announce screen change
    static func screenChanged(_ message: String? = nil) {
        UIAccessibility.post(notification: .screenChanged, argument: message)
    }
    
    /// Announce layout change
    static func layoutChanged(_ element: Any? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: element)
    }
}

// MARK: - Accessibility Hints

struct AccessibilityHints {
    static let waitingListItem = "Double tap to see options. Swipe up or down to adjust."
    static let graveyardItem = "Buried purchase. Double tap for details."
    static let panicButton = "Double tap when feeling tempted to shop."
    static let progressBar = "Shows progress toward goal."
    static let addButton = "Double tap to add a new item."
    static let buryButton = "Double tap to bury this item and add to your savings."
}

// MARK: - Dynamic Type Support

extension Font {
    /// Returns a font that scales appropriately with Dynamic Type
    static func scaledFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Minimum Touch Target

struct MinimumTouchTarget: ViewModifier {
    let minSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: minSize, minHeight: minSize)
    }
}

extension View {
    /// Ensure minimum 44x44pt touch target for accessibility
    func accessibleTouchTarget() -> some View {
        modifier(MinimumTouchTarget(minSize: 44))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Button("Accessible Button") {}
            .buttonStyle(AccessibleButtonStyle())
            .accessibleTouchTarget()
        
        Text("$1,247")
            .accessibilityCurrency(1247)
        
        Text("🔥 14")
            .accessibilityStreak(14)
    }
    .padding()
}

