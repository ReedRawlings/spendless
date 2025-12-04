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
            let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.spendless.data")
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
        let suiteName = "group.com.spendless.data"
        let pendingPanicKey = "pendingPanicAction"
        
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        
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

