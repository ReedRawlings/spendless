//
//  NoBuyCalendarView.swift
//  SpendLess
//
//  Beautiful calendar view for NoBuy challenge tracking
//

import SwiftUI
import Lottie

struct NoBuyCalendarView: View {
    let challenge: NoBuyChallenge
    let entries: [NoBuyDayEntry]
    let onDayTap: (Date) -> Void
    @Binding var celebratingDate: Date?

    private let calendar = Calendar.current

    init(challenge: NoBuyChallenge, entries: [NoBuyDayEntry], celebratingDate: Binding<Date?> = .constant(nil), onDayTap: @escaping (Date) -> Void) {
        self.challenge = challenge
        self.entries = entries
        self._celebratingDate = celebratingDate
        self.onDayTap = onDayTap
    }

    /// Days to show in the challenge
    private var challengeDays: [Date] {
        var days: [Date] = []
        var currentDate = challenge.startDate
        let endDate = challenge.endDate

        while currentDate <= endDate {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return days
    }

    private func isCelebrating(_ date: Date) -> Bool {
        guard let celebratingDate else { return false }
        return calendar.isDate(date, inSameDayAs: celebratingDate)
    }

    var body: some View {
        VStack(spacing: SpendLessSpacing.md) {
            // Scrollable days view
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SpendLessSpacing.sm) {
                        ForEach(challengeDays, id: \.self) { date in
                            DayCell(
                                date: date,
                                entry: entries.entry(for: date),
                                isToday: calendar.isDateInToday(date),
                                isFuture: date > Date(),
                                isCelebrating: isCelebrating(date),
                                onTap: { onDayTap(date) }
                            )
                            .id(date)
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.sm)
                }
                .onAppear {
                    // Scroll to today or first unchecked day
                    if let today = challengeDays.first(where: { calendar.isDateInToday($0) }) {
                        withAnimation {
                            proxy.scrollTo(today, anchor: .center)
                        }
                    }
                }
            }
        }
        .padding(.vertical, SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
        .spendLessShadow(SpendLessShadow.cardShadow)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("NoBuy challenge calendar")
    }
}

// MARK: - Day Cell

private struct DayCell: View {
    let date: Date
    let entry: NoBuyDayEntry?
    let isToday: Bool
    let isFuture: Bool
    let isCelebrating: Bool
    let onTap: () -> Void

    @State private var showLottie = false
    @State private var celebrationScale: CGFloat = 1.0

    private let calendar = Calendar.current

    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private var isTappable: Bool {
        !isFuture
    }

    var body: some View {
        Button(action: handleTap) {
            VStack(spacing: SpendLessSpacing.xs) {
                // Day name (Mon, Tue, etc.)
                Text(dayName)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(isToday ? Color.spendLessPrimary : Color.spendLessTextMuted)

                // Day circle with status
                ZStack {
                    // Background
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 44, height: 44)

                    // Border for today
                    if isToday {
                        Circle()
                            .strokeBorder(Color.spendLessPrimary, lineWidth: 2)
                            .frame(width: 44, height: 44)
                    }

                    // Content
                    Group {
                        if let entry {
                            if entry.isSuccess {
                                Image(systemName: entry.successEmoji)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(Color.spendLessGold)
                                    .scaleEffect(celebrationScale)
                            } else {
                                // Missed - show day number with dot
                                VStack(spacing: 2) {
                                    Text("\(dayNumber)")
                                        .font(SpendLessFont.caption)
                                        .foregroundStyle(Color.spendLessTextMuted)
                                    Circle()
                                        .fill(Color.spendLessTextMuted.opacity(0.4))
                                        .frame(width: 5, height: 5)
                                }
                            }
                        } else if isToday {
                            // Today needs check-in
                            Text("?")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessPrimary)
                        } else {
                            // Regular day
                            Text("\(dayNumber)")
                                .font(SpendLessFont.body)
                                .foregroundStyle(textColor)
                        }
                    }

                    // Lottie celebration animation
                    if showLottie {
                        LottieView(animation: .named("starSuccess"))
                            .playing(loopMode: .playOnce)
                            .frame(width: 80, height: 80)
                            .allowsHitTesting(false)
                    }
                }

                // Month label (only show for 1st of month)
                if dayNumber == 1 {
                    Text(monthName)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.spendLessTextMuted)
                } else {
                    // Spacer for alignment
                    Color.clear
                        .frame(height: 11)
                }
            }
        }
        .disabled(!isTappable)
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .onChange(of: isCelebrating) { _, newValue in
            if newValue {
                triggerCelebration()
            }
        }
    }

    private var backgroundColor: Color {
        if let entry, entry.isSuccess {
            return Color.spendLessGold.opacity(0.15)
        } else if isToday {
            return Color.spendLessPrimary.opacity(0.1)
        } else if isFuture {
            return Color.spendLessTextMuted.opacity(0.05)
        } else {
            return Color.clear
        }
    }

    private var textColor: Color {
        if isFuture {
            return Color.spendLessTextMuted.opacity(0.4)
        } else {
            return Color.spendLessTextSecondary
        }
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let dateString = formatter.string(from: date)

        if let entry {
            if entry.isSuccess {
                return "\(dateString), no purchases, successful"
            } else {
                return "\(dateString), purchase made"
            }
        } else if isToday {
            return "\(dateString), today, needs check-in"
        } else if isFuture {
            return "\(dateString), future date"
        } else {
            return dateString
        }
    }

    private var accessibilityHint: String {
        if isTappable {
            if entry == nil && isToday {
                return "Double tap to check in for today"
            } else if entry != nil {
                return "Double tap to update check-in"
            }
            return "Double tap to check in"
        }
        return ""
    }

    private func handleTap() {
        guard isTappable else { return }
        HapticFeedback.selection()
        onTap()
    }

    private func triggerCelebration() {
        HapticFeedback.noBuySuccess()

        // Show Lottie animation
        showLottie = true

        // Pulse the icon
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            celebrationScale = 1.2
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                celebrationScale = 1.0
            }
        }

        // Hide Lottie after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showLottie = false
        }
    }
}

// MARK: - Preview

#Preview {
    let challenge = NoBuyChallenge(
        startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        durationType: .oneWeek,
        offLimitCategories: [.clothing, .beauty]
    )

    let entries: [NoBuyDayEntry] = (-3...(-1)).map { dayOffset in
        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
        return NoBuyDayEntry(
            challengeID: challenge.id,
            date: date,
            didMakePurchase: dayOffset == -2 // One missed day
        )
    }

    return VStack {
        NoBuyCalendarView(
            challenge: challenge,
            entries: entries,
            onDayTap: { date in
                print("Tapped: \(date)")
            }
        )
        .padding()
    }
    .background(Color.spendLessBackground)
}

#Preview("30 Days") {
    let challenge = NoBuyChallenge(
        startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
        durationType: .oneMonth,
        offLimitCategories: [.clothing, .beauty]
    )

    let entries: [NoBuyDayEntry] = (-10...(-1)).map { dayOffset in
        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
        return NoBuyDayEntry(
            challengeID: challenge.id,
            date: date,
            didMakePurchase: dayOffset == -5 || dayOffset == -8
        )
    }

    return VStack {
        NoBuyCalendarView(
            challenge: challenge,
            entries: entries,
            onDayTap: { date in
                print("Tapped: \(date)")
            }
        )
        .padding()
    }
    .background(Color.spendLessBackground)
}
