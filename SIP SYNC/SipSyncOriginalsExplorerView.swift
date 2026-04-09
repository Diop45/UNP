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
    @State private var selectedHashtag: String? = nil
    
    private let sampleData = SampleData.shared
    
    enum ContentCategory: String, CaseIterable {
        case all = "All"
        case classes = "Classes"
        case videos = "Videos"
    }
    
    /// Hashtag labels (no #) for category strip, from ambassador profiles.
    private var hashtagFilters: [String] {
        let raw = sampleData.sampleBartenderProfiles.flatMap(\.contentCategories)
        let cleaned = raw.map { $0.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        return Array(Set(cleaned)).sorted().prefix(5).map { $0 }
    }
    
    private func profileImageForHashtag(_ tag: String) -> String {
        if let p = sampleData.sampleBartenderProfiles.first(where: { prof in
            prof.contentCategories.contains { $0.replacingOccurrences(of: "#", with: "").lowercased() == tag.lowercased() }
        }) {
            return p.profileImage
        }
        return "Negroni"
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
        
        let categoryFiltered: [(id: UUID, type: ContentType, item: Any)]
        if let tag = selectedHashtag {
            let t = tag.lowercased()
            categoryFiltered = base.filter { content in
                switch content.type {
                case .classItem:
                    guard let classItem = content.item as? BartenderClass,
                          let prof = sampleData.sampleBartenderProfiles.first(where: { $0.author.id == classItem.bartender.id })
                    else { return false }
                    return prof.contentCategories.contains {
                        $0.replacingOccurrences(of: "#", with: "").lowercased() == t
                    }
                case .video:
                    guard let (_, profile) = content.item as? (ContentItem, BartenderProfile) else { return false }
                    return profile.contentCategories.contains {
                        $0.replacingOccurrences(of: "#", with: "").lowercased() == t
                    }
                }
            }
        } else if let category = selectedCategory {
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
    
    private var rowShowsClasses: Bool {
        selectedCategory != .videos || selectedHashtag != nil
    }
    
    private var rowShowsVideos: Bool {
        selectedCategory != .classes || selectedHashtag != nil
    }
    
    private var newsItems: [BartenderClass] {
        Array(sampleData.sampleBartenderClasses.prefix(4))
    }
    
    private var headerProfile: BartenderProfile? {
        sampleData.sampleBartenderProfiles.first
    }
    
    // MARK: - Layout (recipe-app style + UNP tokens)
    
    private var originalsTopBar: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(UNPColors.cream)
                    .frame(width: 40, height: 40)
                    .background(UNPColors.cardSurface)
                    .clipShape(Circle())
            }
            Spacer()
            Text("UNP Originals")
                .font(.headline.weight(.semibold))
                .foregroundStyle(UNPColors.cream)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
    
    private var originalsSearchRow: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(UNPColors.creamMuted())
                TextField("Search your recipes", text: $searchText)
                    .foregroundStyle(UNPColors.cream)
                    .font(.subheadline)
                    .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(UNPColors.creamMuted(0.2), lineWidth: 1)
            )
            
            if let profile = headerProfile {
                Image(profile.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(UNPColors.creamMuted(0.25), lineWidth: 1))
            }
        }
    }
    
    private var originalsPremiumBanner: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Go UNP Premium")
                    .font(.unpDisplay(17, weight: .bold))
                    .foregroundStyle(UNPColors.accent)
                Text("Get full access to classes, full recipes in Pour, and ambassador tools.")
                    .font(.unpBody(13))
                    .foregroundStyle(UNPColors.cream)
                    .fixedSize(horizontal: false, vertical: true)
                Button { } label: {
                    Text("Start 7-day FREE trial")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(UNPColors.background)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(UNPColors.cream)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image("Mixology Class")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
        }
        .padding(16)
        .background(UNPColors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous)
                .stroke(UNPColors.creamMuted(0.12), lineWidth: 1)
        )
    }
    
    private func originalsSectionHeader(title: String, showSeeAll: Bool) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.unpDisplay(17, weight: .semibold))
                .foregroundStyle(UNPColors.cream)
            Spacer()
            if showSeeAll {
                Button { } label: {
                    HStack(spacing: 4) {
                        Text("see all")
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(UNPColors.creamMuted())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var originalsCategorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            originalsSectionHeader(title: "Category", showSeeAll: true)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    categoryCircle(title: "All", imageName: "Negroni", isSelected: selectedHashtag == nil && selectedCategory == .all) {
                        selectedHashtag = nil
                        selectedCategory = .all
                    }
                    categoryCircle(title: "Classes", imageName: "Mixology Class", isSelected: selectedHashtag == nil && selectedCategory == .classes) {
                        selectedHashtag = nil
                        selectedCategory = .classes
                    }
                    categoryCircle(title: "Videos", imageName: "Dirty Martini", isSelected: selectedHashtag == nil && selectedCategory == .videos) {
                        selectedHashtag = nil
                        selectedCategory = .videos
                    }
                    ForEach(hashtagFilters, id: \.self) { tag in
                        categoryCircle(
                            title: tag.capitalized,
                            imageName: profileImageForHashtag(tag),
                            isSelected: selectedHashtag?.lowercased() == tag.lowercased()
                        ) {
                            selectedCategory = nil
                            selectedHashtag = tag
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 8)
    }
    
    private func categoryCircle(title: String, imageName: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipped()
                        .clipShape(Circle())
                    Circle()
                        .fill(Color.black.opacity(0.45))
                    Text(title)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(UNPColors.cream)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 64)
                }
                .frame(width: 72, height: 72)
                .overlay(
                    Circle()
                        .stroke(isSelected ? UNPColors.tabBarSelected : Color.clear, lineWidth: 3)
                )
            }
        }
        .buttonStyle(.plain)
    }
    
    private func originalsNewsRow(item: BartenderClass) -> some View {
        Button {
            selectedClass = item
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(UNPColors.cream)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    Text(item.bartender.name)
                        .font(.caption)
                        .foregroundStyle(UNPColors.creamMuted())
                }
                Spacer(minLength: 8)
                Image(item.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small, style: .continuous))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
        }
        .buttonStyle(.plain)
    }
    
    var body: some View {
        ZStack {
            UNPColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                originalsTopBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        originalsSearchRow
                            .padding(.horizontal, 20)
                        
                        originalsPremiumBanner
                            .padding(.horizontal, 20)
                        
                        originalsCategorySection
                        
                        if !classes.isEmpty && rowShowsClasses {
                            originalsSectionHeader(title: "Classes near you", showSeeAll: classes.count > 3)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(classes) { classItem in
                                        ClassExplorerCard(classItem: classItem) {
                                            selectedClass = classItem
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        if !videos.isEmpty && rowShowsVideos {
                            originalsSectionHeader(title: "Original picks for you", showSeeAll: videos.count > 3)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(Array(videos.enumerated()), id: \.element.0.id) { _, videoTuple in
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
                        
                        if !newsItems.isEmpty {
                            originalsSectionHeader(title: "Spotlight", showSeeAll: newsItems.count > 2)
                            VStack(spacing: 0) {
                                ForEach(Array(newsItems.enumerated()), id: \.element.id) { index, item in
                                    originalsNewsRow(item: item)
                                    if index < newsItems.count - 1 {
                                        Divider()
                                            .background(UNPColors.creamMuted(0.15))
                                            .padding(.leading, 20)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .background(UNPColors.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 36)
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
                        .frame(width: 180, height: 220)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
                    
                    LinearGradient(
                        colors: [.clear, UNPColors.background.opacity(0.5), UNPColors.background.opacity(0.92)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
                    
                    VStack {
                        HStack {
                            if classItem.isGoing {
                                Text("Going")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(UNPColors.background)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(UNPColors.cream.opacity(0.92))
                                    .clipShape(Capsule())
                            }
                            Spacer()
                            if classItem.isLocked {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(UNPColors.cream)
                                    .font(.caption)
                                    .padding(8)
                                    .background(UNPColors.cardSurface.opacity(0.9))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(10)
                        Spacer()
                    }
                }
                .frame(width: 180, height: 220)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(classItem.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(UNPColors.cream)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(classItem.bartender.name)
                        .font(.caption)
                        .foregroundStyle(UNPColors.creamMuted())
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundStyle(UNPColors.accent)
                        Text(dateFormatter.string(from: classItem.date))
                            .font(.caption2)
                            .foregroundStyle(UNPColors.creamMuted())
                    }
                    
                    if let price = classItem.price {
                        Text("$\(Int(price))")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(UNPColors.accent)
                    }
                }
                .padding(12)
                .frame(width: 180, alignment: .leading)
                .background(UNPColors.cardSurface)
            }
            .frame(width: 180)
            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous)
                    .stroke(UNPColors.creamMuted(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Video Explorer Card
struct VideoExplorerCard: View {
    let contentItem: ContentItem
    let profile: BartenderProfile
    let onTap: () -> Void
    
    private var mockRating: String {
        let n = abs(contentItem.id.hashValue % 15)
        return String(format: "%.1f", 4.4 + Double(n) / 10.0)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Image(contentItem.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 220)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
                    
                    LinearGradient(
                        colors: [.clear, UNPColors.background.opacity(0.35)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: 180, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(UNPColors.accent)
                        Text(mockRating)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(UNPColors.background)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(UNPColors.cream.opacity(0.95))
                    .clipShape(Capsule())
                    .padding(10)
                    
                    Image(systemName: "play.circle.fill")
                        .foregroundStyle(UNPColors.cream)
                        .font(.system(size: 36))
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                .frame(width: 180, height: 220)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(contentItem.title ?? "UNP Original")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(UNPColors.cream)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 8) {
                        Image(profile.profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 28, height: 28)
                            .clipShape(Circle())
                        Text(profile.author.name)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(UNPColors.creamMuted())
                            .lineLimit(1)
                        if profile.author.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(UNPColors.accent)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .padding(12)
                .frame(width: 180, alignment: .leading)
                .background(UNPColors.cardSurface)
            }
            .frame(width: 180)
            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous)
                    .stroke(UNPColors.creamMuted(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Video Detail Sheet
struct VideoDetailSheet: View {
    let contentItem: ContentItem
    let profile: BartenderProfile
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            UNPColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(UNPColors.cream)
                                .frame(width: 40, height: 40)
                                .background(UNPColors.cardSurface)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    ZStack(alignment: .center) {
                        Image(contentItem.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 280)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
                        
                        Image(systemName: "play.circle.fill")
                            .foregroundStyle(UNPColors.cream)
                            .font(.system(size: 56))
                            .shadow(color: .black.opacity(0.45), radius: 6, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(contentItem.title ?? "UNP Original Video")
                            .font(.title.bold())
                            .foregroundStyle(UNPColors.cream)
                        
                        HStack(spacing: 12) {
                            Image(profile.profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 52, height: 52)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(UNPColors.creamMuted(0.2), lineWidth: 1))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(profile.author.name)
                                        .font(.headline)
                                        .foregroundStyle(UNPColors.cream)
                                    if profile.author.verified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(UNPColors.accent)
                                    }
                                }
                                if let location = profile.author.location {
                                    Text(location)
                                        .font(.subheadline)
                                        .foregroundStyle(UNPColors.creamMuted())
                                }
                            }
                            Spacer()
                        }
                        
                        Text(profile.bio)
                            .font(.body)
                            .foregroundStyle(UNPColors.creamMuted(0.85))
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 80)
                }
            }
        }
    }
}

#Preview {
    SipSyncOriginalsExplorerView(cartItems: .constant([]))
        .environmentObject(UNPDataStore.shared)
}

