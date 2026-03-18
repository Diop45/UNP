//
//  HomeView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedCategory: DrinkCategory
    @Binding var cartItems: [OrderItem]
    @Binding var favoriteDrinks: [Drink]
    @Binding var selectedUserType: UserType?
    @Binding var socialPosts: [SocialPost] // Shared posts array
    @StateObject private var userManager = UserManager.shared
    @State private var searchText = ""
    @State private var showDiscovery = false
    @State private var selectedInterests: Set<DrinkInterest> = []
    @State private var showDrinkDetail = false
    @State private var selectedDrink: Drink?
    @State private var selectedBartenderProfile: BartenderProfile?
    @State private var showBartenderDetail = false
    @State private var showBartenderClasses = false
    @State private var showSearch = false
    @State private var selectedPostForComment: SocialPost?
    @State private var showCommentSheet = false
    @StateObject private var tipJarManager = TipJarManager.shared
    @State private var showTipAmountSheet = false
    @State private var selectedPostForTip: SocialPost?
    @State private var showInsufficientFundsAlert = false
    @State private var insufficientFundsMessage = ""
    @State private var showOriginalsExplorer = false
    
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
        // Fallback to sample user
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
        guard !selectedInterests.isEmpty else {
            return base.sorted { $0.createdAt > $1.createdAt }
        }
        return base
            .map { post in (post, matchScore(for: post)) }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 { return lhs.0.createdAt > rhs.0.createdAt }
                return lhs.1 > rhs.1
            }
            .map { $0.0 }
    }

    private func matchScore(for post: SocialPost) -> Int {
        // Map interests to simple keyword set for matching
        let lowerContent = (post.content + " " + (post.tags.joined(separator: " "))).lowercased()
        var score = 0
        for interest in selectedInterests {
            switch interest {
            // Spirits
            case .whiskey: if lowerContent.contains("whiskey") || lowerContent.contains("whisky") { score += 2 }
            case .bourbon: if lowerContent.contains("bourbon") { score += 2 }
            case .scotch: if lowerContent.contains("scotch") { score += 2 }
            case .gin: if lowerContent.contains("gin") { score += 2 }
            case .tequila: if lowerContent.contains("tequila") { score += 2 }
            case .rum: if lowerContent.contains("rum") { score += 2 }
            case .vodka: if lowerContent.contains("vodka") { score += 2 }
            // Cocktails
            case .negroni: if lowerContent.contains("negroni") { score += 3 }
            case .martini: if lowerContent.contains("martini") { score += 3 }
            case .oldFashioned: if lowerContent.contains("old fashioned") || lowerContent.contains("oldfashioned") { score += 3 }
            case .spritz: if lowerContent.contains("spritz") || lowerContent.contains("spritzer") || lowerContent.contains("detroit sour") { score += 1 }
            case .margarita: if lowerContent.contains("margarita") { score += 3 }
            case .manhattan: if lowerContent.contains("manhattan") { score += 3 }
            // Wine & Beer & NA
            case .redWine: if lowerContent.contains("red wine") || lowerContent.contains("wine") { score += 1 }
            case .whiteWine: if lowerContent.contains("white wine") || lowerContent.contains("wine") { score += 1 }
            case .sparkling: if lowerContent.contains("sparkling") || lowerContent.contains("champagne") { score += 1 }
            case .ipa: if lowerContent.contains("ipa") { score += 1 }
            case .lager: if lowerContent.contains("lager") { score += 1 }
            case .stout: if lowerContent.contains("stout") { score += 1 }
            case .mocktails: if lowerContent.contains("mocktail") || lowerContent.contains("non-alcoholic") { score += 1 }
            }
        }
        // Light boost based on post type alignment
        switch post.postType {
        case .cocktail: score += selectedInterests.contains(where: { [.negroni, .martini, .oldFashioned, .spritz, .margarita, .manhattan].contains($0) }) ? 1 : 0
        case .event, .venue, .experience, .training, .tip: break
        }
        return score
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
                // New TopNavigationBar with raised background and shadow
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
                        
                        // Top hero + Originals remain when in All view
                        if selectedUserType == nil {
                            HeroHorizontalScroller()
                            VStack(spacing: 12) {
                                HStack {
                                    SectionHeader(
                                        title: "SipSync Originals",
                                        showChevron: true,
                                        onChevronTap: {
                                            showBartenderClasses = true
                                        }
                                    )
                                    
                                    // Bypass Button
                                    Button(action: {
                                        showOriginalsExplorer = true
                                    }) {
                                        Text("Bypass")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.yellow)
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 20)
                                BartenderOriginalsCarousel(
                                    profiles: sampleData.sampleBartenderProfiles,
                                    selectedProfile: $selectedBartenderProfile,
                                    showDetailSheet: $showBartenderDetail,
                                    onMixologyClassTap: {
                                        showBartenderClasses = true
                                    }
                                )
                            }
                        }
                        
                        // Discovery prompt when viewing All
                        if selectedUserType == nil {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "Personalize your feed", showChevron: false)
                    HStack {
                                    Text(selectedInterests.isEmpty ? "Tell us your drink interests" : selectedInterests.map { $0.rawValue }.prefix(3).joined(separator: ", ") + (selectedInterests.count > 3 ? "…" : ""))
                                        .foregroundColor(.gray)
                        Spacer()
                                    Button(action: { showDiscovery = true }) {
                                        Text(selectedInterests.isEmpty ? "Get started" : "Edit")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.yellow)
                                            .cornerRadius(16)
                                    }
                            }
                        }
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
        .background(
            NavigationLink(
                destination: Group {
                    if let drink = selectedDrink {
                        DrinkDetailView(drink: drink, cartItems: $cartItems, favoriteDrinks: $favoriteDrinks)
                    }
                },
                isActive: $showDrinkDetail,
                label: { EmptyView() }
            )
            .hidden()
        )
        .sheet(isPresented: $showDiscovery) {
            PersonalizeFeedView(selectedInterests: $selectedInterests) {
                showDiscovery = false
            }
        }
        .sheet(isPresented: $showBartenderDetail) {
            if let profile = selectedBartenderProfile {
                BartenderDetailSheet(
                    profile: Binding(
                        get: { profile },
                        set: { newValue in
                            selectedBartenderProfile = newValue
                        }
                    ),
                    isPresented: $showBartenderDetail
                )
            }
        }
        .sheet(isPresented: $showBartenderClasses) {
            BartenderClassesView(cartItems: $cartItems)
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
        .sheet(isPresented: $showOriginalsExplorer) {
            SipSyncOriginalsExplorerView(cartItems: $cartItems)
        }
        .onAppear {
            // Initialize posts if empty
            if socialPosts.isEmpty {
                socialPosts = sampleData.sampleSocialPosts
            }
            // Initialize user if needed
            if userManager.currentUser == nil {
                userManager.currentUser = sampleData.sampleUser
            }
        }
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
}

#Preview {
    HomeView(
        selectedCategory: .constant(.drinks),
        cartItems: .constant([]),
        favoriteDrinks: .constant([]),
        selectedUserType: .constant(nil),
        socialPosts: .constant([])
    )
}
