//
//  SearchView.swift
//  SIP SYNC
//
//  Created by AI Assistant - Comprehensive Search System
//

import SwiftUI
import MapKit

// MARK: - Search Result Types
enum SearchResultType {
    case drink(Drink)
    case venue(Location)
    case user(SocialUser)
}

struct SearchResult: Identifiable {
    let id = UUID()
    let type: SearchResultType
    let title: String
    let subtitle: String?
    let image: String?
    let icon: String
    
    var drink: Drink? {
        if case .drink(let drink) = type { return drink }
        return nil
    }
    
    var venue: Location? {
        if case .venue(let location) = type { return location }
        return nil
    }
    
    var user: SocialUser? {
        if case .user(let socialUser) = type { return socialUser }
        return nil
    }
}

// MARK: - Unified Search View
struct UnifiedSearchView: View {
    @Binding var searchText: String
    @Binding var isPresented: Bool
    @State private var searchResults: [SearchResult] = []
    @State private var selectedDrink: Drink?
    @State private var selectedVenue: Location?
    @State private var showDrinkDetail = false
    @State private var showVenueMap = false
    @Binding var cartItems: [OrderItem]
    @Binding var favoriteDrinks: [Drink]
    
    private let sampleData = SampleData.shared
    
    var body: some View {
        ZStack {
            // Dark purple background
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
                // Search Header
                HStack {
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
                    
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search drinks, venues, users...", text: $searchText)
                            .foregroundColor(.white)
                            .submitLabel(.search)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.15, green: 0.1, blue: 0.25),
                                Color(red: 0.2, green: 0.15, blue: 0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.leading, 8)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Search Results
                if searchText.isEmpty {
                    // Show recent searches or categories
                    RecentSearchesView()
                } else if searchResults.isEmpty {
                    // No results
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Try searching for drinks, venues, or users")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    // Show results
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Group results by type
                            if let drinkResults = groupedResults["drink"], !drinkResults.isEmpty {
                                SearchResultsSection(
                                    title: "Drinks",
                                    icon: "wineglass.fill",
                                    results: drinkResults,
                                    onTap: handleResultTap
                                )
                            }
                            
                            if let venueResults = groupedResults["venue"], !venueResults.isEmpty {
                                SearchResultsSection(
                                    title: "Venues",
                                    icon: "building.2.fill",
                                    results: venueResults,
                                    onTap: handleResultTap
                                )
                            }
                            
                            if let userResults = groupedResults["user"], !userResults.isEmpty {
                                SearchResultsSection(
                                    title: "Users",
                                    icon: "person.fill",
                                    results: userResults,
                                    onTap: handleResultTap
                                )
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .onChange(of: searchText) { newValue in
            performSearch(query: newValue)
        }
        .fullScreenCover(isPresented: $showDrinkDetail) {
            if let drink = selectedDrink {
                NavigationView {
                    DrinkDetailView(drink: drink, cartItems: $cartItems, favoriteDrinks: $favoriteDrinks)
                }
            }
        }
        .sheet(isPresented: $showVenueMap) {
            if let venue = selectedVenue {
                VenueMapView(location: venue)
            }
        }
    }
    
    private var groupedResults: [String: [SearchResult]] {
        var grouped: [String: [SearchResult]] = [:]
        
        for result in searchResults {
            let key: String
            switch result.type {
            case .drink: key = "drink"
            case .venue: key = "venue"
            case .user: key = "user"
            }
            
            if grouped[key] == nil {
                grouped[key] = []
            }
            grouped[key]?.append(result)
        }
        
        return grouped
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let queryLower = query.lowercased().trimmingCharacters(in: .whitespaces)
        var results: [SearchResult] = []
        
        // Search Drinks
        for drink in sampleData.sampleDrinks {
            if drink.name.lowercased().contains(queryLower) ||
               drink.bio.lowercased().contains(queryLower) ||
               drink.tags.joined(separator: " ").lowercased().contains(queryLower) ||
               drink.category.rawValue.lowercased().contains(queryLower) {
                results.append(SearchResult(
                    type: .drink(drink),
                    title: drink.name,
                    subtitle: drink.category.rawValue,
                    image: drink.image,
                    icon: iconForCategory(drink.category)
                ))
            }
        }
        
        // Search Venues (Locations)
        for location in sampleData.sampleLocations {
            if location.name.lowercased().contains(queryLower) ||
               location.subtitle.lowercased().contains(queryLower) {
                results.append(SearchResult(
                    type: .venue(location),
                    title: location.name,
                    subtitle: location.subtitle,
                    image: location.image,
                    icon: location.locationType == .venue ? "building.2.fill" : "wineglass.fill"
                ))
            }
        }
        
        // Search Users
        for user in sampleData.sampleSocialUsers {
            if user.name.lowercased().contains(queryLower) ||
               user.username.lowercased().contains(queryLower) ||
               (user.location?.lowercased().contains(queryLower) ?? false) {
                results.append(SearchResult(
                    type: .user(user),
                    title: user.name,
                    subtitle: "@\(user.username)",
                    image: user.profileImage,
                    icon: iconForUserType(user.userType)
                ))
            }
        }
        
        // Sort results by relevance (exact matches first, then partial)
        searchResults = results.sorted { result1, result2 in
            let title1 = result1.title.lowercased()
            let title2 = result2.title.lowercased()
            
            let exactMatch1 = title1 == queryLower
            let exactMatch2 = title2 == queryLower
            
            if exactMatch1 != exactMatch2 {
                return exactMatch1
            }
            
            let startsWith1 = title1.hasPrefix(queryLower)
            let startsWith2 = title2.hasPrefix(queryLower)
            
            if startsWith1 != startsWith2 {
                return startsWith1
            }
            
            return title1 < title2
        }
    }
    
    private func handleResultTap(_ result: SearchResult) {
        switch result.type {
        case .drink(let drink):
            selectedDrink = drink
            showDrinkDetail = true
            isPresented = false
            
        case .venue(let location):
            selectedVenue = location
            showVenueMap = true
            isPresented = false
            
        case .user(_):
            // Navigate to user profile or filter feed by user
            // For now, we'll just close search - could navigate to profile view
            // In a full implementation, this would navigate to user profile
            isPresented = false
        }
    }
    
    private func iconForCategory(_ category: DrinkCategory) -> String {
        switch category {
        case .drinks: return "wineglass.fill"
        case .food: return "fork.knife"
        case .social: return "person.2"
        }
    }
    
    private func iconForUserType(_ userType: UserType) -> String {
        switch userType {
        case .consumer: return "person.fill"
        case .bartender: return "wineglass.fill"
        case .venue: return "building.2.fill"
        }
    }
}

// MARK: - Search Results Section
struct SearchResultsSection: View {
    let title: String
    let icon: String
    let results: [SearchResult]
    let onTap: (SearchResult) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                    .font(.headline)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("(\(results.count))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            ForEach(results) { result in
                SearchResultRow(result: result) {
                    onTap(result)
                }
            }
        }
    }
}

// MARK: - Search Result Row
struct SearchResultRow: View {
    let result: SearchResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Image or Icon
                Group {
                    if let imageName = result.image {
                        // Try to load image from assets
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        // Fallback to icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
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
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: result.icon)
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if let subtitle = result.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        
        Divider()
            .background(Color.gray.opacity(0.3))
            .padding(.leading, 82)
    }
}

// MARK: - Recent Searches View
struct RecentSearchesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Search Suggestions")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Popular Drinks")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["Negroni", "Martini", "Scotch", "Spritzer"], id: \.self) { drink in
                                SuggestionChip(title: drink, icon: "wineglass.fill")
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Popular Venues")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(["The Nest Bar", "PORT", "Nelson Cocktail Lounge"], id: \.self) { venue in
                                SuggestionChip(title: venue, icon: "building.2.fill")
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Suggestion Chip
struct SuggestionChip: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.subheadline)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Venue Map View (for venue search results)
struct VenueMapView: View {
    let location: Location
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State private var region: MKCoordinateRegion
    @State private var showLocationCard = true
    
    init(location: Location) {
        self.location = location
        _region = State(initialValue: MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map
                Map(coordinateRegion: $region, annotationItems: [location]) { loc in
                    MapAnnotation(coordinate: loc.coordinate) {
                        Button(action: {
                            withAnimation {
                                showLocationCard = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: loc.locationType == .bartender ? "person.crop.circle.fill" : "building.2.fill")
                                    .foregroundColor(loc.locationType == .bartender ? .yellow : .orange)
                                    .font(.title2)
                            }
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .ignoresSafeArea(.all)
                
                // Location Card
                if showLocationCard {
                    VStack {
                        Spacer()
                        LocationCard(location: location) {
                            withAnimation {
                                showLocationCard = false
                            }
                        }
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle(location.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            // Center map on location with animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }
        }
    }
}

#Preview {
    UnifiedSearchView(
        searchText: .constant(""),
        isPresented: .constant(true),
        cartItems: .constant([]),
        favoriteDrinks: .constant([])
    )
}

