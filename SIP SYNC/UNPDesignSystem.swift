//
//  UNPDesignSystem.swift
//  Until The Next Pour — design tokens
//

import SwiftUI
import UIKit

enum UNPColors {
    static let background = Color(red: 0.039, green: 0.031, blue: 0.024)      // #0A0806
    static let cardSurface = Color(red: 0.129, green: 0.110, blue: 0.086)       // #211C16
    /// Selected tab icon/label on `TabView` (distinct from content accent).
    static let tabBarSelected = Color(red: 0.58, green: 0.33, blue: 0.98)       // violet ~#9468FA
    static let cream = Color(red: 0.961, green: 0.902, blue: 0.784)           // #F5E6C8
    static func creamMuted(_ opacity: Double = 0.45) -> Color {
        cream.opacity(opacity)
    }
    /// Solid copper (dark / “night” UI); use for explicit non-adaptive fills when needed.
    static let accentCopper = Color(red: 0.831, green: 0.522, blue: 0.224)     // #D4853A
    /// Icons & primary tint: **copper** in dark mode, **creamMuted** in light (follows `ColorScheme`).
    static var accent: Color {
        Color(
            UIColor { traits in
                if traits.userInterfaceStyle == .light {
                    return UIColor(red: 0.961, green: 0.902, blue: 0.784, alpha: 0.45)
                }
                return UIColor(red: 0.831, green: 0.522, blue: 0.224, alpha: 1.0)
            }
        )
    }
}

enum UNPRadius {
    static let card: CGFloat = 16
    static let small: CGFloat = 12
}

extension Font {
    static func unpDisplay(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func unpBody(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
}

struct UNPCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(UNPColors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
    }
}

extension View {
    func unpCard() -> some View { modifier(UNPCardStyle()) }
}
