//
//  EditLetterView.swift
//  SpendLess
//
//  View for editing the future self letter
//

import SwiftUI
import SwiftData

struct EditLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var profiles: [UserProfile]
    
    @State private var letterText: String = ""
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: SpendLessSpacing.lg) {
                    VStack(spacing: SpendLessSpacing.sm) {
                        Text("Edit Your Letter")
                            .font(SpendLessFont.title2)
                            .foregroundStyle(Color.spendLessTextPrimary)
                            .padding(.top, SpendLessSpacing.lg)
                        
                        Text("This message will appear when you need it most.")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    
                    TextEditor(text: $letterText)
                        .frame(minHeight: 200)
                        .padding(SpendLessSpacing.sm)
                        .background(Color.spendLessCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                        .padding(.horizontal, SpendLessSpacing.lg)
                    
                    Spacer()
                    
                    PrimaryButton("Save") {
                        saveLetter()
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.bottom, SpendLessSpacing.xl)
                }
            }
            .navigationTitle("Edit Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                letterText = profile?.futureLetterText ?? ""
            }
        }
    }
    
    private func saveLetter() {
        profile?.futureLetterText = letterText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Sync to App Groups
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        if !letterText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sharedDefaults?.set(letterText.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "futureLetterText")
        }
        
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save letter")
        }
        dismiss()
    }
}

