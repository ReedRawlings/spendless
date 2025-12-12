//
//  OnboardingScreens2.swift
//  SpendLess
//
//  Onboarding screens 9-15
//

import SwiftUI
import PencilKit
import FamilyControls

// MARK: - Screen 9: Commitment (3-Page Flow)

struct OnboardingCommitmentView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
    @State private var currentPage = 0
    @State private var letterText = "" // Kept for backward compatibility but not used in new flow
    @State private var hasSigned = false
    @State private var showSignatureSheet = false
    @State private var commitmentDate: Date?
    @State private var showGlow = false
    @State private var triggerConfetti = false
    
    // Animation states for confrontation page
    @State private var showFirstCard = false
    @State private var showSecondCard = false
    @State private var showButton = false
    @State private var secondCardIconPop = false
    
    // Animation states for profile analysis page
    @State private var isAnalyzing = true
    @State private var showHeader = false
    @State private var showStrengths = false
    @State private var showFocusAreas = false
    @State private var showPrediction = false
    @State private var showLetterSelection = false
    @State private var selectedLetterOption: FutureSelfLetterOption?
    
    private let totalPages = 3
    
    var body: some View {
        OnboardingContainer(step: .commitment) {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    // Page 1: The Confrontation
                    confrontationPage
                        .tag(0)
                    
                    // Page 2: Future Self Letter
                    futureSelfLetterPage
                        .tag(1)
                    
                    // Page 3: The Signature
                    signaturePage
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Page indicator
                HStack(spacing: SpendLessSpacing.xs) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.spendLessPrimary : Color.spendLessTextMuted)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, SpendLessSpacing.md)
                .padding(.bottom, SpendLessSpacing.lg)
            }
        }
        .sheet(isPresented: $showSignatureSheet) {
            SignatureSheetView(
                onSave: { signatureData, date in
                    appState.onboardingSignatureData = signatureData
                    appState.onboardingCommitmentDate = date
                    commitmentDate = date
                    hasSigned = true
                    showSignatureSheet = false
                    
                    // Trigger celebration
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        hasSigned = true
                    }
                    
                    // Delayed glow
                    withAnimation(.easeInOut(duration: 0.6).delay(0.2)) {
                        showGlow = true
                    }
                    
                    // Trigger confetti
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        triggerConfetti = true
                    }
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            )
        }
    }
    
    // MARK: - Page 1: The Confrontation
    
    private var confrontationPage: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            VStack(spacing: SpendLessSpacing.lg) {
                Text("Let's be real.")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("You told us you spend about")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    
                    Text(formatCurrency(appState.onboardingSpendRange.monthlyEstimate))
                        .font(SpendLessFont.largeTitle)
                        .foregroundStyle(Color.spendLessPrimary)
                    
                    Text("every month on things you don't need.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .multilineTextAlignment(.center)
                
                // Two paths visualization
                VStack(spacing: SpendLessSpacing.md) {
                    // Negative path (dimmed)
                    pathCard(
                        icon: "💸",
                        destination: "🗑️",
                        amount: formatCurrency(appState.onboardingSpendRange.yearlyEstimate) + "/yr",
                        label: "Where it's going now",
                        isHighlighted: false
                    )
                    .opacity(showFirstCard ? 1 : 0)
                    .offset(x: showFirstCard ? 0 : -30)
                    .animation(.easeOut(duration: 0.4), value: showFirstCard)
                    
                    // Positive path (highlighted) - inline to support icon pop animation
                    HStack(spacing: SpendLessSpacing.md) {
                        Text("💵")
                            .font(.title)
                        
                        HStack(spacing: SpendLessSpacing.xs) {
                            Text("→")
                                .foregroundStyle(Color.spendLessPrimary)
                            Text("→")
                                .foregroundStyle(Color.spendLessPrimary)
                            Text("→")
                                .foregroundStyle(Color.spendLessPrimary)
                        }
                        
                        Text(positivePathIcon)
                            .font(.title2)
                            .scaleEffect(secondCardIconPop ? 1 : 0.5)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: secondCardIconPop)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: SpendLessSpacing.xxs) {
                            Text(positivePathText)
                                .font(SpendLessFont.headline)
                                .foregroundStyle(Color.spendLessPrimary)
                            
                            Text("Where it could go")
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextSecondary)
                        }
                    }
                    .padding(SpendLessSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .fill(Color.spendLessPrimary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                    .strokeBorder(Color.spendLessPrimary, lineWidth: 2)
                            )
                    )
                    .opacity(showSecondCard ? 1 : 0)
                    .offset(y: showSecondCard ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showSecondCard)
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            
            PrimaryButton(ctaText) {
                withAnimation {
                    currentPage = 1
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
            .opacity(showButton ? 1 : 0)
            .scaleEffect(showButton ? 1 : 0.95)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showButton)
        }
        .onAppear {
            // Only animate if we're on the confrontation page
            guard currentPage == 0 else { return }
            
            // Reset animation states when view appears
            showFirstCard = false
            showSecondCard = false
            showButton = false
            secondCardIconPop = false
            
            // Sequence the card reveals
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                guard currentPage == 0 else { return }
                withAnimation(.easeOut(duration: 0.4)) {
                    showFirstCard = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                guard currentPage == 0 else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showSecondCard = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                guard currentPage == 0 else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    secondCardIconPop = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                guard currentPage == 0 else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showButton = true
                }
            }
        }
        .onChange(of: currentPage) { oldValue, newValue in
            // Reset animations when navigating away from confrontation page
            if newValue != 0 {
                showFirstCard = false
                showSecondCard = false
                showButton = false
                secondCardIconPop = false
            }
        }
    }
    
    private var goalDestination: String {
        appState.onboardingGoalType.icon
    }
    
    private var goalName: String {
        if appState.onboardingGoalType.requiresDetails && !appState.onboardingGoalName.isEmpty {
            return appState.onboardingGoalName
        } else {
            switch appState.onboardingGoalType {
            case .vacation: return "Your dream trip"
            case .debtFree: return "Freedom from debt"
            case .emergency: return "Peace of mind"
            case .justStop: return "Your wallet"
            default: return "Your goal"
            }
        }
    }
    
    // MARK: - Dynamic CTA Text
    
    private var ctaText: String {
        switch appState.onboardingGoalType {
        case .emergency:
            return "I choose security"
        case .vacation:
            if appState.onboardingGoalName.isEmpty {
                return "I choose adventure"
            } else {
                return "I choose \(appState.onboardingGoalName)"
            }
        case .debtFree:
            return "I choose freedom"
        case .retirement:
            return "I choose my future"
        case .downPayment:
            return "I choose my home"
        case .car:
            return "I choose the car"
        case .bigPurchase:
            if appState.onboardingGoalName.isEmpty {
                return "I'm taking this back"
            } else {
                return "I choose \(appState.onboardingGoalName)"
            }
        case .justStop:
            return "That money stays mine"
        }
    }
    
    // MARK: - Dynamic Positive Path Content
    
    private var positivePathText: String {
        let displayName = getGoalDisplayName(
            goalType: appState.onboardingGoalType,
            goalName: appState.onboardingGoalName.isEmpty ? nil : appState.onboardingGoalName
        )
        return displayName
    }
    
    private var positivePathIcon: String {
        switch appState.onboardingGoalType {
        case .emergency: return "🛡️"
        case .vacation: return "✈️"
        case .debtFree: return "⛓️‍💥"
        case .retirement: return "🌅"
        case .downPayment: return "🏠"
        case .car: return "🚗"
        case .bigPurchase: return "🎁"
        case .justStop: return "🏝️"
        }
    }
    
    private func pathCard(icon: String, destination: String, amount: String, label: String, isHighlighted: Bool) -> some View {
        HStack(spacing: SpendLessSpacing.md) {
            Text(icon)
                .font(.title)
            
            HStack(spacing: SpendLessSpacing.xs) {
                Text("→")
                    .foregroundStyle(isHighlighted ? Color.spendLessPrimary : Color.spendLessTextMuted)
                Text("→")
                    .foregroundStyle(isHighlighted ? Color.spendLessPrimary : Color.spendLessTextMuted)
                Text("→")
                    .foregroundStyle(isHighlighted ? Color.spendLessPrimary : Color.spendLessTextMuted)
            }
            
            Text(destination)
                .font(.title2)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: SpendLessSpacing.xxs) {
                Text(amount)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(isHighlighted ? Color.spendLessPrimary : Color.spendLessTextMuted)
                
                Text(label)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(isHighlighted ? Color.spendLessTextSecondary : Color.spendLessTextMuted)
            }
        }
        .padding(SpendLessSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SpendLessRadius.md)
                .fill(isHighlighted ? Color.spendLessPrimary.opacity(0.1) : Color.spendLessCardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendLessRadius.md)
                        .strokeBorder(
                            isHighlighted ? Color.spendLessPrimary : Color.spendLessTextMuted.opacity(0.3),
                            lineWidth: isHighlighted ? 2 : 1
                        )
                )
        )
    }
    
    // MARK: - Page 2: Your Profile
    
    private var analysis: ProfileAnalysis {
        ProfileAnalysisEngine.analyzeProfile(appState: appState)
    }
    
    private var futureSelfLetterPage: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                if isAnalyzing {
                    // Analyzing state
                    VStack(spacing: SpendLessSpacing.md) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.spendLessPrimary)
                        
                        Text("Analyzing your patterns...")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                } else {
                    // Header
                    VStack(spacing: SpendLessSpacing.xs) {
                        Text("✨ YOUR PROFILE")
                            .font(SpendLessFont.title2)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        Text("Based on what you shared, here's what we see.")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, SpendLessSpacing.lg)
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .opacity(showHeader ? 1 : 0)
                    .offset(y: showHeader ? 0 : 10)
                    
                    // Strengths Section
                    if !analysis.strengths.isEmpty {
                        VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                            HStack(spacing: SpendLessSpacing.xs) {
                                Text("🌟")
                                Text("STRENGTHS")
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessGold)
                            }
                            
                            Rectangle()
                                .fill(Color.spendLessGold.opacity(0.3))
                                .frame(height: 1)
                            
                            VStack(spacing: SpendLessSpacing.sm) {
                                ForEach(Array(analysis.strengths.enumerated()), id: \.offset) { index, strength in
                                    Card {
                                        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                                            Text(strength.title)
                                                .font(SpendLessFont.bodyBold)
                                                .foregroundStyle(Color.spendLessTextPrimary)
                                            
                                            Text(strength.description)
                                                .font(SpendLessFont.body)
                                                .foregroundStyle(Color.spendLessTextSecondary)
                                        }
                                    }
                                    .opacity(showStrengths ? 1 : 0)
                                    .offset(y: showStrengths ? 0 : 10)
                                    .animation(
                                        .spring(response: 0.4, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.1),
                                        value: showStrengths
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.lg)
                    }
                    
                    // Focus Areas Section
                    if !analysis.focusAreas.isEmpty {
                        VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                            HStack(spacing: SpendLessSpacing.xs) {
                                Text("🌱")
                                Text("AREAS FOR EXPLORATION")
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessSecondary)
                            }
                            
                            Rectangle()
                                .fill(Color.spendLessSecondary.opacity(0.3))
                                .frame(height: 1)
                            
                            VStack(spacing: SpendLessSpacing.sm) {
                                ForEach(Array(analysis.focusAreas.enumerated()), id: \.offset) { index, focusArea in
                                    Card {
                                        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                                            Text(focusArea.title)
                                                .font(SpendLessFont.bodyBold)
                                                .foregroundStyle(Color.spendLessTextPrimary)
                                            
                                            Text(focusArea.description)
                                                .font(SpendLessFont.body)
                                                .foregroundStyle(Color.spendLessTextSecondary)
                                        }
                                    }
                                    .background(Color.spendLessSecondary.opacity(0.05))
                                    .opacity(showFocusAreas ? 1 : 0)
                                    .offset(y: showFocusAreas ? 0 : 10)
                                    .animation(
                                        .spring(response: 0.4, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.1),
                                        value: showFocusAreas
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.lg)
                    }
                    
                    // Prediction Section
                    if let prediction = analysis.prediction {
                        VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                            Card {
                                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                                    HStack(spacing: SpendLessSpacing.xs) {
                                        Text("📅")
                                        Text("YOUR PATH")
                                            .font(SpendLessFont.bodyBold)
                                            .foregroundStyle(Color.spendLessTextPrimary)
                                    }
                                    
                                    Text("At your pace—resisting just \(prediction.resistanceRate) of impulses—you could reach your goal in ~\(prediction.daysToGoal) days.")
                                        .font(SpendLessFont.body)
                                        .foregroundStyle(Color.spendLessTextSecondary)
                                }
                            }
                            .background(Color.spendLessPrimary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                                    .strokeBorder(Color.spendLessPrimary, lineWidth: 1)
                            )
                            .opacity(showPrediction ? 1 : 0)
                            .offset(y: showPrediction ? 0 : 10)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showPrediction)
                        }
                        .padding(.horizontal, SpendLessSpacing.lg)
                    } else if appState.onboardingGoalType == .justStop {
                        VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                            Card {
                                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                                    HStack(spacing: SpendLessSpacing.xs) {
                                        Text("📅")
                                        Text("YOUR PATH")
                                            .font(SpendLessFont.bodyBold)
                                            .foregroundStyle(Color.spendLessTextPrimary)
                                    }
                                    
                                    Text("Every dollar you keep is a win. Let's start counting.")
                                        .font(SpendLessFont.body)
                                        .foregroundStyle(Color.spendLessTextSecondary)
                                }
                            }
                            .background(Color.spendLessPrimary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                                    .strokeBorder(Color.spendLessPrimary, lineWidth: 1)
                            )
                            .opacity(showPrediction ? 1 : 0)
                            .offset(y: showPrediction ? 0 : 10)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showPrediction)
                        }
                        .padding(.horizontal, SpendLessSpacing.lg)
                    } else if appState.onboardingGoalAmount > 0 {
                        // Long timeline case (>365 days)
                        VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                            Card {
                                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                                    HStack(spacing: SpendLessSpacing.xs) {
                                        Text("📅")
                                        Text("YOUR PATH")
                                            .font(SpendLessFont.bodyBold)
                                            .foregroundStyle(Color.spendLessTextPrimary)
                                    }
                                    
                                    Text("At your pace, you'll make real progress within your first month.")
                                        .font(SpendLessFont.body)
                                        .foregroundStyle(Color.spendLessTextSecondary)
                                }
                            }
                            .background(Color.spendLessPrimary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                                    .strokeBorder(Color.spendLessPrimary, lineWidth: 1)
                            )
                            .opacity(showPrediction ? 1 : 0)
                            .offset(y: showPrediction ? 0 : 10)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showPrediction)
                        }
                        .padding(.horizontal, SpendLessSpacing.lg)
                    }
                    
                    // Letter Selection Section
                    VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                        HStack(spacing: SpendLessSpacing.xs) {
                            Text("💌")
                            Text("YOUR REMINDER")
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextSecondary)
                        }
                        
                        Text("Choose a message to show yourself when you're tempted:")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .padding(.bottom, SpendLessSpacing.xs)
                        
                        let letterOptions = getFutureSelfLetterOptions(
                            goalName: appState.onboardingGoalName.isEmpty ? nil : appState.onboardingGoalName
                        )
                        
                        VStack(spacing: SpendLessSpacing.sm) {
                            ForEach(letterOptions.prefix(4)) { option in
                                Button {
                                    selectedLetterOption = option
                                    appState.onboardingFutureLetterText = option.text
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                } label: {
                                    HStack(alignment: .top, spacing: SpendLessSpacing.sm) {
                                        // Selection indicator
                                        ZStack {
                                            Circle()
                                                .stroke(
                                                    selectedLetterOption?.id == option.id ? Color.spendLessPrimary : Color.spendLessTextMuted,
                                                    lineWidth: 2
                                                )
                                                .frame(width: 20, height: 20)
                                            
                                            if selectedLetterOption?.id == option.id {
                                                Circle()
                                                    .fill(Color.spendLessPrimary)
                                                    .frame(width: 12, height: 12)
                                            }
                                        }
                                        .padding(.top, 2)
                                        
                                        // Letter text
                                        Text(option.text)
                                            .font(SpendLessFont.body)
                                            .foregroundStyle(Color.spendLessTextPrimary)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(SpendLessSpacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                            .fill(
                                                selectedLetterOption?.id == option.id
                                                ? Color.spendLessPrimary.opacity(0.1)
                                                : Color.spendLessCardBackground
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                            .strokeBorder(
                                                selectedLetterOption?.id == option.id
                                                ? Color.spendLessPrimary
                                                : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // Note about customization
                        Text("💡 You can change this later in Settings")
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextMuted)
                            .padding(.top, SpendLessSpacing.xs)
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .opacity(showLetterSelection ? 1 : 0)
                    .offset(y: showLetterSelection ? 0 : 10)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showLetterSelection)
                    
                    // Continue button
                    PrimaryButton("Continue") {
                        // Use selected letter or fallback to first option
                        if appState.onboardingFutureLetterText == nil {
                            let options = getFutureSelfLetterOptions(
                                goalName: appState.onboardingGoalName.isEmpty ? nil : appState.onboardingGoalName
                            )
                            appState.onboardingFutureLetterText = options.first?.text ?? generatePlaceholderText(
                                triggers: appState.onboardingTriggers,
                                goalName: appState.onboardingGoalName.isEmpty ? nil : appState.onboardingGoalName
                            )
                        }
                        
                        withAnimation {
                            currentPage = 2
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.top, SpendLessSpacing.lg)
                    .padding(.bottom, SpendLessSpacing.xl)
                }
            }
        }
        .onAppear {
            // Start analyzing animation
            isAnalyzing = true
            showHeader = false
            showStrengths = false
            showFocusAreas = false
            showPrediction = false
            
            // After 1.5 seconds, show content with staggered animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isAnalyzing = false
                
                // Staggered reveal
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showHeader = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showStrengths = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showFocusAreas = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showPrediction = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showLetterSelection = true
                    }
                }
            }
        }
        .onChange(of: currentPage) { oldValue, newValue in
            // Reset animation states when navigating away
            if newValue != 1 {
                isAnalyzing = true
                showHeader = false
                showStrengths = false
                showFocusAreas = false
                showPrediction = false
                showLetterSelection = false
            }
        }
    }
    
    private func commitmentFeature(icon: String, text: String) -> some View {
        HStack(spacing: SpendLessSpacing.xs) {
            Text(icon)
            Text(text)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
    }
    
    private var goalDisplayName: String {
        if appState.onboardingGoalType.requiresDetails && !appState.onboardingGoalName.isEmpty {
            return appState.onboardingGoalName
        } else {
            switch appState.onboardingGoalType {
            case .vacation: return "Your dream trip"
            case .debtFree: return "Freedom from debt"
            case .emergency: return "Peace of mind"
            case .justStop: return "Your wallet"
            default: return "Your goal"
            }
        }
    }
    
    private func calculateTimeframe() -> String? {
        guard appState.onboardingGoalType.requiresDetails,
              appState.onboardingGoalAmount > 0 else {
            return nil
        }
        
        let monthlyEstimate = (appState.onboardingSpendRange.monthlyEstimate as NSDecimalNumber).doubleValue
        let goalAmount = (appState.onboardingGoalAmount as NSDecimalNumber).doubleValue
        
        guard monthlyEstimate > 0 else { return nil }
        
        let months = goalAmount / monthlyEstimate
        return formatTimeframe(months: months)
    }
    
    // MARK: - Page 3: The Signature
    
    private var signaturePage: some View {
        ZStack {
            VStack(spacing: SpendLessSpacing.lg) {
                Spacer()
                
                VStack(spacing: SpendLessSpacing.md) {
                    Text("✍️")
                        .font(.system(size: 50))
                    
                    Text("Make it official.")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text(generateCommitmentText(goalType: appState.onboardingGoalType, goalName: appState.onboardingGoalName.isEmpty ? nil : appState.onboardingGoalName))
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SpendLessSpacing.lg)
                }
                
                // Signature area
                Button {
                    showSignatureSheet = true
                } label: {
                    VStack(spacing: SpendLessSpacing.md) {
                        if hasSigned, let date = commitmentDate {
                            if let signatureData = appState.onboardingSignatureData,
                               let uiImage = UIImage(data: signatureData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            Text("Signed on \(formatCommitmentDate(date))")
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextSecondary)
                        } else {
                            VStack(spacing: SpendLessSpacing.sm) {
                                Image(systemName: "pencil.tip")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.spendLessTextMuted)
                                
                                Text("Tap to sign your commitment")
                                    .font(SpendLessFont.body)
                                    .foregroundStyle(Color.spendLessTextSecondary)
                            }
                            .frame(height: 100)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(SpendLessSpacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                            .strokeBorder(
                                hasSigned ? Color.spendLessPrimary : Color.spendLessTextMuted,
                                lineWidth: 2,
                                antialiased: true
                            )
                    )
                    .background(
                        // Glow effect behind card when signed
                        RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                            .fill(Color.spendLessGold.opacity(showGlow ? 0.15 : 0))
                            .blur(radius: 20)
                            .scaleEffect(1.1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                PrimaryButton("I'm Committed", icon: "arrow.right") {
                    onContinue()
                }
                .disabled(!hasSigned)
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
            
            // Confetti layer
            ConfettiBurst(trigger: $triggerConfetti)
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

// MARK: - Signature Sheet View (FIXED)

struct SignatureSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (Data, Date) -> Void
    
    @State private var canvasView = PKCanvasView()
    @State private var drawing = PKDrawing()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()  // White background for signature
                
                VStack(spacing: SpendLessSpacing.lg) {
                    Text("Sign with your finger")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .padding(.top, SpendLessSpacing.lg)
                    
                    // Signature canvas
                    SignatureCanvasRepresentable(
                        canvasView: $canvasView,
                        drawing: $drawing
                    )
                    .frame(height: 300)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .strokeBorder(Color.spendLessTextMuted, lineWidth: 1)
                    )
                    .padding(.horizontal, SpendLessSpacing.md)
                    
                    Button("Clear") {
                        drawing = PKDrawing()
                        canvasView.drawing = PKDrawing()
                    }
                    .foregroundStyle(Color.spendLessError)
                    
                    Spacer()
                }
            }
            .navigationTitle("Sign Your Commitment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveSignature()
                    }
                    .disabled(drawing.strokes.isEmpty)
                }
            }
        }
    }
    
    private func saveSignature() {
        // Export signature to image data
        let bounds = drawing.bounds
        
        guard !bounds.isEmpty else {
            return
        }
        
        // Add padding around signature
        let padding: CGFloat = 20
        let imageSize = CGSize(
            width: bounds.width + padding * 2,
            height: bounds.height + padding * 2
        )
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let image = renderer.image { context in
            // Transparent background
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: imageSize))
            
            // Center the drawing
            context.cgContext.translateBy(x: padding - bounds.minX, y: padding - bounds.minY)
            
            // Draw signature
            drawing.image(from: bounds, scale: UIScreen.main.scale).draw(at: .zero)
        }
        
        if let imageData = image.pngData() {
            onSave(imageData, Date())
        }
    }
}

// MARK: - Signature Canvas Representable (NEW)

struct SignatureCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: SignatureCanvasRepresentable
        
        init(_ parent: SignatureCanvasRepresentable) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}

// MARK: - Screen 10: Permission Explanation

struct OnboardingPermissionView: View {
    let onContinue: () -> Void
    
    @State private var isRequestingAuth = false
    @State private var showAuthError = false
    
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
                    
                    Text("When you tap \"Grant Access\", iOS will show a permission prompt. If it doesn't appear, you may need to enable it in Settings > Screen Time > SpendLess.")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, SpendLessSpacing.xs)
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
        .onAppear {
            // Check if already authorized
            checkAuthorizationStatus()
        }
        .alert("Screen Time Access Required", isPresented: $showAuthError) {
            Button("Open Settings") {
                // Open Settings app (can't deep link to Screen Time directly)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Continue Anyway", role: .cancel) {
                onContinue()
            }
        } message: {
            Text("To enable Screen Time access:\n\n1. Open Settings\n2. Tap Screen Time\n3. Tap SpendLess\n4. Toggle on \"Allow Family Controls\"\n\nThen return here to continue.")
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
    
    private func checkAuthorizationStatus() {
        let authStatus = AuthorizationCenter.shared.authorizationStatus
        
        switch authStatus {
        case .approved:
            // Already authorized - skip this screen
            onContinue()
        case .denied:
            // User previously denied - show error
            showAuthError = true
        case .notDetermined:
            // Need to request - button will handle it
            break
        @unknown default:
            break
        }
    }
    
    private func requestAuthorization() {
        let authStatus = AuthorizationCenter.shared.authorizationStatus
        
        // If already approved, just continue
        if authStatus == .approved {
            onContinue()
            return
        }
        
        // If denied, show error
        if authStatus == .denied {
            showAuthError = true
            return
        }
        
        // Request authorization
        isRequestingAuth = true
        
        Task {
            do {
                // This shows the REAL iOS Screen Time authorization prompt
                try await ScreenTimeManager.shared.requestAuthorization()
                await MainActor.run {
                    isRequestingAuth = false
                    onContinue()
                }
            } catch {
                await MainActor.run {
                    isRequestingAuth = false
                    // Check if it was denied
                    if AuthorizationCenter.shared.authorizationStatus == .denied {
                        showAuthError = true
                    } else {
                        // Other error - still continue
                        onContinue()
                    }
                }
            }
        }
    }
}

// MARK: - Screen 11: App Selection

struct OnboardingAppSelectionView: View {
    let onContinue: () -> Void
    
    @Bindable var screenTimeManager = ScreenTimeManager.shared
    @State private var selection = FamilyActivitySelection()
    @State private var showPicker = false
    @State private var showAuthError = false
    
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
                if screenTimeManager.blockedAppCount > 0 {
                    Card {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.spendLessSecondary)
                            Text("\(screenTimeManager.blockedAppCount) apps selected")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessTextPrimary)
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                VStack(spacing: SpendLessSpacing.md) {
                    PrimaryButton("Select Apps", icon: "apps.iphone") {
                        openPicker()
                    }
                    
                    if screenTimeManager.blockedAppCount > 0 {
                        SecondaryButton("Continue") {
                            onContinue()
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Skip button
                    if screenTimeManager.blockedAppCount == 0 {
                        Button("Skip for now") {
                            onContinue()
                        }
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextMuted)
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
        .familyActivityPicker(isPresented: $showPicker, selection: $selection)
        .onChange(of: selection) { oldValue, newValue in
            let newCount = newValue.applicationTokens.count + 
                          newValue.categoryTokens.count + 
                          newValue.webDomainTokens.count
            
            if newCount > 0 {
                withAnimation {
                    screenTimeManager.handleSelection(newValue)
                }
            }
        }
        .onChange(of: showPicker) { oldValue, newValue in
            if !newValue {  // Picker just closed
                // Process final selection
                let totalSelected = selection.applicationTokens.count + 
                                  selection.categoryTokens.count + 
                                  selection.webDomainTokens.count
                
                if totalSelected > 0 {
                    screenTimeManager.handleSelection(selection)
                }
            }
        }
        .onAppear {
            selection = screenTimeManager.selection
        }
        .alert("Screen Time Access Required", isPresented: $showAuthError) {
            Button("Open Settings") {
                // Open Settings app (can't deep link to Screen Time directly)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Try Again") {
                openPicker()
            }
            Button("Skip", role: .cancel) {
                onContinue()
            }
        } message: {
            Text("To enable Screen Time access:\n\n1. Open Settings\n2. Tap Screen Time\n3. Tap SpendLess\n4. Toggle on \"Allow Family Controls\"\n\nThen return here and tap \"Try Again\".")
        }
    }
    
    private func openPicker() {
        // Check authorization status first
        let authStatus = AuthorizationCenter.shared.authorizationStatus
        
        switch authStatus {
        case .notDetermined:
            // Should have been authorized in previous screen, but just in case:
            // Request authorization first
            Task {
                do {
                    try await ScreenTimeManager.shared.requestAuthorization()
                    await MainActor.run {
                        showPicker = true
                    }
                } catch {
                    await MainActor.run {
                        showAuthError = true
                    }
                }
            }
            
        case .approved:
            // Already authorized - just show the picker
            showPicker = true
            
        case .denied:
            // User denied authorization - show error
            showAuthError = true
            
        @unknown default:
            // Unknown status - try to show picker anyway
            showPicker = true
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
}

// MARK: - Screen 14: Notification Permission

struct OnboardingNotificationPermissionView: View {
    let onContinue: () -> Void
    
    @State private var isRequestingPermission = false
    private let authStatus = AuthorizationCenter.shared.authorizationStatus
    private var isScreenTimeAuthorized: Bool {
        authStatus == .approved
    }
    
    var body: some View {
        OnboardingContainer(step: .notificationPermission) {
            VStack(spacing: SpendLessSpacing.lg) {
                Spacer()
                
                // Check if Screen Time is authorized
                if isScreenTimeAuthorized {
                    // Show notification permission request UI
                    notificationPermissionContent
                } else {
                    // Shield not accepted - just show continue button
                    skipContent
                }
                
                Spacer()
                
                // Button stack
                VStack(spacing: SpendLessSpacing.md) {
                    PrimaryButton(
                        isScreenTimeAuthorized ? "Enable Notifications" : "Continue",
                        icon: isScreenTimeAuthorized ? "bell.fill" : "arrow.right",
                        isLoading: isRequestingPermission
                    ) {
                        if isScreenTimeAuthorized {
                            requestNotificationPermission()
                        } else {
                            onContinue()
                        }
                    }
                    
                    // Show "Not right now" option only when Screen Time is authorized
                    if isScreenTimeAuthorized {
                        SecondaryButton("Not right now") {
                            onContinue()
                        }
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
    
    private var notificationPermissionContent: some View {
        VStack(spacing: SpendLessSpacing.md) {
            Image(systemName: "bell.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.spendLessPrimary)
            
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Stay on track with notifications")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    featureRow(icon: "clock.fill", text: "Remind you when temporary access ends")
                    featureRow(icon: "hand.raised.fill", text: "Celebrate your progress and milestones")
                    featureRow(icon: "sparkles", text: "Keep you motivated with timely updates")
                }
                .padding(.top, SpendLessSpacing.sm)
                
                Text("You can change this later in Settings.")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.top, SpendLessSpacing.sm)
            }
            .padding(.horizontal, SpendLessSpacing.lg)
        }
    }
    
    private var skipContent: some View {
        VStack(spacing: SpendLessSpacing.md) {
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.spendLessPrimary)
            
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Almost there!")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("You're all set to start protecting your spending.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SpendLessSpacing.lg)
            }
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: SpendLessSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(Color.spendLessSecondary)
                .frame(width: 24)
            Text(text)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextPrimary)
        }
    }
    
    @MainActor
    private func requestNotificationPermission() {
        isRequestingPermission = true
        
        Task {
            // Request permission - this will trigger the system dialog
            // Must be called from main thread context
            _ = await NotificationManager.shared.requestPermission()
            
            isRequestingPermission = false
            // Continue regardless of whether permission was granted
            // User can enable later in Settings if needed
            onContinue()
        }
    }
}

// MARK: - Screen 15: How It Works

struct OnboardingHowItWorksView: View {
    let onContinue: () -> Void
    
    @State private var currentSlide = 0
    
    private let slides = [
        ("hand.raised.fill", "When you try to open a blocked app...", "A shield screen appears to pause you. Simple, but effective."),
        ("sparkles", "Rich interventions via Shortcuts", "Set up Shortcuts to get breathing exercises and reflection prompts when you're tempted."),
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
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom page indicator with black dots
                HStack(spacing: SpendLessSpacing.xs) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlide ? Color.spendLessTextPrimary : Color.spendLessTextPrimary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, SpendLessSpacing.sm)
                
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

