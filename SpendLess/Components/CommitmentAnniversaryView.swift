//
//  CommitmentAnniversaryView.swift
//  SpendLess
//
//  Celebration view for commitment anniversaries
//

import SwiftUI
import SwiftData

struct CommitmentAnniversaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var graveyardItems: [GraveyardItem]
    
    let milestone: Int
    let onDismiss: () -> Void
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var totalSaved: Decimal {
        graveyardItems.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.md) {
                    Text("🎉 \(milestone) DAYS! 🎉")
                        .font(SpendLessFont.largeTitle)
                        .foregroundStyle(Color.spendLessPrimary)
                    
                    Text(anniversaryMessage)
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, SpendLessSpacing.xl)
                
                if let signatureData = profile?.signatureImageData,
                   let uiImage = UIImage(data: signatureData),
                   let commitmentDate = profile?.commitmentDate {
                    VStack(spacing: SpendLessSpacing.sm) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                        
                        Text(formatCommitmentDate(commitmentDate))
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(SpendLessSpacing.md)
                    .background(Color.spendLessCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                }
                
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("Since then, you've kept")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    
                    Text(formatCurrency(totalSaved))
                        .font(SpendLessFont.largeTitle)
                        .foregroundStyle(Color.spendLessPrimary)
                    
                    Text("in your pocket.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                
                HStack(spacing: SpendLessSpacing.md) {
                    SecondaryButton("Share My Win") {
                        // TODO: Implement sharing
                        onDismiss()
                    }
                    
                    PrimaryButton("Continue") {
                        onDismiss()
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
            .padding(SpendLessSpacing.lg)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
            .padding(SpendLessSpacing.lg)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
    
    private var anniversaryMessage: String {
        switch milestone {
        case 7:
            return "One week down. You're building something."
        case 30:
            return "One month. You're literally rewiring your brain."
        case 90:
            return "90 days. Most people can't go 90 hours."
        case 365:
            return "One year. You did what most people only talk about."
        default:
            return "You're doing it. Keep going."
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

