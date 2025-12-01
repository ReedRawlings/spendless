//
//  OnboardingScreens2.swift
//  SpendLess
//
//  Onboarding screens 9-15
//

import SwiftUI

// MARK: - Screen 9: Commitment

struct OnboardingCommitmentView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
    @State private var hasSigned = false
    
    var body: some View {
        OnboardingContainer(step: .commitment) {
            VStack(spacing: SpendLessSpacing.lg) {
                Spacer()
                
                VStack(spacing: SpendLessSpacing.md) {
                    Text("One last thing.")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    if appState.onboardingGoalType.requiresDetails && !appState.onboardingGoalName.isEmpty {
                        Text("Every dollar you don't waste is a dollar toward \(appState.onboardingGoalName).")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Every dollar you don't waste stays in your pocket.")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Signature area
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("Tap below to commit")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            hasSigned = true
                        }
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    } label: {
                        VStack(spacing: SpendLessSpacing.sm) {
                            if hasSigned {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.spendLessPrimary)
                                
                                Text("I'm done buying things I don't need.")
                                    .font(SpendLessFont.bodyBold)
                                    .foregroundStyle(Color.spendLessPrimary)
                            } else {
                                Image(systemName: "hand.tap")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.spendLessTextMuted)
                                
                                Text("I'm done buying things I don't need.")
                                    .font(SpendLessFont.body)
                                    .foregroundStyle(Color.spendLessTextSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(SpendLessSpacing.xl)
                        .background(
                            RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                                .strokeBorder(
                                    hasSigned ? Color.spendLessPrimary : Color.spendLessTextMuted,
                                    lineWidth: 2,
                                    antialiased: true
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                PrimaryButton("I'm ready", icon: "arrow.right") {
                    onContinue()
                }
                .disabled(!hasSigned)
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
}

// MARK: - Screen 10: Permission Explanation

struct OnboardingPermissionView: View {
    let onContinue: () -> Void
    
    @State private var isRequestingAuth = false
    
    var body: some View {
        OnboardingContainer(step: .permissionExplanation) {
            VStack(spacing: SpendLessSpacing.lg) {
                Spacer()
                
                Image(systemName: "hourglass.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.spendLessPrimary)
                
                VStack(spacing: SpendLessSpacing.md) {
                    Text("To block shopping apps, we need Screen Time access.")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                        featureRow(icon: "checkmark.circle.fill", text: "Block apps you choose")
                        featureRow(icon: "checkmark.circle.fill", text: "Show you when you're tempted")
                        featureRow(icon: "checkmark.circle.fill", text: "Keep your data 100% private")
                    }
                    .padding(.top, SpendLessSpacing.sm)
                    
                    Text("Your browsing stays on your device. We never see what you buy.")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, SpendLessSpacing.sm)
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                PrimaryButton("Grant Access", icon: "lock.open", isLoading: isRequestingAuth) {
                    requestAuthorization()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: SpendLessSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(Color.spendLessSecondary)
            Text(text)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextPrimary)
        }
    }
    
    private func requestAuthorization() {
        isRequestingAuth = true
        
        Task {
            do {
                try await ScreenTimeManager.shared.requestAuthorization()
                await MainActor.run {
                    isRequestingAuth = false
                    onContinue()
                }
            } catch {
                await MainActor.run {
                    isRequestingAuth = false
                    // Still continue even if authorization fails
                    onContinue()
                }
            }
        }
    }
}

// MARK: - Screen 11: App Selection

struct OnboardingAppSelectionView: View {
    let onContinue: () -> Void
    
    @State private var showPicker = false
    
    var body: some View {
        OnboardingContainer(step: .appSelection) {
            VStack(spacing: SpendLessSpacing.lg) {
                Spacer()
                
                VStack(spacing: SpendLessSpacing.md) {
                    Text("Now let's block those apps.")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Look for the SHOPPING category and select the apps that tempt you most.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Selected apps count
                if ScreenTimeManager.shared.blockedAppCount > 0 {
                    Card {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.spendLessSecondary)
                            Text("\(ScreenTimeManager.shared.blockedAppCount) apps selected")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessTextPrimary)
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                }
                
                Spacer()
                
                VStack(spacing: SpendLessSpacing.md) {
                    PrimaryButton("Select Apps", icon: "apps.iphone") {
                        showPicker = true
                    }
                    
                    if ScreenTimeManager.shared.blockedAppCount > 0 {
                        SecondaryButton("Continue") {
                            onContinue()
                        }
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
        .sheet(isPresented: $showPicker) {
            MockAppPickerView()
        }
    }
}

// MARK: - Screen 12: Website Blocking

struct OnboardingWebsiteBlockingView: View {
    let onContinue: () -> Void
    
    @State private var blockAllShopping = false
    
    var body: some View {
        OnboardingContainer(step: .websiteBlocking) {
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("What about shopping in Safari?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("You can also shop through websites. Want to block those too?")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, SpendLessSpacing.xl)
                .padding(.horizontal, SpendLessSpacing.lg)
                
                VStack(spacing: SpendLessSpacing.sm) {
                    SelectionCard(
                        title: "Block all shopping websites",
                        subtitle: "Recommended",
                        icon: "🛡️",
                        isSelected: blockAllShopping
                    ) {
                        blockAllShopping = true
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                    
                    SelectionCard(
                        title: "Skip for now",
                        subtitle: "You can enable this later",
                        icon: "⏭️",
                        isSelected: !blockAllShopping
                    ) {
                        blockAllShopping = false
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
                .padding(.horizontal, SpendLessSpacing.md)
                
                Spacer()
                
                PrimaryButton("Continue") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
}

// MARK: - Screen 13: Selection Confirmation

struct OnboardingConfirmationView: View {
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingContainer(step: .selectionConfirmation) {
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("Perfect!")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    if ScreenTimeManager.shared.blockedAppCount > 0 {
                        Text("You selected \(ScreenTimeManager.shared.blockedAppCount) apps to block.")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                }
                .padding(.top, SpendLessSpacing.xl)
                
                // Show selected apps
                if !ScreenTimeManager.shared.mockSelectedApps.isEmpty {
                    ScrollView {
                        VStack(spacing: SpendLessSpacing.sm) {
                            ForEach(ScreenTimeManager.shared.mockSelectedApps) { app in
                                HStack(spacing: SpendLessSpacing.md) {
                                    IconView(appIcon(for: app.name), font: .title2)
                                    
                                    Text(app.name)
                                        .font(SpendLessFont.body)
                                        .foregroundStyle(Color.spendLessTextPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.spendLessSecondary)
                                }
                                .padding(SpendLessSpacing.md)
                                .background(Color.spendLessCardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                    }
                }
                
                Text("These apps are now being watched. When you try to open them, we'll help you pause and think.")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                PrimaryButton("Continue") {
                    // Apply shields
                    ScreenTimeManager.shared.applyShields()
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
    
    private func appIcon(for name: String) -> String {
        switch name {
        case "Amazon": return "🛒"
        case "Shein": return "👗"
        case "Temu": return "📦"
        case "Target": return "🎯"
        case "Walmart": return "🛒"
        case "TikTok Shop": return "🎵"
        case "Instagram": return "📸"
        case "Etsy": return "🏠"
        case "ASOS": return "👠"
        case "Sephora": return "💄"
        default: return "📱"
        }
    }
}

// MARK: - Screen 14: How It Works

struct OnboardingHowItWorksView: View {
    let onContinue: () -> Void
    
    @State private var currentSlide = 0
    
    private let slides = [
        ("hand.raised.fill", "When you try to open a blocked app...", "We'll step in and ask what you wanted."),
        ("questionmark.circle.fill", "We'll ask what you wanted", "Just browsing? Something specific? We'll help you decide."),
        ("clock.fill", "Add it to your 7-day Waiting List", "If you still want it after a week, buy it guilt-free."),
        ("leaf.fill", "Bury what you don't need", "Most impulses don't survive 7 days. Watch your Cart Graveyard grow!"),
        ("target", "Watch your progress", "Every dollar you don't waste goes toward your goal.")
    ]
    
    var body: some View {
        OnboardingContainer(step: .howItWorks) {
            VStack(spacing: SpendLessSpacing.lg) {
                Text("How we'll help")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .padding(.top, SpendLessSpacing.xl)
                
                TabView(selection: $currentSlide) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        slideView(index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                Text("Most impulses don't survive 7 days.")
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessPrimary)
                
                PrimaryButton("Let's do this", icon: "arrow.right") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
    
    private func slideView(index: Int) -> some View {
        let slide = slides[index]
        return VStack(spacing: SpendLessSpacing.lg) {
            Image(systemName: slide.0)
                .font(.system(size: 60))
                .foregroundStyle(Color.spendLessPrimary)
            
            VStack(spacing: SpendLessSpacing.sm) {
                Text(slide.1)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(slide.2)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, SpendLessSpacing.lg)
        }
        .padding()
    }
}

// MARK: - Screen 15: Difficulty Mode

struct OnboardingDifficultyModeView: View {
    @Environment(AppState.self) private var appState
    let onComplete: () -> Void
    
    var body: some View {
        OnboardingContainer(step: .difficultyMode) {
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("How strict should we be?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("You can change this anytime in Settings")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.xl)
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.md) {
                        ForEach(DifficultyMode.allCases) { mode in
                            DifficultyModeCard(
                                mode: mode,
                                isSelected: appState.onboardingDifficultyMode == mode
                            ) {
                                appState.onboardingDifficultyMode = mode
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                }
                
                PrimaryButton("Start my journey", icon: "sparkles") {
                    onComplete()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
}

// MARK: - Previews

#Preview("Commitment") {
    OnboardingCommitmentView {}
        .environment(AppState.shared)
}

#Preview("Permission") {
    OnboardingPermissionView {}
        .environment(AppState.shared)
}

#Preview("App Selection") {
    OnboardingAppSelectionView {}
        .environment(AppState.shared)
}

#Preview("How It Works") {
    OnboardingHowItWorksView {}
        .environment(AppState.shared)
}

#Preview("Difficulty Mode") {
    OnboardingDifficultyModeView {}
        .environment(AppState.shared)
}

