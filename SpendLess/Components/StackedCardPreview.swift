//
//  StackedCardPreview.swift
//  SpendLess
//
//  Stacked card preview component for lead magnet PDF preview
//

import SwiftUI

struct StackedCardPreview: View {
    @State private var showCards = false
    
    var body: some View {
        ZStack {
            // Back card (sage green)
            card(
                color: Color.spendLessSecondaryLight,
                label: "The Two Pathways",
                icon: "arrow.triangle.branch",
                rotation: -3,
                offset: CGSize(width: -8, height: 8),
                delay: 0.1
            )
            
            // Middle card (warm gold)
            card(
                color: Color.spendLessGoldLight,
                label: "3-Minute Reset",
                icon: "timer",
                rotation: 0,
                offset: CGSize(width: 0, height: 0),
                delay: 0.2
            )
            
            // Front card (coral/primary)
            card(
                color: Color.spendLessPrimary,
                label: "Your Action Plan",
                icon: "checkmark.circle.fill",
                rotation: 3,
                offset: CGSize(width: 8, height: -8),
                delay: 0.3
            )
        }
        .frame(height: 200)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                showCards = true
            }
        }
    }
    
    private func card(
        color: Color,
        label: String,
        icon: String,
        rotation: Double,
        offset: CGSize,
        delay: Double
    ) -> some View {
        VStack(spacing: SpendLessSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.9))
            
            Text(label)
                .font(SpendLessFont.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.95))
        }
        .frame(maxWidth: .infinity)
        .padding(SpendLessSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                .fill(color)
        )
        .rotationEffect(.degrees(showCards ? rotation : 0))
        .offset(showCards ? offset : CGSize(width: 0, height: 20))
        .opacity(showCards ? 1 : 0)
        .spendLessShadow(SpendLessShadow.cardShadow)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7)
            .delay(delay),
            value: showCards
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        StackedCardPreview()
        Spacer()
    }
    .padding()
    .background(Color.spendLessBackground)
}

