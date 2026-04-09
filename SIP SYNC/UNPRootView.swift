//
//  UNPRootView.swift
//  Until The Next Pour — tab shell
//

import SwiftUI

struct UNPRootView: View {
    @EnvironmentObject private var store: UNPDataStore
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                UNPLandingView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            NavigationStack {
                UNPExploreJourneyView()
            }
            .tabItem { Label("Explore", systemImage: "map.fill") }
            .tag(1)

            NavigationStack {
                UNPPourJourneyView()
            }
            .tabItem { Label("Pour", systemImage: "wineglass.fill") }
            .tag(2)

            NavigationStack {
                UNPPourCircleView()
            }
            .tabItem { Label("Circles", systemImage: "person.3.fill") }
            .tag(3)

            NavigationStack {
                UNPProfileShellView()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
            .tag(4)
        }
        .tint(UNPColors.tabBarSelected)
        .background(UNPColors.background)
        .onAppear {
            if !UserDefaults.standard.bool(forKey: UNPTourKeys.completed) {
                store.showGuidedTourOverlay = true
            }
        }
        .overlay {
            if store.showGuidedTourOverlay {
                UNPGuidedTourOverlay(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview("UNP Root") {
    UNPRootView()
        .environmentObject(UNPDataStore.shared)
}
