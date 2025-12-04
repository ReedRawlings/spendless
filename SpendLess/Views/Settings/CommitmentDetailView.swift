//
//  CommitmentDetailView.swift
//  SpendLess
//
//  View for displaying user's commitment details
//

import SwiftUI
import SwiftData
import PencilKit

struct CommitmentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var profiles: [UserProfile]
    // Query only active goals to avoid loading all goals into memory
    @Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]

    @State private var showRenewSignature = false

    private var profile: UserProfile? {
        profiles.first
    }

    private var currentGoal: UserGoal? {
        activeGoals.first
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    // Commitment text and signature
                    Card {
                        VStack(spacing: SpendLessSpacing.md) {
                            if let goalType = profile?.goalType {
                                Text(generateCommitmentText(
                                    goalType: goalType,
                                    goalName: currentGoal?.name
                                ))
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextPrimary)
                                .multilineTextAlignment(.center)
                            }
                            
                            if let signatureData = profile?.signatureImageData,
                               let uiImage = UIImage(data: signatureData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 120)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, SpendLessSpacing.sm)
                            }
                            
                            if let commitmentDate = profile?.commitmentDate {
                                Text(formatCommitmentDate(commitmentDate))
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessTextMuted)
                                    .padding(.top, SpendLessSpacing.xs)
                            }
                        }
                        .padding(SpendLessSpacing.lg)
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    .padding(.top, SpendLessSpacing.lg)
                    
                    // Letter section
                    if let letterText = profile?.futureLetterText, !letterText.isEmpty {
                        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                            Text("MY LETTER TO MYSELF")
                                .font(SpendLessFont.headline)
                                .foregroundStyle(Color.spendLessTextPrimary)
                                .padding(.horizontal, SpendLessSpacing.md)
                            
                            Card {
                                Text(letterText)
                                    .font(SpendLessFont.body)
                                    .foregroundStyle(Color.spendLessTextPrimary)
                                    .multilineTextAlignment(.leading)
                                    .padding(SpendLessSpacing.md)
                            }
                            .padding(.horizontal, SpendLessSpacing.md)
                        }
                    }
                    
                    // Renew commitment button
                    PrimaryButton("Renew My Commitment") {
                        showRenewSignature = true
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.bottom, SpendLessSpacing.xl)
                }
            }
        }
        .navigationTitle("My Commitment")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRenewSignature) {
            RenewCommitmentView()
        }
    }
}

// MARK: - Renew Commitment View

struct RenewCommitmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var profiles: [UserProfile]
    
    @State private var drawing = PKDrawing()
    @State private var showSignatureSheet = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: SpendLessSpacing.lg) {
                    Spacer()
                    
                    VStack(spacing: SpendLessSpacing.md) {
                        Text("✍️")
                            .font(.system(size: 50))
                        
                        Text("Renew your commitment")
                            .font(SpendLessFont.title2)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        if let goalType = profile?.goalType {
                            Text(generateCommitmentText(
                                goalType: goalType,
                                goalName: nil
                            ))
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, SpendLessSpacing.lg)
                        }
                    }
                    
                    if let existingSignature = profile?.signatureImageData,
                       let uiImage = UIImage(data: existingSignature) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: SpendLessSpacing.sm) {
                            Image(systemName: "pencil.tip")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.spendLessTextMuted)
                            
                            Text("Tap to sign")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(SpendLessSpacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                        .strokeBorder(Color.spendLessTextMuted, lineWidth: 2)
                )
                .onTapGesture {
                    showSignatureSheet = true
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                PrimaryButton("Save") {
                    saveRenewal()
                }
                .disabled(profile?.signatureImageData == nil)
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
            .navigationTitle("Renew Commitment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSignatureSheet) {
                SignatureSheetView { signatureData, date in
                    profile?.signatureImageData = signatureData
                    profile?.commitmentDate = date
                    if !modelContext.saveSafely() {
                        print("⚠️ Warning: Failed to save signature")
                    }
                }
            }
        }
    }
    
    private func saveRenewal() {
        guard let profile = profile,
              profile.signatureImageData != nil else {
            return
        }

        // Sync to App Groups
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        if let letterText = profile.futureLetterText, !letterText.isEmpty {
            sharedDefaults?.set(letterText, forKey: "futureLetterText")
        }

        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save renewal")
        }
        dismiss()
    }
}

