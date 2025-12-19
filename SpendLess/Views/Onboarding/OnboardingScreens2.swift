//
//  OnboardingScreens2.swift
//  SpendLess
//
//  Screen Time permission and app selection screens
//

import SwiftUI
import FamilyControls

// MARK: - Screen Time Permission

struct OnboardingPermissionView: View {
    let onContinue: () -> Void

    @State private var isRequestingAuth = false
    @State private var showAuthError = false

    var body: some View {
        OnboardingContainer(step: .screenTimeAccess) {
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

// MARK: - App Selection

struct OnboardingAppSelectionView: View {
    let onContinue: () -> Void

    @Bindable var screenTimeManager = ScreenTimeManager.shared
    @State private var selection = FamilyActivitySelection()
    @State private var showPicker = false
    @State private var showAuthError = false

    var body: some View {
        OnboardingContainer(step: .blockApps) {
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

// MARK: - Previews

#Preview("Permission") {
    OnboardingPermissionView {}
        .environment(AppState.shared)
}

#Preview("App Selection") {
    OnboardingAppSelectionView {}
        .environment(AppState.shared)
}
