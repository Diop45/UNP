//
//  SipSyncOriginalsExplorerView.swift
//  SIP SYNC
//
//  Created by AI Assistant
//

import SwiftUI

struct SipSyncOriginalsExplorerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var cartItems: [OrderItem]
    @State private var selectedClass: BartenderClass?
    @State private var selectedContentItem: (ContentItem, BartenderProfile)?
    @State private var searchText: String = ""
    @State private var selectedCategory: ContentCategory? = .all
    
    private let sampleData = SampleData.shared
    
    enum ContentCategory: String, CaseIterable {
        case all = "All"
        case classes = "Classes"
        case videos = "Videos"
    }
    
    // Combine all classes and content items from profiles
    private var allContent: [(id: UUID, type: ContentType, item: Any)] {
        var content: [(id: UUID, type: ContentType, item: Any)] = []
        
        // Add all classes
        for classItem in sampleData.sampleBartenderClasses {
            content.append((id: classItem.id, type: .classItem, item: classItem))
        }
        
        // Add all content items from profiles
        for profile in sampleData.sampleBartenderProfiles {
            for contentItem in profile.contentGallery {
                content.append((id: contentItem.id, type: .video, item: (contentItem, profile)))
            }
        }
        
        return content
    }
    
    enum ContentType {
        case classItem
        case video
    }
    
    private var filteredContent: [(id: UUID, type: ContentType, item: Any)] {
        let base = allContent
        
        // Filter by category
        let categoryFiltered: [(id: UUID, type: ContentType, item: Any)]
        if let category = selectedCategory {
            switch category {
            case .all:
                categoryFiltered = base
            case .classes:
                categoryFiltered = base.filter { $0.type == .classItem }
            case .videos:
                categoryFiltered = base.filter { $0.type == .video }
            }
        } else {
            categoryFiltered = base
        }
        
        // Filter by search text
        if searchText.isEmpty {
            return categoryFiltered
        }
        
        let searchLower = searchText.lowercased()
        return categoryFiltered.filter { content in
            switch content.type {
            case .classItem:
                if let classItem = content.item as? BartenderClass {
                    return classItem.title.lowercased().contains(searchLower) ||
                           classItem.bartender.name.lowercased().contains(searchLower) ||
                           classItem.description.lowercased().contains(searchLower)
                }
            case .video:
                if let (contentItem, profile) = content.item as? (ContentItem, BartenderProfile) {
                    return (contentItem.title?.lowercased().contains(searchLower) ?? false) ||
                           profile.author.name.lowercased().contains(searchLower) ||
                           profile.bio.lowercased().contains(searchLower)
                }
            }
            return false
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
    
    // Separate classes and videos
    private var classes: [BartenderClass] {
        let filtered = filteredContent.filter { $0.type == .classItem }
        return filtered.compactMap { $0.item as? BartenderClass }
    }
    
    private var videos: [(ContentItem, BartenderProfile)] {
        let filtered = filteredContent.filter { $0.type == .video }
        return filtered.compactMap { content in
            if let tuple = content.item as? (ContentItem, BartenderProfile) {
                return tuple
            }
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            // Dark purple background matching SipSync UI
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
                // Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title3)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("SipSync Originals")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                    TextField("Search classes and videos...", text: $searchText)
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ContentCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(selectedCategory == category ? .black : .white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(selectedCategory == category ? Color.yellow : Color.black.opacity(0.3))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 24)
                
                // Content Sections (Netflix-style horizontal scrolling)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Classes Section
                        if (selectedCategory == .all || selectedCategory == .classes) && !classes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("CLASSES")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(classes) { classItem in
                                            ClassExplorerCard(classItem: classItem) {
                                                selectedClass = classItem
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        
                        // Videos Section
                        if (selectedCategory == .all || selectedCategory == .videos) && !videos.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("VIDEOS")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(Array(videos.enumerated()), id: \.element.0.id) { index, videoTuple in
                                            VideoExplorerCard(
                                                contentItem: videoTuple.0,
                                                profile: videoTuple.1
                                            ) {
                                                selectedContentItem = videoTuple
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(item: $selectedClass) { classItem in
            ClassDetailView(classItem: classItem, cartItems: $cartItems)
        }
        .sheet(isPresented: Binding(
            get: { selectedContentItem != nil },
            set: { if !$0 { selectedContentItem = nil } }
        )) {
            if let (contentItem, profile) = selectedContentItem {
                VideoDetailSheet(contentItem: contentItem, profile: profile)
            }
        }
    }
}

// MARK: - Class Explorer Card
struct ClassExplorerCard: View {
    let classItem: BartenderClass
    let onTap: () -> Void
    
    private let sampleData = SampleData.shared
    
    private var classCardImage: String {
        guard let profile = sampleData.sampleBartenderProfiles.first(where: { $0.author.id == classItem.bartender.id }) else {
            return classItem.image
        }
        
        let bartenderClasses = sampleData.sampleBartenderClasses.filter { $0.bartender.id == classItem.bartender.id }
        let classIndex = bartenderClasses.firstIndex(where: { $0.id == classItem.id }) ?? 0
        
        if classIndex == 0 {
            return profile.profileImage
        } else {
            let galleryIndex = (classIndex - 1) % profile.contentGallery.count
            return profile.contentGallery[galleryIndex].image
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    private var dateFormatterFull: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Image(classCardImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 240)
                        .clipped()
                        .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    // Gradient overlay for better text readability
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 240)
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    // Top badges
                    VStack {
                        HStack {
                            // Going badge
                            if classItem.isGoing {
                                Text("Going")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color(red: 0.7, green: 0.9, blue: 0.7))
                                    .cornerRadius(6)
                            }
                            
                            Spacer()
                            
                            // Lock icon if locked
                            if classItem.isLocked {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(8)
                        
                        Spacer()
                    }
                }
                
                // Bottom info section
                VStack(alignment: .leading, spacing: 6) {
                    Text(classItem.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(classItem.bartender.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text("\(dateFormatter.string(from: classItem.date))")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    if let price = classItem.price {
                        Text("$\(Int(price))")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(width: 180, alignment: .leading)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            }
            .frame(width: 180)
            .cornerRadius(12)
        }
    }
}

// MARK: - Video Explorer Card
struct VideoExplorerCard: View {
    let contentItem: ContentItem
    let profile: BartenderProfile
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .center) {
                    Image(contentItem.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 240)
                        .clipped()
                        .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 240)
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    // Play icon overlay (centered)
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                // Bottom info section
                VStack(alignment: .leading, spacing: 6) {
                    Text(contentItem.title ?? "Video")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(profile.author.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text("Video")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(width: 180, alignment: .leading)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            }
            .frame(width: 180)
            .cornerRadius(12)
        }
    }
}

// MARK: - Video Detail Sheet
struct VideoDetailSheet: View {
    let contentItem: ContentItem
    let profile: BartenderProfile
    @Environment(\.presentationMode) var presentationMode
    
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Back Button
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Video Image
                    ZStack(alignment: .center) {
                        Image(contentItem.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(20)
                        
                        // Play button overlay
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 60))
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.horizontal, 20)
                    
                    // Video Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text(contentItem.title ?? "SipSync Original Video")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Bartender Info
                        HStack(spacing: 12) {
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
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(profile.author.name.prefix(1)))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.author.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                if let location = profile.author.location {
                                    Text(location)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Bio
                        Text(profile.bio)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
        }
    }
}

#Preview {
    SipSyncOriginalsExplorerView(cartItems: .constant([]))
}

