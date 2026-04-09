//
//  BartenderClassesView.swift
//  SIP SYNC
//
//  Created by AI Assistant on 10/28/25.
//

import SwiftUI

struct BartenderClassesView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var cartItems: [OrderItem]
    @State private var selectedClass: BartenderClass?
    @State private var showSubscriptionPayment = false
    
    private let sampleData = SampleData.shared
    private let subscriptionPrice: Double = 9.99 // Monthly subscription price
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM d"
        return formatter
    }
    
    var body: some View {
        ZStack {
            UNPColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                        .font(.unpDisplay(17, weight: .semibold))
                        .foregroundStyle(UNPColors.cream)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Horizontal Scrollable Class Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(sampleData.sampleBartenderClasses) { classItem in
                            BartenderClassCard(
                                classItem: classItem,
                                onTap: {
                                    selectedClass = classItem
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Get the party started with Classes")
                            .font(.unpDisplay(22, weight: .bold))
                            .foregroundStyle(UNPColors.cream)
                        
                        Text("An UNP Premium subscription is required to unlock classes.")
                            .font(.unpBody(15))
                            .foregroundStyle(UNPColors.creamMuted(0.72))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Button {
                        showSubscriptionPayment = false
                    } label: {
                        Text("Subscribe - $\(String(format: "%.2f", subscriptionPrice))/month")
                            .font(.unpDisplay(17, weight: .semibold))
                            .foregroundStyle(UNPColors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(UNPColors.cream)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 34)
            }
        }
        .sheet(item: $selectedClass) { classItem in
            ClassDetailView(classItem: classItem, cartItems: $cartItems)
        }
    }
}

// MARK: - Bartender Class Card
struct BartenderClassCard: View {
    let classItem: BartenderClass
    let onTap: () -> Void
    
    private let sampleData = SampleData.shared
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM d"
        return formatter
    }
    
    // Get a unique image for each class card
    private var classCardImage: String {
        // Find matching bartender profile
        guard let profile = sampleData.sampleBartenderProfiles.first(where: { $0.author.id == classItem.bartender.id }) else {
            return classItem.image
        }
        
        // Get all classes by this bartender to determine which image to use
        let bartenderClasses = sampleData.sampleBartenderClasses.filter { $0.bartender.id == classItem.bartender.id }
        let classIndex = bartenderClasses.firstIndex(where: { $0.id == classItem.id }) ?? 0
        
        // Use profile image for first class, contentGallery images for subsequent classes
        if classIndex == 0 {
            return profile.profileImage
        } else {
            // Use images from contentGallery, cycling through them
            let galleryIndex = (classIndex - 1) % profile.contentGallery.count
            return profile.contentGallery[galleryIndex].image
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                Image(classCardImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 400)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
                
                LinearGradient(
                    colors: [
                        .clear,
                        UNPColors.background.opacity(0.35),
                        UNPColors.background.opacity(0.88)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: 300, height: 400)
                .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
                
                VStack {
                    HStack {
                        if classItem.isGoing {
                            Text("Going")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(UNPColors.background)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(red: 0.7, green: 0.9, blue: 0.7))
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        if classItem.isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(UNPColors.cream)
                                .font(.title3)
                                .padding(10)
                                .background(UNPColors.cardSurface.opacity(0.92))
                                .clipShape(Circle())
                        }
                    }
                    .padding(14)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    if !classItem.attendees.isEmpty {
                        HStack(spacing: -6) {
                            ForEach(Array(classItem.attendees.prefix(3)), id: \.id) { attendee in
                                Circle()
                                    .fill(UNPColors.tabBarSelected.opacity(0.85))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text(String(attendee.name.prefix(1)))
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(UNPColors.cream)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(UNPColors.cream, lineWidth: 2)
                                    )
                            }
                            
                            if classItem.attendees.count > 3 {
                                Circle()
                                    .fill(UNPColors.cardSurface)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text("+\(classItem.attendees.count - 3)")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(UNPColors.cream)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(UNPColors.cream, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    Text(classItem.title)
                        .font(.unpDisplay(22, weight: .bold))
                        .foregroundStyle(UNPColors.cream)
                        .lineLimit(2)
                    
                    Text("\(dateFormatter.string(from: classItem.date)), \(classItem.time)")
                        .font(.unpBody(15))
                        .foregroundStyle(UNPColors.creamMuted(0.88))
                    
                    Text(classItem.location)
                        .font(.unpBody(15))
                        .foregroundStyle(UNPColors.creamMuted(0.72))
                }
                .frame(width: 300, alignment: .leading)
                .padding(16)
            }
            .frame(width: 300, height: 400)
            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous)
                    .stroke(UNPColors.creamMuted(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Class Detail View
struct ClassDetailView: View {
    let classItem: BartenderClass
    @Binding var cartItems: [OrderItem]
    @Environment(\.presentationMode) var presentationMode
    
    private let sampleData = SampleData.shared
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMMM d 'at' h:mm a"
        return formatter
    }
    
    private var bartenderProfileImage: String? {
        sampleData.sampleBartenderProfiles.first { $0.author.id == classItem.bartender.id }?.profileImage
    }
    
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
                    
                    // Class Image - use unique image for each class
                    ZStack(alignment: .topTrailing) {
                        // Get unique image for this class
                        let classImage: String = {
                            guard let profile = sampleData.sampleBartenderProfiles.first(where: { $0.author.id == classItem.bartender.id }) else {
                                return classItem.image
                            }
                            
                            // Get all classes by this bartender to determine which image to use
                            let bartenderClasses = sampleData.sampleBartenderClasses.filter { $0.bartender.id == classItem.bartender.id }
                            let classIndex = bartenderClasses.firstIndex(where: { $0.id == classItem.id }) ?? 0
                            
                            // Use profile image for first class, contentGallery images for subsequent classes
                            if classIndex == 0 {
                                return profile.profileImage
                            } else {
                                // Use images from contentGallery, cycling through them
                                let galleryIndex = (classIndex - 1) % profile.contentGallery.count
                                return profile.contentGallery[galleryIndex].image
                            }
                        }()
                        
                        Image(classImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
                        
                        if classItem.isLocked {
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(UNPColors.cream)
                                        .font(.title2)
                                        .padding(14)
                                        .background(UNPColors.cardSurface.opacity(0.92))
                                        .clipShape(Circle())
                                        .padding(16)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(classItem.title)
                            .font(.unpDisplay(28, weight: .bold))
                            .foregroundStyle(UNPColors.cream)
                        
                        HStack(spacing: 12) {
                            Group {
                                if let img = bartenderProfileImage {
                                    Image(img)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Circle()
                                        .fill(UNPColors.cardSurface)
                                        .overlay(
                                            Text(String(classItem.bartender.name.prefix(1)))
                                                .font(.title3.weight(.bold))
                                                .foregroundStyle(UNPColors.cream)
                                        )
                                }
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(UNPColors.creamMuted(0.2), lineWidth: 1))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(classItem.bartender.name)
                                    .font(.unpDisplay(17, weight: .semibold))
                                    .foregroundStyle(UNPColors.cream)
                                if let location = classItem.bartender.location {
                                    Text(location)
                                        .font(.unpBody(15))
                                        .foregroundStyle(UNPColors.creamMuted(0.72))
                                }
                            }
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundStyle(UNPColors.accent)
                            Text(dateFormatter.string(from: classItem.date) + ", \(classItem.time)")
                                .foregroundStyle(UNPColors.creamMuted(0.88))
                        }
                        .font(.unpBody(15))
                        
                        HStack(spacing: 12) {
                            Image(systemName: "location")
                                .foregroundStyle(UNPColors.accent)
                            Text(classItem.location)
                                .foregroundStyle(UNPColors.creamMuted(0.88))
                        }
                        .font(.unpBody(15))
                        
                        Text(classItem.description)
                            .font(.unpBody(16))
                            .foregroundStyle(UNPColors.creamMuted(0.85))
                            .lineSpacing(4)
                            .padding(.top, 8)
                        
                        if !classItem.attendees.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Attendees")
                                    .font(.unpDisplay(17, weight: .semibold))
                                    .foregroundStyle(UNPColors.cream)
                                
                                HStack(spacing: 12) {
                                    ForEach(classItem.attendees, id: \.id) { attendee in
                                        VStack(spacing: 4) {
                                            Circle()
                                                .fill(UNPColors.tabBarSelected.opacity(0.75))
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Text(String(attendee.name.prefix(1)))
                                                        .font(.headline.weight(.bold))
                                                        .foregroundStyle(UNPColors.cream)
                                                )
                                            
                                            Text(attendee.name.components(separatedBy: " ").first ?? "")
                                                .font(.unpBody(12))
                                                .foregroundStyle(UNPColors.creamMuted(0.72))
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            
            if classItem.isLocked {
                VStack {
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Group {
                            if let price = classItem.price {
                                Text("Unlock Class - $\(Int(price))")
                            } else {
                                Text("Unlock Class")
                            }
                        }
                        .font(.unpDisplay(17, weight: .semibold))
                        .foregroundStyle(UNPColors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(UNPColors.cream)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
            }
        }
    }
}

#Preview {
    BartenderClassesView(cartItems: .constant([]))
}

