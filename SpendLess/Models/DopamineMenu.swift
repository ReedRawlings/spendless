//
//  DopamineMenu.swift
//  SpendLess
//
//  Dopamine Menu data models for healthy activity alternatives
//

import Foundation

// MARK: - Default Dopamine Activities

enum DopamineActivity: String, CaseIterable, Codable, Identifiable {
    case walk = "Go for a 10-minute walk"
    case text = "Text a friend something nice"
    case music = "Put on your favorite album"
    case create = "Make something (draw, cook, craft)"
    case organize = "Organize one drawer"
    case watch = "Watch one episode of something"
    case stretch = "Do 5 minutes of stretching"
    case journal = "Write 3 things you're grateful for"
    case coffee = "Make yourself a nice drink"
    case outside = "Sit outside for 5 minutes"
    case nap = "Take a 20-minute nap"
    case call = "Call someone you haven't talked to"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .walk: return "🚶"
        case .text: return "💬"
        case .music: return "🎵"
        case .create: return "🎨"
        case .organize: return "🗄️"
        case .watch: return "📺"
        case .stretch: return "🧘"
        case .journal: return "📝"
        case .coffee: return "☕"
        case .outside: return "🌤️"
        case .nap: return "😴"
        case .call: return "📞"
        }
    }
    
    var shortName: String {
        switch self {
        case .walk: return "Take a walk"
        case .text: return "Text a friend"
        case .music: return "Listen to music"
        case .create: return "Make something"
        case .organize: return "Organize"
        case .watch: return "Watch something"
        case .stretch: return "Stretch"
        case .journal: return "Journal"
        case .coffee: return "Make a drink"
        case .outside: return "Go outside"
        case .nap: return "Take a nap"
        case .call: return "Call someone"
        }
    }
}

// MARK: - Activity Log (V2)

struct DopamineActivityLog: Codable, Identifiable {
    let id: UUID
    let activity: String
    let timestamp: Date
    let context: DopamineContext?
    
    init(
        id: UUID = UUID(),
        activity: String,
        timestamp: Date = Date(),
        context: DopamineContext? = nil
    ) {
        self.id = id
        self.activity = activity
        self.timestamp = timestamp
        self.context = context
    }
}

enum DopamineContext: String, Codable {
    case panicButton
    case intervention
    case manual
}

