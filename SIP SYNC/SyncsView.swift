//
//  SyncsView.swift
//  SIP SYNC
//
//  Created by AI Assistant on 10/28/25.
//

import SwiftUI

struct SyncsView: View {
    @Binding var cartItems: [OrderItem]
    @Binding var socialPosts: [SocialPost] // Shared posts to update HomeView
    @State private var searchText = ""
    @State private var selectedUserType: UserType? = nil
    @State private var showCreateSync = false
    @State private var showSearch = false
    @State private var favoriteDrinks: [Drink] = []
    
    // Current user (would come from session/auth)
    private var currentUser: SocialUser {
        SampleData.shared.sampleUser.name == "John Doe" 
            ? SocialUser(name: "John Doe", username: "johndoe", userType: .consumer, location: "Detroit, MI")
            : SampleData.shared.sampleSocialUsers.first ?? SocialUser(name: "User", username: "user", userType: .consumer, location: "Detroit")
    }
    
    // Filter posts to show only syncs (user uploads)
    private var syncPosts: [SocialPost] {
        socialPosts.filter { post in
            // Show posts that match selected user type filter
            if let userType = selectedUserType {
                return post.author.userType == userType
            }
            return true
        }
        .sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.25),
                    Color(red: 0.1, green: 0.05, blue: 0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // New TopNavigationBar with raised background and shadow
                TopNavigationBar(selectedCategory: $selectedUserType)
                
                // Search field below the navigation
                SearchPillField(text: $searchText) {
                    showSearch = true
                }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Create Sync Button
                        Button(action: {
                            showCreateSync = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Create a Sync")
                                    .font(.headline)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.yellow)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        SectionHeader(title: "Recent Syncs")
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        if syncPosts.isEmpty {
                            EmptySyncsView()
                                .padding(.horizontal, 20)
                                .padding(.top, 40)
                        } else {
                            ForEach(syncPosts) { post in
                                SyncPostCard(post: post, cartItems: $cartItems)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showCreateSync) {
            SyncPostView(socialPosts: $socialPosts, currentUser: currentUser)
        }
        .sheet(isPresented: $showSearch) {
            UnifiedSearchView(
                searchText: $searchText,
                isPresented: $showSearch,
                cartItems: $cartItems,
                favoriteDrinks: $favoriteDrinks
            )
                        }
                    }
}

// MARK: - Sync Post Card (shows actual posts with images and captions)
struct SyncPostCard: View {
    let post: SocialPost
    @Binding var cartItems: [OrderItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author info
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.5),
                                Color.orange.opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: post.author.userType == .bartender ? "wineglass.fill" : "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.author.username)
                        .foregroundColor(.white)
                        .font(.headline)
                        if post.author.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                    HStack(spacing: 6) {
                        Text(timeAgoString(from: post.createdAt))
                            .foregroundColor(.gray)
                            .font(.caption)
                        if !post.tags.isEmpty {
                            Text("•")
                                .foregroundColor(.gray)
                                .font(.caption)
                            Text(post.tags.prefix(2).joined(separator: " "))
                            .foregroundColor(.yellow)
                            .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            // Caption
            if !post.content.isEmpty {
                Text(post.content)
                    .foregroundColor(.white)
                    .font(.body)
                    .lineSpacing(4)
            }
            
            // Image
            if let imageName = post.image {
                // Check if it's a user upload (starts with "user_upload_") or asset name
                if imageName.hasPrefix("user_upload_") {
                    // Placeholder for user-uploaded image
                    // In a real app, this would load from a URL or cache
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                        .frame(height: 300)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.yellow)
                                Text("User Upload")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                } else {
                    // Asset image
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(12)
                }
            }
            
            // Tags
            if !post.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Add to cart
                    let mockDrink = SampleData.shared.sampleDrinks.first { $0.category == .drinks } ?? SampleData.shared.sampleDrinks[0]
                    let item = OrderItem(drink: mockDrink, quantity: 1, price: mockDrink.price)
                    cartItems.append(item)
                }) {
                    Label("Sync", systemImage: "arrow.2.squarepath")
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.yellow)
                        .cornerRadius(16)
                }
                
                Button(action: {}) {
                    Label("Reply", systemImage: "bubble.left")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(16)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
}

// MARK: - Empty Syncs View
struct EmptySyncsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.2.squarepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No syncs yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Be the first to sync and share your drink experience with the community!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
}

#Preview {
    SyncsView(cartItems: .constant([]), socialPosts: .constant([]))
}




