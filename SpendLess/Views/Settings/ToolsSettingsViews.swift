//
//  ToolsSettingsViews.swift
//  SpendLess
//
//  Settings views for Tools configuration
//

import SwiftUI
import SwiftData

// MARK: - Dopamine Menu Settings

struct DopamineMenuSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    
    @State private var showSetup = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            List {
                Section {
                    if let profile, profile.hasDopamineMenuSetup {
                        // Show current activities
                        ForEach(Array(profile.dopamineMenuSelectedDefaults), id: \.self) { activity in
                            HStack {
                                Text(activity.emoji)
                                    .font(.title2)
                                Text(activity.rawValue)
                                    .font(SpendLessFont.body)
                            }
                        }
                        
                        ForEach(profile.dopamineMenuCustomActivities ?? [], id: \.self) { activity in
                            HStack {
                                Text("✨")
                                    .font(.title2)
                                Text(activity)
                                    .font(SpendLessFont.body)
                            }
                        }
                    } else {
                        Text("No activities configured")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextMuted)
                    }
                } header: {
                    Text("Current Activities")
                }
                
                Section {
                    Button {
                        showSetup = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil.circle")
                                .foregroundStyle(Color.spendLessPrimary)
                            Text(profile?.hasDopamineMenuSetup == true ? "Edit Activities" : "Set Up Dopamine Menu")
                                .foregroundStyle(Color.spendLessPrimary)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Dopamine Menu")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSetup) {
            NavigationStack {
                DopamineMenuSetupView(isInitialSetup: false)
            }
        }
    }
}

// MARK: - Birth Year Settings

struct BirthYearSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    
    @State private var selectedYear: Int = 1990
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    private var currentAge: Int {
        currentYear - selectedYear
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("Birth Year")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Used for calculating opportunity cost")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.xl)
                
                Picker("Birth Year", selection: $selectedYear) {
                    ForEach((currentYear - 80)...(currentYear - 16), id: \.self) { year in
                        Text("\(year)").tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 180)
                
                Text("Age: \(currentAge) years old")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessPrimary)
                
                Text("Years until 65: \(max(65 - currentAge, 0))")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                
                Spacer()
                
                PrimaryButton("Save") {
                    saveBirthYear()
                }
                .padding(.horizontal, SpendLessSpacing.md)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
        .navigationTitle("Birth Year")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let birthYear = profile?.birthYear {
                selectedYear = birthYear
            } else {
                // Default to 30 years ago
                selectedYear = currentYear - 30
            }
        }
    }
    
    private func saveBirthYear() {
        HapticFeedback.mediumSuccess()
        
        if let profile {
            profile.birthYear = selectedYear
        } else {
            let newProfile = UserProfile()
            newProfile.birthYear = selectedYear
            modelContext.insert(newProfile)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Preview

#Preview("Dopamine Menu Settings") {
    NavigationStack {
        DopamineMenuSettingsView()
    }
    .modelContainer(for: [UserProfile.self], inMemory: true)
}

#Preview("Birth Year Settings") {
    NavigationStack {
        BirthYearSettingsView()
    }
    .modelContainer(for: [UserProfile.self], inMemory: true)
}

