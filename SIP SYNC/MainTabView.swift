//  MainTabView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var unpStore: UNPDataStore
    @State private var selectedTab = 0
    @State private var selectedCategory: DrinkCategory = .drinks
    @State private var cartItems: [OrderItem] = []
    @State private var favoriteDrinks: [Drink] = []
    @State private var homeUserType: UserType? = nil
    @State private var socialPosts: [SocialPost] = [] // Shared posts array

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                HomeView(
                    selectedCategory: $selectedCategory,
                    cartItems: $cartItems,
                    favoriteDrinks: $favoriteDrinks,
                    selectedUserType: $homeUserType,
                    socialPosts: $socialPosts
                )
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)
            
            // Community Tab
            NavigationStack {
                CommunityView()
            }
            .tabItem {
                Image(systemName: "heart")
                Text("Community")
            }
            .tag(1)
            
            // Cart Tab
            NavigationStack {
                CartView(cartItems: $cartItems)
            }
            .tabItem {
                ZStack {
                    Image(systemName: "cart")
                    if !cartItems.isEmpty {
                        Text("\(cartItems.count)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 8, y: -8)
                    }
                }
                Text("Cart")
            }
            .tag(2)
            
            // Profile Tab
            NavigationStack {
                ProfileView(favoriteDrinks: $favoriteDrinks)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(3)
        }
        .tint(UNPColors.tabBarSelected)
        .overlay {
            if unpStore.showGuidedTourOverlay {
                UNPGuidedTourOverlay(selectedTab: $selectedTab)
            }
        }
        .onAppear {
            // Initialize social posts from sample data
            if socialPosts.isEmpty {
                socialPosts = SampleData.shared.sampleSocialPosts
            }
            if !UserDefaults.standard.bool(forKey: UNPTourKeys.completed) {
                unpStore.showGuidedTourOverlay = true
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            handleTabSelection(newValue)
        }
    }
    
    // MARK: - Tab Selection Logic
    private func handleTabSelection(_ newTab: Int) {
        switch newTab {
        case 0: // Home
            homeUserType = nil // Reset to "All" view
        case 1: // Community
            break // No special handling needed
        case 2: // Cart
            break // No special handling needed
        case 3: // Profile
            break // No special handling needed
        default:
            break
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppTheme.shared)
        .environmentObject(UNPDataStore.shared)
        .preferredColorScheme(AppTheme.shared.isNightMode ? .dark : .light)
}
