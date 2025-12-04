//
//  SpendLessApp.swift
//  SpendLess
//
//  Main app entry point
//

import SwiftUI
import SwiftData
import AppIntents

@main
struct SpendLessApp: App {
    
    // MARK: - SwiftData Container
    
    /// Current schema version - increment this when making breaking schema changes
    /// Since we have no users yet, we can reset the database when this changes
    private static let currentSchemaVersion = 2
    
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
        
        // Check if we need to reset the database due to schema changes
        // Safe to do since we have no users yet
        let schemaVersionKey = "SwiftDataSchemaVersion"
        let defaults = UserDefaults.standard
        let savedSchemaVersion = defaults.integer(forKey: schemaVersionKey)
        
        if savedSchemaVersion != Self.currentSchemaVersion {
            print("🔄 Schema version changed (\(savedSchemaVersion) -> \(Self.currentSchemaVersion)). Resetting database...")
            Self.resetDatabase()
            defaults.set(Self.currentSchemaVersion, forKey: schemaVersionKey)
        }
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If creation fails, try resetting and recreating
            print("⚠️ ModelContainer creation failed: \(error)")
            print("Attempting to reset database and recreate...")
            
            Self.resetDatabase()
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even after reset: \(error)")
            }
        }
    }()
    
    /// Resets the SwiftData database by deleting all store files
    /// Safe to call since we have no users yet
    private static func resetDatabase() {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID) else {
            print("⚠️ Could not get container URL for database reset")
            return
        }
        
        let storeURL = containerURL.appendingPathComponent("Library/Application Support/default.store")
        let walURL = storeURL.appendingPathExtension("wal")
        let shmURL = storeURL.appendingPathExtension("shm")
        
        // Delete all database files
        let filesToDelete = [storeURL, walURL, shmURL]
        for url in filesToDelete {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                    print("✅ Deleted: \(url.lastPathComponent)")
                } catch {
                    print("⚠️ Failed to delete \(url.lastPathComponent): \(error)")
                }
            }
        }
        
        print("✅ Database reset complete")
    }
    
    // MARK: - App State
    
    @State private var appState = AppState.shared
    
    // MARK: - Intervention Manager
    
    @State private var interventionManager = InterventionManager.shared
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(interventionManager)
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
            // Show panic button flow (from widget or shortcut)
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
            
        default:
            break
        }
    }
}

// MARK: - Root View (handles onboarding vs main app)

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(InterventionManager.self) private var interventionManager
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    
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
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Check for pending interventions when app becomes active
                interventionManager.checkForPendingIntervention()
                
                // Check for pending Control Widget action (panic button from Control Center)
                checkForPendingControlWidgetAction()
                
                // Sync widget data when app becomes active
                if appState.hasCompletedOnboarding {
                    appState.syncWidgetData(context: modelContext)
                }
            }
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
            
            // Trigger the panic button flow
            appState.pendingDeepLink = "panicButton"
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

