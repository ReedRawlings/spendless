//
//  Theme.swift
//  SpendLess
//
//  Design system for SpendLess - warm, encouraging, celebratory
//

import SwiftUI

// MARK: - Color Palette

extension Color {
    // Primary - Warm terracotta/coral
    static let spendLessPrimary = Color(red: 0.89, green: 0.45, blue: 0.36)
    static let spendLessPrimaryDark = Color(red: 0.76, green: 0.35, blue: 0.27)
    static let spendLessPrimaryLight = Color(red: 0.95, green: 0.65, blue: 0.58)
    
    // Secondary - Sage green
    static let spendLessSecondary = Color(red: 0.55, green: 0.68, blue: 0.55)
    static let spendLessSecondaryDark = Color(red: 0.42, green: 0.55, blue: 0.42)
    static let spendLessSecondaryLight = Color(red: 0.75, green: 0.85, blue: 0.75)
    
    // Accent - Warm gold for celebrations
    static let spendLessGold = Color(red: 0.91, green: 0.76, blue: 0.42)
    static let spendLessGoldDark = Color(red: 0.80, green: 0.62, blue: 0.25)
    static let spendLessGoldLight = Color(red: 0.96, green: 0.88, blue: 0.68)
    
    // Backgrounds - Warm cream tones
    static let spendLessBackground = Color(red: 0.99, green: 0.97, blue: 0.94)
    static let spendLessBackgroundSecondary = Color(red: 0.96, green: 0.93, blue: 0.88)
    static let spendLessCardBackground = Color.white
    
    // Text colors
    static let spendLessTextPrimary = Color(red: 0.20, green: 0.18, blue: 0.16)
    static let spendLessTextSecondary = Color(red: 0.45, green: 0.42, blue: 0.38)
    static let spendLessTextMuted = Color(red: 0.65, green: 0.62, blue: 0.58)
    
    // Semantic colors
    static let spendLessSuccess = Color(red: 0.55, green: 0.68, blue: 0.55)
    static let spendLessWarning = Color(red: 0.91, green: 0.76, blue: 0.42)
    static let spendLessError = Color(red: 0.85, green: 0.40, blue: 0.40)
    
    // Special
    static let spendLessStreak = Color(red: 0.95, green: 0.55, blue: 0.30) // Fire orange
    
    // Warm sand for gradient backgrounds
    static let warmSand = Color(hue: 0.08, saturation: 0.12, brightness: 0.88)
}

// MARK: - Typography

struct SpendLessFont {
    // Use SF Pro Rounded for friendly, approachable feel
    static func rounded(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        return Font.system(style, design: .rounded).weight(weight)
    }
    
    // Display - Large headlines
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title, design: .rounded).weight(.semibold)
    static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
    static let title3 = Font.system(.title3, design: .rounded).weight(.medium)
    
    // Body
    static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .rounded)
    static let bodyBold = Font.system(.body, design: .rounded).weight(.semibold)
    static let callout = Font.system(.callout, design: .rounded)
    static let subheadline = Font.system(.subheadline, design: .rounded)
    
    // Small
    static let footnote = Font.system(.footnote, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
    static let caption2 = Font.system(.caption2, design: .rounded)
}

// MARK: - Spacing

struct SpendLessSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius

struct SpendLessRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Shadows

struct SpendLessShadow {
    static let cardShadow = ShadowStyle(
        color: Color.black.opacity(0.08),
        radius: 12,
        x: 0,
        y: 4
    )
    
    static let buttonShadow = ShadowStyle(
        color: Color.spendLessPrimary.opacity(0.3),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let subtleShadow = ShadowStyle(
        color: Color.black.opacity(0.05),
        radius: 6,
        x: 0,
        y: 2
    )
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifier for Shadows

extension View {
    func spendLessShadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
    
    func cardStyle() -> some View {
        self
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
            .spendLessShadow(SpendLessShadow.cardShadow)
    }
}

// MARK: - Animation Durations

struct SpendLessAnimation {
    static let quick: Double = 0.2
    static let standard: Double = 0.35
    static let slow: Double = 0.5
    static let celebration: Double = 0.8
    
    static let springResponse: Double = 0.5
    static let springDamping: Double = 0.7
    
    static var spring: Animation {
        .spring(response: springResponse, dampingFraction: springDamping)
    }
    
    static var bouncy: Animation {
        .spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - Gradients

struct SpendLessGradient {
    static let warmBackground = LinearGradient(
        colors: [Color.spendLessBackground, Color.spendLessBackgroundSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let primaryButton = LinearGradient(
        colors: [Color.spendLessPrimary, Color.spendLessPrimaryDark],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let celebration = LinearGradient(
        colors: [Color.spendLessGold, Color.spendLessGoldLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let progress = LinearGradient(
        colors: [Color.spendLessSecondary, Color.spendLessSecondaryLight],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Preview Helper

#Preview("Theme Colors") {
    ScrollView {
        VStack(spacing: 20) {
            Group {
                Text("Primary Colors")
                    .font(SpendLessFont.headline)
                HStack {
                    ColorSwatch(color: .spendLessPrimary, name: "Primary")
                    ColorSwatch(color: .spendLessPrimaryDark, name: "Primary Dark")
                    ColorSwatch(color: .spendLessPrimaryLight, name: "Primary Light")
                }
            }
            
            Group {
                Text("Secondary Colors")
                    .font(SpendLessFont.headline)
                HStack {
                    ColorSwatch(color: .spendLessSecondary, name: "Secondary")
                    ColorSwatch(color: .spendLessSecondaryDark, name: "Sec Dark")
                    ColorSwatch(color: .spendLessSecondaryLight, name: "Sec Light")
                }
            }
            
            Group {
                Text("Gold/Accent")
                    .font(SpendLessFont.headline)
                HStack {
                    ColorSwatch(color: .spendLessGold, name: "Gold")
                    ColorSwatch(color: .spendLessGoldDark, name: "Gold Dark")
                    ColorSwatch(color: .spendLessGoldLight, name: "Gold Light")
                }
            }
            
            Group {
                Text("Typography")
                    .font(SpendLessFont.headline)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Large Title").font(SpendLessFont.largeTitle)
                    Text("Title").font(SpendLessFont.title)
                    Text("Title 2").font(SpendLessFont.title2)
                    Text("Headline").font(SpendLessFont.headline)
                    Text("Body").font(SpendLessFont.body)
                    Text("Caption").font(SpendLessFont.caption)
                }
            }
        }
        .padding()
    }
    .background(Color.spendLessBackground)
}

struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
            Text(name)
                .font(.caption2)
        }
    }
}

