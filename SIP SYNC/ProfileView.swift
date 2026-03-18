//
//  ProfileView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI
import PhotosUI
import PassKit

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
    @State private var showAddToTipJar = false
    @State private var showCashOutTipJar = false
    @State private var addCashAmount: Double = 0.0
    @StateObject private var applePayManager = ApplePayManager()
    @StateObject private var tipJarManager = TipJarManager.shared
    
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
                
                // Tip Jar Section
                tipJarSection
                
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
                    .foregroundColor(.white)
                Text("Orders")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            VStack {
                Text("8")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Reviews")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            VStack {
                Text("4.8")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Rating")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var tipJarSection: some View {
        TipJarSection(
            balance: tipJarManager.balance,
            onAddCash: { amount in
                addCashAmount = amount
                applePayManager.requestPayment(amount: amount) { success, error in
                    if success {
                        tipJarManager.addToBalance(amount)
                    }
                }
            },
            onCashOut: {
                showCashOutTipJar = true
            }
        )
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var favoritesSection: some View {
        Group {
            if !favoriteDrinks.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "My Favorites")
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
                                                .fill(Color.gray.opacity(0.3))
                                                .overlay(
                                                    Image(systemName: getSystemIcon(for: drink.category))
                                                        .font(.title)
                                                        .foregroundColor(.white)
                                                )
                                        }
                                    }
                                    .frame(width: 120, height: 80)
                                    .clipped()
                                    .cornerRadius(12)
                                    
                                    Text(drink.name)
                                        .font(.caption)
                                        .foregroundColor(.white)
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
            SectionHeader(title: "Menu")
            
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
            // Dark background
            Color.black.ignoresSafeArea()
            
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
        }
        .sheet(isPresented: $showCashOutTipJar) {
            CashOutTipJarSheet(balance: Binding(
                get: { tipJarManager.balance },
                set: { _ in } // Balance is managed by TipJarManager
            ), onCashOut: { amount in
                tipJarManager.deductFromBalance(amount)
            })
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
        // Return colors based on user's interests
        if userType == .bartender {
            return [Color.yellow.opacity(0.4), Color.orange.opacity(0.4), Color.red.opacity(0.3)]
        } else if interests.contains(.negroni) || interests.contains(.martini) {
            return [Color.red.opacity(0.4), Color.orange.opacity(0.4), Color.yellow.opacity(0.3)]
        } else if interests.contains(.whiskey) || interests.contains(.bourbon) || interests.contains(.scotch) {
            return [Color.brown.opacity(0.4), Color.orange.opacity(0.3), Color.yellow.opacity(0.3)]
        } else if interests.contains(.gin) {
            return [Color.green.opacity(0.4), Color.mint.opacity(0.3), Color.blue.opacity(0.3)]
        } else {
            return [Color.yellow.opacity(0.4), Color.orange.opacity(0.4), Color.red.opacity(0.3)]
        }
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
                        Color.black.opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Navigation buttons
            HStack {
                Button(action: {}) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.title3)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .font(.title3)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
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
                                        .foregroundColor(.white.opacity(0.9))
                                        .font(.system(size: 50))
                                }
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                        
                        // Edit icon overlay
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.black)
                                        .font(.system(size: 14))
                                }
                                .offset(x: 8, y: -8)
                            }
                        }
                        .frame(width: 120, height: 120)
                    }
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
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
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Geometric shapes with colors
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    // Create geometric facets
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
                            Color.green.opacity(0.6),
                            Color.blue.opacity(0.6),
                            Color.purple.opacity(0.6)
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
                            Color.pink.opacity(0.5),
                            Color.yellow.opacity(0.5)
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
                        .foregroundColor(.white)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow, lineWidth: 2)
                        )
                    
                    Button(action: {
                        if !editingName.isEmpty {
                            user.name = editingName
                        }
                        isEditingName = false
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.yellow)
                            .font(.title3)
                            .padding(8)
                            .background(Color.yellow.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        editingName = user.name
                        isEditingName = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.title3)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
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
                            .foregroundColor(.white)
                        
                        Image(systemName: "pencil")
                            .foregroundColor(.yellow)
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
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.caption)
                        .foregroundColor(.gray)
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
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(8)
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
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(user.location)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                // Languages
                if !user.languages.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(user.languages.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.white)
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
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                }
                
                // Instagram Button
                if user.instagramHandle != nil {
                    Button(action: {}) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                
                // Twitter/X Button
                if user.twitterHandle != nil {
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
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
                        .foregroundColor(.white)
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
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.5))
        .cornerRadius(16)
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
            return .orange
        case .vodka:
            return .white
        case .negroni, .martini, .oldFashioned, .spritz, .margarita, .manhattan:
            return .yellow
        case .redWine:
            return .red
        case .whiteWine, .sparkling:
            return .yellow
        case .ipa:
            return .orange
        case .lager:
            return .yellow
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
                    .foregroundColor(isDestructive ? .red : .yellow)
                    .font(.title2)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isDestructive ? .red : .white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 16)
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Tip Jar Section
struct TipJarSection: View {
    let balance: Double
    let onAddCash: (Double) -> Void
    let onCashOut: () -> Void
    
    @State private var showAmountSelector = false
    @State private var selectedAmount: Double? = nil
    
    private let quickAmounts: [Double] = [10, 25, 50, 100]
    
    var body: some View {
        VStack(spacing: 16) {
            // Balance Header
            HStack {
                Text("Tip Jar")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Account & Routing")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Balance Amount
            Text("$\(String(format: "%.2f", balance))")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action Buttons
            VStack(spacing: 12) {
                // Quick Amount Buttons
                HStack(spacing: 8) {
                    ForEach(quickAmounts, id: \.self) { amount in
                        Button(action: {
                            selectedAmount = amount
                            onAddCash(amount)
                        }) {
                            Text("$\(Int(amount))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedAmount == amount ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedAmount == amount ? Color.yellow : Color.gray.opacity(0.3))
                                .cornerRadius(12)
                        }
                    }
                }
                
                // Apple Pay Button
                if PKPaymentAuthorizationController.canMakePayments() {
                    ApplePayButton(
                        amount: selectedAmount ?? 0,
                        onPaymentSuccess: { amount in
                            onAddCash(amount)
                            selectedAmount = nil
                        }
                    )
                    .frame(height: 50)
                    .cornerRadius(12)
                    .opacity(selectedAmount != nil ? 1.0 : 0.5)
                    .disabled(selectedAmount == nil)
                } else {
                    // Fallback if Apple Pay not available
                    Button(action: {
                        showAmountSelector = true
                    }) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                            Text("Add Cash")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(20)
                    }
                }
                
                // Cash Out Button
                Button(action: onCashOut) {
                    Text("Cash Out")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(20)
                }
            }
            .sheet(isPresented: $showAmountSelector) {
                CustomAmountSheet(onAmountSelected: { amount in
                    selectedAmount = amount
                    onAddCash(amount)
                    showAmountSelector = false
                })
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Apple Pay Manager
class ApplePayManager: NSObject, ObservableObject, PKPaymentAuthorizationControllerDelegate {
    private var paymentCompletion: ((Bool, Error?) -> Void)?
    private var paymentAmount: Double = 0.0
    
    func requestPayment(amount: Double, completion: @escaping (Bool, Error?) -> Void) {
        guard PKPaymentAuthorizationController.canMakePayments() else {
            completion(false, NSError(domain: "ApplePayError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Apple Pay is not available"]))
            return
        }
        
        self.paymentAmount = amount
        self.paymentCompletion = completion
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.sipsync.app" // Replace with your merchant ID
        request.supportedNetworks = [.amex, .visa, .masterCard, .discover]
        request.merchantCapabilities = .threeDSecure
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        // Create payment summary items
        let tipJarItem = PKPaymentSummaryItem(
            label: "Tip Jar",
            amount: NSDecimalNumber(value: amount)
        )
        
        request.paymentSummaryItems = [tipJarItem]
        
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        controller.present { success in
            if !success {
                completion(false, NSError(domain: "ApplePayError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to present Apple Pay"]))
            }
        }
    }
    
    // MARK: - PKPaymentAuthorizationControllerDelegate
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // In a real app, you would send the payment token to your backend
        // For now, we'll simulate a successful payment
        DispatchQueue.main.async {
            self.paymentCompletion?(true, nil)
        }
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss()
    }
}

// MARK: - Apple Pay Button
struct ApplePayButton: UIViewRepresentable {
    let amount: Double
    let onPaymentSuccess: (Double) -> Void
    
    @StateObject private var applePayManager = ApplePayManager()
    
    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(amount: amount, onPaymentSuccess: onPaymentSuccess, applePayManager: applePayManager)
    }
    
    class Coordinator: NSObject {
        let amount: Double
        let onPaymentSuccess: (Double) -> Void
        let applePayManager: ApplePayManager
        
        init(amount: Double, onPaymentSuccess: @escaping (Double) -> Void, applePayManager: ApplePayManager) {
            self.amount = amount
            self.onPaymentSuccess = onPaymentSuccess
            self.applePayManager = applePayManager
        }
        
        @objc func buttonTapped() {
            applePayManager.requestPayment(amount: self.amount) { [weak self] success, error in
                guard let self = self else { return }
                if success {
                    self.onPaymentSuccess(self.amount)
                }
            }
        }
    }
}

// MARK: - Custom Amount Sheet
struct CustomAmountSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAmountSelected: (Double) -> Void
    @State private var amount: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Custom Amount Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Enter Amount")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("$")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            TextField("0.00", text: $amount)
                                .font(.title2)
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .padding(20)
                    
                    Spacer()
                    
                    // Continue Button
                    Button(action: {
                        if let amountValue = Double(amount), amountValue > 0 {
                            onAmountSelected(amountValue)
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0)
                    .opacity(amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0 ? 0.5 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Custom Amount")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
}

// MARK: - Cash Out Tip Jar Sheet
struct CashOutTipJarSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var balance: Double
    let onCashOut: (Double) -> Void
    @State private var amount: String = ""
    @State private var selectedAmount: Double? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Current Balance
                    VStack(spacing: 8) {
                        Text("Available Balance")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("$\(String(format: "%.2f", balance))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    // Amount to Cash Out
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Amount to Cash Out")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("$")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            TextField("0.00", text: $amount)
                                .font(.title2)
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        
                        Button(action: {
                            amount = String(format: "%.2f", balance)
                            selectedAmount = balance
                        }) {
                            Text("Cash Out All")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Spacer()
                    
                    // Cash Out Button
                    Button(action: {
                        if let amountValue = Double(amount), amountValue > 0, amountValue <= balance {
                            onCashOut(amountValue)
                            dismiss()
                        }
                    }) {
                        Text("Cash Out")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0 || Double(amount)! > balance)
                    .opacity(amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0 || Double(amount)! > balance ? 0.5 : 1.0)
                }
                .padding(20)
            }
            .navigationTitle("Cash Out")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
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
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Bartender Info
                    VStack(spacing: 12) {
                        Text("Tip \(post.author.name)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Show appreciation for this great drink!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Quick Amount Buttons
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Tip")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(quickAmounts, id: \.self) { amount in
                                Button(action: {
                                    selectedAmount = amount
                                    customAmount = ""
                                }) {
                                    Text("$\(Int(amount))")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(selectedAmount == amount ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedAmount == amount ? Color.yellow : Color.gray.opacity(0.3))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Custom Amount
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom Amount")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("$")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            TextField("0.00", text: $customAmount)
                                .font(.title2)
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .onChange(of: customAmount) { oldValue, newValue in
                                    if !newValue.isEmpty {
                                        selectedAmount = nil
                                    }
                                }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
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
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
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
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
}

// MARK: - Add Funds to Tip Jar Sheet
struct AddFundsToTipJarSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tipJarManager = TipJarManager.shared
    @StateObject private var applePayManager = ApplePayManager()
    @State private var selectedAmount: Double? = nil
    @State private var customAmount: String = ""
    
    private let quickAmounts: [Double] = [10, 25, 50, 100]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Current Balance
                    VStack(spacing: 8) {
                        Text("Current Balance")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("$\(String(format: "%.2f", tipJarManager.balance))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    // Quick Amount Buttons
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Add")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(quickAmounts, id: \.self) { amount in
                                Button(action: {
                                    selectedAmount = amount
                                    customAmount = ""
                                    applePayManager.requestPayment(amount: amount) { success, error in
                                        if success {
                                            tipJarManager.addToBalance(amount)
                                            dismiss()
                                        }
                                    }
                                }) {
                                    Text("$\(Int(amount))")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(selectedAmount == amount ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedAmount == amount ? Color.yellow : Color.gray.opacity(0.3))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Custom Amount
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom Amount")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("$")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            TextField("0.00", text: $customAmount)
                                .font(.title2)
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .onChange(of: customAmount) { oldValue, newValue in
                                    if !newValue.isEmpty {
                                        selectedAmount = nil
                                    }
                                }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Apple Pay Button
                    if PKPaymentAuthorizationController.canMakePayments() {
                        if let amount = selectedAmount ?? (Double(customAmount) ?? nil), amount > 0 {
                            ApplePayButton(
                                amount: amount,
                                onPaymentSuccess: { amount in
                                    tipJarManager.addToBalance(amount)
                                    dismiss()
                                }
                            )
                            .frame(height: 50)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Add Funds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
}

#Preview {
    ProfileView(favoriteDrinks: .constant([]))
}