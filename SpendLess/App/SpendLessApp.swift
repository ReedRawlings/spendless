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
    
    // MARK: - Session Manager
    
    @State private var sessionManager = ShieldSessionManager.shared
    
    // MARK: - Notification Manager
    
    @State private var notificationManager = NotificationManager.shared
    
    // MARK: - Initialization

    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationManager.shared

        // Configure StoreKit 2 asynchronously
        // The async configure method ensures proper initialization before any subscription checks
        // Use the shared instance directly here to avoid capturing `self` in an escaping closure
        Task { @MainActor in
            let service = SubscriptionService.shared
            await service.configure()

            // For returning users, check subscription status immediately after configuration
            // This ensures Pro features are available right away
            if UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.hasCompletedOnboarding) {
                await service.checkSubscriptionStatus()
            }
        }

        // Notification permission will be requested during onboarding after shield acceptance
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(interventionManager)
                .environment(subscriptionService)
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
            appState.pendingDeepLink = "dashboard"
            
        case "waitinglist":
            // Navigate to waiting list with specific item: spendless://waitinglist/{itemID}
            // Extract item ID from path
            let pathComponents = url.pathComponents.filter { $0 != "/" }
            if let itemIDString = pathComponents.first {
                appState.pendingWaitingListItemID = itemIDString
            }
            appState.pendingDeepLink = "waitinglist"
            
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
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    
    /// State for showing paywall
    @State private var showPaywall = false
    
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
        .sheet(isPresented: $showPaywall) {
            SpendLessPaywallView()
        }
        .onChange(of: appState.shouldShowPaywallAfterOnboarding) { oldValue, newValue in
            if newValue && !oldValue {
                print("🎯 Onboarding Complete - Showing Paywall")
                
                Task { @MainActor in
                    // Wait for onboarding transition to complete
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    
                    // Show paywall
                    showPaywall = true
                    
                    // Check subscription status in background (for logging only)
                    Task {
                        await subscriptionService.checkSubscriptionStatus()
                        print("📊 Subscription check: hasProAccess = \(subscriptionService.hasProAccess)")
                    }
                    
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
                
                // Process pending waiting list notification actions
                processPendingWaitingListActions()
                
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
                // Process pending waiting list notification actions
                processPendingWaitingListActions()
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
            appState.pendingDeepLink = "dashboard"
            
        case "waitinglist":
            // Navigate to waiting list with specific item: spendless://waitinglist/{itemID}
            // Extract item ID from path
            let pathComponents = url.pathComponents.filter { $0 != "/" }
            if let itemIDString = pathComponents.first {
                appState.pendingWaitingListItemID = itemIDString
            }
            appState.pendingDeepLink = "waitinglist"
            
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
                    try await MailerLiteService.shared.submitEmailForPDF(
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
    
    // MARK: - Pending Waiting List Actions
    
    /// Process any pending waiting list actions from notification background actions
    private func processPendingWaitingListActions() {
        let pendingActions = NotificationManager.shared.getAllPendingWaitingListActions()
        
        guard !pendingActions.isEmpty else { return }
        
        print("[RootView] Processing \(pendingActions.count) pending waiting list actions")
        
        // Fetch all waiting list items
        let descriptor = FetchDescriptor<WaitingListItem>()
        guard let items = try? modelContext.fetch(descriptor) else {
            print("[RootView] Failed to fetch waiting list items")
            return
        }
        
        // Fetch active goal for adding savings
        let goalDescriptor = FetchDescriptor<UserGoal>(predicate: #Predicate { $0.isActive })
        let goals = try? modelContext.fetch(goalDescriptor)
        let currentGoal = goals?.first
        
        for (itemIDString, action) in pendingActions {
            guard let itemID = UUID(uuidString: itemIDString),
                  let item = items.first(where: { $0.id == itemID }) else {
                // Item not found, clear the action
                NotificationManager.shared.clearPendingWaitingListAction(for: itemIDString)
                print("[RootView] Item \(itemIDString) not found, clearing action")
                continue
            }
            
            switch action {
            case "keepOnList":
                // Record a check-in
                item.recordCheckin()
                print("[RootView] Recorded check-in for '\(item.name)'")
                
            case "buryIt":
                // Cancel notifications
                NotificationManager.shared.cancelWaitingListNotifications(for: item.id)
                
                // Create graveyard item
                let graveyardItem = GraveyardItem(
                    from: item,
                    source: .waitingList,
                    removalReason: .urgePassed,
                    removalReasonNote: "Buried via notification"
                )
                modelContext.insert(graveyardItem)
                
                // Update goal
                if let goal = currentGoal {
                    goal.addSavings(item.amount)
                }
                
                // Delete waiting list item
                modelContext.delete(item)
                print("[RootView] Buried '\(item.name)' from notification action")
                
            default:
                print("[RootView] Unknown action '\(action)' for item \(itemIDString)")
            }
            
            // Clear the processed action
            NotificationManager.shared.clearPendingWaitingListAction(for: itemIDString)
        }
        
        // Save all changes
        try? modelContext.save()
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

