//
//  MainTabView.swift
//  SpendLess
//
//  Main tab bar navigation
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case waitingList = "Waiting"
        case graveyard = "Graveyard"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .waitingList: return "clock.fill"
            case .graveyard: return "leaf.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)
            
            WaitingListView()
                .tabItem {
                    Label(Tab.waitingList.rawValue, systemImage: Tab.waitingList.icon)
                }
                .tag(Tab.waitingList)
            
            GraveyardView()
                .tabItem {
                    Label(Tab.graveyard.rawValue, systemImage: Tab.graveyard.icon)
                }
                .tag(Tab.graveyard)
            
            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(Color.spendLessPrimary)
    }
}

#Preview {
    MainTabView()
        .environment(AppState.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self
        ], inMemory: true)
}

