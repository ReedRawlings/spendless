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
    @State private var letterText = ""
    @State private var hasSigned = false
    @State private var showSignatureSheet = false
    @State private var commitmentDate: Date?
    @State private var showGlow = false
    @State private var triggerConfetti = false
    
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
                    
                    // Positive path (highlighted)
                    pathCard(
                        icon: "💵",
                        destination: goalDestination,
                        amount: goalName,
                        label: "Where it could go",
                        isHighlighted: true
                    )
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            
            PrimaryButton("I want the second one") {
                withAnimation {
                    currentPage = 1
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
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
    
    // MARK: - Page 2: The Reflection
    
    private var uniqueStruggleDisplayNames: [String] {
        let triggerDisplayNames = Set(appState.onboardingTriggers.map { displayName(for: $0) })
        let timingDisplayNames = Set(appState.onboardingTimings.map { displayName(for: $0) })
        return triggerDisplayNames.union(timingDisplayNames).sorted()
    }
    
    private var futureSelfLetterPage: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Header
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("Here's what you shared")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                }
                .padding(.top, SpendLessSpacing.lg)
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // You struggle with card
                Card {
                    VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                        HStack(spacing: SpendLessSpacing.xs) {
                            Text("😩")
                            Text("You struggle with:")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessTextPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                            ForEach(uniqueStruggleDisplayNames, id: \.self) { displayName in
                                HStack(spacing: SpendLessSpacing.xs) {
                                    Text("•")
                                        .foregroundStyle(Color.spendLessTextSecondary)
                                    Text(displayName)
                                        .font(SpendLessFont.body)
                                        .foregroundStyle(Color.spendLessTextSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // You want card
                Card {
                    VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                        HStack(spacing: SpendLessSpacing.xs) {
                            Text("✨")
                            Text("You want:")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessTextPrimary)
                        }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], alignment: .leading, spacing: SpendLessSpacing.xs) {
                            ForEach(Array(appState.onboardingDesiredOutcomes), id: \.self) { outcome in
                                HStack(spacing: SpendLessSpacing.xs) {
                                    Text(outcome.icon)
                                    Text(outcome.displayName)
                                        .font(SpendLessFont.caption)
                                        .foregroundStyle(Color.spendLessTextPrimary)
                                }
                                .padding(.horizontal, SpendLessSpacing.sm)
                                .padding(.vertical, SpendLessSpacing.xs)
                                .background(Color.spendLessPrimary.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Your goal card
                Card {
                    VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                        HStack(spacing: SpendLessSpacing.xs) {
                            Text("🎯")
                            Text("Your goal:")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessTextPrimary)
                        }
                        
                        HStack(spacing: SpendLessSpacing.md) {
                            Text(appState.onboardingGoalType.icon)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                                if appState.onboardingGoalType.requiresDetails && !appState.onboardingGoalName.isEmpty {
                                    Text(appState.onboardingGoalName)
                                        .font(SpendLessFont.bodyBold)
                                        .foregroundStyle(Color.spendLessTextPrimary)
                                } else {
                                    Text(goalDisplayName)
                                        .font(SpendLessFont.bodyBold)
                                        .foregroundStyle(Color.spendLessTextPrimary)
                                }
                                
                                if appState.onboardingGoalAmount > 0 {
                                    Text(formatCurrency(appState.onboardingGoalAmount))
                                        .font(SpendLessFont.caption)
                                        .foregroundStyle(Color.spendLessTextSecondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Divider
                Rectangle()
                    .fill(Color.spendLessTextMuted.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, SpendLessSpacing.lg)
                
                // We commit to help you card
                Card {
                    VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                        HStack(spacing: SpendLessSpacing.xs) {
                            Text("🤝")
                            Text("We commit to help you:")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessTextPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                            commitmentFeature(icon: "🛡️", text: "Block your tempting apps")
                            commitmentFeature(icon: "⏳", text: "7-day waiting list")
                            commitmentFeature(icon: "🎯", text: "Track your progress")
                            commitmentFeature(icon: "💪", text: "Build real self-control")
                        }
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Divider
                Rectangle()
                    .fill(Color.spendLessTextMuted.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, SpendLessSpacing.lg)
                
                // Future self letter section
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    Text("What would your future self want you to remember?")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    TextEditor(text: $letterText)
                        .frame(minHeight: 120)
                        .padding(SpendLessSpacing.sm)
                        .background(Color.spendLessCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                        .overlay(
                            Group {
                                if letterText.isEmpty {
                                    Text(generatePlaceholderText(
                                        triggers: appState.onboardingTriggers,
                                        goalName: appState.onboardingGoalName.isEmpty ? nil : appState.onboardingGoalName
                                    ))
                                    .font(SpendLessFont.body)
                                    .foregroundStyle(Color.spendLessTextMuted)
                                    .padding(SpendLessSpacing.md)
                                    .allowsHitTesting(false)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                    
                    Text("💡 We'll show you this when you try to open a blocked app.")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Continue button
                PrimaryButton("Continue") {
                    // Save letter text (or use default if empty)
                    if letterText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        appState.onboardingFutureLetterText = generatePlaceholderText(
                            triggers: appState.onboardingTriggers,
                            goalName: appState.onboardingGoalName.isEmpty ? nil : appState.onboardingGoalName
                        )
                    } else {
                        appState.onboardingFutureLetterText = letterText.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    withAnimation {
                        currentPage = 2
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
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
                                    .padding()
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

// MARK: - Signature Sheet View

struct SignatureSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (Data, Date) -> Void
    
    @State private var drawing = PKDrawing()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: SpendLessSpacing.lg) {
                    Text("Sign with your finger")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .padding(.top, SpendLessSpacing.lg)
                    
                    SignatureCanvasView(drawing: $drawing)
                        .frame(height: 300)
                        .padding(SpendLessSpacing.md)
                    
                    Button("Clear") {
                        drawing = PKDrawing()
                    }
                    .foregroundStyle(Color.spendLessError)
                    .padding(.bottom, SpendLessSpacing.lg)
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
                        let canvas = PKCanvasView()
                        canvas.drawing = drawing
                        if let signatureData = exportSignature(from: canvas) {
                            onSave(signatureData, Date())
                        }
                    }
                    .disabled(drawing.strokes.isEmpty)
                }
            }
        }
    }
}

// MARK: - Signature Canvas View

struct SignatureCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvas.backgroundColor = .white
        canvas.drawing = drawing
        
        // Add observer for drawing changes
        canvas.delegate = context.coordinator
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: SignatureCanvasView
        
        init(_ parent: SignatureCanvasView) {
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
    
    @Bindable var screenTimeManager = ScreenTimeManager.shared
    @State private var selection = FamilyActivitySelection()
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
                }
                
                Spacer()
                
                VStack(spacing: SpendLessSpacing.md) {
                    PrimaryButton("Select Apps", icon: "apps.iphone") {
                        showPicker = true
                    }
                    
                    #if DEBUG
                    VStack(spacing: SpendLessSpacing.xs) {
                        Text("Debug Info")
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextMuted)
                        
                        Text("Apps: \(selection.applicationTokens.count)")
                            .font(SpendLessFont.caption)
                        Text("Categories: \(selection.categoryTokens.count)")
                            .font(SpendLessFont.caption)
                        Text("Domains: \(selection.webDomainTokens.count)")
                            .font(SpendLessFont.caption)
                        Text("Total: \(screenTimeManager.blockedAppCount)")
                            .font(SpendLessFont.caption)
                    }
                    .padding(.top, SpendLessSpacing.sm)
                    #endif
                    
                    if screenTimeManager.blockedAppCount > 0 {
                        SecondaryButton("Continue") {
                            onContinue()
                        }
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
        .familyActivityPicker(isPresented: $showPicker, selection: $selection)
        .onChange(of: selection) { oldValue, newValue in
            print("[OnboardingAppSelectionView] 🔄 Selection changed")
            print("  - Old count: \(oldValue.applicationTokens.count + oldValue.categoryTokens.count + oldValue.webDomainTokens.count)")
            print("  - New count: \(newValue.applicationTokens.count + newValue.categoryTokens.count + newValue.webDomainTokens.count)")
            
            // Update immediately
            screenTimeManager.handleSelection(newValue)
        }
        .onChange(of: showPicker) { oldValue, newValue in
            if !newValue {
                // Picker just dismissed - ensure we process the selection
                print("[OnboardingAppSelectionView] 📱 Picker dismissed")
                print("  - Final selection count: \(selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count)")
                
                // Double-check the selection was processed
                if selection.applicationTokens.count > 0 || selection.categoryTokens.count > 0 || selection.webDomainTokens.count > 0 {
                    screenTimeManager.handleSelection(selection)
                }
            } else {
                print("[OnboardingAppSelectionView] 📱 Picker opened")
            }
        }
        .onAppear {
            // Load existing selection
            selection = screenTimeManager.selection
            print("[OnboardingAppSelectionView] 📋 Loaded existing selection: \(screenTimeManager.blockedAppCount) items")
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

