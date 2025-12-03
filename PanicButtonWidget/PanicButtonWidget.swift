//
//  PanicButtonWidget.swift
//  PanicButtonWidget
//
//  A calming widget that reminds users of their commitment
//  and provides a moment of pause before impulse purchases.
//

import WidgetKit
import SwiftUI

// MARK: - App Group Keys

private enum WidgetDataKeys {
    static let suiteName = "group.com.spendless.data"
    static let futureLetterText = "futureLetterText"
    static let goalName = "goalName"
    static let goalProgress = "goalProgress"
    static let totalSaved = "totalSaved"
    static let streakDays = "streakDays"
    static let commitmentDate = "commitmentDate"
    static let userName = "userName"
}

// MARK: - Widget Data

struct WidgetData {
    let futureLetterText: String?
    let goalName: String?
    let goalProgress: Double
    let totalSaved: Double
    let streakDays: Int
    let commitmentDays: Int?
    let userName: String?
    
    static let placeholder = WidgetData(
        futureLetterText: "Remember why you started. You deserve financial peace.",
        goalName: "Your Dream",
        goalProgress: 0.35,
        totalSaved: 247,
        streakDays: 12,
        commitmentDays: 30,
        userName: nil
    )
    
    static func load() -> WidgetData {
        guard let defaults = UserDefaults(suiteName: WidgetDataKeys.suiteName) else {
            return .placeholder
        }
        
        let letterText = defaults.string(forKey: WidgetDataKeys.futureLetterText)
        let goalName = defaults.string(forKey: WidgetDataKeys.goalName)
        let goalProgress = defaults.double(forKey: WidgetDataKeys.goalProgress)
        let totalSaved = defaults.double(forKey: WidgetDataKeys.totalSaved)
        let streakDays = defaults.integer(forKey: WidgetDataKeys.streakDays)
        let userName = defaults.string(forKey: WidgetDataKeys.userName)
        
        var commitmentDays: Int? = nil
        if let commitmentDate = defaults.object(forKey: WidgetDataKeys.commitmentDate) as? Date {
            commitmentDays = Calendar.current.dateComponents([.day], from: commitmentDate, to: Date()).day
        }
        
        return WidgetData(
            futureLetterText: letterText,
            goalName: goalName,
            goalProgress: goalProgress,
            totalSaved: totalSaved,
            streakDays: streakDays,
            commitmentDays: commitmentDays,
            userName: userName
        )
    }
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PanicButtonEntry {
        PanicButtonEntry(date: Date(), data: .placeholder, affirmation: Affirmation.random())
    }

    func getSnapshot(in context: Context, completion: @escaping (PanicButtonEntry) -> ()) {
        let data = context.isPreview ? .placeholder : WidgetData.load()
        let entry = PanicButtonEntry(date: Date(), data: data, affirmation: Affirmation.random())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let data = WidgetData.load()
        var entries: [PanicButtonEntry] = []

        // Create entries that rotate affirmations every 30 minutes
        let currentDate = Date()
        let affirmations = Affirmation.allCases.shuffled()
        
        for (index, _) in affirmations.enumerated() {
            let entryDate = Calendar.current.date(byAdding: .minute, value: index * 30, to: currentDate)!
            let entry = PanicButtonEntry(
                date: entryDate,
                data: data,
                affirmation: affirmations[index % affirmations.count]
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct PanicButtonEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
    let affirmation: Affirmation
}

// MARK: - Affirmations

enum Affirmation: String, CaseIterable {
    case pause = "Pause. Breathe. You're in control."
    case urge = "The urge will pass. It always does."
    case future = "Your future self is cheering for you."
    case deserve = "You deserve financial peace."
    case enough = "You are enough without buying anything."
    case wait = "Wait 24 hours. If it's meant to be, it'll still be there."
    case feeling = "Shopping won't fix the feeling."
    case proud = "Make your tomorrow self proud."
    case progress = "Progress over perfection."
    case choice = "Every choice shapes your story."
    
    static func random() -> Affirmation {
        allCases.randomElement() ?? .pause
    }
}

// MARK: - Widget Colors (matching app theme)

extension Color {
    /// Creates a color that adapts to light and dark mode using RGB tuples
    init(widgetLight: (Double, Double, Double), widgetDark: (Double, Double, Double)) {
        self.init(uiColor: UIColor { traitCollection in
            let rgb: (Double, Double, Double)
            switch traitCollection.userInterfaceStyle {
            case .dark:
                rgb = widgetDark
            default:
                rgb = widgetLight
            }
            return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1.0)
        })
    }
    
    static let widgetPrimary = Color(widgetLight: (0.89, 0.45, 0.36), widgetDark: (0.95, 0.65, 0.58))
    static let widgetPrimaryDark = Color(widgetLight: (0.76, 0.35, 0.27), widgetDark: (0.89, 0.45, 0.36))
    static let widgetSecondary = Color(widgetLight: (0.55, 0.68, 0.55), widgetDark: (0.65, 0.78, 0.65))
    static let widgetGold = Color(widgetLight: (0.91, 0.76, 0.42), widgetDark: (0.96, 0.88, 0.68))
    static let widgetBackground = Color(widgetLight: (0.99, 0.97, 0.94), widgetDark: (0.12, 0.10, 0.09))
    static let widgetBackgroundSecondary = Color(widgetLight: (0.96, 0.93, 0.88), widgetDark: (0.16, 0.14, 0.12))
    static let widgetTextPrimary = Color(widgetLight: (0.20, 0.18, 0.16), widgetDark: (0.95, 0.93, 0.90))
    static let widgetTextSecondary = Color(widgetLight: (0.45, 0.42, 0.38), widgetDark: (0.75, 0.72, 0.68))
    static let widgetStreak = Color(widgetLight: (0.95, 0.55, 0.30), widgetDark: (1.0, 0.65, 0.40))
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: PanicButtonEntry
    
    var body: some View {
        ZStack {
            // Subtle pattern background
            GeometryReader { geo in
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.widgetPrimary.opacity(0.08))
                        .frame(width: 60 + CGFloat(i * 20), height: 60 + CGFloat(i * 20))
                        .offset(x: geo.size.width * 0.7, y: -20 + CGFloat(i * 15))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Breathing circle indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.widgetPrimary)
                        .frame(width: 10, height: 10)
                    Text("Breathe")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.widgetPrimary)
                }
                
                Spacer()
                
                // Affirmation
                Text(entry.affirmation.rawValue)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.widgetTextPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                // Streak badge
                if entry.data.streakDays > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundColor(.widgetStreak)
                        Text("\(entry.data.streakDays) days")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.widgetTextSecondary)
                    }
                }
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: PanicButtonEntry
    
    var body: some View {
        ZStack {
            // Background decoration
            GeometryReader { geo in
                Circle()
                    .fill(Color.widgetSecondary.opacity(0.12))
                    .frame(width: 100, height: 100)
                    .offset(x: geo.size.width - 60, y: -30)
                
                Circle()
                    .fill(Color.widgetPrimary.opacity(0.08))
                    .frame(width: 80, height: 80)
                    .offset(x: geo.size.width - 100, y: geo.size.height - 40)
            }
            
            HStack(spacing: 16) {
                // Left side - Affirmation & action
                VStack(alignment: .leading, spacing: 8) {
                    // Header
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.widgetPrimary)
                        Text("Take a moment")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.widgetPrimary)
                    }
                    
                    // Main affirmation
                    Text(entry.affirmation.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.widgetTextPrimary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    // Call to action hint
                    HStack(spacing: 4) {
                        Text("Tap for help")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.widgetTextSecondary)
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundColor(.widgetTextSecondary)
                    }
                }
                
                // Right side - Stats
                VStack(spacing: 10) {
                    // Streak
                    VStack(spacing: 2) {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.widgetStreak)
                            Text("\(entry.data.streakDays)")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.widgetTextPrimary)
                        }
                        Text("day streak")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.widgetTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Saved amount
                    if entry.data.totalSaved > 0 {
                        VStack(spacing: 2) {
                            Text(formatCurrency(entry.data.totalSaved))
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.widgetSecondary)
                            Text("saved")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(.widgetTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(width: 80)
            }
            .padding(14)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Large Widget View

struct LargeWidgetView: View {
    let entry: PanicButtonEntry
    
    var body: some View {
        ZStack {
            // Decorative elements
            GeometryReader { geo in
                Circle()
                    .fill(Color.widgetGold.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .offset(x: geo.size.width - 80, y: -50)
                
                Circle()
                    .fill(Color.widgetSecondary.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .offset(x: -30, y: geo.size.height - 60)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Header with breathing prompt
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.widgetPrimary.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Circle()
                                .fill(Color.widgetPrimary)
                                .frame(width: 16, height: 16)
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Take a breath")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.widgetTextPrimary)
                            Text("You're in control")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.widgetTextSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Streak badge
                    if entry.data.streakDays > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.widgetStreak)
                            Text("\(entry.data.streakDays)")
                                .fontWeight(.bold)
                        }
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.widgetTextPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Capsule())
                    }
                }
                
                Divider()
                    .background(Color.widgetTextSecondary.opacity(0.3))
                
                // Letter excerpt or affirmation
                VStack(alignment: .leading, spacing: 6) {
                    if let letter = entry.data.futureLetterText, !letter.isEmpty {
                        Text("You wrote to yourself:")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.widgetPrimary)
                        
                        Text("\"\(truncateLetter(letter))\"")
                            .font(.system(.subheadline, design: .rounded))
                            .italic()
                            .foregroundColor(.widgetTextPrimary)
                            .lineLimit(3)
                    } else {
                        Text(entry.affirmation.rawValue)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.widgetTextPrimary)
                    }
                }
                .padding(.vertical, 4)
                
                Spacer()
                
                // Goal progress (if available)
                if let goalName = entry.data.goalName, !goalName.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(goalName)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.widgetTextPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(entry.data.goalProgress * 100))%")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.widgetSecondary)
                        }
                        
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.widgetSecondary.opacity(0.2))
                                    .frame(height: 8)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.widgetSecondary, Color(red: 0.65, green: 0.78, blue: 0.65)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(geo.size.width * entry.data.goalProgress, 8), height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Bottom stats row
                HStack(spacing: 12) {
                    if entry.data.totalSaved > 0 {
                        StatPill(
                            icon: "dollarsign.circle.fill",
                            value: formatCurrency(entry.data.totalSaved),
                            label: "saved",
                            color: .widgetSecondary
                        )
                    }
                    
                    if let days = entry.data.commitmentDays, days > 0 {
                        StatPill(
                            icon: "calendar.badge.checkmark",
                            value: "\(days)",
                            label: "days committed",
                            color: .widgetGold
                        )
                    }
                    
                    Spacer()
                    
                    // CTA
                    HStack(spacing: 4) {
                        Text("Need help?")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.widgetPrimary)
                }
            }
            .padding(16)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    private func truncateLetter(_ text: String) -> String {
        if text.count > 120 {
            return String(text.prefix(117)) + "..."
        }
        return text
    }
}

// MARK: - Stat Pill Component

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.widgetTextPrimary)
                Text(label)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.widgetTextSecondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Widget Entry View

struct PanicButtonWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .systemLarge:
                LargeWidgetView(entry: entry)
            default:
                SmallWidgetView(entry: entry)
            }
        }
        .widgetURL(URL(string: "spendless://panic"))
    }
}

// MARK: - Widget Configuration

struct PanicButtonWidget: Widget {
    let kind: String = "PanicButtonWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PanicButtonWidgetEntryView(entry: entry)
                    .containerBackground(Color.widgetBackground, for: .widget)
            } else {
                PanicButtonWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color.widgetBackground)
            }
        }
        .configurationDisplayName("Pause & Breathe")
        .description("A gentle reminder of your commitment. Tap when you feel tempted.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    PanicButtonWidget()
} timeline: {
    PanicButtonEntry(date: .now, data: .placeholder, affirmation: .pause)
}

#Preview("Medium", as: .systemMedium) {
    PanicButtonWidget()
} timeline: {
    PanicButtonEntry(date: .now, data: .placeholder, affirmation: .urge)
}

#Preview("Large", as: .systemLarge) {
    PanicButtonWidget()
} timeline: {
    PanicButtonEntry(date: .now, data: .placeholder, affirmation: .future)
}

