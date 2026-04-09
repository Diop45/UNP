//
//  SIP_SYNCApp.swift
//  Until The Next Pour
//

import SwiftUI

@main
struct SIP_SYNCApp: App {
    @StateObject private var unpStore = UNPDataStore.shared

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(unpStore)
                .environmentObject(AppTheme.shared)
        }
    }
}

private struct AppRootView: View {
    @EnvironmentObject private var unpStore: UNPDataStore
    @EnvironmentObject private var theme: AppTheme
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if unpStore.firstRunCompleted {
                MainTabView()
            } else {
                UNPOnboardingFlow()
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .onAppear { theme.refresh() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { theme.refresh() }
        }
    }
}
