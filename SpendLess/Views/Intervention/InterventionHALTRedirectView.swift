//
//  InterventionHALTRedirectView.swift
//  SpendLess
//
//  Redirect screen shown after user selects a HALT state
//

import SwiftUI

struct InterventionHALTRedirectView: View {
    let state: HALTState
    let onRedirectAccepted: () -> Void
    let onRedirectDeclined: () -> Void
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Emoji and title
            VStack(spacing: SpendLessSpacing.md) {
                Text(state.emoji)
                    .font(.system(size: 64))
                
                Text(state.title)
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SpendLessSpacing.lg)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer()
            
            // Suggestions
            VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                Text("Try one of these instead:")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .padding(.horizontal, SpendLessSpacing.lg)
                
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    ForEach(state.suggestions, id: \.self) { suggestion in
                        HStack(spacing: SpendLessSpacing.sm) {
                            Text("•")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessPrimary)
                            Text(suggestion)
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextPrimary)
                        }
                    }
                }
                .padding(SpendLessSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.spendLessGold.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: SpendLessSpacing.md) {
                PrimaryButton("I'll do that ✓") {
                    onRedirectAccepted()
                }
                
                TextButton("I still want to browse") {
                    onRedirectDeclined()
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xxl)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    InterventionHALTRedirectView(
        state: .hungry,
        onRedirectAccepted: {
            print("Accepted")
        },
        onRedirectDeclined: {
            print("Declined")
        }
    )
}

