//
//  SpendLessApp.swift
//  SpendLess
//
//  Main app entry point
//

import SwiftUI
import SwiftData
import AppIntents
import UserNotifications

@main
struct SpendLessApp: App {
    
    // MARK: - SwiftData Container
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .automatic // Will use App Groups when configured
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            #if DEBUG
            // During development, if migration fails, reset the store
            // This is safe since we don't have active users yet
            // TODO: Remove this before shipping - implement proper schema versioning instead
            print("⚠️ ModelContainer creation failed: \(error)")
            print("Resetting store for development...")

            // Get the store URL from the App Group container
            let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID)
            let storeURL = containerURL?.appendingPathComponent("Library/Application Support/default.store")

            if let storeURL = storeURL, FileManager.default.fileExists(atPath: storeURL.path) {
                do {
                    // Delete the store and its related files
                    try FileManager.default.removeItem(at: storeURL)
                    let walURL = storeURL.appendingPathExtension("wal")
                    let shmURL = storeURL.appendingPathExtension("shm")
                    try? FileManager.default.removeItem(at: walURL)
                    try? FileManager.default.removeItem(at: shmURL)

                    print("✅ Store reset. Recreating ModelContainer...")
                    return try ModelContainer(for: schema, configurations: [modelConfiguration])
                } catch {
                    fatalError("Could not reset store: \(error)")
                }
            } else {
                fatalError("Could not create ModelContainer: \(error)")
            }
            #else
            fatalError("Could not create ModelContainer: \(error)")
            #endif
        }
    }()
    
    // MARK: - App State
    
    @State private var appState = AppState.shared
    
    // MARK: - Intervention Manager
    
    @State private var interventionManager = InterventionManager.shared
    
    // MARK: - Subscription Service
    
    @State private var subscriptionService = SubscriptionService.shared
    
    // MARK: - Superwall Service
    
    @State private var superwallService = SuperwallService.shared
    
    // MARK: - Session Manager
    
    @State private var sessionManager = ShieldSessionManager.shared
    
    // MARK: - Notification Manager
    
    @State private var notificationManager = NotificationManager.shared
    
    // MARK: - Initialization
    
    init() {
        // Configure RevenueCat
        // Note: Make sure to replace the API key in Constants.swift with your actual key
        if AppConstants.revenueCatAPIKey != "YOUR_REVENUECAT_API_KEY_HERE" {
            subscriptionService.configure(apiKey: AppConstants.revenueCatAPIKey)
        } else {
            print("⚠️ RevenueCat API key not configured. Please add your API key to Constants.swift")
        }
        
        // Store Superwall API key (lazy configuration - won't trigger StoreKit on launch)
        // Superwall will be configured when first paywall is requested
        if AppConstants.superwallAPIKey != "YOUR_SUPERWALL_API_KEY_HERE" {
            superwallService.setAPIKey(AppConstants.superwallAPIKey)
        } else {
            print("⚠️ Superwall API key not configured. Please add your API key to Constants.swift")
        }
        
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        
        // Request notification permission on first launch
        Task { @MainActor in
            await Self.requestNotificationPermissionIfNeeded()
        }
    }
    
    // MARK: - Notification Permission
    
    private static func requestNotificationPermissionIfNeeded() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = await NotificationManager.shared.requestPermission()
        }
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(interventionManager)
                .environment(subscriptionService)
                .environment(superwallService)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Deep Linking
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "spendless" else { return }
        
        switch url.host {
        case "addToWaitingList":
            // Navigate to add waiting list item
            // This will be handled by the view that needs to show the add flow
            appState.pendingDeepLink = "addToWaitingList"
            
        case "breathingExercise":
            // Show breathing exercise
            appState.pendingDeepLink = "breathingExercise"
            
        case "panicButton", "panic":
            // Show feeling tempted flow (from widget or shortcut)
            appState.pendingDeepLink = "panicButton"
            
        case "intervention":
            // Handle intervention deep link: spendless://intervention?type=breathing
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let typeString = components?.queryItems?.first(where: { $0.name == "type" })?.value ?? "full"
            let appName = components?.queryItems?.first(where: { $0.name == "app" })?.value
            
            if let type = InterventionManager.InterventionTypeValue(rawValue: typeString) {
                interventionManager.triggeringApp = appName
                interventionManager.triggerIntervention(type: type)
            }
            
        case "dashboard":
            // Navigate to dashboard (from notification)
            // TODO: Navigation design needs to be finalized - currently just sets a flag
            appState.pendingDeepLink = "dashboard"
            
        default:
            break
        }
    }
    
}

// MARK: - Root View (handles onboarding vs main app)

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(InterventionManager.self) private var interventionManager
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(SuperwallService.self) private var superwallService
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    
    /// State for showing RevenueCat paywall (when using fallback mode)
    @State private var showRevenueCatPaywall = false {
        didSet {
            print("📱 showRevenueCatPaywall changed to: \(showRevenueCatPaywall)")
        }
    }
    
    var body: some View {
        ZStack {
            Group {
                if appState.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingCoordinatorView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
            
            // Intervention overlay
            if interventionManager.isShowingIntervention {
                InterventionFlowView(manager: interventionManager)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: interventionManager.isShowingIntervention)
        .sheet(isPresented: $showRevenueCatPaywall) {
            SpendLessPaywallView()
        }
        .onChange(of: appState.shouldShowPaywallAfterOnboarding) { oldValue, newValue in
            if newValue && !oldValue {
                print("🎯 Onboarding Complete - Paywall Trigger Flow")
                print(String(repeating: "=", count: 50))
                
                // Check if using Test Store
                let apiKey = AppConstants.revenueCatAPIKey
                let isTestStore = apiKey.hasPrefix("test_")
                print("   RevenueCat Environment: \(isTestStore ? "Test Store ✅" : "Production")")
                print("   API Key: \(apiKey.prefix(10))...\(apiKey.suffix(4))")
                print("   Paywall Mode: \(AppConstants.useRevenueCatPaywallForTesting ? "RevenueCat (Testing)" : "Superwall")")
                    
                // Trigger paywall immediately - let Superwall handle subscription checks
                Task { @MainActor in
                    print("   ⏳ Waiting 0.5 seconds for onboarding transition...")
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    
                    print("   🚀 Triggering paywall NOW")
                    print("   Paywall Mode: \(AppConstants.useRevenueCatPaywallForTesting ? "RevenueCat (Testing)" : "Superwall")")
                    
                    // Choose paywall based on configuration
                    if AppConstants.useRevenueCatPaywallForTesting {
                        print("   📱 Using RevenueCat PaywallView for testing")
                        print("   🚀 Setting showRevenueCatPaywall = true")
                        showRevenueCatPaywall = true
                        print("   ✅ showRevenueCatPaywall set to: \(showRevenueCatPaywall)")
                    } else {
                        print("   📱 Triggering Superwall paywall via 'campaign_trigger' event")
                        print("   Note: Superwall will check subscription status and show/hide accordingly")
                        print("   🚀 Calling superwallService.register(event: 'campaign_trigger')")
                            superwallService.register(event: "campaign_trigger")
                        print("   ✅ Superwall register() called")
                    }
                    
                    // Check subscription status in background (for logging only)
                    Task {
                        await subscriptionService.checkSubscriptionStatus()
                        print("   📊 Background subscription check: hasProAccess = \(subscriptionService.hasProAccess)")
                    }
                    
                    print(String(repeating: "=", count: 50))
                        appState.markPaywallShownAfterOnboarding()
                        appState.shouldShowPaywallAfterOnboarding = false
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Check for pending interventions when app becomes active
                interventionManager.checkForPendingIntervention()
                
                // Check for pending Control Widget action (feeling tempted from Control Center)
                checkForPendingControlWidgetAction()
                
                // Process pending email submissions
                processPendingEmailSubmissions()
                
                // Check for expired sessions and handle restoration
                Task { @MainActor in
                    ShieldSessionManager.shared.checkSessions()
                    ShieldSessionManager.shared.detectOrphanedSessions()
                }
                
                // Sync widget data when app becomes active
                if appState.hasCompletedOnboarding {
                    appState.syncWidgetData(context: modelContext)
                }
            }
        }
        .onAppear {
            // Check sessions on app launch
            Task { @MainActor in
                ShieldSessionManager.shared.checkSessions()
                // Process any pending events from extensions
                processExtensionEvents()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Handle notification taps when app becomes active
            handleNotificationTapIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: .checkForIntervention)) { _ in
            interventionManager.checkForPendingIntervention()
        }
    }
    
    // MARK: - Control Widget Action Check
    
    private func checkForPendingControlWidgetAction() {
        let pendingPanicKey = "pendingPanicAction"

        guard let defaults = UserDefaults(suiteName: AppConstants.appGroupID) else { return }
        
        if defaults.bool(forKey: pendingPanicKey) {
            // Clear the flag
            defaults.set(false, forKey: pendingPanicKey)
            defaults.synchronize()
            
            // Trigger the feeling tempted flow
            appState.pendingDeepLink = "panicButton"
        }
    }
    
    // MARK: - Extension Events Processing
    
    private func processExtensionEvents() {
        // Process any JSON string events from extensions
        // This will be handled by ShieldAnalytics.getAllEvents() which processes both formats
        _ = ShieldAnalytics.shared.getAllEvents()
    }
    
    // MARK: - Notification Tap Handling
    
    private func handleNotificationTapIfNeeded() {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        guard let deepLink = sharedDefaults?.string(forKey: "pendingNotificationDeepLink") else {
            return
        }
        
        // Clear the flag
        sharedDefaults?.removeObject(forKey: "pendingNotificationDeepLink")
        sharedDefaults?.synchronize()
        
        // Handle the deep link
        if let url = URL(string: deepLink) {
            handleDeepLink(url)
        }
    }
    
    // MARK: - Deep Link Handling (in RootView)
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "spendless" else { return }
        
        switch url.host {
        case "addToWaitingList":
            // Navigate to add waiting list item
            // This will be handled by the view that needs to show the add flow
            appState.pendingDeepLink = "addToWaitingList"
            
        case "breathingExercise":
            // Show breathing exercise
            appState.pendingDeepLink = "breathingExercise"
            
        case "panicButton", "panic":
            // Show feeling tempted flow (from widget or shortcut)
            appState.pendingDeepLink = "panicButton"
            
        case "intervention":
            // Handle intervention deep link: spendless://intervention?type=breathing
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let typeString = components?.queryItems?.first(where: { $0.name == "type" })?.value ?? "full"
            let appName = components?.queryItems?.first(where: { $0.name == "app" })?.value
            
            if let type = InterventionManager.InterventionTypeValue(rawValue: typeString) {
                interventionManager.triggeringApp = appName
                interventionManager.triggerIntervention(type: type)
            }
            
        case "dashboard":
            // Navigate to dashboard (from notification)
            // TODO: Navigation design needs to be finalized - currently just sets a flag
            appState.pendingDeepLink = "dashboard"
            
        default:
            break
        }
    }
    
    // MARK: - Pending Email Submissions
    
    private func processPendingEmailSubmissions() {
        let pending = PendingSubmissionsStore.shared.all()
        guard !pending.isEmpty else { return }
        
        Task {
            for submission in pending {
                do {
                    try await ConvertKitService.shared.submitEmailForPDF(
                        email: submission.email,
                        optedIntoMarketing: submission.optedIntoMarketing,
                        source: submission.source
                    )
                    
                    // Success - remove from queue
                    await MainActor.run {
                        PendingSubmissionsStore.shared.remove(submission)
                    }
                } catch {
                    // Will retry next time app becomes active
                    print("⚠️ Failed to process pending email submission: \(error)")
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environment(AppState.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self
        ], inMemory: true)
}

