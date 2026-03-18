//
//  CommunityView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

struct CommunityView: View {
    @StateObject private var userManager = UserManager.shared
    @State private var searchText = ""
    @State private var selectedUserType: UserType? = nil
    @State private var socialPosts: [SocialPost] = []
    @State private var favoriteDrinks: [Drink] = []
    @State private var cartItems: [OrderItem] = []
    @State private var showSearch = false
    @State private var selectedPostForComment: SocialPost?
    @State private var showCommentSheet = false
    @StateObject private var tipJarManager = TipJarManager.shared
    @State private var showTipAmountSheet = false
    @State private var selectedPostForTip: SocialPost?
    @State private var showInsufficientFundsAlert = false
    @State private var insufficientFundsMessage = ""
    
    let sampleData = SampleData.shared
    
    // Current user as SocialUser
    private var currentSocialUser: SocialUser {
        if let user = userManager.currentUser {
            return SocialUser(
                name: user.name,
                username: user.name.lowercased().replacingOccurrences(of: " ", with: ""),
                profileImage: user.profileImage,
                userType: user.userType,
                location: user.location,
                verified: false
            )
        }
        return sampleData.sampleSocialUsers.first ?? SocialUser(
            name: "User",
            username: "user",
            userType: .consumer,
            location: "Detroit"
        )
    }
    
    var filteredPosts: [SocialPost] {
        let base: [SocialPost]
        if let userType = selectedUserType {
            base = socialPosts.filter { $0.author.userType == userType }
        } else {
            base = socialPosts
        }
        return base.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ZStack {
            // Dark purple background that flows from navigation
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
                // TopNavigationBar with raised background and shadow
                TopNavigationBar(selectedCategory: $selectedUserType)
                
                // Unified scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        // Search field below the navigation
                        SearchPillField(text: $searchText) {
                            showSearch = true
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        
                        // Community header
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(
                                title: "Community Feed",
                                subtitle: "Connect with fellow enthusiasts",
                                showChevron: false
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Social feed list
                        LazyVStack(spacing: 24) {
                            ForEach(filteredPosts) { post in
                                SocialPostCard(
                                    post: post,
                                    cartItems: $cartItems,
                                    onLike: {
                                        handleLike(for: post)
                                    },
                                    onAddToCart: {
                                        // Find or create drink based on post
                                        let drink = findOrCreateDrinkFromPost(post)
                                        let orderItem = OrderItem(drink: drink, quantity: 1, price: drink.price)
                                        cartItems.append(orderItem)
                                    },
                                    onComment: {
                                        selectedPostForComment = post
                                        showCommentSheet = true
                                    },
                                    onRepost: {
                                        handleRepost(for: post)
                                    },
                                    onTip: {
                                        selectedPostForTip = post
                                        showTipAmountSheet = true
                                    }
                                )
                                .padding(.horizontal, 20)
                                .padding(.bottom, 4)
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            UnifiedSearchView(
                searchText: $searchText,
                isPresented: $showSearch,
                cartItems: $cartItems,
                favoriteDrinks: $favoriteDrinks
            )
        }
        .sheet(isPresented: $showCommentSheet) {
            if let post = selectedPostForComment,
               let index = socialPosts.firstIndex(where: { $0.id == post.id }) {
                CommentSheet(post: Binding(
                    get: { socialPosts[index] },
                    set: { socialPosts[index] = $0 }
                ), currentUser: currentSocialUser)
            }
        }
        .sheet(isPresented: $showTipAmountSheet) {
            if let post = selectedPostForTip {
                TipAmountSheet(
                    post: post,
                    onTipSent: { amount in
                        let result = tipJarManager.processTip(amount: amount, bartenderId: post.author.id)
                        if !result.isSuccess {
                            if let errorMessage = result.errorMessage {
                                insufficientFundsMessage = errorMessage
                                showInsufficientFundsAlert = true
                            }
                        }
                        showTipAmountSheet = false
                    }
                )
            }
        }
        .alert("Insufficient Funds", isPresented: $showInsufficientFundsAlert) {
            Button("Add Funds") {
                // Navigate to profile to add funds
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(insufficientFundsMessage)
        }
        .onAppear {
            loadSocialPosts()
            // Initialize user if needed
            if userManager.currentUser == nil {
                userManager.currentUser = sampleData.sampleUser
            }
        }
    }
    
    private func loadSocialPosts() {
        socialPosts = sampleData.sampleSocialPosts
    }
    
    // MARK: - Interaction Handlers
    
    private func handleLike(for post: SocialPost) {
        guard let index = socialPosts.firstIndex(where: { $0.id == post.id }),
              var currentUser = userManager.currentUser else { return }
        
        let wasLiked = post.isLiked
        
        // Toggle like state on post
        socialPosts[index].isLiked.toggle()
        socialPosts[index].likes += wasLiked ? -1 : 1
        
        // Update user's liked posts
        if wasLiked {
            currentUser.likedPostIds.remove(post.id)
        } else {
            currentUser.likedPostIds.insert(post.id)
        }
        
        userManager.updateUser(currentUser)
    }
    
    private func handleRepost(for post: SocialPost) {
        guard let index = socialPosts.firstIndex(where: { $0.id == post.id }) else { return }
        
        let wasSynced = post.isSynced
        
        // Toggle sync state
        socialPosts[index].isSynced.toggle()
        socialPosts[index].syncs += wasSynced ? -1 : 1
        
        // If reposting (not un-reposting), create a new repost
        if !wasSynced {
            let repost = SocialPost(
                author: currentSocialUser,
                content: post.content,
                image: post.image,
                tags: post.tags,
                createdAt: Date(),
                likes: 0,
                comments: 0,
                syncs: 0,
                isLiked: false,
                isSynced: false,
                postType: post.postType,
                commentsList: [],
                repostedBy: currentSocialUser,
                originalPostId: post.id
            )
            
            // Insert repost at the beginning of the feed
            socialPosts.insert(repost, at: 0)
            
            // Increment sync count on original post
            socialPosts[index].syncs += 1
        }
    }
    
    // Helper function to find or create a drink from a post
    private func findOrCreateDrinkFromPost(_ post: SocialPost) -> Drink {
        // Try to match by image name first
        if let imageName = post.image {
            if let matchedDrink = sampleData.sampleDrinks.first(where: { $0.image.lowercased() == imageName.lowercased() }) {
                return matchedDrink
            }
        }
        
        // Try to match by post content/tags (look for drink names)
        let content = post.content.lowercased()
        for drink in sampleData.sampleDrinks {
            if content.contains(drink.name.lowercased()) {
                return drink
            }
        }
        
        // Try to match by tags
        for tag in post.tags {
            let tagLower = tag.lowercased().replacingOccurrences(of: "#", with: "")
            if let matchedDrink = sampleData.sampleDrinks.first(where: { drink in
                drink.name.lowercased() == tagLower || drink.tags.contains(where: { $0.lowercased() == tagLower })
            }) {
                return matchedDrink
            }
        }
        
        // Default: return first drink from drinks category, or first available
        return sampleData.sampleDrinks.first { $0.category == .drinks } ?? sampleData.sampleDrinks[0]
    }
}

#Preview {
    CommunityView()
}
