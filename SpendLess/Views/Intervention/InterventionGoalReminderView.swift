//
//  InterventionGoalReminderView.swift
//  SpendLess
//
//  Shows user's goal and commitment during intervention
//

import SwiftUI

struct InterventionGoalReminderView: View {
    let onComplete: (Bool) -> Void
    
    @State private var appeared = false
    
    // Read from shared defaults
    private var goalName: String {
        UserDefaults(suiteName: AppConstants.appGroupID)?.string(forKey: "goalName") ?? "Your Goal"
    }

    private var savedAmount: Double {
        UserDefaults(suiteName: AppConstants.appGroupID)?.double(forKey: "savedAmount") ?? 0
    }

    private var targetAmount: Double {
        UserDefaults(suiteName: AppConstants.appGroupID)?.double(forKey: "targetAmount") ?? 1000
    }

    private var commitment: String {
        let defaults = UserDefaults(suiteName: AppConstants.appGroupID)
        return defaults?.string(forKey: "userCommitment")
            ?? defaults?.string(forKey: "futureLetterText")
            ?? "I'm done buying things I don't need"
    }
    
    private var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(savedAmount / targetAmount, 1.0)
    }
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Goal visualization
            VStack(spacing: SpendLessSpacing.md) {
                // Goal icon
                ZStack {
                    Circle()
                        .fill(Color.spendLessGold.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Text("🎯")
                        .font(.system(size: 50))
                }
                .scaleEffect(appeared ? 1 : 0.5)
                
                Text(goalName)
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                // Progress bar
                VStack(spacing: SpendLessSpacing.xs) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: SpendLessRadius.sm)
                                .fill(Color.spendLessBackgroundSecondary)
                            
                            RoundedRectangle(cornerRadius: SpendLessRadius.sm)
                                .fill(Color.spendLessGold)
                                .frame(width: geometry.size.width * progress)
                        }
                    }
                    .frame(height: 16)
                    
                    HStack {
                        Text("$\(Int(savedAmount)) saved")
                            .font(SpendLessFont.subheadline)
                            .foregroundStyle(Color.spendLessTextSecondary)
                        
                        Spacer()
                        
                        Text("$\(Int(targetAmount)) goal")
                            .font(SpendLessFont.subheadline)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                }
                .padding(.horizontal, SpendLessSpacing.xxl)
            }
            .opacity(appeared ? 1 : 0)
            
            // Commitment
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Your commitment:")
                    .font(SpendLessFont.subheadline)
                    .foregroundStyle(Color.spendLessTextSecondary)
                
                Text("\"\(commitment)\"")
                    .font(SpendLessFont.body)
                    .fontWeight(.medium)
                    .italic()
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SpendLessSpacing.xl)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            Spacer()
            
            // Actions
            VStack(spacing: SpendLessSpacing.md) {
                PrimaryButton("You're right, I'll pass") {
                    onComplete(true)
                }
                
                SecondaryButton("I still need to check") {
                    onComplete(false)
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xxl)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    InterventionGoalReminderView { resisted in
        print("Resisted: \(resisted)")
    }
}

