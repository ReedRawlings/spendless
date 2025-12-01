//
//  HapticFeedback.swift
//  SpendLess
//
//  Centralized haptic feedback patterns
//

import SwiftUI
import UIKit

enum HapticFeedback {
    
    // MARK: - Success Patterns
    
    /// Light success - for small wins (checking in, small saves)
    static func lightSuccess() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium success - for completing actions (burying items, adding to list)
    static func mediumSuccess() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy celebration - for major milestones (goal completion, streak milestones)
    static func celebration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Interaction Patterns
    
    /// Selection changed - for toggles, selections
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    /// Button tap - soft feedback for button presses
    static func buttonTap() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    // MARK: - Warning Patterns
    
    /// Warning - for destructive actions or important alerts
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Error - for failed actions
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Custom Patterns
    
    /// Money saved pattern - multiple light taps to simulate coins
    static func moneySaved(count: Int = 3) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        
        for i in 0..<min(count, 5) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                generator.impactOccurred()
            }
        }
    }
    
    /// Burial pattern - satisfying thud
    static func burial() {
        let lightGenerator = UIImpactFeedbackGenerator(style: .light)
        let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        
        lightGenerator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            heavyGenerator.impactOccurred()
        }
    }
    
    /// Streak milestone - celebratory pattern
    static func streakMilestone() {
        let generator = UINotificationFeedbackGenerator()
        
        generator.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - View Modifier for Haptics

struct HapticOnTap: ViewModifier {
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    let generator = UIImpactFeedbackGenerator(style: style)
                    generator.impactOccurred()
                }
            )
    }
}

extension View {
    func hapticOnTap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        modifier(HapticOnTap(style: style))
    }
}

