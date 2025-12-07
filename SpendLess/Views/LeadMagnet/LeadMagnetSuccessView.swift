//
//  LeadMagnetSuccessView.swift
//  SpendLess
//
//  Success screen shown after email submission
//

import SwiftUI

struct LeadMagnetSuccessView: View {
    let email: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Success icon
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.spendLessPrimary)
                .symbolEffect(.bounce, value: true)
            
            // Headline
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Check Your Inbox!")
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("Your Self-Compassion Guide is on its way to")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
                
                Text(email)
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessPrimary)
                
                Text("(Check spam if you don't see it in a few minutes)")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.top, SpendLessSpacing.xs)
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            
            // Continue button
            PrimaryButton("Continue to SpendLess") {
                onContinue()
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .background(Color.spendLessBackground)
        .onAppear {
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - Preview

#Preview {
    LeadMagnetSuccessView(
        email: "user@example.com",
        onContinue: {}
    )
}

