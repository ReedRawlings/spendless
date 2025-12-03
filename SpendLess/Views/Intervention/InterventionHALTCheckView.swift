//
//  InterventionHALTCheckView.swift
//  SpendLess
//
//  HALT (Hungry, Angry, Lonely, Tired) check for intervention flow
//

import SwiftUI

struct InterventionHALTCheckView: View {
    @Bindable var manager: InterventionManager
    let onComplete: (HALTState?) -> Void
    
    @State private var appeared = false
    @State private var selectedState: HALTState? = nil
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Header
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Before you go in...")
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("How are you feeling?")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer()
            
            // HALT Options
            VStack(spacing: SpendLessSpacing.md) {
                ForEach(HALTState.allCases) { state in
                    HALTOptionButton(
                        emoji: state.emoji,
                        label: state.displayName,
                        isSelected: selectedState == state
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedState = (selectedState == state) ? nil : state
                        }
                        
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            
            // Continue button
            VStack(spacing: SpendLessSpacing.md) {
                PrimaryButton("I'm fine, actually") {
                    onComplete(nil)
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
        .onChange(of: selectedState) { _, newValue in
            // Auto-advance when a state is selected
            if let state = newValue {
                // Small delay for visual feedback
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onComplete(state)
                }
            }
        }
    }
}

// MARK: - HALT Option Button

struct HALTOptionButton: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SpendLessSpacing.md) {
                Text(emoji)
                    .font(.title2)
                
                Text(label)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(isSelected ? .white : Color.spendLessTextPrimary)
                
                Spacer()
            }
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .fill(isSelected ? Color.spendLessPrimary : Color.spendLessCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(isSelected ? Color.clear : Color.spendLessBackgroundSecondary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    InterventionHALTCheckView(manager: .shared) { state in
        print("Selected: \(state?.displayName ?? "none")")
    }
}
