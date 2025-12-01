//
//  ScreenTimeManager.swift
//  SpendLess
//
//  Stub implementation for Screen Time API
//  Will be enabled when entitlements are approved
//

import Foundation
import SwiftUI

// MARK: - Protocol for Screen Time Management

protocol ScreenTimeManaging {
    var isAuthorized: Bool { get }
    var blockedAppCount: Int { get }
    
    func requestAuthorization() async throws
    func openAppPicker()
    func applyShields()
    func removeShields()
}

// MARK: - Screen Time Manager (Stub Implementation)

@Observable
final class ScreenTimeManager: ScreenTimeManaging {
    
    // MARK: - Singleton
    static let shared = ScreenTimeManager()
    
    // MARK: - State
    private(set) var isAuthorized: Bool = false
    private(set) var blockedAppCount: Int = 0
    private(set) var isPickerPresented: Bool = false
    
    // MARK: - Mock Data for Development
    var mockSelectedApps: [MockAppToken] = []
    
    // MARK: - Initialization
    private init() {
        // Load saved state
        loadState()
    }
    
    // MARK: - Authorization
    
    /// Request Screen Time authorization
    /// Note: This is a stub - actual implementation requires FamilyControls entitlement
    func requestAuthorization() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        #if targetEnvironment(simulator)
        // In simulator, always succeed for testing
        await MainActor.run {
            isAuthorized = true
            saveState()
            AppState.shared.isScreenTimeAuthorized = true
            AppState.shared.saveToUserDefaults()
        }
        #else
        // On device, this would use actual FamilyControls
        // For now, simulate success
        await MainActor.run {
            isAuthorized = true
            saveState()
            AppState.shared.isScreenTimeAuthorized = true
            AppState.shared.saveToUserDefaults()
        }
        
        /*
        // ACTUAL IMPLEMENTATION (when entitlements available):
        import FamilyControls
        
        let center = AuthorizationCenter.shared
        try await center.requestAuthorization(for: .individual)
        
        await MainActor.run {
            isAuthorized = true
            saveState()
        }
        */
        #endif
    }
    
    // MARK: - App Selection
    
    /// Present the app picker
    /// Note: This is a stub - actual implementation uses FamilyActivityPicker
    func openAppPicker() {
        isPickerPresented = true
        
        /*
        // ACTUAL IMPLEMENTATION (when entitlements available):
        // The picker is presented via SwiftUI modifier:
        //
        // .familyActivityPicker(
        //     isPresented: $screenTimeManager.isPickerPresented,
        //     selection: $screenTimeManager.selection
        // )
        */
    }
    
    func closeAppPicker() {
        isPickerPresented = false
    }
    
    /// Handle selection from the picker (mock implementation)
    func handleMockSelection(_ apps: [MockAppToken]) {
        mockSelectedApps = apps
        blockedAppCount = apps.count
        AppState.shared.blockedAppCount = apps.count
        saveState()
    }
    
    // MARK: - Shield Management
    
    /// Apply shields to selected apps
    /// Note: This is a stub - actual implementation uses ManagedSettings
    func applyShields() {
        guard isAuthorized else { return }
        
        /*
        // ACTUAL IMPLEMENTATION (when entitlements available):
        import ManagedSettings
        
        let store = ManagedSettingsStore()
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        */
        
        print("[ScreenTimeManager] Shields applied to \(blockedAppCount) apps (stub)")
    }
    
    /// Remove all shields
    func removeShields() {
        /*
        // ACTUAL IMPLEMENTATION:
        let store = ManagedSettingsStore()
        store.clearAllSettings()
        */
        
        print("[ScreenTimeManager] Shields removed (stub)")
    }
    
    // MARK: - Persistence
    
    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(isAuthorized, forKey: "screenTime.isAuthorized")
        defaults.set(blockedAppCount, forKey: "screenTime.blockedAppCount")
        
        // Save mock app tokens
        if let encoded = try? JSONEncoder().encode(mockSelectedApps) {
            defaults.set(encoded, forKey: "screenTime.mockSelectedApps")
        }
    }
    
    private func loadState() {
        let defaults = UserDefaults.standard
        isAuthorized = defaults.bool(forKey: "screenTime.isAuthorized")
        blockedAppCount = defaults.integer(forKey: "screenTime.blockedAppCount")
        
        // Load mock app tokens
        if let data = defaults.data(forKey: "screenTime.mockSelectedApps"),
           let apps = try? JSONDecoder().decode([MockAppToken].self, from: data) {
            mockSelectedApps = apps
        }
    }
    
    // MARK: - Reset (for testing)
    
    func reset() {
        isAuthorized = false
        blockedAppCount = 0
        mockSelectedApps = []
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "screenTime.isAuthorized")
        defaults.removeObject(forKey: "screenTime.blockedAppCount")
        defaults.removeObject(forKey: "screenTime.mockSelectedApps")
        
        AppState.shared.isScreenTimeAuthorized = false
        AppState.shared.blockedAppCount = 0
        AppState.shared.saveToUserDefaults()
    }
}

// MARK: - Mock App Token (for development/testing)

struct MockAppToken: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let bundleIdentifier: String
    let category: String
    
    init(name: String, bundleIdentifier: String, category: String = "Shopping") {
        self.id = UUID()
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.category = category
    }
}

// MARK: - Common Shopping Apps (for mock picker)

extension MockAppToken {
    static let commonShoppingApps: [MockAppToken] = [
        MockAppToken(name: "Amazon", bundleIdentifier: "com.amazon.Amazon", category: "Shopping"),
        MockAppToken(name: "Shein", bundleIdentifier: "com.shein.shein", category: "Shopping"),
        MockAppToken(name: "Temu", bundleIdentifier: "com.einnovation.temu", category: "Shopping"),
        MockAppToken(name: "Target", bundleIdentifier: "com.target.targetapp", category: "Shopping"),
        MockAppToken(name: "Walmart", bundleIdentifier: "com.walmart.electronics", category: "Shopping"),
        MockAppToken(name: "TikTok Shop", bundleIdentifier: "com.zhiliaoapp.musically", category: "Social"),
        MockAppToken(name: "Instagram", bundleIdentifier: "com.burbn.instagram", category: "Social"),
        MockAppToken(name: "Etsy", bundleIdentifier: "com.etsy.etsy", category: "Shopping"),
        MockAppToken(name: "ASOS", bundleIdentifier: "com.asos.asos", category: "Shopping"),
        MockAppToken(name: "Sephora", bundleIdentifier: "com.sephora.sephora", category: "Shopping"),
        MockAppToken(name: "Zara", bundleIdentifier: "com.inditex.zara", category: "Shopping"),
        MockAppToken(name: "H&M", bundleIdentifier: "com.hm.goe", category: "Shopping"),
        MockAppToken(name: "Nike", bundleIdentifier: "com.nike.onenikecommerce", category: "Shopping"),
        MockAppToken(name: "eBay", bundleIdentifier: "com.ebay.iphone", category: "Shopping"),
        MockAppToken(name: "Wish", bundleIdentifier: "com.contextlogic.Wish", category: "Shopping"),
    ]
}

// MARK: - Mock App Picker View (for development)

struct MockAppPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var screenTimeManager = ScreenTimeManager.shared
    @State private var selectedApps: Set<MockAppToken> = []
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(MockAppToken.commonShoppingApps) { app in
                        Button {
                            if selectedApps.contains(app) {
                                selectedApps.remove(app)
                            } else {
                                selectedApps.insert(app)
                            }
                        } label: {
                            HStack {
                                IconView(appIcon(for: app.name), font: .title2)
                                
                                VStack(alignment: .leading) {
                                    Text(app.name)
                                        .font(SpendLessFont.body)
                                        .foregroundStyle(Color.spendLessTextPrimary)
                                    Text(app.category)
                                        .font(SpendLessFont.caption)
                                        .foregroundStyle(Color.spendLessTextMuted)
                                }
                                
                                Spacer()
                                
                                if selectedApps.contains(app) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.spendLessPrimary)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(Color.spendLessTextMuted)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Shopping Apps")
                } footer: {
                    Text("This is a mock picker for development. The real FamilyActivityPicker will be used when Screen Time entitlements are available.")
                        .font(SpendLessFont.caption)
                }
            }
            .navigationTitle("Select Apps to Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        screenTimeManager.handleMockSelection(Array(selectedApps))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            selectedApps = Set(screenTimeManager.mockSelectedApps)
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
        case "Zara": return "👔"
        case "H&M": return "👕"
        case "Nike": return "👟"
        case "eBay": return "🏷️"
        case "Wish": return "⭐"
        default: return "📱"
        }
    }
}

#Preview {
    MockAppPickerView()
}

