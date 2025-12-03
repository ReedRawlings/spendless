//
//  InterventionReflectionView.swift
//  SpendLess
//
//  Reflection question after breathing exercise
//

import SwiftUI

struct InterventionReflectionView: View {
    let onJustBrowsing: () -> Void
    let onSomethingSpecific: () -> Void
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.spendLessPrimary.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 45))
                    .foregroundStyle(Color.spendLessPrimary)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.5)
            
            // Question
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Nice work pausing.")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("What brought you here?")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer()
            
            // Options
            VStack(spacing: SpendLessSpacing.md) {
                Button(action: onSomethingSpecific) {
                    HStack(spacing: SpendLessSpacing.md) {
                        Image(systemName: "tag.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                            Text("I wanted something specific")
                                .font(SpendLessFont.headline)
                            
                            Text("Add it to your waiting list")
                                .font(SpendLessFont.caption)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.medium))
                    }
                    .foregroundStyle(.white)
                    .padding(SpendLessSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .fill(Color.spendLessPrimary)
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: onJustBrowsing) {
                    HStack(spacing: SpendLessSpacing.md) {
                        Image(systemName: "eye.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                            Text("Just browsing")
                                .font(SpendLessFont.headline)
                            
                            Text("I don't need anything")
                                .font(SpendLessFont.caption)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.medium))
                    }
                    .foregroundStyle(Color.spendLessPrimary)
                    .padding(SpendLessSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .fill(Color.spendLessPrimary.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 30)
            
            Spacer()
                .frame(height: SpendLessSpacing.xxl)
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
    InterventionReflectionView(
        onJustBrowsing: { print("Just browsing") },
        onSomethingSpecific: { print("Something specific") }
    )
}

