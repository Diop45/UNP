//
//  Components.swift
//  SIP SYNC
//
//  Consolidated reusable UI components
//

import SwiftUI

// MARK: - Reusable Header (Airbnb-style)
struct SSHeader: View {
    @EnvironmentObject var theme: AppTheme
    let logoText: String
    let location: String
    var onMenu: (() -> Void)?
    var onNotifications: (() -> Void)?
    var onProfile: (() -> Void)?
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text(logoText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.accent)
                    .frame(width: 30, height: 30)
                    .background(theme.accent.opacity(0.2))
                    .clipShape(Circle())
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .foregroundColor(theme.accent)
                    Text(location)
                        .foregroundColor(theme.textPrimary)
                        .lineLimit(1)
                }
            }
            Spacer()
            HStack(spacing: 16) {
                Button(action: { onMenu?() }) {
                    Image(systemName: "line.3.horizontal").foregroundColor(theme.textPrimary)
                }
                Button(action: { onNotifications?() }) {
                    Image(systemName: "bell").foregroundColor(theme.textPrimary)
                }
                Button(action: { onProfile?() }) {
                    Circle()
                        .fill(theme.textSecondary)
                        .frame(width: 32, height: 32)
                        .overlay(Image(systemName: "person").foregroundColor(theme.textPrimary))
                }
            }
        }
    }
}

// MARK: - Search Bar (theme-aware)
struct SSSearchBar: View {
    @EnvironmentObject var theme: AppTheme
    @Binding var text: String
    var placeholder: String = "Search..."
    var onSubmit: (() -> Void)?
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(theme.textSecondary)
            TextField(placeholder, text: $text)
                .foregroundColor(theme.textPrimary)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(theme.textSecondary)
                }
            }
        }
        .padding()
        .background(theme.inputBackground)
        .cornerRadius(12)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    @EnvironmentObject var theme: AppTheme
    let title: String
    var subtitle: String? = nil
    var showChevron: Bool = true
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil
    var onChevronTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
            }
            Spacer(minLength: 12)
            if let actionTitle = actionTitle, let onAction = onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .foregroundColor(theme.accent)
                }
            } else if showChevron {
                Button(action: { onChevronTap?() }) {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Pill
struct Pill: View {
    @EnvironmentObject var theme: AppTheme
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : theme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? theme.accent : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? theme.accent : theme.borderColor, lineWidth: 1)
                )
        }
    }
}

// MARK: - Social Post Components
struct SocialPostCard: View {
    @EnvironmentObject var theme: AppTheme
    let post: SocialPost
    @Binding var cartItems: [OrderItem]
    let onLike: () -> Void
    let onAddToCart: () -> Void
    let onComment: () -> Void
    let onRepost: () -> Void
    let onTip: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Repost indicator (if this is a repost)
            if let reposter = post.repostedBy {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.2.squarepath")
                        .foregroundColor(theme.textSecondary)
                        .font(.caption)
                    Text("\(reposter.username) reposted")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            
            // Author info
            HStack(spacing: 12) {
                Circle()
                    .fill(theme.textSecondary)
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "person").foregroundColor(theme.textPrimary))
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.author.username)
                            .font(.headline)
                            .foregroundColor(theme.textPrimary)
                        if post.author.verified {
                            Image(systemName: "checkmark.seal.fill").foregroundColor(theme.accent).font(.caption)
                        }
                    }
                    HStack(spacing: 4) {
                        if let location = post.author.location {
                            Text(location).font(.caption).foregroundColor(theme.textSecondary)
                        }
                        Text("•").font(.caption).foregroundColor(theme.textSecondary)
                        Text(timeAgoString(from: post.createdAt)).font(.caption).foregroundColor(theme.textSecondary)
                    }
                }
                Spacer()
                Button(action: {}) { Image(systemName: "ellipsis").foregroundColor(theme.textSecondary) }
            }
            
            // Post content
            Text(post.content).font(.body).foregroundColor(theme.textPrimary)
            
            // Tags
            if !post.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(theme.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(theme.accent.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            
            // Post image (if available)
            if let imageName = post.image {
                ZStack(alignment: .topTrailing) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    .padding(10)
                    .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 2)
                }
            }
            
            // Action buttons
            HStack(spacing: 20) {
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart").foregroundColor(post.isLiked ? .red : .gray)
                        Text("\(post.likes)").font(.caption).foregroundColor(.gray)
                    }
                }
                Button(action: onComment) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left").foregroundColor(.gray)
                        Text("\(post.comments)").font(.caption).foregroundColor(.gray)
                    }
                }
                // Sync icon - repost functionality (like Twitter)
                Button(action: onRepost) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isSynced ? "arrow.2.squarepath" : "arrow.2.squarepath")
                            .foregroundColor(post.isSynced ? .green : .gray)
                        Text("\(post.syncs)").font(.caption).foregroundColor(post.isSynced ? .green : .gray)
                    }
                }
                // Cart icon - adds item to cart
                Button(action: onAddToCart) {
                    HStack(spacing: 4) {
                        Image(systemName: "cart.badge.plus").foregroundColor(theme.accent)
                        Text("Add").font(.caption).foregroundColor(theme.accent)
                    }
                }
                Spacer()
                Button(action: onTip) {
                    Text("Tip")
                        .font(.caption)
                        .foregroundColor(theme.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.accent, lineWidth: 1))
                }
            }
        }
        .padding(16)
        .background(theme.cardBackground)
        .cornerRadius(16)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        return hours > 0 ? "\(hours)h" : "\(minutes)m"
    }
}

// MARK: - User Type Filter (chip style)
struct UserTypeFilter: View {
    @EnvironmentObject var theme: AppTheme
    @Binding var selectedType: UserType?
    let types: [UserType]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: { selectedType = nil }) {
                    Text("All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedType == nil ? .white : theme.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(selectedType == nil ? theme.accent : Color.clear)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(selectedType == nil ? theme.accent : theme.borderColor, lineWidth: 1))
                }
                ForEach(types, id: \.self) { type in
                    Button(action: { selectedType = type }) {
                        Text(type.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedType == type ? .white : theme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedType == type ? theme.accent : Color.clear)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(selectedType == type ? theme.accent : theme.borderColor, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Selectable Tag (for discovery)
struct SelectableTag: View {
    let title: String
    let systemIcon: String?
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = systemIcon {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16))
                }
                Text(title)
                    .foregroundColor(.black)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(isSelected ? color : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1))
            .cornerRadius(20)
        }
    }
}

// MARK: - Airbnb-style Search Pill
struct SearchPillField: View {
    @EnvironmentObject var theme: AppTheme
    @Binding var text: String
    var placeholder: String = "Start your search"
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(theme.textSecondary)
                Text(text.isEmpty ? placeholder : text)
                    .foregroundColor(text.isEmpty ? theme.textSecondary : theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(theme.inputBackground)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(theme.borderColor, lineWidth: 1)
        )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Top Category Icon Tabs (All / Consumers / Bartenders / Venues)
struct CategoryIconTabBar: View {
    @Binding var selectedType: UserType?
    
    struct Tab: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let icon: String
        let type: UserType?
    }
    
    private var tabs: [Tab] {
        [
            Tab(title: "All", icon: "globe", type: nil),
            Tab(title: "Consumers", icon: "person", type: .consumer),
            Tab(title: "Bartenders", icon: "hands.sparkles", type: .bartender),
            Tab(title: "Venues", icon: "building.2", type: .venue)
        ]
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 28) {
                ForEach(tabs) { tab in
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                            .foregroundColor(selectedType == tab.type ? .black : .gray)
                        Text(tab.title)
                            .font(.footnote)
                            .foregroundColor(selectedType == tab.type ? .black : .gray)
                        Rectangle()
                            .fill(selectedType == tab.type ? Color.black : Color.clear)
                            .frame(height: 2)
                            .cornerRadius(1)
                    }
                    .onTapGesture { selectedType = tab.type }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Hero Reminder Card
struct HeroReminderCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Sync up with friends")
                    .font(.headline)
                    .foregroundColor(.black)
                Text("This week  •  Detroit")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .frame(width: 72, height: 72)
                VStack(spacing: 2) {
                    Text("STARTS IN").font(.caption2).foregroundColor(.gray)
                    Text("7").font(.system(size: 28, weight: .bold)).foregroundColor(.black)
                    Text("DAYS").font(.caption2).foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .frame(width: 300)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 8)
    }
}

// MARK: - Ad Countdown Card
struct AdCountdownCard: View {
    @State private var remaining: Int = 30
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Sponsored")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Limited-time offer")
                    .font(.headline)
                    .foregroundColor(.black)
                Text("Ad refresh in \(remaining)s")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "megaphone")
                .foregroundColor(.black)
                .frame(width: 48, height: 48)
                .background(Color.yellow.opacity(0.6))
                .clipShape(Circle())
        }
        .padding(16)
        .frame(width: 300)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 8)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            remaining = max(0, remaining - 1)
            if remaining == 0 { remaining = 30 }
        }
    }
}

// MARK: - Horizontal Hero Scroller
struct HeroHorizontalScroller: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                HeroReminderCard()
                AdCountdownCard()
                HeroReminderCard()
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Liquid Glass Search Bar
struct LiquidGlassSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search Maps"
    var onProfileTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            // Search Icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            // Text Field
            TextField(placeholder, text: $text)
                .font(.body)
                .foregroundColor(.black)
            
            Spacer(minLength: 8)
            
            // Microphone Icon
            Button(action: {}) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // Profile Picture (blended with liquid glass effect)
            Button(action: { onProfileTap?() }) {
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
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                    )
                    .overlay(
                        // Subtle white border that blends with liquid glass
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            // Liquid Glass Effect
            ZStack {
                // Ultra thin material blur
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                
                // Subtle white overlay for extra glow
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white.opacity(0.3), location: 0.0),
                                .init(color: Color.white.opacity(0.1), location: 0.5),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .overlay(
            // Subtle border
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 8)
        .shadow(color: Color.white.opacity(0.1), radius: 2, x: 0, y: -1)
    }
}

// MARK: - Top Navigation Bar (Airbnb-style)
struct TopNavigationBar: View {
    @EnvironmentObject var theme: AppTheme
    @Binding var selectedCategory: UserType?
    
    private let categories = [
        (UserType.consumer, "Consumers", "person.2.fill"),
        (UserType.bartender, "Bartenders", "wineglass.fill"),
        (UserType.venue, "Venues", "building.2.fill")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with logo and actions
            HStack {
                // Brand lockup (SipSyncLogo asset — UN ribbon + glass + wordmark)
                Image("SipSyncLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 160, maxHeight: 40)
                    .accessibilityLabel("Until The Next Pour")
                
                Spacer()
                
                // Right actions
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(theme.accent)
                    }
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(theme.accent)
                    }
                    Button(action: {}) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(theme.accent)
                    }
                    Button(action: {}) {
                        Circle()
                            .fill(theme.accent.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person")
                                    .foregroundColor(theme.accent)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 16)
            
            // Category tabs
            HStack(spacing: 0) {
                ForEach(categories, id: \.0) { category, title, icon in
                    Button(action: {
                        selectedCategory = selectedCategory == category ? nil : category
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: icon)
                                .font(.system(size: 18))
                                .foregroundColor(theme.accent)
                            
                            Text(title)
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(selectedCategory == category ? theme.textPrimary : theme.textSecondary)
                            
                            Rectangle()
                                .fill(selectedCategory == category ? theme.accent : .clear)
                                .frame(height: 2)
                                .cornerRadius(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(theme.cardBackground)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - SipSync Originals Bartender Carousel
struct BartenderOriginalsCarousel: View {
    let profiles: [BartenderProfile]
    @Binding var selectedProfile: BartenderProfile?
    @Binding var showDetailSheet: Bool
    var onMixologyClassTap: (() -> Void)? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Mixology Class Card (first item)
                MixologyClassCard(onTap: {
                    onMixologyClassTap?()
                })
                
                // Bartender Profile Cards
                ForEach(profiles) { profile in
                    BartenderPreviewCard(
                        profile: profile,
                        onTap: {
                            selectedProfile = profile
                            showDetailSheet = true
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Mixology Class Card
struct MixologyClassCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    // Mixology Class Image
                    Image("Mixology Class")
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 220, height: 180)
                        .clipped()
                        .cornerRadius(20)
                    
                    // Gradient overlay for better text readability
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.0),
                            Color.black.opacity(0.4)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .cornerRadius(20)
                    
                    // "Class" Badge
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Class")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(8)
                    
                    // Title overlay at bottom
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        Text("Mixology Class")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                }
                
                // Subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text("Learn from Experts")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .lineLimit(1)
                    Text("Master cocktail techniques")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                        .lineLimit(1)
                }
            }
            .frame(width: 220)
        }
    }
}

// MARK: - Bartender Preview Card (HomeView)
struct BartenderPreviewCard: View {
    let profile: BartenderProfile
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    // Profile Image
                    Image(profile.profileImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 220, height: 180)
                        .clipped()
                        .cornerRadius(20)
                    
                    // "Original" Badge
                    Text("Original")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(8)
                }
                
                // Name and Handle
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.author.name)
                        .foregroundColor(.white)
                        .font(.headline)
                        .lineLimit(1)
                    Text("@\(profile.author.username)")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                        .lineLimit(1)
                }
            }
            .frame(width: 220)
        }
    }
}

// MARK: - Instagram-style Stories Components

// MARK: - Stories Bar (Horizontal Scroll)
struct StoriesBar: View {
    let storySets: [StorySet]
    @Binding var selectedStorySet: StorySet?
    @Binding var selectedStoryIndex: Int
    var onAddStory: (() -> Void)? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Add Story Button (first item)
                if let onAddStory = onAddStory {
                    AddStoryBubble(onTap: onAddStory)
                }
                
                // Existing story sets
                ForEach(storySets.filter { !$0.activeStories.isEmpty }) { storySet in
                    StoryBubble(
                        storySet: storySet,
                        onTap: {
                            selectedStorySet = storySet
                            selectedStoryIndex = 0
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.1),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Add Story Bubble
struct AddStoryBubble: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    // Outer ring (dashed for "add")
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 2.5, dash: [5, 5])
                        )
                        .frame(width: 70, height: 70)
                    
                    // Add icon circle
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow.opacity(0.3),
                                    Color.orange.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                        )
                        .clipShape(Circle())
                }
                
                Text("Your Story")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Story Bubble (Individual Story Avatar)
struct StoryBubble: View {
    let storySet: StorySet
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    // Outer ring (colored if has unviewed stories)
                    Circle()
                        .stroke(
                            storySet.hasUnviewedStories
                                ? LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: 2.5
                        )
                        .frame(width: 70, height: 70)
                    
                    // Profile image placeholder
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow.opacity(0.3),
                                    Color.orange.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: storySet.author.userType == .bartender ? "wineglass.fill" : storySet.author.userType == .venue ? "building.2.fill" : "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        )
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                }
                
                // Username
                Text(storySet.author.username)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(width: 70)
            }
        }
    }
}

// MARK: - Story Viewer (Full-Screen Instagram-style)
struct StoryViewer: View {
    let storySet: StorySet
    @Binding var currentStoryIndex: Int
    @Binding var isPresented: Bool
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    @State private var isPaused: Bool = false
    @State private var dragOffset: CGSize = .zero
    
    private let storyDuration: TimeInterval = 5.0 // 5 seconds per story (Instagram standard)
    
    private var currentStory: Story? {
        let activeStories = storySet.activeStories
        guard currentStoryIndex < activeStories.count else { return nil }
        return activeStories[currentStoryIndex]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Story Content - fills entire screen
                if let story = currentStory {
                    ZStack {
                        // Story Image - fills entire screen including safe areas
                        if let imageName = story.image {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .ignoresSafeArea(.all)
                        } else {
                            Color.gray.opacity(0.3)
                                .ignoresSafeArea(.all)
                        }
                        
                        // Story Text Overlay
                        if let text = story.text {
                            VStack {
                                Spacer()
                                Text(text)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(story.textColor == "white" ? .white : .black)
                                    .padding()
                                    .background(
                                        story.textColor == "white" 
                                            ? Color.black.opacity(0.3)
                                            : Color.white.opacity(0.3)
                                    )
                                    .cornerRadius(12)
                                    .padding(.bottom, 100)
                            }
                        }
                    }
                    .offset(dragOffset)
                    
                    // Top Progress Bars - absolutely positioned at top
                    VStack(spacing: 0) {
                        // Progress bars at absolute top
                        HStack(spacing: 4) {
                            ForEach(0..<storySet.activeStories.count, id: \.self) { index in
                                GeometryReader { barGeometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.purple.opacity(0.3))
                                            .frame(height: 3)
                                        
                                        if index == currentStoryIndex {
                                            Rectangle()
                                                .fill(Color.purple)
                                                .frame(width: barGeometry.size.width * progress, height: 3)
                                        } else if index < currentStoryIndex {
                                            Rectangle()
                                                .fill(Color.purple)
                                                .frame(width: barGeometry.size.width, height: 3)
                                        }
                                    }
                                }
                                .frame(height: 3)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, geometry.safeAreaInsets.top + 8)
                        
                        // Header with User Info (below progress bars)
                        HStack {
                            // User Profile
                            HStack(spacing: 8) {
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
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: storySet.author.userType == .bartender ? "wineglass.fill" : storySet.author.userType == .venue ? "building.2.fill" : "person.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text(storySet.author.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.purple)
                                        
                                        if storySet.author.verified {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(.blue)
                                                .font(.caption)
                                        }
                                    }
                                    
                                    if let timeAgo = timeAgoString(from: story.createdAt) {
                                        Text(timeAgo)
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Close Button
                            Button(action: {
                                pauseTimer()
                                isPresented = false
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .padding(8)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea(.all, edges: .top)
                    
                    // Bottom Actions
                    VStack {
                        Spacer()
                        HStack(spacing: 20) {
                            // Like Button
                            Button(action: {}) {
                                Image(systemName: "heart")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(12)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                            
                            // Reply Button
                            Button(action: {}) {
                                Image(systemName: "message")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(12)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                            
                            // Share Button
                            Button(action: {}) {
                                Image(systemName: "paperplane")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(12)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            // More Button
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(12)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    
                    // Tap Areas for Navigation (Left/Right)
                    HStack(spacing: 0) {
                        // Left tap area (previous)
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: geometry.size.width * 0.33)
                            .onTapGesture {
                                previousStory()
                            }
                        
                        // Center (pause/play)
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: geometry.size.width * 0.34)
                            .onTapGesture {
                                togglePause()
                            }
                        
                        // Right tap area (next)
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: geometry.size.width * 0.33)
                            .onTapGesture {
                                nextStory()
                            }
                    }
                    .frame(height: geometry.size.height)
                    
                    // Swipe Down to Dismiss
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height > 0 {
                                    dragOffset = value.translation
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 150 {
                                    pauseTimer()
                                    isPresented = false
                                } else {
                                    withAnimation {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            pauseTimer()
        }
        .onChange(of: currentStoryIndex) { _ in
            resetProgress()
            startTimer()
        }
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        pauseTimer()
        isPaused = false
        progress = 0.0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if !isPaused {
                progress += 0.1 / storyDuration
                if progress >= 1.0 {
                    nextStory()
                }
            }
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func resetProgress() {
        progress = 0.0
    }
    
    // MARK: - Navigation
    private func nextStory() {
        let activeStories = storySet.activeStories
        if currentStoryIndex < activeStories.count - 1 {
            currentStoryIndex += 1
        } else {
            // Move to next story set or close
            isPresented = false
        }
    }
    
    private func previousStory() {
        if currentStoryIndex > 0 {
            currentStoryIndex -= 1
        }
    }
    
    // MARK: - Helper
    private func timeAgoString(from date: Date) -> String? {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Bartender Detail Sheet (Quick Sheet)
struct BartenderDetailSheet: View {
    @Binding var profile: BartenderProfile
    @Binding var isPresented: Bool
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image (blurred)
                Image(profile.profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(
                        Color.black.opacity(0.4)
                    )
                    .blur(radius: 20)
                    .ignoresSafeArea()
                
                // Navigation Bar (Fixed at top)
                VStack {
                    HStack {
                        // Back Button
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Profile Handle
                        Text("@\(profile.author.username)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Action Button
                        Button(action: {}) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, geometry.safeAreaInsets.top + 8)
                    
                    Spacer()
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Top spacer to account for navigation bar
                        Color.clear
                            .frame(height: geometry.safeAreaInsets.top + 60)
                        
                        // Profile Header Card
                        VStack(alignment: .leading, spacing: 12) {
                            // Name and Handle
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(profile.author.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    if profile.author.verified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.blue)
                                            .font(.title3)
                                    }
                                }
                                
                                Text("@\(profile.author.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            // Bio/Quote
                            Text(profile.bio)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineSpacing(3)
                            
                            // Statistics
                            HStack(spacing: 20) {
                                StatItem(count: profile.followers, label: "Followers")
                                StatItem(count: profile.following, label: "Following")
                                StatItem(count: profile.comments, label: "Comments")
                            }
                            .padding(.vertical, 4)
                            
                            // Follow Button
                            Button(action: {
                                profile.isFollowed.toggle()
                            }) {
                                Text(profile.isFollowed ? "Following" : "Follow")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(profile.isFollowed ? .white : .black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(profile.isFollowed ? Color.gray.opacity(0.3) : Color.white)
                                    .cornerRadius(24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(profile.isFollowed ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1)
                                    )
                            }
                            
                            // "See Profile" Button
                            Button(action: {
                                // Navigate to full profile
                            }) {
                                HStack {
                                    Text("See profile")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Image(systemName: "arrow.right")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(20)
                            }
                        }
                    .padding(16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.7),
                                Color.black.opacity(0.5),
                                Color.black.opacity(0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(20)
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                    
                        // Content Categories (Hashtags)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.top, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(profile.contentCategories, id: \.self) { category in
                                        Text(category)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                        }
                        
                        // Content Gallery
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gallery")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.top, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(profile.contentGallery) { item in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Image(item.image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 150, height: 150)
                                                .clipped()
                                                .cornerRadius(12)
                                            
                                            if let title = item.title {
                                                Text(title)
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .lineLimit(1)
                                                    .frame(width: 150, alignment: .leading)
                                            }
                                        }
                                        .frame(width: 150)
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                        }
                        
                        // Comment Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Comments")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.top, 20)
                            
                            // Sample Comment
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.white.opacity(0.6))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Elena Juni @elena.juni")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Thanks for the great recipe recommendation for this greek salad. Had so much fun making it with my family. Greetings from USA!")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                        .lineSpacing(2)
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 12)
                            .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Stat Item Helper
struct StatItem: View {
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

#Preview("Shared components") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            SSHeader(
                logoText: "UNP",
                location: "Detroit",
                onMenu: {},
                onNotifications: {},
                onProfile: {}
            )
            SSSearchBar(text: .constant("Negroni"))
            TopNavigationBar(selectedCategory: .constant(.consumer))
            SocialPostCard(
                post: SampleData.shared.sampleSocialPosts[0],
                cartItems: .constant([]),
                onLike: {},
                onAddToCart: {},
                onComment: {},
                onRepost: {},
                onTip: {}
            )
            StatItem(count: 42, label: "Followers")
        }
        .padding()
    }
    .background(Color.black)
    .environmentObject(AppTheme.shared)
}

