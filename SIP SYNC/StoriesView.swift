//
//  StoriesView.swift
//  SIP SYNC
//
//  Created by AI Assistant on 10/28/25.
//

import SwiftUI
import MapKit

struct StoriesView: View {
    @State private var searchText = ""
    @State private var selectedUserType: UserType? = nil
    @State private var selectedLocation: Location? = nil
    @State private var selectedStorySet: StorySet? = nil
    @State private var selectedStoryIndex: Int = 0
    @State private var showStoryViewer: Bool = false
    @State private var showAddStory = false
    @State private var storySets: [StorySet] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private let sampleData = SampleData.shared
    
    // Current user (would come from session/auth)
    private var currentUser: SocialUser {
        SampleData.shared.sampleSocialUsers.first ?? SocialUser(
            name: "You",
            username: "user",
            userType: .consumer,
            location: "Detroit"
        )
    }
    
    private var activeStorySets: [StorySet] {
        let allSets = storySets.isEmpty ? sampleData.sampleStorySets : storySets
        return allSets.filter { !$0.activeStories.isEmpty }
    }
    
    private var filteredLocations: [Location] {
        if let userType = selectedUserType {
            switch userType {
            case .bartender:
                return sampleData.sampleLocations.filter { $0.locationType == .bartender }
            case .venue:
                return sampleData.sampleLocations.filter { $0.locationType == .venue }
            case .consumer:
                return sampleData.sampleLocations
            }
        }
        return sampleData.sampleLocations
    }
    
    var body: some View {
        ZStack {
            // Full screen map
            Map(coordinateRegion: $region, annotationItems: filteredLocations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Button(action: {
                        withAnimation {
                            selectedLocation = location
                        }
                    }) {
                        Image(systemName: location.locationType == .bartender ? "person.crop.circle.fill" : "building.2.fill")
                            .foregroundColor(location.locationType == .bartender ? .yellow : .orange)
                            .font(.title2)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 32, height: 32)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .ignoresSafeArea(.all)
            
            // Liquid Glass Search Bar and Stories Bar - positioned at the top
            VStack(spacing: 0) {
                LiquidGlassSearchBar(text: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // Instagram-style Stories Bar
                StoriesBar(
                    storySets: activeStorySets,
                    selectedStorySet: $selectedStorySet,
                    selectedStoryIndex: $selectedStoryIndex,
                    onAddStory: {
                        showAddStory = true
                    }
                )
                
                Spacer()
            }
            
            // Location Card (slides up from bottom)
            if let location = selectedLocation {
                VStack {
                    Spacer()
                    LocationCard(location: location) {
                        withAnimation {
                            selectedLocation = nil
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            
            // Full-Screen Story Viewer
            if let storySet = selectedStorySet {
                StoryViewer(
                    storySet: storySet,
                    currentStoryIndex: $selectedStoryIndex,
                    isPresented: Binding(
                        get: { selectedStorySet != nil },
                        set: { isPresented in
                            if !isPresented {
                                selectedStorySet = nil
                                selectedStoryIndex = 0
                            }
                        }
                    )
                )
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .sheet(isPresented: $showAddStory) {
            AddStoryView(isPresented: $showAddStory) { image, text, rating in
                createReviewFromImage(image, reviewText: text, rating: rating)
            }
        }
        .onAppear {
            if storySets.isEmpty {
                storySets = sampleData.sampleStorySets
            }
        }
    }
    
    private func createReviewFromImage(_ image: UIImage?, reviewText: String?, rating: Int?) {
        // Save image to temporary location (in production, save to permanent storage)
        let imageName = image != nil ? "review_\(UUID().uuidString).jpg" : nil
        
        // Create new review (story as review)
        let now = Date()
        var newStory = Story(
            image: imageName,
            reviewText: reviewText,
            rating: rating,
            textColor: "white",
            createdAt: now,
            author: currentUser,
            locationId: selectedLocation?.id,
            expiresAt: nil // Reviews don't expire
        )
        
        // Check if user already has a story set
        if let existingIndex = storySets.firstIndex(where: { $0.author.id == currentUser.id }) {
            // Add to existing story set
            var updatedSet = storySets[existingIndex]
            var updatedStories = updatedSet.stories
            updatedStories.append(newStory)
            updatedSet.stories = updatedStories
            storySets[existingIndex] = updatedSet
        } else {
            // Create new story set for user
            let newStorySet = StorySet(
                author: currentUser,
                stories: [newStory],
                viewedStories: []
            )
            storySets.insert(newStorySet, at: 0) // Add at beginning
        }
        
        // In production, you would:
        // 1. Save the image to disk/cloud storage
        // 2. Upload review metadata to backend
        // 3. Update local state
    }
}

// MARK: - Location Card (Yelp-Style)
struct LocationCard: View {
    let location: Location
    let onDismiss: () -> Void
    @State private var selectedStoryIndex = 0
    @State private var showReviewForm = false
    @State private var reviews: [Review] = []
    @State private var showPhotoFullScreen = false
    @State private var selectedPhoto: String?
    
    // Convert SocialPost to Review
    private var convertedReviews: [Review] {
        location.stories.map { post in
            Review(
                author: post.author,
                rating: 5, // Default rating, could be extracted from story if available
                reviewText: post.content,
                photos: post.image != nil ? [post.image!] : [],
                createdAt: post.createdAt,
                helpfulCount: post.likes,
                isHelpful: false
            )
        }
    }
    
    private var allReviews: [Review] {
        reviews.isEmpty ? convertedReviews : reviews
    }
    
    private var averageRating: Double {
        guard !allReviews.isEmpty else { return 0 }
        let sum = allReviews.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(allReviews.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text(location.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                
                                // Address
                                if let address = location.address {
                                    HStack(spacing: 4) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top, 2)
                                }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.black)
                            }
                            Button(action: onDismiss) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                            }
                            }
                        }
                        
                        // Sip Sync Bartenders Badge
                        if location.hasSipSyncBartender {
                            SipSyncBartendersBadge(bartenders: location.sipSyncBartenders)
                        }
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                    .foregroundColor(.white)
                                Text("Directions")
                                    .foregroundColor(.white)
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "safari.fill")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Reviews Section (Yelp-Style)
                    ReviewsSection(
                        reviews: allReviews,
                        averageRating: averageRating,
                        reviewCount: allReviews.count,
                        onAddReview: {
                            showReviewForm = true
                        },
                        onHelpful: { review in
                            // Update review in reviews array or converted reviews
                            if let index = reviews.firstIndex(where: { $0.id == review.id }) {
                                reviews[index].isHelpful.toggle()
                                reviews[index].helpfulCount += reviews[index].isHelpful ? 1 : -1
                            } else {
                                // Add to reviews array if it was from converted reviews
                                var updatedReview = review
                                updatedReview.isHelpful.toggle()
                                updatedReview.helpfulCount += updatedReview.isHelpful ? 1 : -1
                                reviews.append(updatedReview)
                            }
                        },
                        onPhotoTap: { photoName in
                            selectedPhoto = photoName
                            showPhotoFullScreen = true
                        }
                    )
                    .padding(.top, 8)
                }
                .padding(20)
            }
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -4)
        .frame(height: 600) // Increased height for reviews
        .sheet(isPresented: $showReviewForm) {
            YelpReviewForm(
                isPresented: $showReviewForm,
                location: location
            ) { newReview in
                reviews.insert(newReview, at: 0) // Add new review at top
            }
        }
        .fullScreenCover(isPresented: $showPhotoFullScreen) {
            if let photo = selectedPhoto {
                PhotoFullScreenView(imageName: photo) {
                    showPhotoFullScreen = false
                }
            }
        }
    }
}

// MARK: - Photo Full Screen View
struct PhotoFullScreenView: View {
    let imageName: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

// MARK: - Review Card (Editable Story Card)
struct StoryCard: View {
    let story: SocialPost
    let index: Int
    @State private var showEditReview = false
    @State private var editableStory: Story?
    
    // Convert SocialPost to Story for editing
    private var storyForEditing: Story? {
        // Find the story in storySets or create from SocialPost
        // For now, create a basic story from SocialPost
        return Story(
            image: story.image,
            reviewText: story.content,
            rating: nil,
            textColor: "white",
            createdAt: story.createdAt,
            author: story.author,
            locationId: nil,
            expiresAt: nil
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                if let story = storyForEditing {
                    editableStory = story
                    showEditReview = true
                }
            }) {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                if let imageName = story.image {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 180)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 140, height: 180)
                }
                
                        // Edit indicator
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.white)
                                .font(.caption)
                                .padding(4)
                                .background(Color.yellow)
                                .clipShape(Circle())
                            Spacer()
                        }
                    .padding(8)
            }
            
                    VStack(alignment: .leading, spacing: 4) {
            Text(story.content)
                .font(.caption)
                .foregroundColor(.black)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
                        
                        // Review metadata
                        HStack(spacing: 4) {
                            Text(story.author.name)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showEditReview) {
            if let story = editableStory {
                EditReviewView(
                    story: story,
                    isPresented: $showEditReview
                ) { updatedStory in
                    // Update the story in the location
                    // In production, this would update the backend
                    print("Review updated: \(updatedStory.reviewText ?? "no text")")
                }
            }
        }
    }
}

// MARK: - Rounded Corner Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    StoriesView()
}