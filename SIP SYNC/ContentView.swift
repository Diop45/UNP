//
//  ContentView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var selectedCategory: DrinkCategory = .drinks
    @State private var cartItems: [OrderItem] = []
    @State private var favoriteDrinks: [Drink] = []
    @State private var homeUserType: UserType? = nil
    @State private var socialPosts: [SocialPost] = [] // Shared posts array

    var body: some View {
        TabView(selection: Binding(
            get: { selectedTab },
            set: { newValue in
                selectedTab = newValue
                handleTabSelection(newValue)
            }
        )) {
            // Home Tab
            HomeTabView(
                selectedCategory: $selectedCategory,
                cartItems: $cartItems,
                favoriteDrinks: $favoriteDrinks,
                selectedUserType: $homeUserType,
                socialPosts: $socialPosts
            )
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)

            // Syncs Tab
            SyncsTabView(cartItems: $cartItems, socialPosts: $socialPosts)
            .tabItem {
                Image(systemName: "arrow.2.squarepath")
                Text("Syncs")
            }
            .tag(1)

            // Stories Tab
            StoriesTabView()
            .tabItem {
                Image(systemName: "sparkles")
                Text("Stories")
            }
            .tag(2)

            // Cart Tab
            CartTabView(cartItems: $cartItems)
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
            .tag(3)

            // Profile Tab
            ProfileTabView(favoriteDrinks: $favoriteDrinks)
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(4)
        }
        .accentColor(.yellow)
        .preferredColorScheme(.dark)
        .onAppear {
            // Initialize social posts from sample data
            if socialPosts.isEmpty {
                socialPosts = SampleData.shared.sampleSocialPosts
            }
        }
    }
    
    // MARK: - Tab Selection Logic
    private func handleTabSelection(_ newTab: Int) {
        print("Tab selected: \(newTab)")
        switch newTab {
        case 0: // Home
            print("Resetting to Home view")
            homeUserType = nil // Reset to "All" view
        case 1: // Syncs
            print("Switching to Syncs")
            break // No special handling needed
        case 2: // Stories
            print("Switching to Stories")
            break // No special handling needed
        case 3: // Cart
            print("Switching to Cart")
            break // No special handling needed
        case 4: // Profile
            print("Switching to Profile")
            break // No special handling needed
        default:
            print("Unknown tab: \(newTab)")
            break
        }
    }
}

// MARK: - Tab View Wrappers
// These wrappers ensure the tab bar remains persistent across all navigation

struct HomeTabView: View {
    @Binding var selectedCategory: DrinkCategory
    @Binding var cartItems: [OrderItem]
    @Binding var favoriteDrinks: [Drink]
    @Binding var selectedUserType: UserType?
    @Binding var socialPosts: [SocialPost]
    
    var body: some View {
        NavigationStack {
            HomeView(
                selectedCategory: $selectedCategory,
                cartItems: $cartItems,
                favoriteDrinks: $favoriteDrinks,
                selectedUserType: $selectedUserType,
                socialPosts: $socialPosts
            )
        }
    }
}

struct SyncsTabView: View {
    @Binding var cartItems: [OrderItem]
    @Binding var socialPosts: [SocialPost]
    
    var body: some View {
        NavigationStack {
            SyncsView(cartItems: $cartItems, socialPosts: $socialPosts)
        }
    }
}

struct StoriesTabView: View {
    var body: some View {
        NavigationStack {
            StoriesView()
        }
    }
}

struct CartTabView: View {
    @Binding var cartItems: [OrderItem]
    
    var body: some View {
        NavigationStack {
            CartView(cartItems: $cartItems)
        }
    }
}

struct ProfileTabView: View {
    @Binding var favoriteDrinks: [Drink]
    
    var body: some View {
        NavigationStack {
            ProfileView(favoriteDrinks: $favoriteDrinks)
        }
    }
}

#Preview {
    ContentView()
}
