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
    static let spendLessPrimary = Color(light: (0.89, 0.45, 0.36), dark: (0.95, 0.65, 0.58))
    static let spendLessPrimaryDark = Color(light: (0.76, 0.35, 0.27), dark: (0.89, 0.45, 0.36))
    static let spendLessPrimaryLight = Color(light: (0.95, 0.65, 0.58), dark: (0.85, 0.55, 0.48))
    
    // Secondary - Sage green
    static let spendLessSecondary = Color(light: (0.55, 0.68, 0.55), dark: (0.65, 0.78, 0.65))
    static let spendLessSecondaryDark = Color(light: (0.42, 0.55, 0.42), dark: (0.55, 0.68, 0.55))
    static let spendLessSecondaryLight = Color(light: (0.75, 0.85, 0.75), dark: (0.65, 0.75, 0.65))
    
    // Accent - Warm gold for celebrations
    static let spendLessGold = Color(light: (0.91, 0.76, 0.42), dark: (0.96, 0.88, 0.68))
    static let spendLessGoldDark = Color(light: (0.80, 0.62, 0.25), dark: (0.91, 0.76, 0.42))
    static let spendLessGoldLight = Color(light: (0.96, 0.88, 0.68), dark: (0.90, 0.82, 0.60))
    
    // Backgrounds - Warm cream tones for light, warm dark tones for dark mode
    static let spendLessBackground = Color(light: (0.99, 0.97, 0.94), dark: (0.12, 0.10, 0.09))
    static let spendLessBackgroundSecondary = Color(light: (0.96, 0.93, 0.88), dark: (0.16, 0.14, 0.12))
    static let spendLessCardBackground = Color(light: (1.0, 1.0, 1.0), dark: (0.18, 0.16, 0.14))
    
    // Text colors - dark in light mode, light in dark mode
    static let spendLessTextPrimary = Color(light: (0.20, 0.18, 0.16), dark: (0.95, 0.93, 0.90))
    static let spendLessTextSecondary = Color(light: (0.45, 0.42, 0.38), dark: (0.75, 0.72, 0.68))
    static let spendLessTextMuted = Color(light: (0.65, 0.62, 0.58), dark: (0.55, 0.52, 0.48))
    
    // Semantic colors - adjusted for dark mode
    static let spendLessSuccess = Color(light: (0.55, 0.68, 0.55), dark: (0.65, 0.78, 0.65))
    static let spendLessWarning = Color(light: (0.91, 0.76, 0.42), dark: (0.96, 0.88, 0.68))
    static let spendLessError = Color(light: (0.85, 0.40, 0.40), dark: (0.95, 0.50, 0.50))
    
    // Special
    static let spendLessStreak = Color(light: (0.95, 0.55, 0.30), dark: (1.0, 0.65, 0.40))
    
    // Warm sand for gradient backgrounds (converted from HSB to RGB)
    static let warmSand = Color(
        light: (0.96, 0.94, 0.88),  // Light warm sand
        dark: (0.25, 0.22, 0.20)    // Dark warm sand
    )
}

// MARK: - Adaptive Color Helper

extension Color {
    /// Creates a color that adapts to light and dark mode using RGB tuples
    init(light: (Double, Double, Double), dark: (Double, Double, Double)) {
        self.init(uiColor: UIColor { traitCollection in
            let rgb: (Double, Double, Double)
            switch traitCollection.userInterfaceStyle {
            case .dark:
                rgb = dark
            default:
                rgb = light
            }
            return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1.0)
        })
    }
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

