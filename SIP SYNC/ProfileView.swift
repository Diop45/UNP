//
//  ProfileView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI
import PhotosUI

/// Section title on the Profile tab using UNP tokens (avoids `AppTheme` day/night mismatch with `SectionHeader`).
private struct UNPProfileSectionHeader: View {
    let title: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(UNPColors.cream)
            Spacer()
        }
    }
}

struct ProfileView: View {
    @Binding var favoriteDrinks: [Drink]
    @StateObject private var userManager = UserManager.shared
    @State private var user: User = SampleData.shared.sampleUser
    @State private var searchText = ""
    @State private var selectedUserType: UserType? = nil
    @State private var currentUserType: UserType = .consumer // This would come from user session
    @State private var showSettings = false
    @State private var showSearch = false
    @State private var showEditProfile = false
    @State private var showFavorites = false
    @State private var showOrderHistory = false
    @State private var showPaymentMethods = false
    @State private var showAddresses = false
    @State private var showNotifications = false
    @State private var showHelpSupport = false
    @State private var showAbout = false
    @State private var showLogoutAlert = false
    @State private var cartItems: [OrderItem] = []
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var isEditingName = false
    @State private var editingName = ""
    
    private var profileContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Modern Profile Header with Banner
                ModernProfileHeader(
                    user: user,
                    userType: currentUserType,
                    selectedPhoto: $selectedPhoto
                )
                
                // Profile Content Section
                ProfileContentSection(
                    user: $user,
                    userType: currentUserType,
                    interests: user.interests,
                    isEditingName: $isEditingName,
                    editingName: $editingName
                )
                .padding(.bottom, 24)
                
                // Profile stats
                profileStatsSection
                
                // Favorites section
                favoritesSection
                
                // Menu options - User type specific
                menuSection
            }
            .padding(.bottom, 100)
        }
    }
    
    private var profileStatsSection: some View {
        HStack(spacing: 40) {
            VStack {
                Text("12")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(UNPColors.cream)
                Text("Orders")
                    .font(.caption)
                    .foregroundColor(UNPColors.creamMuted())
            }
            
            VStack {
                Text("8")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(UNPColors.cream)
                Text("Reviews")
                    .font(.caption)
                    .foregroundColor(UNPColors.creamMuted())
            }
            
            VStack {
                Text("4.8")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(UNPColors.cream)
                Text("Rating")
                    .font(.caption)
                    .foregroundColor(UNPColors.creamMuted())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var favoritesSection: some View {
        Group {
            if !favoriteDrinks.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    UNPProfileSectionHeader(title: "My Favorites")
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(favoriteDrinks, id: \.name) { drink in
                                VStack(alignment: .leading, spacing: 8) {
                                    // Drink image
                                    Group {
                                        if let imageName = getImageName(for: drink.name) {
                                            Image(imageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(UNPColors.cardSurface)
                                                .overlay(
                                                    Image(systemName: getSystemIcon(for: drink.category))
                                                        .font(.title)
                                                        .foregroundColor(UNPColors.creamMuted())
                                                )
                                        }
                                    }
                                    .frame(width: 120, height: 80)
                                    .clipped()
                                    .cornerRadius(12)
                                    
                                    Text(drink.name)
                                        .font(.caption)
                                        .foregroundColor(UNPColors.cream)
                                        .lineLimit(2)
                                }
                                .frame(width: 120)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 20)
            }
        }
    }
    
    private var menuSection: some View {
        VStack(spacing: 0) {
            UNPProfileSectionHeader(title: "Menu")
            
            // Common menu items
            ProfileMenuRow(icon: "person", title: "Edit Profile", action: {
                showEditProfile = true
            })
            ProfileMenuRow(icon: "heart", title: "Favorites", action: {
                showFavorites = true
            })
            ProfileMenuRow(icon: "clock", title: "Order History", action: {
                showOrderHistory = true
            })
            
            NavigationLink {
                UNPProfileShellView()
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .foregroundColor(UNPColors.accent)
                        .font(.title2)
                        .frame(width: 24)
                    Text("Rewards & tiers")
                        .font(.headline)
                        .foregroundColor(UNPColors.cream)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(UNPColors.creamMuted())
                        .font(.caption)
                }
                .padding(.vertical, 16)
                .background(UNPColors.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
            }
            .padding(.bottom, 8)
            
            // User type specific items
            if currentUserType == .bartender {
                ProfileMenuRow(icon: "chart.bar.fill", title: "Dashboard", action: {
                    // Navigate to bartender dashboard
                })
                ProfileMenuRow(icon: "calendar", title: "My Classes", action: {})
            } else if currentUserType == .venue {
                ProfileMenuRow(icon: "chart.bar.fill", title: "Dashboard", action: {
                    // Navigate to venue dashboard
                })
                ProfileMenuRow(icon: "calendar", title: "My Events", action: {})
            }
            
            // Common items - consolidated into Settings
            ProfileMenuRow(icon: "creditcard", title: "Payment Methods", action: {
                showPaymentMethods = true
            })
            ProfileMenuRow(icon: "location", title: "Addresses", action: {
                showAddresses = true
            })
            ProfileMenuRow(icon: "bell", title: "Notifications", action: {
                showNotifications = true
            })
            ProfileMenuRow(icon: "gear", title: "Settings", action: {
                showSettings = true
            })
            ProfileMenuRow(icon: "questionmark.circle", title: "Help & Support", action: {
                showHelpSupport = true
            })
            ProfileMenuRow(icon: "info.circle", title: "About", action: {
                showAbout = true
            })
            ProfileMenuRow(icon: "rectangle.portrait.and.arrow.right", title: "Logout", action: {
                showLogoutAlert = true
            }, isDestructive: true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    var body: some View {
        ZStack {
            UNPColors.background.ignoresSafeArea()
            
            profileContent
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(user: $user)
        }
        .sheet(isPresented: $showFavorites) {
            FavoritesSheet(favoriteDrinks: $favoriteDrinks)
        }
        .sheet(isPresented: $showOrderHistory) {
            OrderHistorySheet()
        }
        .sheet(isPresented: $showPaymentMethods) {
            PaymentMethodsSheet()
        }
        .sheet(isPresented: $showAddresses) {
            AddressesSheet()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsSettingsSheet()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showHelpSupport) {
            HelpSupportSheet()
        }
        .sheet(isPresented: $showAbout) {
            AboutSheet()
        }
        .sheet(isPresented: $showSearch) {
            UnifiedSearchView(
                searchText: $searchText,
                isPresented: $showSearch,
                cartItems: $cartItems,
                favoriteDrinks: $favoriteDrinks
            )
            .environmentObject(UNPDataStore.shared)
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                // Handle logout - in a real app, clear user session and navigate to splash
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .onChange(of: selectedPhoto) { oldValue, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let _ = UIImage(data: data) {
                    // In a real app, upload image and get URL
                    user.profileImage = "user_\(UUID().uuidString)"
                }
            }
        }
        .onChange(of: isEditingName) { oldValue, newValue in
            if newValue {
                editingName = user.name
            } else {
                if !editingName.isEmpty && editingName != user.name {
                    user.name = editingName
                    UserManager.shared.updateUser(user)
                }
            }
        }
        .onAppear {
            // Sync user from UserManager
            if let currentUser = userManager.currentUser {
                user = currentUser
            } else {
                // Fallback to sample user if no user in manager
                user = SampleData.shared.sampleUser
            }
        }
        .onChange(of: userManager.currentUser?.name) { oldValue, newValue in
            if let currentUser = userManager.currentUser {
                user = currentUser
            }
        }
    }
    
    private func getImageName(for drinkName: String) -> String? {
        switch drinkName {
        case "Negroni":
            return "Negroni"
        case "Scotch & Bourbon":
            return "Scotch"
        case "Spritzer":
            return "Spritzer"
        case "Martini":
            return "Dirty Martini"
        case "Red Wine":
            return "Red Wine"
        case "White Wine":
            return "White Wine"
        default:
            return nil
        }
    }
    
    private func getSystemIcon(for category: DrinkCategory) -> String {
        switch category {
        case .drinks:
            return "wineglass"
        case .food:
            return "fork.knife"
        case .social:
            return "person.2"
        }
    }
    
    private func iconForPrimaryInterest(_ interests: Set<DrinkInterest>) -> String {
        // Prioritize cocktail interests
        if interests.contains(.negroni) || interests.contains(.martini) || interests.contains(.oldFashioned) {
            return "wineglass.fill"
        }
        // Then spirits
        if interests.contains(.whiskey) || interests.contains(.bourbon) || interests.contains(.scotch) {
            return "drop.fill"
        }
        // Default to wineglass
        return "wineglass.fill"
    }
}

// MARK: - Modern Profile Components (from ModernProfileView.swift)

// MARK: - Modern Profile Header
struct ModernProfileHeader: View {
    let user: User
    let userType: UserType
    @Binding var selectedPhoto: PhotosPickerItem?
    
    private func iconForPrimaryInterest(_ interests: Set<DrinkInterest>) -> String {
        // Prioritize cocktail interests
        if interests.contains(.negroni) || interests.contains(.martini) || interests.contains(.oldFashioned) {
            return "wineglass.fill"
        }
        // Then spirits
        if interests.contains(.whiskey) || interests.contains(.bourbon) || interests.contains(.scotch) {
            return "drop.fill"
        }
        // Default to wineglass
        return "wineglass.fill"
    }
    
    private func interestsBasedColors(for interests: Set<DrinkInterest>, userType: UserType) -> [Color] {
        let a = UNPColors.accent
        let c = UNPColors.cardSurface
        if userType == .bartender {
            return [a.opacity(0.7), a.opacity(0.45), c]
        }
        if interests.contains(.negroni) || interests.contains(.martini) {
            return [a.opacity(0.65), a.opacity(0.4), c]
        }
        if interests.contains(.whiskey) || interests.contains(.bourbon) || interests.contains(.scotch) {
            return [a.opacity(0.55), c, UNPColors.background]
        }
        if interests.contains(.gin) {
            return [c, a.opacity(0.35), UNPColors.creamMuted(0.22)]
        }
        return [a.opacity(0.6), c, a.opacity(0.3)]
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Header Banner
            Group {
                if let headerImage = user.headerImage {
                    Image(headerImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    // Geometric colorful banner (default)
                    GeometricBannerView()
                }
            }
            .frame(height: 200)
            .clipped()
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        UNPColors.background.opacity(0.45)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Navigation buttons
            HStack {
                Button(action: {}) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(UNPColors.cream)
                        .font(.title3)
                        .padding(8)
                        .background(UNPColors.cardSurface.opacity(0.95))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(UNPColors.cream)
                        .font(.title3)
                        .padding(8)
                        .background(UNPColors.cardSurface.opacity(0.95))
                        .clipShape(Circle())
                }
            }
            .padding()
            
            // Profile Picture (overlapping banner) - Editable
            VStack {
                Spacer()
                
                // Profile Picture - User Photo - Tappable to edit
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ZStack {
                        Group {
                            if let profileImage = user.profileImage, !profileImage.isEmpty {
                                // Load actual user photo
                                Image(profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                // User photo placeholder - person icon with drink-themed background
                                ZStack {
                                    // Background gradient based on interests
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: interestsBasedColors(for: user.interests, userType: userType)),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Person icon (represents actual user photo)
                                    Image(systemName: "person.fill")
                                        .foregroundColor(UNPColors.cream.opacity(0.88))
                                        .font(.system(size: 50))
                                }
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(UNPColors.cream, lineWidth: 4)
                        )
                        
                        // Edit icon overlay
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(UNPColors.accent)
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(UNPColors.background)
                                        .font(.system(size: 14))
                                }
                                .offset(x: 8, y: -8)
                            }
                        }
                        .frame(width: 120, height: 120)
                    }
                    .shadow(color: UNPColors.background.opacity(0.5), radius: 8, x: 0, y: 4)
                }
                .offset(y: 60) // Half overlapping the banner
            }
        }
        .frame(height: 260)
    }
}

// MARK: - Geometric Banner View
struct GeometricBannerView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    UNPColors.background,
                    UNPColors.cardSurface
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.2))
                    path.addLine(to: CGPoint(x: width * 0.6, y: 0))
                    path.addLine(to: CGPoint(x: width, y: height * 0.3))
                    path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.5))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            UNPColors.accent.opacity(0.45),
                            UNPColors.accent.opacity(0.18)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    path.move(to: CGPoint(x: width * 0.4, y: 0))
                    path.addLine(to: CGPoint(x: width, y: height * 0.4))
                    path.addLine(to: CGPoint(x: width * 0.8, y: height))
                    path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.6))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            UNPColors.creamMuted(0.18),
                            UNPColors.accent.opacity(0.28)
                        ]),
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
            }
        }
    }
}

// MARK: - Profile Content Section
struct ProfileContentSection: View {
    @Binding var user: User
    let userType: UserType
    let interests: Set<DrinkInterest>
    @Binding var isEditingName: Bool
    @Binding var editingName: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Name - Editable
            if isEditingName {
                HStack(spacing: 12) {
                    TextField("Enter name", text: $editingName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(UNPColors.cream)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(UNPColors.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous)
                                .stroke(UNPColors.accent, lineWidth: 2)
                        )
                    
                    Button(action: {
                        if !editingName.isEmpty {
                            user.name = editingName
                        }
                        isEditingName = false
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(UNPColors.accent)
                            .font(.title3)
                            .padding(8)
                            .background(UNPColors.accent.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        editingName = user.name
                        isEditingName = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(UNPColors.creamMuted())
                            .font(.title3)
                            .padding(8)
                            .background(UNPColors.cardSurface)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
            } else {
                Button(action: {
                    isEditingName = true
                    editingName = user.name
                }) {
                    HStack(spacing: 8) {
                        Text(user.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(UNPColors.cream)
                        
                        Image(systemName: "pencil")
                            .foregroundColor(UNPColors.accent)
                            .font(.caption)
                            .opacity(0.7)
                    }
                }
                .padding(.top, 60) // Space for overlapping profile picture
            }
            
            // Profession and Bio (based on interests)
            VStack(spacing: 8) {
                if let profession = user.profession {
                    Text(profession)
                        .font(.subheadline)
                        .foregroundColor(UNPColors.cream)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.caption)
                        .foregroundColor(UNPColors.creamMuted())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Show top interests as tags below bio
                if !interests.isEmpty {
                    let topInterests = Array(interests.prefix(3))
                    HStack(spacing: 8) {
                        ForEach(topInterests, id: \.self) { interest in
                            Text(interest.rawValue)
                                .font(.caption2)
                                .foregroundColor(UNPColors.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(UNPColors.accent.opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                    .padding(.top, 4)
                }
            }
            
            // Location and Languages
            HStack(spacing: 20) {
                // Location
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .foregroundColor(UNPColors.accent)
                        .font(.caption)
                    Text(user.location)
                        .font(.caption)
                        .foregroundColor(UNPColors.cream)
                }
                
                // Languages
                if !user.languages.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(UNPColors.accent)
                            .font(.caption)
                        Text(user.languages.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(UNPColors.cream)
                    }
                }
            }
            .padding(.top, 8)
            
            // Action Buttons
            HStack(spacing: 12) {
                // Message Button
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "message.fill")
                            .font(.caption)
                        Text("Message")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(UNPColors.cream)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(UNPColors.cardSurface)
                    .clipShape(Capsule(style: .continuous))
                }
                
                // Instagram Button
                if user.instagramHandle != nil {
                    Button(action: {}) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(UNPColors.cream)
                            .font(.caption)
                            .padding(10)
                            .background(UNPColors.cardSurface)
                            .clipShape(Circle())
                    }
                }
                
                // Twitter/X Button
                if user.twitterHandle != nil {
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .foregroundColor(UNPColors.cream)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(10)
                            .background(UNPColors.cardSurface)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.top, 16)
            
            // Interests Section
            if !interests.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("INTERESTS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(UNPColors.cream)
                        .tracking(1)
                        .padding(.horizontal, 20)
                    
                    // Interest Tags - Wrapping layout
                    WrappingHStack(items: Array(interests)) { interest in
                        InterestTag(interest: interest)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 24)
            }
        }
    }
}

// MARK: - Interest Tag
struct InterestTag: View {
    let interest: DrinkInterest
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconForInterest(interest))
                .font(.caption2)
                .foregroundColor(colorForInterest(interest))
            
            Text(interest.rawValue)
                .font(.caption)
                .foregroundColor(UNPColors.cream)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(UNPColors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
    }
    
    private func iconForInterest(_ interest: DrinkInterest) -> String {
        switch interest {
        case .whiskey, .bourbon, .scotch:
            return "drop.fill"
        case .gin, .tequila, .rum, .vodka:
            return "drop.fill"
        case .negroni, .martini, .oldFashioned, .spritz, .margarita, .manhattan:
            return "wineglass.fill"
        case .redWine, .whiteWine, .sparkling:
            return "wineglass.fill"
        case .ipa, .lager, .stout:
            return "drop.fill"
        case .mocktails:
            return "cup.and.saucer.fill"
        }
    }
    
    private func colorForInterest(_ interest: DrinkInterest) -> Color {
        switch interest {
        case .whiskey, .bourbon, .scotch:
            return .brown
        case .gin:
            return .green
        case .tequila:
            return .blue
        case .rum:
            return UNPColors.creamMuted()
        case .vodka:
            return UNPColors.cream
        case .negroni, .martini, .oldFashioned, .spritz, .margarita, .manhattan:
            return UNPColors.accent
        case .redWine:
            return .red
        case .whiteWine, .sparkling:
            return UNPColors.accent
        case .ipa:
            return UNPColors.creamMuted()
        case .lager:
            return UNPColors.accent
        case .stout:
            return .brown
        case .mocktails:
            return .green
        }
    }
}

// MARK: - Wrapping HStack (for wrapping tags)
struct WrappingHStack<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content
    let spacing: CGFloat = 8
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(createRows(), id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func createRows() -> [[Item]] {
        var rows: [[Item]] = []
        var currentRow: [Item] = []
        var currentWidth: CGFloat = 0
        let screenWidth = UIScreen.main.bounds.width - 40 // Account for padding
        
        for item in items {
            // Approximate width of each tag (will be measured dynamically in real implementation)
            let estimatedWidth: CGFloat = 100
            
            if currentWidth + estimatedWidth > screenWidth && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [item]
                currentWidth = estimatedWidth
            } else {
                currentRow.append(item)
                currentWidth += estimatedWidth + spacing
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : UNPColors.accent)
                    .font(.title2)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isDestructive ? .red : UNPColors.cream)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(UNPColors.creamMuted())
                    .font(.caption)
            }
            .padding(.vertical, 16)
            .background(UNPColors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Tip Amount Sheet
struct TipAmountSheet: View {
    @Environment(\.dismiss) private var dismiss
    let post: SocialPost
    let onTipSent: (Double) -> Void
    
    @State private var selectedAmount: Double? = nil
    @State private var customAmount: String = ""
    
    private let quickAmounts: [Double] = [5, 10, 25, 50]
    
    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Bartender Info
                    VStack(spacing: 12) {
                        Text("Tip \(post.author.name)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(UNPColors.cream)
                        
                        Text("Show appreciation for this great drink!")
                            .font(.subheadline)
                            .foregroundColor(UNPColors.creamMuted())
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Quick Amount Buttons
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Tip")
                            .font(.headline)
                            .foregroundColor(UNPColors.cream)
                        
                        HStack(spacing: 12) {
                            ForEach(quickAmounts, id: \.self) { amount in
                                Button(action: {
                                    selectedAmount = amount
                                    customAmount = ""
                                }) {
                                    Text("$\(Int(amount))")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(selectedAmount == amount ? UNPColors.background : UNPColors.cream)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedAmount == amount ? UNPColors.accent : UNPColors.cardSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                                }
                            }
                        }
                    }
                    
                    // Custom Amount
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom Amount")
                            .font(.headline)
                            .foregroundColor(UNPColors.cream)
                        
                        HStack {
                            Text("$")
                                .font(.title2)
                                .foregroundColor(UNPColors.cream)
                            
                            TextField("0.00", text: $customAmount)
                                .font(.title2)
                                .foregroundColor(UNPColors.cream)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .onChange(of: customAmount) { oldValue, newValue in
                                    if !newValue.isEmpty {
                                        selectedAmount = nil
                                    }
                                }
                        }
                        .padding()
                        .background(UNPColors.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                    }
                    
                    Spacer()
                    
                    // Send Tip Button
                    Button(action: {
                        let tipAmount: Double
                        if let selected = selectedAmount {
                            tipAmount = selected
                        } else if let custom = Double(customAmount), custom > 0 {
                            tipAmount = custom
                        } else {
                            return
                        }
                        
                        onTipSent(tipAmount)
                        dismiss()
                    }) {
                        Text("Send Tip")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(UNPColors.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [UNPColors.accent, UNPColors.accent.opacity(0.72)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .disabled(selectedAmount == nil && (customAmount.isEmpty || Double(customAmount) == nil || Double(customAmount)! <= 0))
                    .opacity(selectedAmount == nil && (customAmount.isEmpty || Double(customAmount) == nil || Double(customAmount)! <= 0) ? 0.5 : 1.0)
                }
                .padding(20)
            }
            .navigationTitle("Send Tip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(UNPColors.accent)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
        }
    }
}

// MARK: - Profile Sheet Views (merged from ProfileSheets.swift)

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var user: User
    @State private var editedUser: User
    @State private var selectedPhoto: PhotosPickerItem? = nil

    init(user: Binding<User>) {
        self._user = user
        self._editedUser = State(initialValue: user.wrappedValue)
    }

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                ZStack {
                                    if let profileImage = editedUser.profileImage, !profileImage.isEmpty {
                                        Image(profileImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [UNPColors.accent.opacity(0.38), UNPColors.cardSurface]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .foregroundColor(UNPColors.cream)
                                                    .font(.system(size: 30))
                                            )
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(UNPColors.accent, lineWidth: 3)
                                )
                            }

                            Text("Tap to change photo")
                                .font(.caption)
                                .foregroundColor(UNPColors.creamMuted())
                        }
                        .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("BASIC INFORMATION")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(UNPColors.accent)
                                .tracking(1)

                            VStack(spacing: 12) {
                                ProfileTextField(title: "Name", text: $editedUser.name)
                                ProfileTextField(title: "Email", text: $editedUser.email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                ProfileTextField(title: "Location", text: $editedUser.location)
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("PROFESSIONAL")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(UNPColors.accent)
                                .tracking(1)

                            VStack(spacing: 12) {
                                ProfileTextField(title: "Profession", text: Binding(
                                    get: { editedUser.profession ?? "" },
                                    set: { editedUser.profession = $0.isEmpty ? nil : $0 }
                                ))

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bio")
                                        .font(.headline)
                                        .foregroundColor(UNPColors.cream)

                                    TextEditor(text: Binding(
                                        get: { editedUser.bio ?? "" },
                                        set: { editedUser.bio = $0.isEmpty ? nil : $0 }
                                    ))
                                    .frame(height: 100)
                                    .padding(12)
                                    .background(UNPColors.cardSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                                    .foregroundColor(UNPColors.cream)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous)
                                            .stroke(UNPColors.accent.opacity(0.35), lineWidth: 1)
                                    )
                                    .scrollContentBackground(.hidden)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("SOCIAL MEDIA")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(UNPColors.accent)
                                .tracking(1)

                            VStack(spacing: 12) {
                                ProfileTextField(title: "Instagram", text: Binding(
                                    get: { editedUser.instagramHandle ?? "" },
                                    set: { editedUser.instagramHandle = $0.isEmpty ? nil : $0 }
                                ))
                                .autocapitalization(.none)

                                ProfileTextField(title: "Twitter / X", text: Binding(
                                    get: { editedUser.twitterHandle ?? "" },
                                    set: { editedUser.twitterHandle = $0.isEmpty ? nil : $0 }
                                ))
                                .autocapitalization(.none)
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("LANGUAGES")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(UNPColors.accent)
                                .tracking(1)

                            LanguageSelectionView(languages: Binding(
                                get: { editedUser.languages },
                                set: { editedUser.languages = $0 }
                            ))
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("INTERESTS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(UNPColors.accent)
                                .tracking(1)

                            NavigationLink(destination: InterestsEditView(interests: Binding(
                                get: { editedUser.interests },
                                set: { editedUser.interests = $0 }
                            ))) {
                                HStack {
                                    Text("\(editedUser.interests.count) selected")
                                        .foregroundColor(UNPColors.cream)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(UNPColors.creamMuted())
                                }
                                .padding()
                                .background(UNPColors.cardSurface)
                                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(UNPColors.cream)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        user = editedUser
                        dismiss()
                    }
                    .foregroundColor(UNPColors.accent)
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let _ = UIImage(data: data) {
                    editedUser.profileImage = "user_\(UUID().uuidString)"
                }
            }
        }
    }
}

struct ProfileTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(UNPColors.cream)

            TextField("", text: $text)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
}

struct LanguageSelectionView: View {
    @Binding var languages: [String]

    private let commonLanguages = [
        "English", "Spanish", "French", "German", "Italian",
        "Portuguese", "Japanese", "Chinese", "Korean", "Arabic"
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(commonLanguages, id: \.self) { language in
                LanguageTag(
                    language: language,
                    isSelected: languages.contains(language),
                    onToggle: {
                        if languages.contains(language) {
                            languages.removeAll { $0 == language }
                        } else {
                            languages.append(language)
                        }
                    }
                )
            }
        }
    }
}

struct InterestsEditView: View {
    @Binding var interests: Set<DrinkInterest>

    private let maxSelection = 7
    private var isAtLimit: Bool { interests.count >= maxSelection }

    var body: some View {
        ZStack {
            UNPColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("Select Your Interests")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(UNPColors.cream)

                        Text("Choose up to \(maxSelection) interests")
                            .font(.body)
                            .foregroundColor(UNPColors.creamMuted())

                        if !interests.isEmpty {
                            Text("\(interests.count) selected")
                                .font(.caption)
                                .foregroundColor(UNPColors.accent)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    interestSection(title: "Spirits", items: [
                        (.whiskey, "takeoutbag.and.cup.and.straw", UNPColors.accent),
                        (.bourbon, "flame", Color.red),
                        (.scotch, "drop", Color.blue),
                        (.gin, "leaf", Color.green),
                        (.tequila, "sun.max", UNPColors.accent),
                        (.rum, "sailboat", Color.purple),
                        (.vodka, "snow", Color.cyan)
                    ])

                    interestSection(title: "Cocktails", items: [
                        (.negroni, "wineglass", Color.red),
                        (.martini, "martini.glass", Color.blue),
                        (.oldFashioned, "cube", UNPColors.accent),
                        (.spritz, "sparkles", UNPColors.accent),
                        (.margarita, "tortilla", Color.green),
                        (.manhattan, "building.2", Color.purple)
                    ])

                    interestSection(title: "Wine, Beer & NA", items: [
                        (.redWine, "wineglass", Color.red),
                        (.whiteWine, "wineglass", UNPColors.accent),
                        (.sparkling, "sparkles", Color.cyan),
                        (.ipa, "hare", UNPColors.accent),
                        (.lager, "circle", Color.blue),
                        (.stout, "circle.fill", UNPColors.background),
                        (.mocktails, "bubble", Color.green)
                    ])
                }
            }
        }
        .navigationTitle("Edit Interests")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(UNPColors.background, for: .navigationBar)
    }

    private func interestSection(title: String, items: [(DrinkInterest, String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(UNPColors.cream)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(items, id: \.0) { (interest, icon, color) in
                    InterestSelectionTag(
                        interest: interest,
                        icon: icon,
                        color: color,
                        isSelected: interests.contains(interest),
                        isDisabled: !interests.contains(interest) && isAtLimit,
                        onToggle: { toggle(interest) }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func toggle(_ interest: DrinkInterest) {
        if interests.contains(interest) {
            interests.remove(interest)
        } else if !isAtLimit {
            interests.insert(interest)
        }
    }
}

struct FavoritesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var favoriteDrinks: [Drink]

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()

                if favoriteDrinks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 60))
                            .foregroundColor(UNPColors.creamMuted())
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(UNPColors.cream)
                        Text("Start adding drinks to your favorites")
                            .font(.body)
                            .foregroundColor(UNPColors.creamMuted())
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(favoriteDrinks, id: \.id) { drink in
                                FavoriteDrinkCard(drink: drink)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(UNPColors.accent)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
        }
    }
}

struct FavoriteDrinkCard: View {
    let drink: Drink

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let imageName = getImageName(for: drink.name) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [UNPColors.accent.opacity(0.38), UNPColors.cardSurface]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: getSystemIcon(for: drink.category))
                                .font(.title)
                                .foregroundColor(UNPColors.creamMuted())
                        )
                }
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(12)

            Text(drink.name)
                .font(.headline)
                .foregroundColor(UNPColors.cream)
                .lineLimit(2)

            Text("$\(String(format: "%.2f", drink.price))")
                .font(.subheadline)
                .foregroundColor(UNPColors.accent)
        }
    }

    private func getImageName(for drinkName: String) -> String? {
        switch drinkName {
        case "Negroni": return "Negroni"
        case "Scotch & Bourbon": return "Scotch"
        case "Spritzer": return "Spritzer"
        case "Martini": return "Dirty Martini"
        case "Red Wine": return "Red Wine"
        case "White Wine": return "White Wine"
        default: return nil
        }
    }

    private func getSystemIcon(for category: DrinkCategory) -> String {
        switch category {
        case .drinks: return "wineglass"
        case .food: return "fork.knife"
        case .social: return "person.2"
        }
    }
}

struct OrderHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var orders: [Order] = []

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()

                if orders.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 60))
                            .foregroundColor(UNPColors.creamMuted())
                        Text("No Orders Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(UNPColors.cream)
                        Text("Your order history will appear here")
                            .font(.body)
                            .foregroundColor(UNPColors.creamMuted())
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(orders) { order in
                                OrderHistoryCard(order: order)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Order History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(UNPColors.accent)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
            .onAppear { loadOrders() }
        }
    }

    private func loadOrders() { orders = [] }
}

struct OrderHistoryCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Order #\(String(order.id.uuidString.prefix(8)))")
                    .font(.headline)
                    .foregroundColor(UNPColors.cream)
                Spacer()
                Text(order.status.rawValue)
                    .font(.caption)
                    .foregroundColor(statusColor(for: order.status))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(for: order.status).opacity(0.2))
                    .cornerRadius(8)
            }
            Text(order.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(UNPColors.creamMuted())
            Text("\(order.items.count) items • $\(String(format: "%.2f", order.total))")
                .font(.subheadline)
                .foregroundColor(UNPColors.cream)
        }
        .padding()
        .background(UNPColors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
    }

    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending: return UNPColors.accent
        case .confirmed: return .blue
        case .preparing: return UNPColors.accent.opacity(0.85)
        case .ready: return .green
        case .delivered: return UNPColors.creamMuted(0.5)
        }
    }
}

struct PaymentMethodsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var paymentMethods: [PaymentMethod] = []
    @State private var showAddPayment = false

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()

                if paymentMethods.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 60))
                            .foregroundColor(UNPColors.creamMuted())
                        Text("No Payment Methods")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(UNPColors.cream)
                        Text("Add a payment method to get started")
                            .font(.body)
                            .foregroundColor(UNPColors.creamMuted())
                        Button(action: { showAddPayment = true }) {
                            Text("Add Payment Method")
                                .font(.headline)
                                .foregroundColor(UNPColors.background)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [UNPColors.accent, UNPColors.accent.opacity(0.72)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .padding(.top, 8)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(paymentMethods) { method in
                                PaymentMethodCard(method: method)
                            }
                            Button(action: { showAddPayment = true }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add Payment Method")
                                }
                                .font(.headline)
                                .foregroundColor(UNPColors.accent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(UNPColors.cardSurface)
                                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous)
                                        .stroke(UNPColors.accent.opacity(0.35), lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Payment Methods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(UNPColors.accent)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
            .sheet(isPresented: $showAddPayment) {
                AddPaymentMethodSheet { method in
                    paymentMethods.append(method)
                }
            }
            .onAppear { loadPaymentMethods() }
        }
    }

    private func loadPaymentMethods() { paymentMethods = [] }
}

struct PaymentMethodCard: View {
    let method: PaymentMethod

    var body: some View {
        HStack {
            Image(systemName: iconForPaymentType(method.type))
                .font(.title2)
                .foregroundColor(UNPColors.accent)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(method.type.rawValue)
                    .font(.headline)
                    .foregroundColor(UNPColors.cream)
                Text("•••• \(method.lastFour)")
                    .font(.subheadline)
                    .foregroundColor(UNPColors.creamMuted())
            }
            Spacer()
            if method.isDefault {
                Text("DEFAULT")
                    .font(.caption2)
                    .foregroundColor(UNPColors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(UNPColors.accent.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            }
        }
        .padding()
        .background(UNPColors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
    }

    private func iconForPaymentType(_ type: PaymentType) -> String {
        switch type {
        case .creditCard: return "creditcard.fill"
        case .applePay: return "applelogo"
        case .paypal: return "p.circle.fill"
        }
    }
}

struct AddPaymentMethodSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (PaymentMethod) -> Void
    @State private var selectedType: PaymentType = .creditCard
    @State private var cardNumber = ""
    @State private var cardName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Payment Type")
                                .font(.headline)
                                .foregroundColor(UNPColors.cream)

                            HStack(spacing: 12) {
                                ForEach([PaymentType.creditCard, PaymentType.applePay, PaymentType.paypal], id: \.self) { type in
                                    Button(action: { selectedType = type }) {
                                        VStack {
                                            Image(systemName: iconForPaymentType(type))
                                                .font(.title2)
                                                .foregroundColor(selectedType == type ? UNPColors.accent : UNPColors.creamMuted())
                                            Text(type.rawValue)
                                                .font(.caption)
                                                .foregroundColor(selectedType == type ? UNPColors.cream : UNPColors.creamMuted())
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(selectedType == type ? UNPColors.accent.opacity(0.2) : UNPColors.cardSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        if selectedType == .creditCard {
                            VStack(spacing: 16) {
                                ProfileTextField(title: "Card Number", text: $cardNumber)
                                    .keyboardType(.numberPad)
                                ProfileTextField(title: "Cardholder Name", text: $cardName)
                                HStack(spacing: 12) {
                                    ProfileTextField(title: "Expiry", text: $expiryDate)
                                        .keyboardType(.numbersAndPunctuation)
                                    ProfileTextField(title: "CVV", text: $cvv)
                                        .keyboardType(.numberPad)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationTitle("Add Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(UNPColors.cream)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let lastFour = cardNumber.count >= 4 ? String(cardNumber.suffix(4)) : "0000"
                        let method = PaymentMethod(type: selectedType, lastFour: lastFour, isDefault: false)
                        onAdd(method)
                        dismiss()
                    }
                    .foregroundColor(UNPColors.accent)
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
        }
    }

    private func iconForPaymentType(_ type: PaymentType) -> String {
        switch type {
        case .creditCard: return "creditcard.fill"
        case .applePay: return "applelogo"
        case .paypal: return "p.circle.fill"
        }
    }
}

struct AddressesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var addresses: [String] = []
    @State private var showAddAddress = false

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()

                if addresses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "location")
                            .font(.system(size: 60))
                            .foregroundColor(UNPColors.creamMuted())
                        Text("No Saved Addresses")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(UNPColors.cream)
                        Text("Add an address for faster checkout")
                            .font(.body)
                            .foregroundColor(UNPColors.creamMuted())
                        Button(action: { showAddAddress = true }) {
                            Text("Add Address")
                                .font(.headline)
                                .foregroundColor(UNPColors.background)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [UNPColors.accent, UNPColors.accent.opacity(0.72)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .padding(.top, 8)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(addresses, id: \.self) { address in
                                AddressCard(address: address)
                            }
                            Button(action: { showAddAddress = true }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add Address")
                                }
                                .font(.headline)
                                .foregroundColor(UNPColors.accent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(UNPColors.cardSurface)
                                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous)
                                        .stroke(UNPColors.accent.opacity(0.35), lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Saved Addresses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(UNPColors.accent)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
            .sheet(isPresented: $showAddAddress) {
                AddAddressSheet { address in
                    addresses.append(address)
                }
            }
            .onAppear { loadAddresses() }
        }
    }

    private func loadAddresses() { addresses = [] }
}

struct AddressCard: View {
    let address: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "location.fill")
                .font(.title3)
                .foregroundColor(UNPColors.accent)
                .frame(width: 24)
            Text(address)
                .font(.body)
                .foregroundColor(UNPColors.cream)
            Spacer()
        }
        .padding()
        .background(UNPColors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
    }
}

struct AddAddressSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String) -> Void
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        ProfileTextField(title: "Street Address", text: $address)
                        ProfileTextField(title: "City", text: $city)
                        ProfileTextField(title: "State", text: $state)
                        ProfileTextField(title: "ZIP Code", text: $zipCode)
                            .keyboardType(.numberPad)
                        Spacer().frame(height: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(UNPColors.cream)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let fullAddress = "\(address), \(city), \(state) \(zipCode)"
                        onAdd(fullAddress)
                        dismiss()
                    }
                    .foregroundColor(UNPColors.accent)
                    .fontWeight(.semibold)
                    .disabled(address.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
        }
    }
}

struct NotificationsSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushNotifications = true
    @State private var emailNotifications = true
    @State private var orderUpdates = true
    @State private var promotions = false
    @State private var newDrinks = true

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        SettingsSection(title: "Notification Preferences") {
                            SettingsRow(icon: "bell.fill", title: "Push Notifications", action: {}, hasToggle: true, toggleValue: $pushNotifications)
                            SettingsRow(icon: "envelope.fill", title: "Email Notifications", action: {}, hasToggle: true, toggleValue: $emailNotifications)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        SettingsSection(title: "What to Notify") {
                            SettingsRow(icon: "shippingbox.fill", title: "Order Updates", action: {}, hasToggle: true, toggleValue: $orderUpdates)
                            SettingsRow(icon: "gift.fill", title: "Promotions", action: {}, hasToggle: true, toggleValue: $promotions)
                            SettingsRow(icon: "wineglass.fill", title: "New Drinks", action: {}, hasToggle: true, toggleValue: $newDrinks)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(UNPColors.accent)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
        }
    }
}

struct HelpSupportSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        SettingsSection(title: "Frequently Asked Questions") {
                            HelpSupportRow(icon: "questionmark.circle.fill", title: "How do I place an order?", action: {})
                            HelpSupportRow(icon: "questionmark.circle.fill", title: "How do I track my order?", action: {})
                            HelpSupportRow(icon: "questionmark.circle.fill", title: "What payment methods are accepted?", action: {})
                            HelpSupportRow(icon: "questionmark.circle.fill", title: "How do I cancel an order?", action: {})
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        SettingsSection(title: "Contact Support") {
                            HelpSupportRow(icon: "envelope.fill", title: "Email Support", subtitle: "support@sipsync.com", action: {})
                            HelpSupportRow(icon: "phone.fill", title: "Phone Support", subtitle: "1-800-SIP-SYNC", action: {})
                            HelpSupportRow(icon: "message.fill", title: "Live Chat", action: {})
                        }
                        .padding(.horizontal, 20)

                        SettingsSection(title: "Resources") {
                            HelpSupportRow(icon: "doc.text.fill", title: "Terms of Service", action: {})
                            HelpSupportRow(icon: "lock.shield.fill", title: "Privacy Policy", action: {})
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(UNPColors.accent)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
        }
    }
}

struct HelpSupportRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(UNPColors.accent)
                    .font(.title3)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(UNPColors.cream)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(UNPColors.creamMuted())
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(UNPColors.creamMuted())
                    .font(.caption)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                UNPColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 32) {
                        Image("SipSyncLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .cornerRadius(20)
                            .padding(.top, 40)

                        VStack(spacing: 12) {
                            Text("Until The Next Pour")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(UNPColors.cream)
                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(UNPColors.creamMuted())
                        }

                        VStack(spacing: 16) {
                            Text("About Until The Next Pour")
                                .font(.headline)
                                .foregroundColor(UNPColors.cream)
                            Text("Until The Next Pour is your ultimate destination for discovering, ordering, and enjoying premium drinks. Connect with bartenders, explore venues, and sync your favorite drinks with ease.")
                                .font(.body)
                                .foregroundColor(UNPColors.creamMuted())
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)

                        VStack(spacing: 12) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Rate Us on App Store")
                                }
                                .font(.headline)
                                .foregroundColor(UNPColors.cream)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(UNPColors.cardSurface)
                                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                            }
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share App")
                                }
                                .font(.headline)
                                .foregroundColor(UNPColors.cream)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(UNPColors.cardSurface)
                                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        Text("© 2025 Until The Next Pour. All rights reserved.")
                            .font(.caption)
                            .foregroundColor(UNPColors.creamMuted())
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(UNPColors.accent)
                }
            }
            .toolbarBackground(UNPColors.background, for: .navigationBar)
        }
    }
}

#Preview {
    ProfileView(favoriteDrinks: .constant([]))
        .environmentObject(AppTheme.shared)
        .environmentObject(UNPDataStore.shared)
}