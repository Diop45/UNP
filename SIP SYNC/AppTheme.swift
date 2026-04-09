//
//  AppTheme.swift
//  SIP SYNC
//
//  Time-of-day background (white/day, black/night); accent matches UNP creamMuted.
//

import SwiftUI

// MARK: - App Theme (time-based background)
final class AppTheme: ObservableObject {
    static let shared = AppTheme()
    
    /// Day: 6am–6pm. Night: 6pm–6am
    @Published private(set) var isNightMode: Bool
    
    init() {
        self.isNightMode = Self.isNightHour(Calendar.current.component(.hour, from: Date()))
    }
    
    private static func isNightHour(_ hour: Int) -> Bool {
        hour >= 18 || hour < 6  // 6pm–6am = night
    }
    
    /// Primary background: white (day) or black (night)
    var primaryBackground: Color {
        isNightMode ? .black : .white
    }
    
    /// Primary text: black (day) or white (night)
    var textPrimary: Color {
        isNightMode ? .white : .black
    }
    
    /// Secondary/muted text
    var textSecondary: Color {
        isNightMode ? Color.white.opacity(0.7) : Color.black.opacity(0.6)
    }
    
    /// Matches `UNPColors.accent` (copper when dark, creamMuted when light).
    var accent: Color { UNPColors.accent }
    
    /// Card/surface background
    var cardBackground: Color {
        isNightMode ? Color.white.opacity(0.08) : Color.black.opacity(0.04)
    }
    
    /// Input field background
    var inputBackground: Color {
        isNightMode ? Color.white.opacity(0.12) : Color.black.opacity(0.06)
    }
    
    /// Border color
    var borderColor: Color {
        isNightMode ? Color.white.opacity(0.2) : Color.black.opacity(0.15)
    }
    
    /// Preferred color scheme for system UI
    var preferredColorScheme: ColorScheme? {
        isNightMode ? .dark : .light
    }
    
    /// Refresh theme based on current time (call periodically or on appear)
    func refresh() {
        let hour = Calendar.current.component(.hour, from: Date())
        let newNight = Self.isNightHour(hour)
        if newNight != isNightMode {
            isNightMode = newNight
        }
    }
}
