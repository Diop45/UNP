//
//  UNPExploreJourneyView.swift
//

import SwiftUI
import MapKit
import UIKit

struct UNPExploreJourneyView: View {
    @EnvironmentObject private var store: UNPDataStore
    var highlightId: UUID?
    
    @State private var showMap = true
    @State private var timeFilter: UNPTimeOfDay = .night
    @State private var selectedEvent: UNPEvent?
    @State private var selectedStorySet: StorySet?
    @State private var selectedStoryIndex = 0
    @State private var showAddStory = false
    @State private var storySets: [StorySet] = []
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458),
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
    )
    
    private let sampleData = SampleData.shared
    
    private var filteredEvents: [UNPEvent] {
        store.events.filter { $0.timeCategory == timeFilter }
    }
    
    private var currentUser: SocialUser {
        sampleData.sampleSocialUsers.first ?? SocialUser(
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
    
    var body: some View {
        VStack(spacing: 0) {
            StoriesBar(
                storySets: activeStorySets,
                selectedStorySet: $selectedStorySet,
                selectedStoryIndex: $selectedStoryIndex,
                onAddStory: {
                    showAddStory = true
                }
            )
            
            Picker("", selection: $showMap) {
                Text("Map").tag(true)
                Text("List").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            timeTabs
            
            if showMap {
                mapView
            } else {
                listView
            }
        }
        .background(UNPColors.background.ignoresSafeArea())
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if storySets.isEmpty {
                storySets = sampleData.sampleStorySets
            }
            if let hid = highlightId, let ev = store.events.first(where: { $0.id == hid }) {
                selectedEvent = ev
                centerOn(ev)
            }
        }
        .sheet(isPresented: $showAddStory) {
            AddStoryView(isPresented: $showAddStory) { image, text, rating in
                createStoryHighlight(image, reviewText: text, rating: rating)
            }
        }
        .sheet(item: $selectedEvent) { ev in
            UNPEventDetailSheet(event: ev, tier: store.user.accessTier)
        }
        .overlay {
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
    }
    
    private var timeTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(UNPTimeOfDay.allCases) { t in
                    Button {
                        timeFilter = t
                    } label: {
                        Text(t.label)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(timeFilter == t ? UNPColors.accent : UNPColors.cardSurface)
                            .foregroundStyle(timeFilter == t ? UNPColors.background : UNPColors.cream)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
    
    private var mapView: some View {
        Map(position: $position) {
            ForEach(filteredEvents) { ev in
                Annotation(ev.name, coordinate: CLLocationCoordinate2D(latitude: ev.latitude, longitude: ev.longitude)) {
                    Button {
                        selectedEvent = ev
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(UNPColors.accent)
                            .padding(6)
                            .background(UNPColors.background.opacity(0.9))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .mapStyle(.standard)
        .frame(maxHeight: .infinity)
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredEvents) { ev in
                    Button {
                        selectedEvent = ev
                    } label: {
                        eventRow(ev)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
    }
    
    private func eventRow(_ ev: UNPEvent) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ev.name)
                .font(.headline)
                .foregroundStyle(UNPColors.cream)
            Text(ev.venueName)
                .font(.subheadline)
                .foregroundStyle(UNPColors.creamMuted())
            Text(UNPLandingView.formatTime(ev.startTime))
                .font(.caption)
                .foregroundStyle(UNPColors.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .unpCard()
    }
    
    private func centerOn(_ ev: UNPEvent) {
        position = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: ev.latitude, longitude: ev.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
            )
        )
    }
    
    private func createStoryHighlight(_ image: UIImage?, reviewText: String?, rating: Int?) {
        let imageName = image != nil ? "review_\(UUID().uuidString).jpg" : nil
        let newStory = Story(
            image: imageName,
            reviewText: reviewText,
            rating: rating,
            textColor: "white",
            createdAt: Date(),
            author: currentUser,
            locationId: nil,
            expiresAt: nil
        )
        
        if let existingIndex = storySets.firstIndex(where: { $0.author.id == currentUser.id }) {
            var updatedSet = storySets[existingIndex]
            var updatedStories = updatedSet.stories
            updatedStories.append(newStory)
            updatedSet.stories = updatedStories
            storySets[existingIndex] = updatedSet
        } else {
            let newStorySet = StorySet(
                author: currentUser,
                stories: [newStory],
                viewedStories: []
            )
            storySets.insert(newStorySet, at: 0)
        }
    }
}

struct UNPEventDetailSheet: View {
    @EnvironmentObject private var store: UNPDataStore
    @Environment(\.dismiss) private var dismiss
    let event: UNPEvent
    let tier: UNPAccessTier
    @State private var showCommunityRoom = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(event.name)
                        .font(.title.bold())
                        .foregroundStyle(UNPColors.cream)
                    Text(event.venueName)
                        .foregroundStyle(UNPColors.accent)
                    Text(UNPLandingView.formatTime(event.startTime))
                        .foregroundStyle(UNPColors.creamMuted())
                    Text(event.description)
                        .foregroundStyle(UNPColors.cream)
                    
                    Button {
                        showCommunityRoom = true
                    } label: {
                        Label("Open Event Community", systemImage: "person.3.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(UNPColors.accent)
                    
                    if tier == .paid {
                        Text("How to attend")
                            .font(.headline)
                            .foregroundStyle(UNPColors.accent)
                        Text(event.howToAttend)
                            .foregroundStyle(UNPColors.cream)
                        HStack(spacing: 12) {
                            Button("RSVP") {
                                store.addPoints(40, action: .eventAttendance, label: "RSVP \(event.name)")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(UNPColors.accent)
                            Button("Save") {
                                store.addPoints(25, action: .save, label: "Saved event")
                            }
                            .buttonStyle(.bordered)
                            .tint(UNPColors.cream)
                            ShareLink(item: event.name) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .tint(UNPColors.cream)
                        }
                        related
                    } else {
                        Text("Subscribe for full detail — RSVP, save, share, and cross-links.")
                            .foregroundStyle(UNPColors.creamMuted())
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(UNPColors.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small))
                    }
                }
                .padding(20)
            }
            .background(UNPColors.background)
            .navigationTitle("Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(UNPColors.accent)
                }
            }
        }
        .sheet(isPresented: $showCommunityRoom) {
            NavigationStack {
                UNPEventCommunityRoomView(event: event)
            }
            .environmentObject(store)
        }
    }
    
    private var related: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Related")
                .font(.headline)
                .foregroundStyle(UNPColors.cream)
            let bevs = store.beverages.filter { event.relatedBeverageIds.contains($0.id) }
            ForEach(bevs) { b in
                Text("Pour · \(b.name)")
                    .foregroundStyle(UNPColors.accent)
            }
            let nudges = store.nudges.filter { n in n.linkedEventIds.contains(event.id) }
            ForEach(nudges) { n in
                Text("Nudge · \(n.title)")
                    .foregroundStyle(UNPColors.accent)
            }
        }
    }
}

#Preview("UNP Explore") {
    NavigationStack {
        UNPExploreJourneyView()
    }
    .environmentObject(UNPDataStore.shared)
}

#Preview("UNP Event detail") {
    UNPEventDetailSheet(event: UNPDataStore.shared.events[0], tier: .paid)
        .environmentObject(UNPDataStore.shared)
}

// MARK: - Shared Location Card (used by search map + explore contexts)
struct LocationCard: View {
    let location: Location
    let onDismiss: () -> Void
    @State private var showReviewForm = false
    @State private var reviews: [Review] = []
    @State private var showPhotoFullScreen = false
    @State private var selectedPhoto: String?
    
    private var convertedReviews: [Review] {
        location.stories.map { post in
            Review(
                author: post.author,
                rating: 5,
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
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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
                        
                        if location.hasSipSyncBartender {
                            SipSyncBartendersBadge(bartenders: location.sipSyncBartenders)
                        }
                    }
                    
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
                    
                    ReviewsSection(
                        reviews: allReviews,
                        averageRating: averageRating,
                        reviewCount: allReviews.count,
                        onAddReview: {
                            showReviewForm = true
                        },
                        onHelpful: { review in
                            if let index = reviews.firstIndex(where: { $0.id == review.id }) {
                                reviews[index].isHelpful.toggle()
                                reviews[index].helpfulCount += reviews[index].isHelpful ? 1 : -1
                            } else {
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
        .frame(height: 600)
        .sheet(isPresented: $showReviewForm) {
            YelpReviewForm(
                isPresented: $showReviewForm,
                location: location
            ) { newReview in
                reviews.insert(newReview, at: 0)
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
