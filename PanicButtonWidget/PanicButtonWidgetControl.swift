//
//  PanicButtonWidgetControl.swift
//  PanicButtonWidget
//
//  Control Center widget for quick access to breathing exercise
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Shared Keys for Communication with Main App

private enum ControlWidgetKeys {
    static let suiteName = "group.com.spendless.data"
    static let pendingPanicAction = "pendingPanicAction"
}

// MARK: - Control Widget

struct PanicButtonWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "Future-Selves.SpendLess.PanicButtonControl"
        ) {
            ControlWidgetButton(action: OpenPanicButtonIntent()) {
                Label("Breathe", systemImage: "wind")
            }
        }
        .displayName("Pause & Breathe")
        .description("Quick access when you feel tempted to shop.")
    }
}

// MARK: - App Intent

struct OpenPanicButtonIntent: AppIntent {
    static let title: LocalizedStringResource = "Feeling Tempted"
    static let description = IntentDescription("Opens SpendLess to help you pause and breathe.")
    static let openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        // Store a flag in shared UserDefaults to signal the app to show the feeling tempted flow
        // The app will check for this flag when it becomes active
        if let defaults = UserDefaults(suiteName: ControlWidgetKeys.suiteName) {
            defaults.set(true, forKey: ControlWidgetKeys.pendingPanicAction)
            defaults.synchronize()
        }
        
        return .result()
    }
}
