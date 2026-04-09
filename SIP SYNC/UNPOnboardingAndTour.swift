//
//  UNPOnboardingAndTour.swift
//

import SwiftUI

struct UNPOnboardingFlow: View {
    var body: some View {
        UNPWelcomeLoginView(
            onTakeQuickTour: {},
            onAppleSignInSuccess: {}
        )
    }
}

enum UNPTourKeys {
    static let completed = "unp_tour_done_v1"
}

struct UNPGuidedTourOverlay: View {
    @EnvironmentObject private var store: UNPDataStore
    @Binding var selectedTab: Int
    
    /// Tab indices match `MainTabView`’s `TabView`: Home, Community, Cart, Profile.
    private let messages: [(Int, String)] = [
        (0, "Home is your hub — Your Next Pour cards open Pour, Nudge, Explore, and Circles."),
        (1, "Community is where event chats and group images live."),
        (2, "Cart keeps your orders in one place."),
        (3, "Profile has your account — open Rewards & tiers for UNP points and demo tools.")
    ]
    
    private var index: Int {
        min(store.guidedTourStepIndex, messages.count - 1)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { }
            
            VStack(spacing: 16) {
                Text("Guided tour")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(UNPColors.accent)
                Text(messages[min(store.guidedTourStepIndex, messages.count - 1)].1)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(UNPColors.cream)
                    .padding()
                
                HStack(spacing: 12) {
                    Button("Skip") {
                        finishTour()
                    }
                    .foregroundStyle(UNPColors.creamMuted())
                    
                    Button(store.guidedTourStepIndex < messages.count - 1 ? "Next" : "Done") {
                        if store.guidedTourStepIndex < messages.count - 1 {
                            store.guidedTourStepIndex += 1
                            selectedTab = messages[store.guidedTourStepIndex].0
                        } else {
                            finishTour()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(UNPColors.accent)
                }
            }
            .padding(24)
            .background(UNPColors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card))
            .padding(24)
        }
        .onAppear {
            selectedTab = messages[0].0
        }
    }
    
    private func finishTour() {
        UserDefaults.standard.set(true, forKey: UNPTourKeys.completed)
        store.showGuidedTourOverlay = false
        store.guidedTourStepIndex = 0
    }
}

#Preview("UNP Onboarding") {
    UNPOnboardingFlow()
        .environmentObject(UNPDataStore.shared)
}

#Preview("UNP Guided Tour") {
    UNPGuidedTourOverlay(selectedTab: .constant(0))
        .environmentObject(UNPDataStore.shared)
}
